#!/usr/bin/env python3
"""Run the small-corpus tools, keeping unsupported and unfinished cases visible."""
import argparse
from collections import Counter
from concurrent.futures import ThreadPoolExecutor
import csv
import gzip
import json
from pathlib import Path
import re
import runpy
import subprocess

ROOT = Path(__file__).resolve().parents[2]
TESTS = ROOT / "tests/dataflow-b2b"
COSTS = ROOT / "docs/dataflow-b2b/COST_TABLE.json"
DRIVER = runpy.run_path(str(TESTS / "check-micro.py"))
LIMIT = 610


def invoke(argv, timeout=LIMIT):
    try:
        return subprocess.run(argv, capture_output=True, text=True,
                              check=False, timeout=timeout)
    except subprocess.TimeoutExpired:
        return subprocess.CompletedProcess(argv, 124, "", "timeout")


def error(result):
    return " ".join((result.stderr or result.stdout).strip().split())[-600:] or f"exit {result.returncode}"


def read_report(result):
    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError:
        return {"status": "failed", "reason": error(result)}


def host_hash(ir, clang, host, work, *, corpus):
    if re.search(r"\b(?:convergent|asm|atomicrmw|cmpxchg|inttoptr|ptrtoint)\b", ir):
        raise ValueError("host execution excludes convergent, assembly, atomic and pointer casts")
    # AMD and NVVM builtins cannot be lowered to a CPU execution model.
    if re.search(r"@llvm\.(?:amdgcn|nvvm)\.", ir):
        raise ValueError("target-specific LLVM intrinsic")
    ir = re.sub(r'^target triple = "[^"]*"$', f'target triple = "{host}"', ir, flags=re.M)
    ir = re.sub(r'^target datalayout = "[^"]*"\n', '', ir, flags=re.M)
    ir = re.sub(r' "(?:target-cpu|target-features|tune-cpu)"="[^"]*"', '', ir)
    signature = ir
    if corpus:
        match = re.search(r"^define\s+(\w+)\s+@(region)\(([^)]*)\)", ir, re.M)
        if not match:
            raise ValueError("signature outside scalar CPU harness")
        ty, name, parameters = match.groups()
        parts = parameters.split(",")
        # Only lower pointer regions when accesses stay in the allocated
        # arrays. More general GPU pointers require their own input model.
        if "*" in parameters:
            if re.search(r"\b(?:addrspacecast|bitcast).*\*", ir):
                raise ValueError("pointer casts are outside the CPU memory harness")
            for line in ir.splitlines():
                if "getelementptr" not in line:
                    continue
                indices = re.findall(r", i(?:32|64) ([^, )]+)", line)
                if not indices or any(not n.isdecimal() or int(n) >= 16 for n in indices):
                    raise ValueError("extracted GEP index is outside the CPU memory harness")
            ir = re.sub(r"\s+addrspace\(\d+\)(?=\*)", "", ir)
            parameters = re.sub(r"\s+addrspace\(\d+\)(?=\*)", "", parameters)
            parts = parameters.split(",")
        params = ["i1 %C"]
        for index, part in enumerate(parts[1:]):
            array = re.fullmatch(r"\s*\[(\d+) x (i1|i8|i16|i32|i64|float|double)\]\* %\w+\s*", part)
            if array and int(array[1]) <= 16 and index == len(parts) - 2:
                params.append(f"{array[2]}* %out")
            elif re.fullmatch(r"\s*(i1|i8|i16|i32|i64|float|double)\*? %\w+\s*", part):
                params.append(f"{part.strip().split()[0]} %arg{index}")
            else:
                raise ValueError("argument type is outside the CPU harness")
        signature = f"define {ty} @{name}({', '.join(params)}) {{"
    driver = DRIVER["generate_driver"](signature)
    driver = re.sub(r"(\b(?:int(?:8|16|32|64)_t|float|double|_Bool) arg\d+\[ARRAY_SIZE\];)",
                    r"_Alignas(64) \1", driver)
    native = work / "native.ll"
    source = work / "driver.c"
    binary = work / "driver"
    native.write_text(ir)
    source.write_text(driver)
    result = invoke([clang, "-O0", source, native, "-o", binary], timeout=20)
    if result.returncode:
        raise ValueError("host compile failed: " + error(result))
    result = invoke([binary], timeout=10)
    if result.returncode:
        raise ValueError("host execution failed: " + error(result))
    return result.stdout


def compare(source, report, clang, host, work, *, corpus):
    candidates = report.get("pareto_front", [])
    if not candidates:
        return
    try:
        original_ir = source.read_text()
        if re.search(r"\b(?:undef|poison)\b", original_ir):
            raise ValueError("original IR has undef/poison; byte-for-byte output is not defined")
        original = host_hash(original_ir, clang, host, work, corpus=corpus)
    except ValueError as exc:
        for row in candidates:
            row["semantic_validation"] = {"status": "unsupported", "reason": str(exc)}
        return
    for row in candidates:
        try:
            actual = host_hash((work / row["ir"]).read_text(), clang, host, work, corpus=corpus)
            row["semantic_validation"] = {"status": "pass" if actual == original else "mismatch",
                                          "original_hashes": original.splitlines(),
                                          "candidate_hashes": actual.splitlines()}
        except ValueError as exc:
            row["semantic_validation"] = {"status": "unsupported", "reason": str(exc)}


def baselines(source, args, work):
    catalog = work / "catalog"
    common = [args.engine, "--ir", source, "--function", "region"]
    result = invoke([*common, "--out", work / "unused.ll",
                     "--debug-dir", catalog, "--catalog-only", "1"], timeout=20)
    if result.returncode:
        return {name: {"status": "catalog_failed", "reason": error(result)}
                for name in ("anchor", "darm")}
    rows = json.loads((catalog / "catalog.json").read_text())["candidates"]
    if len(rows) != 1:
        return {name: {"status": "no_single_pair", "reason": f"catalog had {len(rows)} candidates"}
                for name in ("anchor", "darm")}
    pair = rows[0]
    options = [flag for field in ("split", "left", "right")
               for flag in ("--" + field, pair[field])]
    scores = {}
    for strategy in ("anchor", "darm"):
        output = work / (strategy + ".ll")
        result = invoke([*common, *options, "--b2b-strategy", strategy,
                         "--tti-worker", args.tti_worker, "--out", output,
                         "--debug-dir", work / strategy, "--ir-snapshots", "compact"], timeout=30)
        if output.is_file() and result.returncode == 0:
            scores[strategy] = read_report(invoke([args.evaluator, output, COSTS], timeout=20))
            scores[strategy].pop("operations", None)
        else:
            scores[strategy] = {"status": "fusion_rejected", "reason": error(result)}
    return scores


def analyze(item, args, host, corpus):
    key, source = item
    path = args.work / ("corpus" if corpus else "micro") / key
    path.mkdir(parents=True)
    if source.suffix == ".gz":
        original = path / "input.ll"
        original.write_bytes(gzip.decompress(source.read_bytes()))
        source = original
    result = invoke([args.solver, source, COSTS, path])
    report = read_report(result)
    if result.returncode:
        report.update(complete=False, reason=report.get("reason") or error(result))
        report["original_T"] = read_report(invoke([args.evaluator, source, COSTS, "--original"]))            .get("T")
    compare(source, report, args.clang, host, path, corpus=corpus)
    if corpus:
        report["baselines"] = baselines(source, args, path)
    return key, report


def score(report):
    candidates = report.get("pareto_front", [])
    selected = [row for row in candidates
                if row.get("semantic_validation", {}).get("status") != "mismatch"]
    base = report.get("original_T")
    if base:
        selected.append({"T": base})
    best = min(selected, key=lambda row: row["T"], default={})
    conservative = next((row["T"] for row in selected
                         if base and row["T"][0] < base[0] and row["T"][1] <= base[1]
                         and row["T"][2] <= base[2]), base)
    return best, conservative


def summary(output, rows, reports, micro):
    def formatted(vector):
        return ",".join(map(str, vector)) if vector else ""
    columns = ["id", "case", "distinct_sources", "condition_source", "memory",
               "original_T", "best_found_T", "conservative_T", "anchor_T", "darm_T",
               "anchor_gap_to_best_D", "darm_gap_to_best_D", "complete", "reason",
               "anchor_status", "darm_status"]
    features = Counter()
    table = json.loads(COSTS.read_text())
    statuses = {name: Counter() for name in ("anchor", "darm")}
    gaps = {name: [] for name in ("anchor", "darm")}
    gain = conservative_gain = 0
    with (output / "step2-small.tsv").open("w") as file:
        writer = csv.DictWriter(file, fieldnames=columns, delimiter="\t", lineterminator="\n")
        writer.writeheader()
        for item in rows:
            report = reports[item["id"]]
            best, conservative = score(report)
            t, base = best.get("T"), report.get("original_T")
            gain += bool(t and base and t[0] < base[0])
            conservative_gain += bool(base and conservative and conservative[0] < base[0])
            for feature, value in best.get("features", {}).items():
                features[feature] += bool(value)
            cases = sorted({occ["case"] for occ in item["occurrences"]})
            row = dict(id=item["id"], case=";".join(cases), distinct_sources=item["distinct_sources"],
                       condition_source=json.dumps(item["condition_source"], ensure_ascii=False),
                       memory=bool(item["loads"] or item["stores"]), original_T=formatted(base),
                       best_found_T=formatted(t), conservative_T=formatted(conservative),
                       complete=report["complete"], reason=report.get("reason", ""))
            for strategy in ("anchor", "darm"):
                comparison = report["baselines"][strategy]
                vector = comparison.get("T")
                gap = vector[0] - t[0] if vector and t else None
                row[strategy + "_T"] = formatted(vector)
                row[strategy + "_gap_to_best_D"] = gap
                row[strategy + "_status"] = comparison["status"]
                statuses[strategy][comparison["status"]] += 1
                if gap is not None:
                    detail = {}
                    if "guard_branches" in best:
                        for field, label, weight in (
                            ("guard_branches", "分支", table["guard_segment_control"]),
                            ("escaping_values", "合流", table["guard_escape_merge"]),
                            ("selects", "select", table["op"]["select"]),
                        ):
                            detail[label] = (comparison[field] - best[field]) * weight
                        detail["其余操作"] = gap - sum(detail.values())
                    gaps[strategy].append((gap, item["id"], best.get("features", {}), detail))
            writer.writerow(row)

    scoreable = sum(bool(r.get("original_T")) for r in reports.values())
    semantic = Counter(solution["semantic_validation"]["status"]
                       for data in (reports, micro) for r in data.values()
                       for solution in r.get("pareto_front", []))
    lines = [
        "# Dataflow B2B 第 2 步 Small 档", "",
        f"共尝试 {len(rows)} 个区域，{scoreable} 个原始区域可以按抽象代价表计费。"
        f"完备证明数为 {sum(r['complete'] for r in reports.values())}。",
        "",
        f"在已找到且未出现语义不一致的方案中，{gain} 个区域改善了 D 场景，"
        f"{conservative_gain} 个满足保守策略。表内 best_found_T 是当前候选中的最小 D。"
        "语义尚未验证的候选仍保留在原始结果中，所有搜索都保留未完成状态。",
        "",
        "## 现有策略", "",
    ]
    for strategy in gaps:
        comparisons = gaps[strategy]
        lines.append(f"- {strategy} 的可计费比较为 {len(comparisons)}，"
                     f"其中 {sum(gap == 0 for gap, *_ in comparisons)} 个达到当前最佳 D。"
                     f"运行状态为 `{dict(sorted(statuses[strategy].items()))}`。")
    lines.extend(["", "## 候选方案特征", ""])
    for name in ("crossed", "commute", "cmp_swap", "shared_select", "guard_cluster", "speculate_then_select"):
        lines.append(f"- {name} 出现在 {features[name]} 个已选候选中。")
    lines.extend(["", "## 最大已观测差距", "",
                  "按计费项分解差值。候选特征的单独贡献尚未做消融验证。", ""])
    for strategy in gaps:
        lines.append(f"### {strategy}")
        lines.append("")
        ranked = sorted(gaps[strategy], key=lambda row: (-row[0], row[1]))[:10]
        if not ranked:
            lines.append("无可计费比较。")
        for gap, uid, use, detail in ranked:
            names = ", ".join(name for name, used in use.items() if used)
            components = "、".join(f"{name} {value:+d}" for name, value in detail.items() if value)
            suffix = f"代价差构成为 {components}。" if components else ""
            lines.append(f"- `{uid}` 的 D 差距为 {gap}，候选特征为 {names or '无'}。{suffix}")
        lines.append("")
    lines.append(f"前沿代表方案的主机验证（含微型测试）为 `{dict(sorted(semantic.items()))}`。")
    (output / "step2-summary.md").write_text("\n".join(lines) + "\n")


def main(args):
    args.work.mkdir(parents=True, exist_ok=True)
    args.output.mkdir(parents=True, exist_ok=True)
    host = invoke([args.clang, "-dumpmachine"]).stdout.strip()
    if not host:
        raise ValueError("cannot get host triple from clang")
    corpus = TESTS / "corpus"
    rows = [row for row in json.loads((corpus / "inventory-b2b.json").read_text())["regions"]
            if row["size_bucket"] == "small"]
    items = [(row["id"], corpus / row["ir"]) for row in rows]
    micro = [(ir.stem, ir) for ir in sorted((TESTS / "micro").glob("*.ll"))]
    with ThreadPoolExecutor(args.jobs) as pool:
        micro_reports = dict(pool.map(lambda item: analyze(item, args, host, False), micro))
        reports = dict(pool.map(lambda item: analyze(item, args, host, True), items))
    for name, result in (("micro", micro_reports), ("small", reports)):
        (args.output / f"step2-{name}-raw.json").write_text(
            json.dumps(result, ensure_ascii=False, indent=2) + "\n")
    summary(args.output, rows, reports, micro_reports)
    print(f"Recorded {len(micro_reports)} micro cases and {len(reports)} small corpus regions")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ("work", "output", "solver", "evaluator", "engine", "tti-worker", "clang"):
        parser.add_argument("--" + name, type=Path, required=True)
    parser.add_argument("--jobs", type=int, default=4)
    main(parser.parse_args())
