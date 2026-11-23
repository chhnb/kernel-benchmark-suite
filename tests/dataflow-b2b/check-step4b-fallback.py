"""Check the exact strategy's size fallback on an enlarged PCM32 diamond."""
import argparse
from pathlib import Path
import json
import os
import subprocess

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("work", type=Path)
work = parser.parse_args().work
source = (work / "input.ll").read_text()
for arm, value in (("l", 289), ("r", 291)):
    where = source.index(f"  %{value} = add")
    end = source.index("\n", where) + 1
    additions = [f"  %more.{arm}.0 = xor i32 %{value}, 257"]
    for i in range(1, 4):
        additions.append(f"  %more.{arm}.{i} = add i32 %more.{arm}.{i-1}, {11+i}")
    source = source[:end] + "\n".join(additions) + "\n" + source[end:]
    source = source.replace(f"[ %{value}, %{value - 1} ]",
                            f"[ %more.{arm}.3, %{value - 1} ]")
fixture = work / "oversize.ll"
fixture.write_text(source)
verify = Path(os.environ["LLVM_CONFIG"]).with_name("opt")
subprocess.run([verify, "-verify", "-disable-output", fixture], check=True)
out = work / "fallback-test"
out.mkdir()
trials = {}
ir = {}
for name in ("anchor", "dataflow-exact"):
    dest = out / f"{name}.ll"
    debug = out / name
    command = ["build/llvm24-tti/fusion-search-llvm24", "--ir", fixture, "--function",
               "_Z3pcmPi", "--split", "B9", "--left", "B10", "--right", "B11",
               "--tti-worker", str(Path("tools/run-llvm24-tti").resolve()),
               "--b2b-strategy", name, "--out", dest, "--debug-dir", debug]
    if name == "dataflow-exact":
        command += ["--dataflow-solver", "build/llvm24-tti/reference_solver",
                    "--dataflow-costs", "docs/dataflow-b2b/COST_TABLE.json"]
    subprocess.run(command, check=True)
    trials[name] = json.loads((debug / "trial-0/trial.json").read_text())
    ir[name] = dest.read_text().splitlines()[1:]
a, n = trials.values()
assert n["dataflow_exact"]["handler"] == "anchor_fallback"
assert n["dataflow_exact"]["operations"] == 12
assert a["merge_path"] == n["merge_path"]
assert a["score_result"] == n["score_result"]
assert ir["anchor"] == ir["dataflow-exact"]
(out / "verified.json").write_text(json.dumps({
    "anchor_layout": a["merge_path"], "score": a["score_result"],
    "dataflow_exact": n["dataflow_exact"], "identical_cleaned_ir": True,
}, indent=2) + "\n")
print(n["dataflow_exact"])
