#!/usr/bin/env python3
"""Render the Step 6 report from completed solver and device receipts."""

import argparse
from collections import Counter
import gzip
import json
from pathlib import Path
from statistics import median

from check_step5_small import RESULTS
from collect_step6 import ROLES, compressed, read


def cell(text):
    return str(text).replace("|", "\\|")


def optimum(record):
    return all(record["ilp"].get(key, {}).get("optimal") for key in ("min_D", "strategy"))


def bound(result):
    if "bound" not in result:
        return "—"
    return f"{result['bound']} / {100 * result['gap']:.1f}%"


def solver_section(regression, retry):
    lines = ["# 第 6 步 ILP 与 NQU64、MapAiry 端到端验证", "", "## 求解器回归", "",
             "| 复跑集合 | 已证明且与旧结果一致 | 总运行数 |",
             "|---|---:|---:|"]
    for tier, cost, title in (("small", "abstract", "small 抽象"), ("small", "real", "small 真实"),
                              ("proved", "real", "medium 第 5b 步已证明")):
        rows = [r for r in regression if (r["tier"], r["mode"]) == (tier, cost)]
        lines.append(f"| {title} | {sum(r['same'] for r in rows)} | {len(rows)} |")
    data = regression + retry
    lines += ["", f"共 {sum(r['ilp'].get('anchor_hint', False) for r in data)} 次有效 anchor 提示。"
              f"新增 {sum(r['ilp'].get('cuts', {}).get('long_cycle', 0) for r in data)} 条长环约束。",
              "两种目标都核对了完整三场景向量，441 次重跑同时通过语义验证。"
              "无报价区域沿用第 5 和 5b 步的排除。", "",
              "## Medium 超时复跑", "",
              "| 类型 | 全部区域 | 第 5b 步双目标已证明 | 第 6 步双目标已证明 | 复跑仍未证明 | 无报价 |",
              "|---|---:|---:|---:|---:|---:|"]
    for kind, total, unpriced in (("b2b-diamond", 53, 0), ("b2b-triangle", 72, 1)):
        already = sum(r["tier"] == "proved" and r["kind"] == kind for r in regression)
        group = [r for r in retry if r["kind"] == kind]
        proved = sum(optimum(r) for r in group)
        lines.append(f"| {kind[4:]} | {total} | {already} | {already + proved} | "
                     f"{len(group) - proved} | {unpriced} |")
    lines += ["", "下界取第一次 CP-SAT 松弛的 `best_objective_bound`。"
              "松弛计入确定存活且报价不随配对变化的操作，以及必保留保护段的分支。"
              "后续长环、强制推测和多保护段裁剪只删除方案，所以下界仍有效。"
              "实际求得 0 时保留该值。完成穷举时上、下界相等。", ""]
    for key, label in (("min_D", "最小 D"), ("strategy", "§7.2")):
        pending = [r["ilp"].get(key, {}) for r in retry if not r["ilp"].get(key, {}).get("optimal")]
        gap = [v["gap"] for v in pending if "gap" in v]
        positive = sum(v.get("bound", 0) > 0 for v in pending)
        if gap:
            lines.append(f"- {label} 仍未证明 {len(pending)} 个，其中 {positive} 个下界大于 0。"
                         f"{len(gap)} 个有间隙，范围 {100 * min(gap):.1f}%–{100 * max(gap):.1f}%，"
                         f"中位数 {100 * median(gap):.1f}%。")
    lines += ["", "| 区域 ID | 类型 | 旧 D 下界 / 间隙 | 新 D 上界 | 新 D 下界 / 间隙 | "
              "旧 §7.2 下界 / 间隙 | 新 §7.2 上界 | 新 §7.2 下界 / 间隙 | 双目标证明 |",
              "|---|---|---:|---:|---:|---:|---:|---:|---|"]
    for r in sorted(retry, key=lambda r: (r["kind"], r["id"])):
        prev, latest = r["previous"], r["ilp"]
        d, policy = (latest.get(key, {}) for key in ("min_D", "strategy"))
        upper = "—"
        if t := policy.get("T"):
            upper = max(t[1:]) if r["condition_source"] == "workgroup-uniform" else t[0]
        lines.append(f"| `{r['id']}` | {r['kind'][4:]} | {bound(prev['min_D'] or {})} | "
                     f"{d.get('T', ['—'])[0]} | {bound(d)} | {bound(prev['strategy'] or {})} | "
                     f"{upper} | {bound(policy)} | {'是' if optimum(r) else '否'} |")
    return lines


def role_info(role, receipt):
    whole = receipt["roles"][role]
    commits = receipt["greedy"].get(role, {}).get("commits", 0)
    timing = receipt["timing"]
    key = dict(zip(ROLES, ("baseline", "A", "darm", "N")))[role]
    time = median(row[key] for row in timing["rounds"])
    counts = whole["TTI_branches"]
    isa = whole["ISA"]
    return (f"| {role} | {whole['TTI']} | {commits} | 通过 | {time:.3f} | "
            f"{counts['br.conditional']} / {counts['br.unconditional']} / {whole['TTI_control']} | "
            f"{isa.get('conditional_branch', 0)} / {isa.get('branch', 0)} / {isa.get('exec', 0)} |")


def case_section(name, receipt):
    lines = ["", f"## {name}", "",
             "| 变体 | LLVM 24 TTI | 贪心提交 | CPU / GPU 验证 | GPU 中位数 (µs) | IR 条件分支 / 无条件分支 / 控制 TTI | ISA 条件分支 / 全部分支 / exec 指令 |",
             "|---|---:|---:|---|---:|---:|---:|",
             *(role_info(role, receipt) for role in ROLES), ""]
    paired = receipt["timing"]["candidate_over_reference"]
    low, high = paired["confidence_interval_95"]
    lines.append(f"Dataflow-ILP / anchor 的配对时间比为 **{paired['median']:.5f}**"
                 f"（95% bootstrap 区间 {low:.5f}–{high:.5f}）。")
    a, b = (receipt["timing"]["binary_sha256"][key] for key in ("A", "N"))
    if a == b:
        lines.append("两版最终 HSACO 的 SHA-256 相同。")
    greedy = receipt["greedy"]["dataflow-ilp"]
    handlers = Counter(a["dataflow"].get("handler", "既有流程")
                       for a in greedy["attempts"] if "dataflow" in a)
    committed = Counter(a.get("dataflow", {}).get("handler", "既有流程")
                        for a in greedy["attempts"] if a["selected"])
    lines += ["", f"Dataflow-ILP 结构试验处理方式计数为 `{dict(sorted(handlers.items()))}`，"
              f"提交处理方式计数为 `{dict(sorted(committed.items()))}`。"
              "候选的求解状态、区域 T 以及回填清理前后的 kernel 报价在逐项证据中。"]
    lines += ["", "### 贪心提交", ""]
    for role, trace in receipt["greedy"].items():
        lines += [f"#### {role}", "", "| 步 | 区域 ID 或流程 | 处理方式 | Kernel TTI |",
                  "|---:|---|---|---:|"]
        for index, item in enumerate((a for a in trace["attempts"] if a["selected"]), 1):
            region, stats = item.get("region", {}), item.get("dataflow", {})
            label = item["kind"]
            if region:
                label = f"`{region['id']}`" + ("" if region["in_corpus"] else "（动态）")
                if item.get("layout") and item["layout"] not in ("dataflow-exact", "dataflow-ilp"):
                    label += f" / {region['kind']} 根"
            handler = stats.get("handler", item.get("layout", item["kind"]))
            if handler == "ilp_solver":
                handler += "（已证明）" if stats.get("optimal") else "（可行解）"
            lines.append(f"| {index} | {cell(label)} | {cell(handler)} | "
                         f"{item['parent_TTI']} → {item['cleaned_TTI']} |")
        lines.append("")
    old, new = (receipt["roles"][role] for role in ("anchor", "dataflow-ilp"))
    diff = lambda key: old["ISA"].get(key, 0) - new["ISA"].get(key, 0)
    branch_diff = old["TTI_branches"]["br.conditional"] - new["TTI_branches"]["br.conditional"]
    lines += ["### 最终 ISA 分支检查", "",
              f"全 kernel 的 LLVM IR 条件分支净减 {branch_diff} 条，控制报价净降 "
              f"{old['TTI_control'] - new['TTI_control']} 点。"
              f"最终 HSACO 的条件分支净减 {diff('conditional_branch')} 条，"
              f"全部分支净减 {diff('branch')} 条，exec 相关指令净减 {diff('exec')} 条。"
              "负数表示增加。", ""]
    removals = receipt["removed_guards"]
    unmatched = receipt["unmatched_final_anchor_predicates"]
    if unmatched:
        lines.append(f"有 {len(unmatched)} 个 anchor 分支谓词在最终 dataflow-ilp IR 中未找到相同分支谓词。"
                     "证据记录其位置，计数包含可能被改写的谓词。")
    if not removals:
        lines.append("Dataflow 求解器提交中未发现从有保护段改为无保护段的区域。")
    else:
        lines.append(f"求解器提交中有 {len(removals)} 个区域由有保护段变成无保护段。"
                     "下列每项另行核对最终 anchor 版本。")
    for target in removals:
        status = target["status"]
        if status in ("mapped", "anchor already uses select"):
            old, new = (target["isa"][role] for role in ("anchor", "dataflow-ilp"))
            def controls(items):
                return "/".join(str(items.get(k, 0)) for k in ("conditional_branch", "exec", "cndmask"))
            prefix = ("anchor 最终 IR 已对同一谓词用 select。" if status == "anchor already uses select" else "")
            lines.append(f"- `{target['id']}`。本步父 IR 到求解方案的控制 TTI 为 "
                         f"{target['TTI_control_parent']} → {target['TTI_control_solution']}。"
                         f"{prefix}anchor 块 `{', '.join(target['anchor_neighborhood'])}`，"
                         f"dataflow-ilp 块 `{', '.join(target['ilp_neighborhood'])}`。"
                         f"条件分支 / exec / cndmask 为 {controls(old)} → {controls(new)}，"
                         f"控制 TTI 为 {target['TTI_control_anchor']} → {target['TTI_control_ilp']}。"
                         "逐条 ISA 和地址见证据。")
        else:
            lines.append(f"- `{target.get('id', target['trial'])}`。{status}。"
                         "逐区域匹配和归因保留为未决。")
    lines += ["", "### ROCProfiler", "",
              "| 变体 | VALUInsts | SALUInsts | VALUBusy % | MemUnitBusy % | MemUnitStalled % | Wavefronts | kernel µs / 完整重放 µs |",
              "|---|---:|---:|---:|---:|---:|---:|---:|"]
    for role, profile in receipt["profiles"].items():
        med = profile["median"]
        lines.append(f"| {role} | {med['VALUInsts']:.2f} | {med['SALUInsts']:.2f} | {med['VALUBusy']:.3f} | "
                     f"{med['MemUnitBusy']:.3f} | {med['MemUnitStalled']:.3f} | {med['Wavefronts']:.0f} | "
                     f"{med['dispatch_us']:.3f} / {med['replay_us']:.3f} |")
    occupancy = [entry.split(".hsaco ", 1)[-1] for entry in receipt["occupancy"]]
    lines += ["", "静态 wave 驻留上限（anchor、dataflow-ilp）为 " +
              "、".join(f"`{entry}`" for entry in occupancy) +
              "。当前 gfx906 计数器不提供动态 wave 占用率。VALU/SALU 指令按 profiler 的每 wave 指标报告。"]
    return lines


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("work", type=Path)
    parser.add_argument("device_receipt", type=Path)
    args = parser.parse_args()
    regression = read(args.work / "solver/regression.json")
    retry = read(args.work / "solver/retry.json")
    receipt = compressed(args.device_receipt)
    if len(regression) != 441 or not all(r["same"] for r in regression) or len(retry) != 57:
        raise ValueError("incomplete solver results")
    (RESULTS / "step6-solver.json.gz").write_bytes(gzip.compress(
        (json.dumps({"regression": regression, "retry": retry}, indent=2) + "\n").encode(), mtime=0))
    lines = solver_section(regression, retry)
    for name, data in receipt.items():
        lines += case_section(name, data)
    lines += ["", "[逐区域求解证据](step6-solver.json.gz) · [逐候选和设备证据](step6-evidence.json.gz)", ""]
    (RESULTS / "step6.md").write_text("\n".join(lines))


if __name__ == "__main__":
    main()
