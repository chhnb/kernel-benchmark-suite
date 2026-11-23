#!/usr/bin/env python3
"""Audit final medium candidates and summarize certified real-price results."""
import argparse
from collections import Counter
from concurrent.futures import ThreadPoolExecutor
import gzip
import json
from pathlib import Path
import subprocess

from check_step5_small import COSTS, RESULTS, read_solution
from run_step5b import assess, inputs
from summarize_step5 import COMPONENTS, NAMES, STRATEGIES, terms

LABELS = {"instruction": "指令", "select": "select", "control": "控制", "escape": "流出"}


def read(path):
    return json.loads(path.read_text())


def has_solution(result):
    return bool(result.get("T"))


def verified(solution):
    return solution.get("semantic_validation", {}).get("status") == "pass"


def is_proved(row):
    ilp = row["ilp"]
    return all(ilp.get(label, {}).get("optimal") for label in ("min_D", "strategy"))


def is_comparable(row):
    best = row["ilp"].get("min_D", {})
    return best.get("optimal", False) and verified(best)


def timed_out(ilp, budget):
    return (ilp.get("status") == "timeout" or
            "deadline" in ilp.get("reason", "") or
            (ilp.get("status") == "incomplete" and ilp.get("seconds", 0) >= budget - 1))


def replay_incumbent(source, folder, solution, args, label):
    """Check the incumbent after search, without spending more search time."""
    if not has_solution(solution) or verified(solution):
        return
    destination = folder / "ilp" / f"{label}.ll"
    if not destination.is_file() and solution.get("decisions"):
        command = [args.tools / "reference_solver", source, COSTS, folder / "ilp",
                   "--ilp-bridge", "--cost=real"]
        request = solution["decisions"] | {"emit": str(destination)}
        try:
            process = subprocess.run(command, input=json.dumps(request) + "\n",
                                     capture_output=True, text=True, timeout=75)
            report = json.loads(process.stdout.splitlines()[-1])
            if report.get("status") != "ok" or report.get("T") != solution["T"]:
                raise ValueError(f"incumbent replay failed: {report}")
        except (OSError, ValueError, IndexError, subprocess.SubprocessError) as exc:
            solution["audit"] = {"status": "failed", "reason": str(exc)}
            return
    if solution.get("original"):
        destination = source
    if destination.is_file():
        result = read_solution([args.interpreter, source, destination], 45)
        solution["pre_audit_semantic_validation"] = solution.get("semantic_validation")
        solution["semantic_validation"] = result


def audit(entry, args):
    region, folder, source = entry
    row = {key: region[key] for key in ("id", "kind", "condition_source")}
    row["operations"] = region["left_ops"] + region["right_ops"]
    occurrences = region["occurrences"]
    row["cases"] = sorted({item["case"] for item in occurrences})
    row["case"] = next((item["case"] for item in occurrences if item["category"] != "snapshot"),
                       occurrences[0]["case"])
    row["ilp"] = read(folder / "ilp.json")
    row["baselines"] = read(folder / "baselines.json")
    reference = folder / "reference.json"
    if reference.is_file():
        row["reference"] = read(reference)
    for label in ("min_D", "strategy"):
        if label in row["ilp"]:
            replay_incumbent(source, folder, row["ilp"][label], args, label)
    # InstCombine is the last pass. A guard newly exposed by it may still be
    # present in the actual comparator IR even if another SimplifyCFG can fold it.
    for name in STRATEGIES:
        base = row["baselines"][name]
        if base.get("T") or not (folder / f"{name}.ll").is_file():
            continue
        abi = ["--output-buffer"] if region["num_outputs"] > 1 else []
        if "must be speculated by SimplifyCFG" in base.get("reason", ""):
            result = assess(args.evaluator, folder / f"{name}.ll", "--after-cleanup", *abi)
            row["baselines"][name] = base | result | {"strict_evaluator_reason": base["reason"]}
            if result.get("T"):
                row["baselines"][name].pop("reason", None)
    original = row["baselines"]["original"]
    row["status"] = ("unpriced" if not has_solution(original) and not row["ilp"].get("original_T")
                     else "optimal" if is_proved(row)
                     else "timeout" if timed_out(row["ilp"], args.seconds)
                     else "incomplete")
    return row


def difference(baseline, solution):
    a, b = terms(baseline), terms(solution)
    result = {key: a[key] - b[key] for key in COMPONENTS}
    assert sum(result.values()) == baseline["T"][0] - solution["T"][0], (a, b)
    return result


def fmt_terms(values):
    return "(" + ", ".join(f"{values[key]:+d}" for key in COMPONENTS) + ")"


def reference_status(row):
    ref = row["reference"]
    got = row["ilp"]
    if row["status"] == "unpriced":
        return "unpriced"
    if not ref.get("complete") or not all(
            has_solution(got.get(label, {})) for label in ("min_D", "strategy")):
        return "incomplete"
    expect = ref["expected"]
    if expect["min_D"][0] != got["min_D"]["T"][0] or expect["strategy"] != got["strategy"]["T"]:
        return "mismatch" if is_proved(row) else "incumbent_differs"
    return "agree" if is_proved(row) else "incumbent_agrees"


def stats(rows, name, *, medium):
    deltas, gaps = Counter(), Counter()
    net = 0
    skipped = 0
    for row in rows:
        baselines = row["baselines"] if medium else row.get("comparators", {})
        base, best = baselines.get(name, {}), row["ilp"]["min_D"]
        if not has_solution(base):
            skipped += 1
            continue
        gap = base["T"][0] - best["T"][0]
        gaps[gap] += 1
        net += gap
        deltas.update(difference(base, best))
    return gaps, deltas, net, skipped


def summary(medium, small, budget):
    comparable = [r for r in medium if is_comparable(r)]
    lines = ["# 第 5b 步 medium 档真实代价求解", "",
             f"输入 {len(medium)} 个区域，每个区域的求解预算 {budget:g} 秒。"
             "最优证明限于第 5 步的单保护结构和现有 LLVM 生成规则。"
             "两目标都证明完成时计为最优。差距与特征统计要求无约束最小 D 已证明且通过语义差分。", "",
             "| 类型 | 总数 | 两目标均证明 | 超时 | 无报价 | 其他未完成 | 最小 D 已证明且通过语义差分 |",
             "|---|---:|---:|---:|---:|---:|---:|"]
    for kind in ("diamond", "triangle"):
        rows = [r for r in medium if r["kind"] == f"b2b-{kind}"]
        c = Counter(r["status"] for r in rows)
        lines.append(f"| {kind} | {len(rows)} | {c['optimal']} | {c['timeout']} | {c['unpriced']} | "
                     f"{c['incomplete']} | {sum(is_comparable(r) for r in rows)} |")
    cross = [r for r in medium if "reference" in r]
    statuses = Counter(reference_status(r) for r in cross)
    lines += ["", "## ≤14 条指令的参考枚举", "",
              f"覆盖 {len(cross)} 个区域。最小 D 与 §7.2 向量都一致 "
              f"{statuses['agree'] + statuses['incumbent_agrees']} 个，"
              f"其中两边均出具证明 {statuses['agree']} 个，"
              f"ILP 的超时 incumbent 与参考最优一致 {statuses['incumbent_agrees']} 个。"
              f"数值不一致 {statuses['mismatch'] + statuses['incumbent_differs']} 个，"
              f"缺少求解结果 {statuses['incomplete']} 个，无报价 {statuses['unpriced']} 个。", ""]
    for row in cross:
        status = reference_status(row)
        if status not in ("agree", "unpriced"):
            ref, ilp = row["reference"], row["ilp"]
            explanation = "ILP 超时，结果与参考最优一致" if status == "incumbent_agrees" else status
            lines.append(f"- `{row['id']}`，{explanation}。参考 {ref.get('expected', ref.get('reason'))}。"
                         f"ILP 最小 D 向量 {ilp.get('min_D', {}).get('T')}，"
                         f"§7.2 向量 {ilp.get('strategy', {}).get('T')}。")
    lines += ["", "## 与 anchor 和 DARM 的差距", "",
              "diamond 使用现有工具对抽取区域生成并清理的候选报价。证据保留现有裁决的 eligible 状态。"
              "triangle 将原始报价用作两个对照。差距为对照的 $T_D$ 减已验证的最优 $T_D$。"
              "计费项依次为指令、select、控制、流出。负值表示对照 IR 在当前计费下更便宜。", ""]
    for kind in ("diamond", "triangle"):
        group = [r for r in comparable if r["kind"] == f"b2b-{kind}"]
        lines += [f"### {kind}", ""]
        for name in STRATEGIES:
            gaps, deltas, _, skipped = stats(group, name, medium=True)
            lines.append(f"- {name} 达到最优 {gaps[0]}/{sum(gaps.values())}，对照无报价 {skipped}。"
                         f"差距分布 `{dict(sorted(gaps.items()))}`。计费项净差 {fmt_terms(deltas)}。")
        features = Counter()
        for row in group:
            best = row["ilp"]["min_D"]
            features.update({k: bool(best.get("features", {}).get(k)) for k in NAMES})
            if not best["original"] and best.get("guard_branches") == 0:
                features["removed_branch"] += row["baselines"]["original"]["guard_branches"] > 0
        names = NAMES | {"removed_branch": "消除了原有分支"}
        lines += ["", "最优代表的特征数为 " +
                  "、".join(f"{label} {features[key]}" for key, label in names.items()) + "。", ""]
    scored = []
    lines += ["## 同时优于两个对照的前 15 个区域", "",
              "按两个差距中较小者降序。计费项分别对 anchor、DARM 分解，次序为指令、select、控制、流出。", "",
              "| 区域 ID | 类型 | 来源 case | 条件来源 | 最优 D | anchor D | DARM D | 对 anchor | 对 DARM |",
              "|---|---|---|---|---:|---:|---:|---|---|"]
    for row in comparable:
        bases = [row["baselines"][k] for k in STRATEGIES]
        if not all(map(has_solution, bases)):
            continue
        best = row["ilp"]["min_D"]
        gains = [base["T"][0] - best["T"][0] for base in bases]
        if min(gains) > 0:
            scored.append((min(gains), max(gains), row["id"], row))
    for _, _, uid, row in sorted(scored, key=lambda r: (-r[0], -r[1], r[2]))[:15]:
        best = row["ilp"]["min_D"]
        a, d = (row["baselines"][k] for k in STRATEGIES)
        lines.append(f"| `{uid}` | {row['kind'][4:]} | {row['case']} | "
                     f"{row['condition_source']} | {best['T'][0]} | "
                     f"{a['T'][0]} | {d['T'][0]} | {fmt_terms(difference(a, best))} | "
                     f"{fmt_terms(difference(d, best))} |")
    lines += ["", "## small + medium 相对 anchor 的收益归因", "",
              "使用真实代价，限定可比较且已证明并验证的区域。"
              "净账包含平手时互相抵消的计费项。最后一行只纳入 $T_D$ 严格改善的区域。", "",
              "| 范围 | 对照区域数 | 指令 | select | 控制 | 流出 | 总收益 |",
              "|---|---:|---:|---:|---:|---:|---:|"]
    normalized_small = [r for r in small if r["mode"] == "real" and r["status"] == "agree"]
    combined = Counter()
    wins = Counter()
    win_count = 0
    count = 0
    branch_removals = 0
    branch_removal_control = 0
    for name, rows, from_medium in (("small", normalized_small, False), ("medium", comparable, True)):
        g, delta, net, _ = stats(rows, "anchor", medium=from_medium)
        count += sum(g.values())
        combined.update(delta)
        lines.append(f"| {name} | {sum(g.values())} | " +
                     " | ".join(str(delta[k]) for k in COMPONENTS) + f" | {net} |")
        for row in rows:
            base = row["baselines" if from_medium else "comparators"]["anchor"]
            best = row["ilp"]["min_D"]
            if has_solution(base) and base["T"][0] > best["T"][0]:
                delta = difference(base, best)
                wins.update(delta)
                win_count += 1
                if base.get("guard_branches", 0) > 0 and not best["original"] and best.get("guard_branches") == 0:
                    branch_removals += 1
                    branch_removal_control += delta["control"]
    for name, n, total in (("合计净账", count, combined), ("合计正收益", win_count, wins)):
        lines.append(f"| {name} | {n} | " +
                     " | ".join(str(total[k]) for k in COMPONENTS) + f" | {sum(total.values())} |")
    if sum(wins.values()):
        lines += ["", f"正收益中控制项为 {wins['control']} 点，占净收益 "
                  f"{100 * wins['control'] / sum(wins.values()):.1f}%。"
                  f"其中 {branch_removals} 个区域从 anchor 的有条件分支变成无保护段，"
                  f"贡献控制收益 {branch_removal_control} 点。"
                  "各项为有符号差值，因此控制比例可超过 100%。"]
    timeout_rows = [r for r in medium if r["status"] == "timeout"]
    gap_summaries = []
    for kind in ("diamond", "triangle"):
        group = [r["ilp"] for r in timeout_rows if r["kind"] == f"b2b-{kind}"]
        gaps = [r["min_D"]["gap"] for r in group if has_solution(r.get("min_D", {}))]
        if group:
            gap_summary = (f"{100 * min(gaps):.1f}%–{100 * max(gaps):.1f}%"
                           if gaps else "无可用数值")
            gap_summaries.append(f"{kind} {len(group)} 个超时，{len(gaps)} 个有可报告的向量，间隙 {gap_summary}")
    lines += ["", "## 超时、无报价及验证例外", "",
              "超时行列出无约束与策略目标的 incumbent、下界和相对间隙。"
              "第 5 步的运行未出具证明时使用非负计费的全局下界 0。"
              "最小 D 已证明且通过语义差分的超时行仍参与最优解排名和收益归因。"
              "没有返回 incumbent 时，表中以上界标记已知可行的原始 IR。", "",
              "。".join(gap_summaries) + "。" if gap_summaries else "无超时。", "",
              "| 区域 ID | 类型 | 无约束 $T_D$／下界／间隙 | §7.2 目标／下界／间隙 |",
              "|---|---|---|---|"]

    def fmt_gap(solution, uniform):
        if not has_solution(solution):
            return "—"
        objective = max(solution["T"][1:]) if uniform else solution["T"][0]
        return f"{objective}／{solution['bound']}／{100 * solution['gap']:.1f}%"

    for r in medium:
        if r["status"] == "timeout":
            ilp = r["ilp"]
            uniform = r["condition_source"] == "workgroup-uniform"
            if has_solution(ilp.get("min_D", {})):
                minimum = fmt_gap(ilp["min_D"], False)
                policy = fmt_gap(ilp.get("strategy", {}), uniform)
            else:
                original = r["baselines"]["original"]["T"]
                minimum = f"上界 {original[0]}／0／100.0%"
                policy = f"上界 {max(original[1:]) if uniform else original[0]}／0／100.0%"
            lines.append(f"| `{r['id']}` | {r['kind'][4:]} | {minimum} | {policy} |")
    lines.append("")
    for tag in ("min_D", "strategy"):
        validation = Counter(r["ilp"].get(tag, {}).get("semantic_validation", {}).get("status", "无 incumbent")
                             for r in timeout_rows)
        lines.append(f"- 超时区域的 {tag} 语义复核状态计数为 `{dict(sorted(validation.items()))}`。"
                     "逐区域的验证信息见压缩证据。")
    for row in timeout_rows:
        reasons = {r["reason"] for tag in ("min_D", "strategy")
                   if (r := row["ilp"].get(tag, {}).get("semantic_validation", {})).get("reason")}
        if reasons:
            lines.append(f"- `{row['id']}`，超时解语义复核未完成。{'、'.join(sorted(reasons))}。")
    for row in medium:
        uid, ilp = row["id"], row["ilp"]
        if row["status"] in ("unpriced", "incomplete"):
            reason = ilp.get("reason", row["baselines"]["original"].get("reason", "无可用报价"))
            if uid == "989fc49dfa138857002030b37e80a4ccfae0bb38":
                reason += "。LLVM 24 worker 另确认普通调用 `quant_decide` 无报价"
            lines.append(f"- `{uid}`，{row['status']}。{reason}。")
        for name in STRATEGIES:
            base = row["baselines"][name]
            if row["status"] != "unpriced" and not has_solution(base):
                lines.append(f"- `{uid}`，{name} 对照不可用。{base.get('reason', base['status'])}。")
            if is_comparable(row) and has_solution(base) and base["T"][0] < ilp["min_D"]["T"][0]:
                lines.append(f"- `{uid}`，{name} 对照 D={base['T'][0]}，已证明模型最小 D="
                             f"{ilp['min_D']['T'][0]}。计费项 {fmt_terms(difference(base, ilp['min_D']))}。")
        if is_proved(row):
            for label in ("min_D", "strategy"):
                solution = ilp[label]
                if not verified(solution):
                    validation = solution.get("semantic_validation", {})
                    lines.append(f"- `{uid}`，{label} 语义复核未通过。"
                                 f"{validation.get('reason', validation.get('status'))}。")
    lines += ["", "[逐区域证据](step5b-medium.json.gz) · "
              "[运行记录](../../../regression/records/dataflow-b2b-step5b-20261123.md)", ""]
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("work", type=Path)
    parser.add_argument("--tools", type=Path, default=Path("build/llvm24-tti"))
    parser.add_argument("--evaluator", type=Path, required=True)
    parser.add_argument("--interpreter", type=Path, required=True)
    parser.add_argument("--seconds", type=float, default=600)
    args = parser.parse_args()
    with ThreadPoolExecutor(12) as pool:
        medium = list(pool.map(lambda row: audit(row, args), inputs(args)))
    with gzip.open(RESULTS / "step5-small.json.gz", "rt") as stream:
        small = json.load(stream)
    (RESULTS / "step5b-summary.md").write_text(summary(medium, small, args.seconds))
    (RESULTS / "step5b-medium.json.gz").write_bytes(gzip.compress(
        (json.dumps(medium, ensure_ascii=False, indent=2) + "\n").encode(), mtime=0))


if __name__ == "__main__":
    main()
