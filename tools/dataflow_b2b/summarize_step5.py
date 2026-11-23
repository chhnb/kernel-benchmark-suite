#!/usr/bin/env python3
"""Summarize a step 5 small-tier cross-check and reprice prior comparators."""
import argparse
from collections import Counter
from concurrent.futures import ThreadPoolExecutor
import gzip
import json
from pathlib import Path

from check_step5_small import CORPUS, COSTS, read_solution

STRATEGIES = ("anchor", "darm")
COMPONENTS = ("instruction", "select", "control", "escape")
NAMES = {
    "crossed": "交叉配对", "commute": "交换律", "cmp_swap": "谓词交换",
    "shared_select": "select 共享", "paired_memory": "访存配对",
    "speculate_then_select": "推测再选择", "multiple_guards": "多保护段",
}


def terms(row):
    raw = row.get("D_components", {})
    return {
        "instruction": raw.get("instruction", 0) + raw.get("memory", 0),
        "select": sum(raw.get(key, 0) for key in ("select", "folded-join", "simplified-select",
                                                 "folded-condition")),
        "control": raw.get("control", 0),
        "escape": raw.get("escape", 0),
    }


def original_path(row, args):
    folder = args.work / "real" / row["id"]
    for name in ("with-target.ll", "uncompressed.ll"):
        if (folder / name).is_file():
            return folder / name
    return CORPUS / row["ir"]


def compare(result, inventory, args):
    if result["status"] != "agree":
        return
    row = inventory[result["id"]]
    if result["mode"] == "abstract":
        result["comparators"] = result["reference"]["baselines"]
        return
    if row["kind"] == "b2b-triangle":
        value = read_solution([args.evaluator, original_path(row, args), COSTS, "--cost=real",
                               "--original"], 120)
        value.pop("operations", None)
        result["comparators"] = {name: value for name in STRATEGIES}
        return
    folder = args.baselines / "corpus" / row["id"]
    result["comparators"] = {}
    for name in STRATEGIES:
        cleaned = folder / f"{name}.ll"
        if not cleaned.is_file():
            result["comparators"][name] = {"status": "unsupported", "reason": "missing cleaned IR"}
            continue
        flags = ["--output-buffer"] if row["num_outputs"] > 1 else []
        value = read_solution([args.evaluator, cleaned, COSTS, "--cost=real", *flags], 120)
        value.pop("operations", None)
        result["comparators"][name] = value


def bags(rows):
    features = Counter()
    for row in rows:
        features.update({k: bool(row["ilp"]["min_D"].get("features", {}).get(k)) for k in NAMES})
    lines = ["最小 $T_D$ 代表特征数。"
             + "，".join(f"{value} {features[key]}" for key, value in NAMES.items()) + "。", ""]
    for name in STRATEGIES:
        counts, delta = Counter(), Counter()
        for row in rows:
            other = row["comparators"][name]
            if not other.get("T"):
                continue
            best = row["ilp"]["min_D"]
            counts[other["T"][0] - best["T"][0]] += 1
            a, b = terms(other), terms(best)
            delta.update({key: a[key] - b[key] for key in COMPONENTS})
        lines.append(f"- {name} 达到最优 {counts[0]}/{sum(counts.values())}。"
                     f"$T_D$ 差距分布 `{dict(sorted(counts.items()))}`。"
                     f"按指令、选择、控制、流出分解的合计依次为 "
                     f"{', '.join(str(delta[key]) for key in COMPONENTS)}。")
    return lines


def summarize(results, inventory):
    lines = ["# 第 5 步 small 档对拍与门槛结果", "",
             "small 档 188 个区域各运行两种代价。可计价区域的最小 $T_D$ 和 §7.2 所选 $T$ "
             "与参考枚举的对拍结果如下。", "",
             "| 档位／类型 | 区域 | 抽象一致 | 真实一致 | 两种模式均未计价 |",
             "|---|---:|---:|---:|---:|"]
    for kind in ("diamond", "triangle"):
        rows = [r for r in results if r["kind"] == f"b2b-{kind}"]
        counts = Counter((r["mode"], r["status"]) for r in rows)
        unavailable = set.intersection(*({r["id"] for r in rows if r["mode"] == mode
                                           and r["status"] == "unpriced"}
                                          for mode in ("abstract", "real")))
        lines.append(f"| small {kind} | {len(rows)//2} | {counts['abstract','agree']} | "
                     f"{counts['real','agree']} | {len(unavailable)} |")
    lines += ["| medium diamond | 53 | — | — | — |",
              "| medium triangle | 72 | — | — | — |", "",
              "medium 要在 small 全部通过后才开始。当前没有 medium 求解、最优证明、超时、"
              "最优间隙、≤14 条复核及对照统计。", "",
              "## 未计价与其他差异", ""]
    for row in results:
        if row["status"] != "agree":
            lines.append(f"- `{row['id']}`，{row['mode']}。{row['status']}，"
                         f"{row['ilp'].get('reason')}。")
    cuts = Counter()
    for row in results:
        cuts.update(row["ilp"].get("cuts", {}))
    lines += ["", "该 diamond 在第 3b 步也没有抽象真值。普通调用 `g_7_7`、`g_6_6` "
              "的抽象表无报价，LLVM 24 worker 按 `opaque_call_cost_not_whole_callee_cost` 拒绝。"
              "两种求解器的同一失败状态不计入数值通过。", "",
              f"已定价的两目标输出完成语义差分。候选级排除合计 `{dict(cuts)}`。"
              "单项结果、迭代次数及证明状态见 [small 档证据](step5-small.json.gz)。", ""]
    lines += ["## small 档对照", "",
              "抽象对照取第 3b 步产物。真实对照对同一已清理 IR 重报价，"
              "三角形使用原始区域报价。差距为对照减 CP-SAT。"
              "负值表示现有对照产物在当前区域目标下更便宜。", ""]
    for kind in ("diamond", "triangle"):
        for mode in ("abstract", "real"):
            rows = [r for r in results if r["status"] == "agree" and r["mode"] == mode
                    and r["kind"] == f"b2b-{kind}"]
            lines += [f"### small {kind}／{mode}", "", *bags(rows), ""]
    lines += ["## 真实代价下优于 anchor 和 DARM 的 small 区域", "",
              "按较强对照与 CP-SAT 的 $T_D$ 差距排序。最后一列是该差距的计费项构成"
              "（指令、选择、控制、流出）和 CP-SAT 所用特征。", "",
              "| ID | 来源 case | 条件来源 | CP-SAT | anchor | DARM | 差距与方案特征 |",
              "|---|---|---|---:|---:|---:|---|"]
    top = []
    for row in results:
        if row["mode"] != "real" or row["status"] != "agree":
            continue
        if not all(row["comparators"][k].get("T") for k in STRATEGIES):
            continue
        best = row["ilp"]["min_D"]
        scores = [row["comparators"][k]["T"][0] for k in STRATEGIES]
        advantage = min(scores) - best["T"][0]
        if advantage > 0:
            top.append((advantage, max(scores), row["id"], scores, row))
    for advantage, _, uid, scores, row in sorted(top, reverse=True)[:15]:
        best = row["ilp"]["min_D"]
        base = min(row["comparators"].values(), key=lambda competitor: competitor["T"][0])
        a, b = terms(base), terms(best)
        delta = ", ".join(str(a[k] - b[k]) for k in COMPONENTS)
        features = "、".join(NAMES[k] for k, on in best.get("features", {}).items() if on and k in NAMES)
        occurrences = inventory[uid]["occurrences"]
        original = next((o for o in occurrences if o["category"] != "snapshot"), occurrences[0])
        lines.append(f"| `{uid}` | {original['case']} | {row['condition_source']} | "
                     f"{best['T'][0]} | {scores[0]} | {scores[1]} | {advantage} ({delta})，"
                     f"{features or '见计费项'} |")
    lines += ["", "## medium", "",
              "未运行。现有 small 结果无法给出 medium 的表现。", ""]
    return "\n".join(lines)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ("work", "evaluator", "baselines", "summary", "evidence"):
        p.add_argument(name, type=Path)
    args = p.parse_args()
    inventory = {r["id"]: r for r in json.loads((CORPUS/"inventory-b2b.json").read_text())["regions"]}
    results = json.loads((args.work/"small-cross-check.json").read_text())
    with ThreadPoolExecutor(12) as pool:
        list(pool.map(lambda r: compare(r, inventory, args), results))
    args.summary.write_text(summarize(results, inventory))
    args.evidence.write_bytes(gzip.compress((json.dumps(results, ensure_ascii=False) + "\n").encode(),
                                            mtime=0))


if __name__ == "__main__":
    main()
