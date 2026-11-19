#!/usr/bin/env python3
"""Inventory generated, highest-scoring and committed DP1 B2B layouts."""

import argparse
from collections import defaultdict
from dataclasses import dataclass
import json
from pathlib import Path
import re


@dataclass
class Counts:
    layouts: int = 0
    duplicates: int = 0
    scored: int = 0
    best: int = 0
    selected: int = 0
    committed: int = 0


def family(layout):
    name = layout.removeprefix("single-branch-")
    return re.sub(r"-\d+$", "", name.removesuffix("-resplit"))


def read(path):
    return json.loads(path.read_text())


def audit(case, root, families, commits, examples):
    summary = read(root / "summary.json")
    if summary["status"] != "completed" or summary["b2b_strategy"] != "dp1":
        raise ValueError(f"{case}: expected a completed DP1 run")
    selected = {}
    rounds = {}
    commit_number = 0
    for row in summary["rounds"]:
        for attempt in row["attempts"]:
            if attempt.get("directory"):
                rounds[Path(attempt["directory"]).name] = row["iteration"]
        if row["selected"]:
            commit_number += 1
            selected[Path(row["selected"]).name] = (commit_number, row["iteration"])
    if commit_number != summary["commits"] or len(selected) != commit_number:
        raise ValueError(f"{case}: invalid commit sequence")

    local = defaultdict(Counts)
    seen_selected = set()
    missing = []
    for path in sorted(root.rglob("trial.json")):
        trial = read(path)
        request = path.relative_to(root).parts[0]
        if request in selected:
            seen_selected.add(request)
        if trial["fusion_plan"]["kind"] != "B2B":
            continue
        layout = trial["merge_path"]
        rows = trial["layout_profitability"]
        if not rows or any("duplicate" not in row for row in rows):
            if layout.startswith("single-branch-"):
                missing.append(str(path.relative_to(root)))
            continue
        scored = [
            row for row in rows
            if not row["duplicate"] and row["score_result"]["status"] == "scored"
        ]
        high = max((row["score_result"]["total"] for row in scored), default=None)
        winner = trial["score_result"]
        if high is not None and (winner["status"] != "scored" or winner["total"] != high):
            raise ValueError(f"{path}: candidate winner does not have the highest score")
        for row in rows:
            label = row["layout"]
            name = family(label)
            counts = local[name]
            counts.layouts += 1
            counts.duplicates += row["duplicate"]
            if row in scored:
                counts.scored += 1
                if row["score_result"]["total"] == high:
                    counts.best += 1
                    examples.setdefault(name, ("best", case, rounds.get(request, "—"), request, label, trial["candidate"]))
        if winner["status"] == "scored":
            local[family(layout)].selected += 1
        if request in selected:
            number, round_number = selected[request]
            name = family(layout)
            if winner["status"] != "scored":
                raise ValueError(f"{path}: committed B2B without a score")
            local[name].committed += 1
            metrics = winner["metrics"]
            commits.append((case, number, round_number, request, trial["candidate"], layout,
                            metrics["non_cfg_work_gain"], metrics["cfg_phi_gain"]))
            if examples.get(name, ("",))[0] != "commit":
                examples[name] = ("commit", case, round_number, request, layout, trial["candidate"])

    if missing:
        raise ValueError(
            f"{case}: {len(missing)} DP1 trials lack layout diagnostics (first {missing[0]}). "
            "Collect layout_profitability before drawing pruning conclusions."
        )
    if seen_selected != set(selected):
        raise ValueError(f"{case}: missing debug JSON for {sorted(set(selected) - seen_selected)}")
    for name, counts in local.items():
        total = families[name]
        for field in vars(counts):
            setattr(total, field, getattr(total, field) + getattr(counts, field))
    return local, summary


def report(cases, baseline):
    families = defaultdict(Counts)
    commits, case_rows = [], []
    examples = {}
    for case, root in cases:
        local, summary = audit(case, root, families, commits, examples)
        case_rows.append((case, local, summary))
    lines = [
        "# B2B 布局使用统计",
        "",
        f"默认版本 A 为 `{baseline}`。vLLM 64K 和 128K 共享同一个编译产物，布局只统计一次。",
        "生成数包含清理后重复的布局。候选内第一包含并列，选中数按运行时的并列顺序仅计一次。"
        "最终提交按 driver 的 selected 记录连接候选与轮次。",
        "",
        "| 布局族 | 生成 | 重复 | 已评分 | 候选内第一含并列 | 候选内选中 | 最终提交 |",
        "| --- | ---: | ---: | ---: | ---: | ---: | ---: |",
    ]
    for name, counts in sorted(families.items()):
        lines.append(f"| `{name}` | " + " | ".join(map(str, vars(counts).values())) + " |")
    lines.extend([
        "",
        "| Case | B2B 布局生成 | B2B 布局评分 | B2B 最终提交 | 全部提交 | 审计运行秒数 |",
        "| --- | ---: | ---: | ---: | ---: | ---: |",
    ])
    for case, rows, summary in case_rows:
        totals = [sum(getattr(c, key) for c in rows.values())
                  for key in ("layouts", "scored", "committed")]
        lines.append(f"| {case} | " + " | ".join(map(str, totals)) +
                     f" | {summary['commits']} | {summary['elapsed_ms'] / 1e3:.3f} |")
    lines.extend([
        "",
        "## 裁剪判据",
        "",
        "- 生成过、从未获最高分且未提交的布局族" +
        "".join(f" `{k}`" for k, v in sorted(families.items()) if not v.best and not v.committed),
        "- 获过最高分但未提交的布局族" +
        "".join(f" `{k}`" for k, v in sorted(families.items()) if v.best and not v.committed),
        "",
        "## 布局实例",
        "",
        "| 布局族 | 观察 | Case | 轮次 | 试跑目录 | 布局 | 候选 |",
        "| --- | --- | --- | ---: | --- | --- | --- |",
    ])
    for name, fields in sorted(examples.items()):
        lines.append(f"| `{name}` | " + " | ".join(f"`{x}`" for x in fields) + " |")
    lines.extend([
        "",
        "## 已提交的 B2B",
        "",
        "| Case | 第几次提交 | 轮次（从 0 开始） | 试跑目录 | 候选 | 布局 | 非 CFG 工作收益 | CFG／PHI 收益 |",
        "| --- | ---: | ---: | --- | --- | --- | ---: | ---: |",
    ])
    for case, number, iteration, request, candidate, layout, work, cfg in sorted(commits):
        lines.append(f"| {case} | {number} | {iteration} | `{request}` | `{candidate}` | "
                     f"`{layout}` | {work:g} | {cfg:g} |")
    return "\n".join(lines) + "\n"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--baseline", required=True)
    parser.add_argument("--out", required=True, type=Path)
    parser.add_argument("runs", metavar="CASE=DIRECTORY", nargs="+")
    args = parser.parse_args()
    cases = []
    for run in args.runs:
        case, separator, directory = run.partition("=")
        if not all((case, separator, directory)):
            parser.error(f"expected CASE=DIRECTORY: {run}")
        cases.append((case, Path(directory)))
    args.out.write_text(report(cases, args.baseline))


if __name__ == "__main__":
    main()
