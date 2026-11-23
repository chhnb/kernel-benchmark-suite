#!/usr/bin/env python3
"""Run the small-tier gate in both modes against independent enumeration."""
import argparse
from collections import Counter
from concurrent.futures import ThreadPoolExecutor
import gzip
import json
from pathlib import Path
import re
import subprocess
import sys

CORPUS = Path("tests/dataflow-b2b/corpus")
RESULTS = Path("tests/dataflow-b2b/results")
COSTS = Path("docs/dataflow-b2b/COST_TABLE.json")
TARGETS = {
    # HiPIMS-HLLC linked libdevice. Use the target of its original parent kernel.
    "0a29522625b0": ("sm_70", "+ptx32,+sm_70"),
    "62045db1147a": ("sm_70", "+ptx32,+sm_70"),
    "8f1b13db9cb3": ("sm_70", "+ptx32,+sm_70"),
    # vLLM linked unmerged helpers. Use cases/vllm-quant/recipes/llc.json.
    "5a00894ee4a3": ("gfx906", "+sramecc,-xnack"),
    "c8c384ca7255": ("gfx906", "+sramecc,-xnack"),
    "d68091cf76ca": ("gfx906", "+sramecc,-xnack"),
}


def select(front, baseline, source):
    valid = [s["T"] for s in front
             if source != "data" or all(a <= b for a, b in zip(s["T"][1:], baseline[1:]))]
    if source == "workgroup-uniform":
        return min([baseline, *sorted(valid)], key=lambda v: max(v[1:]))
    return min([baseline, *valid])


def read_solution(command, timeout):
    try:
        result = subprocess.run(command, check=False, capture_output=True, text=True,
                                timeout=timeout)
        report = json.loads(result.stdout)
        if result.stderr:
            report["stderr"] = result.stderr
        return report
    except (OSError, ValueError, subprocess.SubprocessError) as exc:
        return {"status": "error", "reason": str(exc)}


def normalize_target(path, dest, target):
    text = path.read_text()
    group = re.search(r"^define .* #(\d+) \{", text, re.M)
    if not group:
        raise ValueError(f"{path}: no target function attribute group")
    header = r"^attributes #" + group[1] + r" = \{ "
    line = next(line for line in text.splitlines() if re.match(header, line))
    assert "target-cpu" not in line and "target-features" not in line, line
    cpu, features = target
    text = re.sub(header, lambda match: match[0] +
                  f'"target-cpu"="{cpu}" "target-features"="{features}" ', text, count=1,
                  flags=re.M)
    dest.write_text(text)
    return dest


def check_region(row, mode, abstract, args):
    uid = row["id"]
    folder = args.work / mode / uid
    folder.mkdir(parents=True, exist_ok=True)
    source = CORPUS / row["ir"]
    if source.suffix == ".gz":
        dest = folder / "uncompressed.ll"
        dest.write_bytes(gzip.decompress(source.read_bytes()))
        source = dest
    configured = TARGETS.get(uid[:12]) if mode == "real" else None
    if configured:
        source = normalize_target(source, folder / "with-target.ll", configured)
    if mode == "real":
        ref = read_solution([args.reference, source, COSTS, folder / "reference",
                             "--cost=real"], 620)
    else:
        ref = abstract[uid]
    ilp = read_solution([sys.executable, "tools/dataflow_b2b/ilp_solver", source, COSTS,
                         folder / "ilp", f"--cost={mode}", "--condition-source",
                         row["condition_source"], "--reference", args.reference,
                         "--interpreter", args.interpreter], 625)
    info = {"id": uid, "kind": row["kind"], "mode": mode, "configured_target": configured,
            "condition_source": row["condition_source"], "reference": ref,
            "ilp": ilp}
    expected = ref.get("original_T")
    if not expected and ilp.get("status") == "unsupported":
        info["status"] = "unpriced"
    elif ilp.get("status") == "semantic_unverified":
        info["status"] = "semantic_unverified"
    elif not ref.get("complete") or ilp.get("status") != "ok":
        info["status"] = "incomplete"
    else:
        best = ref.get("verified_best") if mode == "abstract" else min(
            [expected, *(s["T"] for s in ref["pareto_front"])])
        strategy = ref.get("strategy_choice") if mode == "abstract" else select(
            ref["pareto_front"], expected, row["condition_source"])
        info["expected"] = {"min_D": best[0], "strategy": strategy}
        if ilp["min_D"]["T"][0] != best[0] or ilp["strategy"]["T"] != strategy:
            info["status"] = "mismatch"
        elif any(ilp[key]["semantic_validation"].get("status") != "pass"
                 for key in ("min_D", "strategy")):
            info["status"] = "semantic_unverified"
        else:
            info["status"] = "agree"
    (folder / "result.json").write_text(json.dumps(info, indent=2) + "\n")
    return info


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for field in ("work", "reference", "interpreter"):
        parser.add_argument(field, type=Path)
    parser.add_argument("--jobs", type=int, default=12)
    args = parser.parse_args()
    rows = [r for r in json.loads((CORPUS/"inventory-b2b.json").read_text())["regions"]
            if r["size_bucket"] == "small"]
    with gzip.open(RESULTS / "step3b-small-raw.json.gz") as stream:
        abstract = json.load(stream)
    tasks = [(row, mode) for row in rows for mode in ("abstract", "real")]
    with ThreadPoolExecutor(args.jobs) as pool:
        results = list(pool.map(lambda item: check_region(*item, abstract, args), tasks))
    (args.work / "small-cross-check.json").write_text(json.dumps(results, indent=2) + "\n")
    print(Counter((r["mode"], r["status"]) for r in results))
    return int(any(r["status"] != "agree" for r in results))


if __name__ == "__main__":
    raise SystemExit(main())
