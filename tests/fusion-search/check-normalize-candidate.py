#!/usr/bin/env python3
"""Exercise normalize-only on frozen NQU64 and a losing CED preparation."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tarfile
import tempfile

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))
from tools.compile_kernel import compile_kernel


def verify(llvm, path):
    subprocess.run([llvm / "opt", "-verify", "-disable-output", path], check=True)


def read(path):
    return json.loads(path.read_text())


def normalization_winners(report):
    return [r for r in report["rounds"] if r.get("selected_plan_kind") == "normalize"]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("greedy", type=Path)
    parser.add_argument("llvm_bin", type=Path)
    parser.add_argument("rocm", type=Path)
    args = parser.parse_args()

    reference = ROOT / "regression/golden/20261120-anchor-release"
    frozen = read(reference / "manifest.json")
    cases = {case["case"]: case for case in frozen["cases"]}
    with tempfile.TemporaryDirectory(prefix="normalize-only-") as tmp:
        run = Path(tmp)

        def input_ir(case):
            path = run / f"{case}.ll"
            item = cases[case]["input"]
            with tarfile.open(reference / frozen["archive"]["file"]) as archive:
                path.write_bytes(archive.extractfile(item["archive_entry"]).read())
            assert hashlib.sha256(path.read_bytes()).hexdigest() == item["sha256"]
            return path

        def greedy(source, case, name, mode=None):
            out = run / name
            command = [args.greedy, source, cases[case]["function"], ROOT, out]
            if mode:
                command.extend(("--normalize-candidate", mode))
            subprocess.run(command, check=True)
            verify(args.llvm_bin, out / "final.ll")
            return out, read(out / "summary.json")

        first, summary = greedy(input_ir("NQU64"), "NQU64", "initial")
        assert summary["commits"] == 1
        greedy_parent = first / "final.ll"
        _, off = greedy(greedy_parent, "NQU64", "off", "off")
        candidate, on = greedy(greedy_parent, "NQU64", "on", "on")
        assert off["commits"] == 0 and not normalization_winners(off)
        winners = normalization_winners(on)
        assert len(winners) == 1 and on["commits"] == 1, on["commits"]
        winner = winners[0]
        assert (winner["parent_cost"], winner["selected_cost"]) == (282, 274)
        trial = read(Path(winner["selected"]) / "structural/trial-0/trial.json")
        assert (trial["planKind"], trial["merge_path"]) == ("normalize", "normalize-only")
        assert trial["condition_before"] and trial["condition_prepared"]["dispatch"]
        assert not trial["score_result"]["profitability_rejection"]
        binary = run / "nqu.hsaco"
        compile_kernel(candidate / "final.ll", binary, args.llvm_bin, args.rocm, env=os.environ)
        # G1 from the released gfx906 toolchain (study/nqu-second-fusion, 14775f2).
        assert hashlib.sha256(binary.read_bytes()).hexdigest() == (
            "83bec1d3bb5b164770921cd52763d70670efa5ea12ab5f04082391abbf74e97b"
        )

        _, ced = greedy(input_ir("CED"), "CED", "losing-normalization", "on")
        rejected = [
            attempt
            for row in ced["rounds"]
            for attempt in row["attempts"]
            if attempt["kind"] == "normalize"
            and attempt.get("cost", row["parent_cost"]) > row["parent_cost"]
        ]
        assert rejected, "missing a strictly worse normalize-only control"
        assert all(not attempt["eligible"] and attempt["reason"] == "nonpositive_gain"
                   for attempt in rejected)
        assert all(row["selected_cost"] < row["parent_cost"]
                   for row in normalization_winners(ced))
        # TPACF's first prepared control fits the structural worker's PHI-fold
        # budget. Export it through that worker to catch process configuration
        # and serialization differences in the Greedy candidate.
        _, tpacf = greedy(input_ir("TPACF"), "TPACF", "shared-control", "on")
        winner = tpacf["rounds"][0]
        assert winner.get("selected_plan_kind") == "normalize"
        assert (winner["parent_cost"], winner["selected_cost"]) == (592, 580)
        trial = read(Path(winner["selected"]) / "structural/trial-0/trial.json")
        export = run / "worker-control.ll"
        subprocess.run([
            ROOT / "build/llvm24-tti/fusion-search-llvm24", "--ir",
            trial["prepared_input"], "--function", cases["TPACF"]["function"],
            "--control-only", "1", "--out", export,
        ], check=True)
        assert export.read_bytes() == (Path(winner["selected"]) / "fused.ll").read_bytes()
    print("PASS normalize-only NQU64, losing CED control and exact TPACF control")


if __name__ == "__main__":
    main()
