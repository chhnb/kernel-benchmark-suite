#!/usr/bin/env python3
"""Audit every extracted B2B region and refresh its real-LLVM Fold fields."""
import argparse
from concurrent.futures import ThreadPoolExecutor
import gzip
import json
from pathlib import Path
import subprocess
from tempfile import NamedTemporaryFile

from build_inventory import COSTS, dump_inventory

ROOT = Path(__file__).resolve().parents[2]
CORPUS = ROOT / "tests/dataflow-b2b/corpus"


def check(row, oracle):
    ir = CORPUS / row["ir"]
    if ir.suffix == ".gz":
        with NamedTemporaryFile(suffix=".ll") as source:
            source.write(gzip.decompress(ir.read_bytes()))
            source.flush()
            result = subprocess.run([oracle, source.name, COSTS], capture_output=True, text=True)
    else:
        result = subprocess.run([oracle, ir, COSTS], capture_output=True, text=True)
    report = json.loads(result.stdout) if result.stdout else {"error": result.stderr}
    return {"id": row["id"], "ir": row["ir"], **report, "exit": result.returncode}


def main(args):
    b2b_path = CORPUS / "inventory-b2b.json"
    all_path = CORPUS / "inventory-all.json.gz"
    b2b = json.loads(b2b_path.read_text())
    with gzip.open(all_path, "rt") as stream:
        all_regions = json.load(stream)
    with ThreadPoolExecutor(6) as pool:
        reports = list(pool.map(lambda row: check(row, args.oracle), b2b["regions"]))
    args.report.write_text(json.dumps(reports, indent=2) + "\n")
    failed = [r for r in reports if r["exit"] or r.get("status") != "ok" or len(r.get("guards", [])) != 1]
    if failed:
        raise RuntimeError(f"{len(failed)} regions failed the Fold oracle; see {args.report}")
    by_id = {r["id"]: r["guards"][0] for r in reports}
    changes = []
    for row in b2b["regions"]:
        result = by_id[row["id"]]
        if result["actual"] != row["original_folds"]:
            changes.append((row["id"], row["original_folds"], result["actual"], result["reason"]))
    print(f"{len(reports)} agreements; {sum(r['actual'] for r in by_id.values())} speculated")
    for uid, old, new, reason in changes:
        print(f"{uid}\t{old}\t{new}\t{reason or 'eligible at gfx906 c_SL'}")
    for dataset in (b2b, all_regions):
        for row in dataset["regions"]:
            result = by_id.get(row["id"])
            if result is not None:
                row["original_folds"] = result["actual"]
                row["fold_reason"] = result["reason"] or "eligible at gfx906 c_SL; confirmed by SimplifyCFG"
                row["size_latency_quotes"] = result["size_latency"]
                row["fold_scope"] = "extracted_region"
    dump_inventory(b2b_path, b2b["regions"], b2b["source_errors"])
    dump_inventory(all_path, all_regions["regions"], all_regions["source_errors"])


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("oracle", type=Path)
    parser.add_argument("report", type=Path)
    main(parser.parse_args())
