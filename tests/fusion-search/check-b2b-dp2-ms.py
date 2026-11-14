#!/usr/bin/env python3
"""Check the MS32 shared memory chain and loop PHI transport in a trial."""
import json
from pathlib import Path
import re
import sys

trial = Path(sys.argv[1])
report = json.loads((trial / "trial.json").read_text())
assert report["merge_path"].startswith("single-branch-dp2-")
raw = (trial / "after-raw.ll").read_text()
condition, = re.findall(r"^  (%\w+) = freeze i1 ", raw, re.M)
start = raw.index(f"  {condition} = freeze")
end = raw.index("\n\n", start)
body = raw[start:end]
assert body.count("load i64,") == 1
assert body.count("store i64 ") == 2
assert "br i1" not in body
load, = re.findall(r"^  (%\w+) = load i64,", body, re.M)
assert f"store i64 {load}," in body
choices = re.findall(r"^  (%\w+) = select i1 (%\w+), (.*)$", body, re.M)
assert all(cond == condition for _, cond, _ in choices)
assert len({args for _, _, args in choices}) == len(choices)
outgoing = raw[end + 2:].split("\n\n", 1)[0]
incoming = re.findall(r"^  %\w+ = phi .*?\[ (%\w+), %\w+ \]$", outgoing, re.M)
# Two source-pointer PHIs refer to the same select, so seven PHIs carry
# six distinct values across the merged edge.
assert len(incoming) == 7 and len(set(incoming)) == 6
assert set(incoming) <= {value for value, _, _ in choices}
print("MS32 shares one load and two stores and transfers six distinct exit values")
