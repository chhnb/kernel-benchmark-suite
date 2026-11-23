#!/usr/bin/env python3
"""Check real evaluator prices against the fusion-search worker on parent IR."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess

PREFIXES = ("d23a7c228c5b", "2f29337da1ee", "e37272cdb93e", "02248205bdba")
CORPUS = Path("tests/dataflow-b2b/corpus")
COSTS = Path("docs/dataflow-b2b/COST_TABLE.json")


def llvm_text(path):
    return gzip.decompress(path.read_bytes()) if path.suffix == ".gz" else path.read_bytes()


def report(*args):
    return json.loads(subprocess.check_output(args))


def region_rows(text, occurrence, prices):
    function = occurrence["function"]
    block, join = (occurrence[key].removeprefix("%") for key in ("block", "join"))
    begin = re.search(r"^define .*@" + re.escape(function) + r"\(", text, re.MULTILINE)
    body = text[begin.end():].split("\n}", 1)[0]
    labels = re.findall(r"^([-\w.$]+):", body, re.MULTILINE)
    if not re.match(r"^[-\w.$]+:", body.split("{\n", 1)[1].lstrip()):
        labels.insert(0, block if block not in labels else None)
    split_index, join_index = labels.index(block), labels.index(join)
    quotes = prices["instruction_costs"]
    branch = next(row for row in quotes if row["block_index"] == split_index
                  and row["key"].startswith("br.conditional:"))
    arms = {labels.index(name) for name in re.findall(r"label %([-\w.$]+)", branch["ir"])}
    arms.discard(join_index)
    return [row for row in quotes if row is branch or row["block_index"] in arms or
            (row["block_index"] == join_index and row["key"].startswith("phi:"))]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("evaluator", type=Path)
    parser.add_argument("worker", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    sources = json.loads((CORPUS / "sources.json").read_text())["sources"]
    rows = json.loads((CORPUS / "inventory-b2b.json").read_text())["regions"]
    for prefix in PREFIXES:
        region = next(row for row in rows if row["id"].startswith(prefix))
        occurrence = region["occurrences"][0]
        source = sources[occurrence["source_index"]]
        contents = llvm_text(Path(source["path"]))
        if hashlib.sha256(contents).hexdigest() != occurrence["source_sha256"]:
            raise ValueError(f"{prefix}: parent IR hash mismatch")
        parent = args.output / (prefix + ".ll")
        parent.write_bytes(contents)
        prices = report(args.worker, parent, occurrence["function"])
        charges = region_rows(contents.decode(), occurrence, prices)
        result = report(args.evaluator, CORPUS / region["ir"], COSTS, "--original",
                        "--cost=real", f"--tti-worker={args.worker}")
        parent_cost = sum(row["accepted_cost"] for row in charges)
        item = {"id": region["id"], "occurrence": occurrence, "parent_T_D": parent_cost,
                "evaluator_T": result["T"], "parent_rows": charges,
                "region_rows": result["operations"]}
        (args.output / (prefix + ".json")).write_text(json.dumps(item, indent=2) + "\n")
        print(f"{prefix} ({occurrence['case']}) parent D={parent_cost}, evaluator T={result['T']}",
              flush=True)
        if parent_cost != result["T"][0]:
            return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
