#!/usr/bin/env python3
"""Run the oracle, reference search and unchanged baselines on the extracted corpus."""
import argparse
from collections import Counter
from concurrent.futures import ThreadPoolExecutor
import csv
import gzip
import json
from pathlib import Path
import re

from run_step2 import COSTS, TESTS, compare, error, invoke, read_report

CORPUS = TESTS / "corpus"
RESULTS = TESTS / "results"


def direct_pair(source):
    # Extracted functions start in the entry block, with named or numeric
    # direct successors. fusion-search numbers basic blocks in function order.
    body = source.read_text().split("define ", 1)[1].split("\n}", 1)[0]
    blocks = re.findall(r"(?m)^([A-Za-z0-9_.$-]+):", body)
    fn = body.splitlines()
    if len(fn) > 1 and not fn[1].strip().endswith(":"):
        blocks.insert(0, None)
    branch = re.search(r"(?m)^\s*br i1 [^,]+, label %([-\w.$]+), label %([-\w.$]+)", body)
    if not branch or any(name not in blocks for name in branch.groups()):
        return None
    return ["B0", *(f"B{blocks.index(name)}" for name in branch.groups())]


def run_baselines(source, args, work):
    command = [args.engine, "--ir", source, "--function", "region"]
    catalog = work / "catalog"
    discovery = invoke([*command, "--out", work / "unused.ll", "--catalog-only", "1",
                        "--debug-dir", catalog], timeout=30)
    size = None
    catalog_file = catalog / "catalog.json"
    if not discovery.returncode and catalog_file.is_file():
        proposals = json.loads(catalog_file.read_text())["candidates"]
        size = len(proposals)
    pair = direct_pair(source)
    if pair is None:
        return {name: {"status": "no_pair", "reason": "could not resolve extracted branch successors",
                       "catalog_count": size} for name in ("anchor", "darm")}
    flags = [flag for key, block in zip(("--split", "--left", "--right"), pair)
             for flag in (key, block)]
    scores = {}
    for name in ("anchor", "darm"):
        output = work / (name + ".ll")
        result = invoke([*command, *flags, "--out", output, "--debug-dir", work / name,
                         "--ir-snapshots", "compact", "--b2b-strategy", name,
                         "--tti-worker", args.tti_worker], timeout=45)
        if not result.returncode and output.is_file():
            cost = read_report(invoke([args.evaluator, output, COSTS, "--c-sl=real"]))
            cost.pop("operations", None)
        else:
            cost = {"status": "rejected", "reason": error(result)}
        cost.update(catalog_count=size, pair=pair)
        scores[name] = cost
    return scores


def analyze(key, source, args, host, corpus):
    target = args.work / ("corpus" if corpus else "micro") / key
    target.mkdir(parents=True, exist_ok=False)
    if source.suffix == ".gz":
        path = target / "input.ll"
        path.write_bytes(gzip.decompress(source.read_bytes()))
        source = path
    model = "--c-sl=real" if corpus else "--c-sl=abstract"
    process = invoke([args.solver, source, COSTS, target, model])
    report = read_report(process)
    if process.returncode:
        report.update(complete=False, reason=report.get("reason") or error(process))
    compare(source, report, args.clang, host, target, corpus=corpus)
    for row in report.get("pareto_front", []):
        observed = read_report(invoke([args.interpreter, source, target / row["ir"]], timeout=30))
        if observed["status"] in {"pass", "mismatch"} or row["semantic_validation"]["status"] != "pass":
            row["host_validation"] = row["semantic_validation"]
            row["semantic_validation"] = observed
    for row in report.get("pareto_front", []):
        clean = invoke([args.cleanup, target / row["ir"]], timeout=30)
        status = {0: "unchanged", 1: "changed"}.get(clean.returncode, "failed")
        row["cleanup"] = {"status": status}
        if status == "changed":
            (target / (row["ir"] + ".cleanup.diff")).write_text(clean.stdout)
            before, after = clean.stdout.split("+++ after\n", 1)
            changes = {}
            for name, pattern in (("conditional_branches", r"\bbr i1\b"),
                                  ("phis", r" = phi "), ("selects", r" = select "),
                                  ("loads", r" = load "), ("stores", r"\bstore ")):
                count = len(re.findall(pattern, after)) - len(re.findall(pattern, before))
                if count:
                    changes[name] = count
            row["cleanup"]["counts_delta"] = changes
            def opcodes(text):
                count = Counter()
                for line in text.splitlines():
                    found = re.match(r"^  (?:%[^=]+ = )?(?:(?:tail|musttail|notail) )?([a-z][a-z0-9]+)\b", line)
                    if found:
                        count[found[1]] += 1
                return count
            old_ops, new_ops = opcodes(before), opcodes(after)
            row["cleanup"]["opcodes_delta"] = {
                key: new_ops[key] - old_ops[key] for key in sorted(old_ops.keys() | new_ops.keys())
                if old_ops[key] != new_ops[key]}
        elif status == "failed":
            row["cleanup"]["reason"] = error(clean)
    if corpus:
        report["baselines"] = run_baselines(source, args, target)
    return key, report


def summarize(small, micro, inventory, output):
    ok = lambda solution: solution.get("semantic_validation", {}).get("status") == "pass"
    wins = Counter()
    features = Counter()
    baseline_status = {key: Counter() for key in ("anchor", "darm")}
    cleanup = Counter()
    semantic = Counter()
    kinds = Counter()
    tops = Counter()
    gaps = {key: [] for key in ("anchor", "darm")}
    with (output / "step3-small.tsv").open("w") as file:
        writer = csv.writer(file, delimiter="\t", lineterminator="\n")
        writer.writerow(["region", "original_T", "verified_best_T", "verified_strategy_T",
                         "anchor_T", "darm_T", "complete", "reason"])
        for uid, report in small.items():
            row = inventory[uid]
            baseline = report.get("original_T")
            choices = [s for s in report.get("pareto_front", []) if ok(s)]
            if baseline:
                best = min(choices, key=lambda x: x["T"], default=None)
            else:
                best = None
            score = best["T"] if best else None
            strategy = None
            if score:
                wins["D"] += score[0] < baseline[0]
                condition = row["condition_source"]
                if condition == "thread-pattern":
                    strategy = score
                    wins["strategy"] += score[0] < baseline[0]
                elif condition == "data":
                    allowed = [s["T"] for s in choices
                               if s["T"][1] <= baseline[1] and s["T"][2] <= baseline[2]]
                    strategy = min(allowed, default=baseline)
                    wins["strategy"] += strategy[0] < baseline[0]
                elif condition == "workgroup-uniform":
                    strategy = min([baseline, *(s["T"] for s in choices)], key=lambda x: max(x[1:]))
                    wins["strategy"] += max(strategy[1:]) < max(baseline[1:])
                for feature, value in best.get("features", {}).items():
                    features[feature] += bool(value)
                features["multiple_guards"] += best.get("guard_branches", 0) > 1
            current = min((s["T"][0] for s in report.get("pareto_front", [])), default=None)
            if current is not None:
                for item in report.get("top_k", []):
                    tops[item["k"]] += item["best_observed_D"] > current
            values = []
            for name, result in report["baselines"].items():
                values.append(result.get("T"))
                baseline_status[name][result["status"]] += 1
                if score and result.get("T"):
                    anchor = result.get("D_components", {})
                    before = best.get("D_components", {})
                    detail = {key: anchor.get(key, 0) - before.get(key, 0)
                              for key in sorted(anchor.keys() | before.keys())
                              if anchor.get(key, 0) != before.get(key, 0)}
                    explanation = {"terms": detail, "features": [
                        key for key, enabled in best.get("features", {}).items() if enabled]}
                    gaps[name].append((result["T"][0] - score[0], uid, explanation))
            writer.writerow([uid, baseline, score, strategy, *values,
                             report.get("complete"), report.get("reason")])
    for report in [*small.values(), *micro.values()]:
        for solution in report.get("pareto_front", []):
            semantic[solution.get("semantic_validation", {}).get("status", "not_run")] += 1
            check = solution.get("cleanup", {})
            cleanup[check.get("status", "not_run")] += 1
            if check.get("status") == "changed":
                opcodes = check.get("opcodes_delta", {})
                if not opcodes:
                    category = "块布局、操作数或标志变化"
                elif any(opcode in opcodes for opcode in ("phi", "select")):
                    category = "PHI 或 select 变化"
                elif "br" in opcodes:
                    category = "分支或块折叠"
                elif any(opcode in opcodes for opcode in ("load", "store", "getelementptr")):
                    category = "访存或地址计算变化"
                else:
                    category = "其他操作合并、删除或替换"
                kinds[category] += 1
    complete = sum(report.get("complete", False) for report in small.values())
    lines = ["# Dataflow B2B 第 3 步", "",
             f"Small 档共 {len(small)} 个区域。完备枚举 {complete} 个。",
             "", f"仅统计通过语义差分的前沿代表，D 场景改善 {wins['D']} 个，"
             f"按 §7.2 策略改善 {wins['strategy']} 个。", "",
             f"已验证的当前最佳代表特征计数为 `{dict(sorted(features.items()))}`。", "",
             f"K=1、3、10 相对当前搜索已观测的最低 D 漏掉的区域数依次为 "
             f"{tops[1]}、{tops[3]}、{tops[10]}。全局最优漏失率仍待完备搜索。", "",
             f"语义验证（含微型测试）为 `{dict(sorted(semantic.items()))}`。", "",
             f"清理一致性（含微型测试）为 `{dict(sorted(cleanup.items()))}`。",
             f"可观测差异类别为 `{dict(sorted(kinds.items()))}`。", "",
             "## 与现有工具的比较", ""]
    for name in ("anchor", "darm"):
        lines.append(f"- {name} `{dict(sorted(baseline_status[name].items()))}`。"
                     f"{sum(gap == 0 for gap, *_ in gaps[name])} 个与通过语义验证的当前最佳 D 相等。")
        for gap, uid, context in sorted(gaps[name], key=lambda v: (-v[0], v[1]))[:10]:
            terms = "、".join(f"{key} {value:+}" for key, value in context["terms"].items())
            features_used = "、".join(context["features"]) or "无"
            lines.append(f"  - `{uid}` 的 D 差为 {gap}。计费项差值为 {terms or '零'}，"
                         f"候选特征为 {features_used}。")
    lines.extend(["", "逐区间的拒绝原因、oracle 和语义状态见原始 JSON。"])
    (output / "step3-summary.md").write_text("\n".join(lines) + "\n")


def main(args):
    rows = json.loads((CORPUS / "inventory-b2b.json").read_text())["regions"]
    inventory = {row["id"]: row for row in rows if row["size_bucket"] == "small"}
    host = invoke([args.clang, "-dumpmachine"]).stdout.strip()
    args.output.mkdir(parents=True, exist_ok=True)
    with ThreadPoolExecutor(args.jobs) as pool:
        micros = [(file.stem, file) for file in sorted((TESTS / "micro").glob("*.ll"))]
        micro = dict(pool.map(lambda item: analyze(*item, args, host, False), micros))
        inputs = [(uid, CORPUS / row["ir"]) for uid, row in inventory.items()]
        small = dict(pool.map(lambda item: analyze(*item, args, host, True), inputs))
    for name, reports in (("small", small), ("micro", micro)):
        (args.output / f"step3-{name}-raw.json").write_text(
            json.dumps(reports, ensure_ascii=False, indent=2) + "\n")
    summarize(small, micro, inventory, args.output)
    print(f"Recorded {len(small)} corpus and {len(micro)} micro regions")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ("work", "output", "solver", "evaluator", "engine", "tti-worker", "clang", "cleanup", "interpreter"):
        parser.add_argument("--" + name, type=Path, required=True)
    parser.add_argument("--jobs", type=int, default=4)
    main(parser.parse_args())
