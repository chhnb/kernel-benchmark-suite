#!/usr/bin/env python3
"""Write experiment evidence and the contextual regret tables."""
import argparse
from collections import Counter, defaultdict
import gzip
import json
from pathlib import Path

from check_step5_small import CORPUS, RESULTS
from measure_step7 import CASES, read
from replay_step7 import choices, comparison_price

PARTS = ("instruction", "select", "control", "escape")


def triplet(values):
    return "(" + ",".join(map(str, values)) + ")"


def parts(row):
    if "components" in row:
        return {key: value[0] for key, value in row["components"].items()}
    if "component_vectors" in row:
        return {key: value[0] for key, value in row["component_vectors"].items()}
    source = row.get("D_components", {})
    return {"instruction": source.get("instruction", 0) + source.get("memory", 0),
            "select": sum(source.get(k, 0) for k in ("select", "folded-join", "folded-condition",
                                                      "simplified-select")),
            "control": source.get("control", 0), "escape": source.get("escape", 0)}


def buckets(records):
    return "、".join(f"{n}:{count}" for n, count in sorted(Counter(
        r["regret"] for r in records).items())) or "—"


def paths_report(work, paths):
    lines = ["", "## 只替换一步", "",
             "按最小 $T_D$ 的已测遗憾值选择一步，平手时优先已证明最优，再按原搜索顺序。"
             "复跑验证变更前的提交前缀和候选父 IR。其余轮次沿用 anchor。", "",
             "| Case | 轮 / 区域 | 区域 D 遗憾 | ILP 证明 | 替换步 kernel TTI | 原最终 TTI | 新最终 TTI | 变化 |",
             "|---|---|---:|---|---:|---:|---:|---:|"]
    for row in paths:
        if row["status"] != "completed":
            lines.append(f"| {row['case']} | {row['status']} | — | — | — | — | — | — |")
            continue
        lines.append(f"| {row['case']} | {row['step']} / `{row['region'][:12]}` | {row['regret']} | "
                     f"{'是' if row['optimal'] else '否'} | {row['at_step_TTI']} | {row['baseline']} | "
                     f"{row['final']} | {row['final'] - row['baseline']:+d} |")
    notes = []
    for row in paths:
        if row["status"] != "completed":
            continue
        base = read(work / row["case"] / "anchor/summary.json")
        parent = base["rounds"][row["step"] - 1]["parent_cost"]
        if row["at_step_TTI"] > parent:
            notes.append(f"- {row['case']} 的选中区域回填后整核 TTI 从 {parent} 升到 "
                         f"{row['at_step_TTI']}。替换前已有 {row['prefix_commits']} 次提交。"
                         f"随后整核搜索结束于 {row['final']}，共 {row['commits']} 次提交。")
    return lines + (["", *notes] if notes else [])


def nqu_report():
    inventory = {r["id"]: r for r in read(CORPUS / "inventory-b2b.json")["regions"]}
    sources = defaultdict(list)
    for row in read(CORPUS / "sources.json")["sources"]:
        sources[row["sha256"]].append(row)
    with gzip.open(RESULTS / "step5b-medium.json.gz", "rt") as archive:
        old = [r for r in json.load(archive) if r["case"].startswith("NQU")
               and r["kind"] == "b2b-diamond" and r["status"] == "optimal"
               and r["ilp"]["min_D"]["T"][0] < r["baselines"]["anchor"]["T"][0]]
    assert len(old) == 8
    lines = ["", "## NQU64 的八个历史 diamond", "",
             "| 区域 ID | case / 首个来源 | 位置 | 输入 SHA-256 前缀 |",
             "|---|---|---|---|"]
    for row in old:
        occurrence = inventory[row["id"]]["occurrences"][0]
        sha = occurrence["source_sha256"]
        matches = sources[sha]
        if occurrence["category"] == "snapshot":
            src = next(r for r in matches if r["category"] == "snapshot")
            generation = src["generation"]
            desc = f"{src['case']} / frozen-parity 第 {generation['step']} 步快照"
        else:
            desc = "NQU64 原始输入" if sha.startswith("41d0f") else "同族 DARM 来源输入，SHA 不同"
        lines.append(f"| `{row['id']}` | {desc} | `{occurrence['block']}` | `{sha[:16]}` |")
    lines += ["", "原始 NQU64 的 `%50` 是 `68487b9b6095`（2+21 条），在它被独立试融前，"
              "首步选中外层 B2R `B2:B3:B6`，形成 `%merged.bb14` 的 `80f0bef62b48`（3+21 条）。"
              "该快照区域实际出现了两次，均在第 2 个搜索轮。"
              "无约束最小 D 从 42 降到 38，右侧报价从 35 升到 38，§7.2 保留原始。"
              "随后 anchor 采用 normalize-only，最终区域为 `%unify.bb` 的 `52930d576989`（5+21 条），"
              "没有提交该历史结构的 B2B 融合。其余六个 ID 来自不同 SHA 的 DARM 输入或其他 block size 的快照。"]
    return lines


def lud8_section(work, rows, solutions):
    lines = ["", "## LUD8", "",
             "冻结 manifest 中 diagonal 和 internal 的两条轨迹均无 B2B 候选。"
             "perimeter 的 anchor、DARM 轨迹分别记录 4、6 次 B2B 试验。另按历史共同父 IR 重放两条 perimeter 轨迹。"
             "两份输入的 anchor、DARM 最终 TTI 均为 628、681。", "",
             "区域栏默认是保留区域外标记的清理前报价。入口菱形单独用清理后的共同边界报价，"
             "保留两版相同的 workitem/比较前缀，计费从该前缀末端到第一道 barrier 前的 fence。"
             "整核栏始终使用原策略未加标记的清理产物。", "",
             "| 输入 | 来源轨迹 / 轮 / trial | 区域 ID | Anchor 区域 T | DARM 区域 T | DARM 区域 D 收益 | Anchor / DARM kernel TTI |",
             "|---|---|---|---:|---:|---:|---:|"]
    solution = {r["id"]: r for r in solutions}
    for row in rows:
        if not row["case"].startswith("LUD8"):
            continue
        uid = row["region"]["id"]
        scope = row["scope"]
        a, d = (scope[name]["price"]["T"] for name in ("anchor", "darm"))
        if uid in solution:
            a, d = (solution[uid]["cleaned_region"][name]["T"] for name in ("anchor", "darm"))
        kernel = [row["replays"][role]["kernel"]["work_after"] for role in ("anchor", "darm")]
        trial = Path(row["trial"]).parents[2].name
        lines.append(f"| {row['case']} | {row['source_role']} / {row['step']} / {trial} | `{uid[:12]}` | "
                     f"{triplet(a)} | {triplet(d)} | {a[0] - d[0]:+d} | {kernel[0]} / {kernel[1]} |")
    lines += ["", "两条轨迹重复评估同一个入口候选。冻结输入只有这一个可确认的区域 DARM 胜例。"
              "共同父输入也出现同一个位置的胜例，IR 类型拼写不同所以单独求解。"
              "同一父 IR 与候选键只跑一次 ILP。", "",
              "| 输入 / 区域 | 方案 | 配对（load / store） | 未配对推测 / 保护 / 未映射 | 清理后 select / 保护 / 流出 | 清理后区域 T |",
              "|---|---|---:|---:|---:|---:|"]
    for row in solutions:
        r = next(x for x in rows if x["region"] and x["region"]["id"] == row["id"])
        stats = row["darm_alignment"]
        anchor = row["anchor_hint"]
        # Read source opcodes from the outlined IR in the same side order as the hint.
        from collect_step6 import Kernel
        extracted = Kernel(work / "regions" / r["region"]["ir"], "region")
        _, (_, left, right) = next(iter(extracted.branches.items()))
        def opcodes(block):
            return [line.split(" = ")[-1].split()[0] for line in extracted.blocks[block]
                    if not line.startswith("br ")]
        left_ops, right_ops = opcodes(left), opcodes(right)
        anchor_pairs = Counter(left_ops[p["left_index"]] for p in anchor["pairs"])
        darm_pairs = Counter(p["opcode"] for p in stats["pairs"])
        sizes = len(left_ops) + len(right_ops)
        for strategy, pairs, spec, guarded, unknown in (
            ("anchor", anchor_pairs, sizes - 2 * len(anchor["pairs"]), 0, 0),
            ("DARM", darm_pairs, len(stats["speculated"]), len(stats["protected"]), len(stats["unmapped"]))):
            clean = row["cleaned_region"][strategy.lower()]
            lines.append(f"| {row['case']} / `{row['id'][:12]}` | {strategy} | "
                         f"{sum(pairs.values())} ({pairs['load']} / {pairs['store']}) | {spec} / {guarded} / {unknown} | "
                         f"{clean['count'].get('select', 0)} / 0 / {clean['count'].get('phi', 0)} | {triplet(clean['T'])} |")
    lines += ["", "两版入口清理后均无保护段或流出。DARM 的指令报价节省 7 点，select 多花 1 点，净省 6 点。"
              "冻结输入上多配 3 对，访存配对数相同。该区域收益没有抵消同一父 IR 上的整核 32 点差距。"
              "清理前 anchor 有 31 个 select、0 个保护分支、2 个合流 PHI。"
              "DARM 有 38 个 select、23 个保护分支、38 个合流 PHI。"
              "原样投影 DARM 的配对和保护决策后，LLVM 生成桥返回 multi_guard。CP-SAT 仍收到配对决策提示。", "",
              "此次启动时使用 1800 秒上限。收到反馈后提前请求 CP-SAT 返回已有 incumbent 和下界。"
              "复跑脚本现在默认 120 秒。", "",
              "| 输入 / 区域 | 有效初始提示 | 最小 D incumbent / 下界 | §7.2 incumbent / 下界 | 秒数 / 状态 |",
              "|---|---|---|---|---|"]
    differences = []
    rejected = []
    for row in solutions:
        run = row["ilp"]
        d, strategy = (run.get(k, {}) for k in ("min_D", "strategy"))
        lines.append(f"| {row['case']} / `{row['id'][:12]}` | {run.get('anchor_hint', False)} | "
                     f"{d.get('T', '—')} / {d.get('bound', '—')} | {strategy.get('T', '—')} / "
                     f"{strategy.get('bound', '—')} | {run.get('seconds', 0):.1f} / {run['status']} |")
        if run.get("candidates"):
            rejected.append(f"- {row['case']} 访问了 {run['candidates']:,} 个决策，"
                            f"其中 {run.get('cuts', {}).get('multi_guard', 0):,} 个因需要多个保护段被排除，"
                            f"只有 {run['priced_columns']:,} 个改写取得报价。")
        if d.get("T") and d["T"][0] < row["cleaned_region"]["darm"]["T"][0]:
            baseline = row["cleaned_region"]["darm"]
            diffs = triplet([parts(baseline).get(k, 0) - parts(d).get(k, 0) for k in PARTS])
            pair_key = lambda p: (p["left_index"], p["right_index"], p["recipe"])
            a = {pair_key(p) for p in row["darm_alignment"]["pairs"]}
            b = {pair_key(p) for p in d.get("pairs", [])}
            differences.append(f"- `{row['id'][:12]}` 的最小 D incumbent 比 DARM 低 "
                               f"{baseline['T'][0] - d['T'][0]} 点。重合配对 {len(a & b)}，"
                               f"仅 DARM {len(a - b)}，仅 ILP {len(b - a)}。"
                               f"指令、select、控制、流出分项为 {diffs}。"
                               f"ILP 使用 select {d.get('selects', 0)} 个和保护分支 "
                               f"{d.get('guard_branches', 0)} 条。")
    return lines + (["", *rejected] if rejected else []) + (["", *differences] if differences else [])


def evidence_receipt(rows, solved, priced, paths, lud8):
    candidates, problems = [], {}
    for row, result in zip(rows, solved):
        assert (row["parent"], row["candidate"]) == (result["parent"], result["candidate"])
        record = {k: v for k, v in row.items() if k not in ("strategy_record", "replays")}
        roles = {}
        for name, measured in row["replays"].items():
            actual = measured["context"]
            trial = actual.get("record", {})
            roles[name] = {k: v for k, v in measured.items() if k not in ("context", "outlined")}
            roles[name]["context"] = {k: v for k, v in actual.items() if k != "record"}
            roles[name]["context"].update(layout=trial.get("merge_path"), eligible=trial.get("eligible"),
                                          reason=trial.get("reason"),
                                          decisions=trial.get("anchor", {}).get("dataflow_hint"))
        record["replays"] = roles
        if ilp := result.get("ilp"):
            if folder := ilp.get("folder"):
                problems[folder] = ilp
                record["ilp_result"] = folder
            else:
                record["ilp_status"] = ilp
        candidates.append(record)
    return {"context": candidates, "ilp_results": problems,
            "regret": [{k: v for k, v in row.items() if k != "choice"} for row in priced],
            "path_replays": paths, "lud8": lud8}


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("work", type=Path)
    p.add_argument("--output", type=Path, default=RESULTS)
    args = p.parse_args()
    work = args.work
    rows, solved, paths, lud8 = (read(work / n) for n in (
        "context.json", "solved.json", "paths.json", "lud8-solutions.json"))
    priced = choices(rows, solved)
    lines = ["# 第 7 步在 anchor 流程中测量 B2B 遗憾", "",
             "区域代价为 LLVM 24 报价。优先用保留全部区域外指令标记的清理后上下文报价。"
             "其余仅在独立重放能匹配实际 anchor 计划时，用同计划独立 IR 的清理后报价。"
             "有额外出口或需复制的候选保留整核数据。当前独立求解器无法对它们定义相同区域的 T。", "",
             "## 计数和遗憾分布", "",
             "分布写作 代价:次数。正遗憾合计除以 anchor 的最终 kernel TTI。"
             "每次评估均计入，同一个区域可在不同父 IR 或不同轮重复，合计并非可叠加的整核收益。", "",
             "| Case | 评估 / 提交 | 直接可抽取 | 上下文 / 独立可报价 | 已证明 / 未证明 / 无可比 T | 最小 D 分布 | §7.2 分布 | 最小 D / §7.2 正遗憾合计及比例 |",
             "|---|---:|---:|---:|---:|---|---|---|"]
    for case in CASES:
        cases = [r for r in rows if r["case"] == case]
        q = [r for r in priced if r["case"] == case]
        p1, p2 = ([r for r in q if r["objective"] == label and r["optimal"]]
                  for label in ("min_D", "strategy"))
        counts = Counter(r["basis"] for r in q if r["objective"] == "min_D")
        base = read(work / case / "anchor/summary.json")["final_cost"]
        totals = [sum(max(r["regret"], 0) for r in group) for group in (p1, p2)]
        unproved = sum(r["objective"] == "min_D" and not r["optimal"] for r in q)
        lines.append(f"| {case} | {len(cases)} / {sum(r['committed'] for r in cases)} | "
                     f"{sum(r['direct'] for r in cases)} | {counts['context-cleaned']} / "
                     f"{counts['same-plan-outlined-cleaned']} | {len(p1)} / {unproved} / "
                     f"{len(cases)-len(p1)-unproved} | {buckets(p1)} | {buckets(p2)} | " +
                     " / ".join(f"{t} ({t/base:.1%})" for t in totals) + " |")
        if any(r["regret"] < 0 for r in p1):
            print(case, "negative verified min_D", [r["regret"] for r in p1 if r["regret"] < 0])
    lines += ["", "### 有正遗憾的候选", "",
              "差值顺序为指令、select、控制、流出。带 † 的行使用已验证报价的 incumbent，"
              "其差值是目前找到的收益。", "",
              "| Case | 轮 / trial | 区域 ID | 目标 | 计价位置 | D 遗憾 | 分项 |",
              "|---|---|---|---|---|---:|---|"]
    for item in priced:
        if item["regret"] <= 0:
            continue
        row = rows[item["row"]]
        a, _ = comparison_price(row)
        ac, ic = parts(a), parts(item["choice"])
        difference = [ac.get(k, 0) - ic.get(k, 0) for k in PARTS]
        assert sum(difference) == item["regret"], (ac, ic, item)
        label = item["objective"] + ("" if item["optimal"] else "†")
        label_dir = Path(row["trial"]).parents[2].name
        site = "上下文" if item["basis"] == "context-cleaned" else "同布局独立 IR"
        lines.append(f"| {item['case']} | {row['step']} / {label_dir} | `{row['region']['id'][:12]}` | "
                     f"{label} | {site} | {item['regret']} | {triplet(difference)} |")
    lines += ["", "### 未证明的可比候选", ""]
    for case in CASES:
        groups = [[r for r in priced if r["case"] == case and r["objective"] == name and not r["optimal"]]
                  for name in ("min_D", "strategy")]
        if any(groups):
            lines.append(f"- {case} 的 incumbent 分布。最小 D 为 {buckets(groups[0])}，§7.2 为 {buckets(groups[1])}。")
    lines += ["", "### 已证明结果的带符号合计", "",
              "| Case | 最小 D 合计 / 比例 | §7.2 合计 / 比例 |",
              "|---|---:|---:|"]
    for case in CASES:
        base = read(work / case / "anchor/summary.json")["final_cost"]
        signed = [sum(r["regret"] for r in priced
                      if r["case"] == case and r["objective"] == name and r["optimal"])
                  for name in ("min_D", "strategy")]
        lines.append(f"| {case} | {signed[0]} / {signed[0]/base:.1%} | "
                     f"{signed[1]} / {signed[1]/base:.1%} |")
    lines += paths_report(work, paths) + nqu_report() + lud8_section(work, rows, lud8)
    lines += ["", "[逐候选与求解证据](step7-evidence.json.gz) · "
              "[运行记录](../../../regression/records/dataflow-b2b-step7-20261124.md)", ""]
    (args.output / "step7.md").write_text("\n".join(lines))
    evidence = evidence_receipt(rows, solved, priced, paths, lud8)
    (args.output / "step7-evidence.json.gz").write_bytes(gzip.compress(
        (json.dumps(evidence, indent=2) + "\n").encode(), mtime=0))


if __name__ == "__main__":
    main()
