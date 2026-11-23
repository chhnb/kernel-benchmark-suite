#!/usr/bin/env python3
"""Evaluate the step 3b search and classify cleanup changes by cost."""
import argparse
from collections import Counter
from concurrent.futures import ThreadPoolExecutor
import difflib
import gzip
import json
from pathlib import Path
from statistics import mean

from run_step3 import CORPUS, COSTS, RESULTS
from run_step2 import invoke, read_report

STRATEGIES = ("anchor", "darm")
REGRESSIONS = ("d23a7c228c5b", "2f29337da1ee", "e37272cdb93e")


def cost_terms(report):
    terms = report.get("D_components", {})
    return {
        "control": terms.get("control", 0),
        "escape": terms.get("escape", 0),
        "select": sum(terms.get(key, 0) for key in
                      ("select", "folded-join", "simplified-select", "folded-condition")),
        "instruction": terms.get("instruction", 0) + terms.get("memory", 0),
    }


def strategy_choice(rows, original, source):
    if original is None or not rows:
        return None, None
    if source == "thread-pattern":
        return min(rows, key=lambda row: row["T"])["T"], original[0]
    if source == "data":
        eligible = [row["T"] for row in rows if row["T"][1] <= original[1]
                    and row["T"][2] <= original[2]]
        return min([original, *eligible]), original[0]
    if source == "workgroup-uniform":
        return min([original, *(r["T"] for r in rows)], key=lambda t: max(t[1:])), max(original[1:])
    return None, None


def check_cleanup(row, folder, args):
    original = folder / row["ir"]
    cleaned = folder / (row["ir"] + ".cleaned.ll")
    flags = ["--original"] if row["original"] else []
    result = read_report(invoke([args.cleanup, original, COSTS, cleaned, *flags], timeout=30))
    if result.get("status") == "same_cost":
        result["category"] = "text_only" if result["text_changed"] else "unchanged"
    if result.get("status") != "same_cost" and cleaned.is_file():
        a = original.read_text().splitlines(keepends=True)
        b = cleaned.read_text().splitlines(keepends=True)
        result["ir_diff"] = "".join(difflib.unified_diff(a, b, fromfile="before.ll", tofile="after.ll"))
        body = [line for line in result["ir_diff"].splitlines()
                if line.startswith(("+", "-")) and not line.startswith(("+++", "---"))]
        effect = []
        for kind, tokens in (
            ("CFG/guard", ("br ",)),
            ("join/select", (" phi ", " select ")),
            ("memory/address", (" load ", " store ", "getelementptr", "bitcast")),
            ("instruction", (" = ",)),
        ):
            if any(any(token in line for token in tokens) for line in body):
                effect.append(kind)
        result["effects"] = effect or ["other"]
        if result.get("status") == "cost_changed":
            removed = sum(" = getelementptr " in line for line in body if line.startswith("-"))
            added = sum(" = getelementptr " in line for line in body if line.startswith("+"))
            if removed > added:
                result["effects"].append("GEP elimination")
    if result.get("before") and result["before"] != row["T"]:
        result["reported_before"] = row["T"]
    return result


def baselines(row, report, previous, args):
    if row["kind"] == "b2b-triangle":
        return {name: {"status": "unchanged", "T": report.get("original_T"),
                       "D_components": report.get("original_components", {})}
                for name in STRATEGIES}
    folder = args.baselines / "corpus" / row["id"]
    outputs = {}
    for name in STRATEGIES:
        existing = previous[row["id"]]["baselines"][name]
        path = folder / (name + ".ll")
        if not path.is_file():
            outputs[name] = existing
            continue
        flags = ["--output-buffer"] if row["num_outputs"] > 1 else []
        result = read_report(invoke([args.evaluator, path, COSTS, "--c-sl=real", *flags]))
        result.pop("operations", None)
        trial = folder / name / "trial-0/trial.json"
        if trial.is_file():
            info = json.loads(trial.read_text())
            for key in ("anchor", "fusion_plan", "leaf_anchor_pairs"):
                if key in info:
                    result[key] = info[key]
        result["pair"] = existing.get("pair")
        outputs[name] = result
    return outputs


def analyze(row, previous, args):
    key = row["id"]
    folder = args.work / key
    folder.mkdir(parents=True)
    source = CORPUS / row["ir"]
    if source.suffix == ".gz":
        dest = folder / "input.ll"
        dest.write_bytes(gzip.decompress(source.read_bytes()))
        source = dest
    report = read_report(invoke([args.solver, source, COSTS, folder, "--c-sl=real"]))
    report["kind"] = row["kind"]
    original = read_report(invoke([args.evaluator, source, COSTS, "--c-sl=real", "--original"]))
    report["original_components"] = original.get("D_components", {})
    report["original_T"] = original.get("T")
    report["baselines"] = baselines(row, report, previous, args)
    front = report.get("pareto_front", [])
    for solution in front:
        solution["semantic_validation"] = read_report(
            invoke([args.interpreter, source, folder / solution["ir"]], timeout=45))
        solution["cleanup"] = check_cleanup(solution, folder, args)
    verified = [s for s in front if s["semantic_validation"].get("status") == "pass"]
    best = min(verified, key=lambda s: s["T"], default=None)
    report["verified_best"] = best["T"] if best else None
    original_t = report["original_T"]
    targets = [x["T"] for x in report["baselines"].values() if x.get("T")]
    if original_t:
        targets.append(original_t)
    if targets and (best is None or best["T"][0] > min(t[0] for t in targets)):
        report["invariant"] = "defect"
    elif targets:
        report["invariant"] = "pass"
    else:
        report["invariant"] = "unpriced"
    report["strategy_choice"], baseline = strategy_choice(verified, original_t, row["condition_source"])
    if report["strategy_choice"] is not None:
        choice = report["strategy_choice"]
        val = max(choice[1:]) if row["condition_source"] == "workgroup-uniform" else choice[0]
        report["strategy_gain"] = max(0, baseline - val)
    if any(s["semantic_validation"].get("status") != "pass" for s in front):
        report["complete"] = False
        report["reason"] = "a retained vector failed semantic verification"
    return key, report


def summarize(reports):
    lines = ["# Dataflow B2B 第 3b 步", "",
             "差距与 K 漏失只在不变式通过且标为完备的区域上统计。清理代价变化按方案逐条列出。", ""]
    for kind in ("diamond", "triangle"):
        rows = {k: r for k, r in reports.items() if r["kind"] == "b2b-" + kind}
        valid = {k: r for k, r in rows.items() if r["invariant"] != "defect"}
        complete = {k: r for k, r in valid.items() if r.get("complete") and r["verified_best"]}
        lines += [f"## {kind}", "", f"区域 {len(rows)} 个，完备且通过不变式 {len(complete)} 个。", ""]
        gains = [r["original_T"][0] - r["verified_best"][0] for r in valid.values()
                 if r["verified_best"] and r["original_T"]]
        strategy = [r.get("strategy_gain", 0) for r in valid.values()]
        gains = [n for n in gains if n > 0]
        strategy = [n for n in strategy if n > 0]
        lines += [f"- 已验证方案中 D 收益 {len(gains)} 个，收益区域平均 {mean(gains) if gains else 0:.3f}。",
                  f"- §7.2 策略收益 {len(strategy)} 个，收益区域平均 {mean(strategy) if strategy else 0:.3f}。"]
        features, misses, clean = Counter(), Counter(), Counter()
        for row in rows.values():
            for solution in row.get("pareto_front", []):
                item = solution["cleanup"]
                clean[item.get("category", item.get("status", "failed"))] += 1
        for row in complete.values():
            best = row["verified_best"]
            chosen = next(x for x in row["pareto_front"] if x["T"] == best)
            for feature, enabled in chosen.get("features", {}).items():
                features[feature] += bool(enabled)
            features["multiple_guards"] += chosen.get("guard_branches", 0) > 1
            for k in row.get("top_k", []):
                misses[k["k"]] += k["best_observed_D"] > best[0]
        for name in STRATEGIES:
            gaps, terms = Counter(), Counter()
            for row in complete.values():
                base, best = row["baselines"][name], row["verified_best"]
                if not base.get("T"):
                    continue
                candidate = next(s for s in row["pareto_front"] if s["T"] == best)
                gap = base["T"][0] - best[0]
                gaps[gap] += 1
                left, right = cost_terms(base), cost_terms(candidate)
                terms.update({key: left[key] - right[key] for key in left})
            lines.append(f"- {name} 达到最优 D 的区域数为 {gaps[0]}，差距分布为 "
                         f"`{dict(sorted(gaps.items()))}`，计费项差距合计为 `{dict(terms)}`。")
        lines += [f"- 特征计数 `{dict(sorted(features.items()))}`。",
                  f"- K=1、3、10 漏失数依次为 {misses[1]}、{misses[3]}、{misses[10]}。",
                  f"- 清理分类 `{dict(sorted(clean.items()))}`。", "", "### 不变式", ""]
        lines.append(f"状态统计 `{dict(Counter(r['invariant'] for r in rows.values()))}`。")
        for key, row in rows.items():
            if row["invariant"] == "unpriced":
                lines.append(f"- `{key}`。无法计价。{row.get('reason', '')}。")
            if row["invariant"] != "defect":
                continue
            comparisons = "，".join(f'{name} {value.get("T")} 块配对 {value.get("pair")}'
                                    for name, value in row["baselines"].items())
            lines.append(f"- `{key}`。求解器 {row['verified_best']}，原始 {row['original_T']}，{comparisons}。具体配对数据见原始 JSON。")
        lines.extend(["", "### 清理导致 T 改变", ""])
        for uid, row in rows.items():
            for solution in row.get("pareto_front", []):
                check = solution["cleanup"]
                if check.get("status") not in ("cost_changed", "unsupported", "failed"):
                    continue
                location = f"`{uid}/{solution['ir']}`"
                if check.get("status") == "cost_changed":
                    labels = "、".join(check.get("effects", []))
                    lines.append(f"- {location} {check['before']} → {check['after']}，{labels}。")
                else:
                    lines.append(f"- {location} 无法完成清理计价。{check.get('after_error', check.get('reason', check.get('before_error', '')))}")
        if not any(s["cleanup"].get("status") in ("cost_changed", "unsupported", "failed")
                   for row in rows.values() for s in row.get("pareto_front", [])):
            lines.append("无。")
        lines.append("")
    lines.extend(["## 指定回归", "", "| 区域 | 求解器 D | anchor D | darm D |",
                  "|---|---:|---:|---:|"])
    for prefix in REGRESSIONS:
        row = next(r for uid, r in reports.items() if uid.startswith(prefix))
        ds = [row["verified_best"], *(row["baselines"][s].get("T") for s in STRATEGIES)]
        lines.append(f"| `{prefix}` | " + " | ".join(str(t[0]) if t else "缺失" for t in ds) + " |")
    lines.extend(["", "逐方案完整 IR diff 和前后计价见原始 JSON。"
                  "本次清理的具体计费原因及待确认闭包规则见[运行记录]"
                  "(../../../regression/records/dataflow-b2b-step3b-20261123.md#清理导致的代价变化)。", ""])
    return "\n".join(lines)


def main(args):
    previous = json.loads((RESULTS / "step3-small-raw.json").read_text())
    inventory = json.loads((CORPUS / "inventory-b2b.json").read_text())["regions"]
    with ThreadPoolExecutor(args.jobs) as pool:
        reports = dict(pool.map(lambda r: analyze(r, previous, args),
                                (r for r in inventory if r["size_bucket"] == "small")))
    for prefix in REGRESSIONS:
        key = next(k for k in reports if k.startswith(prefix))
        print(prefix, reports[key]["invariant"], reports[key]["verified_best"], flush=True)
    (RESULTS / "step3b-small-raw.json.gz").write_bytes(gzip.compress(
        (json.dumps(reports, ensure_ascii=False, indent=2) + "\n").encode(), mtime=0))
    (RESULTS / "step3b-summary.md").write_text(summarize(reports))
    print(f"Recorded {len(reports)} regions", flush=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ("work", "baselines", "solver", "evaluator", "cleanup", "interpreter"):
        parser.add_argument("--" + name, type=Path, required=True)
    parser.add_argument("--jobs", type=int, default=6)
    main(parser.parse_args())
