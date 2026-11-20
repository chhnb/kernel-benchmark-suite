#!/usr/bin/env python3
"""Audit existing trial coverage by split root; coordinates are round-local only."""
import argparse, collections, json
from pathlib import Path
p = argparse.ArgumentParser(description=__doc__)
p.add_argument("summary", type=Path)
p.add_argument("--out", type=Path, required=True)
a = p.parse_args()
s = json.loads(a.summary.read_text())
rows = []
stages = collections.defaultdict(lambda: dict(rounds=0, trials=0, commits=0))
for index, r in enumerate(s["rounds"]):
    stage = "decision" if r.get("decision") else "structural_sweep"
    counts = stages[stage]
    counts["rounds"] += 1
    counts["trials"] += len(r["attempts"])
    counts["commits"] += bool(r.get("selected"))
    groups = collections.defaultdict(list)
    for attempt in r["attempts"]:
        groups[attempt["candidate"].rsplit(":", 3)[1]].append(attempt)
    rows.append(dict(round=index, stage=stage, parent=r["parent"],
        roots=len(groups), trials=len(r["attempts"]),
        singleton_roots=sum(len(v)==1 for v in groups.values()),
        positive_roots=sum(any(x.get("eligible") for x in v) for v in groups.values()),
        groups=[dict(split=k, candidates=[x["candidate"] for x in v],
                     gains=[x.get("gain") for x in v]) for k,v in groups.items()]))
a.out.parent.mkdir(parents=True, exist_ok=True)
a.out.write_text(json.dumps(dict(source=str(a.summary), stages=dict(stages),
    limitation="Split roots are not yet tree domains or stable cross-round identities. No cached gain validity is inferred.",
    rounds=rows), indent=2)+"\n")
print(json.dumps(dict(stages), indent=2))
