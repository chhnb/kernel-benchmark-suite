#!/usr/bin/env python3
"""Extract, verify, and count regions from a source manifest."""

import argparse
from collections import Counter, defaultdict
from concurrent.futures import ThreadPoolExecutor
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
from tempfile import TemporaryDirectory

from collect_sources import ROOT, load_ir

KINDS = ("b2b-diamond", "b2b-triangle", "b2r", "r2r", "other")
B2B = set(KINDS[:2])
COSTS = ROOT / "docs/dataflow-b2b/COST_TABLE.json"
MAX_IR_FILE = 1_000_000


def dump_inventory(path, regions, failures):
    with path.open("w") as out:
        out.write('{"regions":[\n')
        for index, region in enumerate(regions):
            if index:
                out.write(",\n")
            json.dump(region, out, ensure_ascii=False, separators=(",", ":"))
        out.write('\n],"source_errors":')
        json.dump(failures, out, ensure_ascii=False)
        out.write("}\n")


def write_summary(path, manifest, regions, failures):
    occurrence_counts = Counter()
    unique = defaultdict(set)
    cases = {(row["category"], row["case"]) for row in manifest["sources"]}
    cross_counts = Counter()
    cross_unique = defaultdict(set)
    extraction_count = sum("ir" in region for region in regions)
    for region in regions:
        kind = region["kind"]
        for occ in region["occurrences"]:
            for group in ((occ["category"], occ["case"]), (occ["category"], "全部"), ("全部", "全部")):
                key = (*group, kind)
                occurrence_counts[key] += 1
                unique[key].add(region["id"])
            if kind in B2B:
                key = (region["size_bucket"], occ["condition_source"],
                       "有" if region["loads"] or region["stores"] else "无")
                cross_counts[key] += 1
                cross_unique[key].add(region["id"])

    def line(category, case):
        cells = []
        for kind in KINDS:
            key = category, case, kind
            cells.append(f"{occurrence_counts[key]} / {len(unique[key])}")
        return f"| {category} | {case} | {' | '.join(cells)} |"

    source_counts = Counter(row["category"] for row in manifest["sources"])
    total = sum(occurrence_counts["全部", "全部", kind] for kind in KINDS)
    lines = [
        "# Dataflow B2B 输入区域语料库",
        "",
        f"清单包含 {sum(source_counts.values())} 条来源记录，扫描得到 {total} 处条件分支区域、"
        f"{len(regions)} 个唯一区域。{extraction_count} 个 B2B 区域已单独保存并经过 LLVM 12 verifier。",
        "",
        "## 按来源和 case 计数",
        "",
        "每格依次为出现次数和结构去重后的数量。同一区域可以出现在不同来源或 case，"
        "所以各行的去重数可有重叠。每个来源的同一模块扫描其全部已定义函数。",
        "",
        "| 来源 | case | " + " | ".join(KINDS) + " |",
        "| --- | --- | ---: | ---: | ---: | ---: | ---: |",
    ]
    for category in ("darm", "project", "snapshot"):
        lines.append(line(category, "全部"))
        lines.extend(line(c, case) for c, case in sorted(cases) if c == category)
    lines.extend([
        line("全部", "全部"),
        "",
        "## B2B 交叉统计",
        "",
        "按每次出现的条件来源计数。同一个结构在不同条件来源分组中可分别出现。",
        "",
        "| 规模 | condition_source | load 或 store | 出现次数 | 唯一区域 |",
        "| --- | --- | --- | ---: | ---: |",
    ])
    for size in ("small", "medium", "large"):
        for condition in ("data", "thread-pattern", "workgroup-uniform"):
            for memory in ("无", "有"):
                key = size, condition, memory
                lines.append(f"| {size} | {condition} | {memory} | {cross_counts[key]} | {len(cross_unique[key])} |")
    lines.extend(["", "## 未收录或无法扫描的输入", ""])
    for row in [*manifest["excluded"], *failures]:
        label = row["case"] + (f" block size {row['block_size']}" if row.get("block_size") is not None else "")
        message = str(row.get("reason", "")).splitlines()
        lines.append(f"- {row['category']} / {label}。{' '.join(message[:2])}")
    lines.extend(["", "## 抽取情况", ""])
    omitted = [region for region in regions if region["kind"] in B2B and "ir" not in region]
    if omitted:
        lines.append(f"{len(omitted)} 个 B2B 结构仅有清单条目。")
        for region in omitted:
            reason = " ".join(region["extraction_error"].strip().splitlines()[:2])
            lines.append(f"- `{region['id']}`。{reason}")
    else:
        lines.append("所有 B2B 结构均有 IR 文件。b2r、r2r 和 other 的位置和结构见 `inventory.json`。")
    path.write_text("\n".join(lines) + "\n")


def extract_one(source, extractor, scratch):
    data = load_ir(source)
    sha = source["sha256"]
    if hashlib.sha256(data).hexdigest() != sha:
        raise ValueError(f"source changed since collection: {source['path']}")
    work = scratch / sha
    work.mkdir()
    native = work / "input.ll"
    native.write_bytes(data)
    result = subprocess.run([extractor, native, COSTS, work / "ir"],
                            capture_output=True, text=True)
    if result.returncode and (result.returncode != 1 or not result.stderr):
        raise RuntimeError(f"extractor failed for {source['path']}: {result.returncode}\n{result.stderr}")
    return sha, result


def build(args):
    manifest = json.loads(args.sources.read_text())
    by_sha = defaultdict(list)
    for index, source in enumerate(manifest["sources"]):
        by_sha[source["sha256"]].append((index, source))
    inventory = {}
    failures = []
    dest = args.output / "regions"
    dest.mkdir(parents=True, exist_ok=False)

    with TemporaryDirectory(prefix="extract-", dir=args.work) as directory, ThreadPoolExecutor(args.jobs) as pool:
        scratch = Path(directory)

        def extract(source):
            return extract_one(source, args.extractor, scratch)

        inputs = [sources[0][1] for sources in by_sha.values()]
        for index, (sha, result) in enumerate(pool.map(extract, inputs), 1):
            if result.returncode:
                reason = result.stderr.replace(str(scratch / sha / "input.ll"), "<source>").strip()
                failures.extend({**item, "reason": reason} for _, item in by_sha[sha])
                continue
            for line in result.stdout.splitlines():
                row = json.loads(line)
                site = row.pop("occurrence")
                region_id = row["id"]
                filename = row.get("ir")
                if region_id not in inventory:
                    if filename:
                        data = (scratch / sha / "ir" / filename).read_bytes()
                        if len(data) > MAX_IR_FILE:
                            row["ir"] += ".gz"
                            data = gzip.compress(data, mtime=0)
                        (dest / row["ir"]).write_bytes(data)
                        row["ir"] = "regions/" + row["ir"]
                    inventory[region_id] = {**row, "occurrences": []}
                region = inventory[region_id]
                for key in ("kind", "left_ops", "right_ops", "num_outputs", "loads", "stores",
                            "convergent", "common_opcodes", "structure"):
                    if region[key] != row[key]:
                        raise ValueError(f"structural ID {region_id} disagrees on {key}")
                # Fold and speculation can depend on facts available in the
                # original module which the extracted signature abstracts.
                site = {**site, "original_folds": row["original_folds"],
                        "fold_reason": row["fold_reason"], "unsafe_to_speculate": row["unsafe_to_speculate"]}
                for source_index, alias in by_sha[sha]:
                    occurrence = {**site, "category": alias["category"], "case": alias["case"],
                                  "source_sha256": sha, "source_index": source_index}
                    region["occurrences"].append(occurrence)
            if index % 100 == 0:
                print(f"Scanned {index}/{len(inputs)} distinct input hashes", flush=True)

        def verify(path):
            if path.suffix != ".gz":
                subprocess.run([args.opt, "-verify", "-disable-output", path], check=True)
            else:
                data = gzip.decompress(path.read_bytes())
                subprocess.run([args.opt, "-verify", "-disable-output", "-"], input=data, check=True)

        paths = sorted(dest.iterdir())
        for _ in pool.map(verify, paths):
            pass

    regions = [inventory[uid] for uid in sorted(inventory)]
    for region in regions:
        where = region["occurrences"]
        region["join_has_other_preds"] = any(occ["join_has_other_preds"] for occ in where)
        sources = sorted({occ["condition_source"] for occ in where})
        region["condition_source"] = sources[0] if len(sources) == 1 else sources
        region["unsafe_to_speculate"] = any(occ["unsafe_to_speculate"] for occ in where)
        fold = {occ["original_folds"] for occ in where}
        if len(fold) > 1:
            region["original_folds"] = None
            region["fold_reason"] = "differs among occurrences"
        for key in ("original_folds", "fold_reason", "unsafe_to_speculate"):
            if all(occ[key] == region[key] for occ in where):
                for occ in where:
                    del occ[key]
    dump_inventory(args.output / "inventory.json", regions, failures)
    write_summary(args.output / "SUMMARY.md", manifest, regions, failures)
    print(f"{len(inputs)} distinct source hashes; {len(failures)} source entries failed LLVM 12")
    print(f"{len(regions)} unique regions; {len(paths)} extracted files passed opt -verify")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sources", required=True, type=Path)
    parser.add_argument("--extractor", required=True, type=Path)
    parser.add_argument("--opt", required=True, type=Path)
    parser.add_argument("--work", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--jobs", default=4, type=int)
    args = parser.parse_args()
    build(args)
