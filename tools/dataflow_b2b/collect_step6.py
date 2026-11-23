#!/usr/bin/env python3
"""Collect solver receipts, committed regions and final HSACO branch evidence."""

import argparse
from collections import Counter, defaultdict
import csv
from difflib import SequenceMatcher
import gzip
import hashlib
import json
from pathlib import Path
import re
from statistics import median
import subprocess

from check_step5_small import CORPUS, COSTS, RESULTS
from collect_step4b import instruction_class

ROLES = ("original", "anchor", "darm", "dataflow-ilp")
CASES = {"NQU64": "_Z24solve_nqueen_cuda_kerneliiPjS_S_S_i", "MapAiry": "evaluate"}
VALUE = re.compile(r"%[-\w.$]+")
BRANCH = re.compile(r"^br i1 ([^,]+), label (%[-\w.$]+), label (%[-\w.$]+)")
SELECT = re.compile(r"^select (?:[\w ]+ )?i1 ([^,]+),")
COUNTERS = ("Wavefronts", "VALUInsts", "SALUInsts", "VALUBusy", "MemUnitBusy",
            "MemUnitStalled", "arch_vgpr", "sgpr")


def read(path):
    return json.loads(path.read_text())


def compressed(path):
    with gzip.open(path, "rt") as stream:
        return json.load(stream)


class Kernel:
    def __init__(self, path, symbol):
        body = path.read_text().split(f"@{symbol}(", 1)[1].split("\n}", 1)[0]
        args, body = body.split("{\n", 1)
        params = VALUE.findall(args.rsplit(")", 1)[0])
        name = "%" + str(sum(p[1:].isdigit() for p in params))
        self.values = dict(zip(params, (f"arg{i}" for i in range(len(params)))))
        self.blocks = {}
        self.branches, self.selects = {}, defaultdict(set)
        for raw in body.splitlines():
            line = raw.split(";", 1)[0].strip()
            if not line:
                continue
            if match := re.fullmatch(r"([-\w.$]+):", line):
                name = "%" + match[1]
                self.blocks[name] = []
                continue
            self.blocks.setdefault(name, []).append(line)
            if line.startswith("%") and " = " in line:
                value, rhs = line.split(" = ", 1)
                self.values[value] = rhs
                if select := SELECT.match(rhs):
                    self.selects[select[1]].add(name)
            elif branch := BRANCH.match(line):
                self.branches[name] = branch.groups()

    def signature(self, value, level=7):
        expr = self.values.get(value, value)
        if expr == value:
            return re.sub(r"%\d+", "%slot", value)
        expr = re.sub(r", ![-.\w]+ !\d+| #\d+$", "", expr)
        if level == 0 or expr.startswith("phi "):
            return re.sub(r"%[-\w.$]+", "%slot", expr)
        return VALUE.sub(lambda match: self.signature(match[0], level - 1), expr)

    def predicate(self, value):
        seen = set()
        while value not in seen:
            seen.add(value)
            expr = self.values.get(value, "")
            if negation := re.fullmatch(r"xor i1 (%[-\w.$]+), true", expr):
                value = negation[1]
                continue
            if expr.startswith("phi i1 "):
                defined = {v for v in re.findall(r"\[ ([^,]+), %[-\w.$]+ \]", expr) if v != "poison"}
                if len(defined) == 1:
                    value = next(iter(defined))
                    continue
            break
        return self.signature(value)

    def branch_cost(self, block, quotes):
        _, left, right = self.branches[block]
        names = list(self.blocks)
        indices = {names.index(name) for name in (block, left, right) if name in self.blocks}
        start = names.index(block)
        # Only count the split and direct, reconverging arms. The join is common.
        exits = [self.blocks.get(name, [""])[-1] for name in (left, right)]
        join = None
        if exits[0] == exits[1] and re.fullmatch(r"br label %[-\w.$]+", exits[0]):
            join = exits[0][9:]
        elif exits[0] == f"br label {right}":
            join = right
        elif exits[1] == f"br label {left}":
            join = left
        if join is not None:
            return sum(q["accepted_cost"] for q in quotes if q.get("accepted_cost") is not None
                       and q["block_index"] in indices and
                       (q["block_index"] == start and q["key"].startswith("br.conditional:") or
                        q["key"].startswith("br.unconditional:") and names[q["block_index"]] != join))
        return None


def read_isa(path):
    text = path.read_text()
    entries = [(int(pc, 16), op.strip()) for op, pc in
               re.findall(r"^[ \t]+(\w[^\n]*?)[ \t]*// ([0-9A-Fa-f]+):", text, re.M)]
    if not entries:
        raise ValueError(f"no instruction in {path}")
    return entries


def counts(entries):
    totals = Counter()
    for _, inst in entries:
        op = inst.split()[0]
        totals[instruction_class(op)] += 1
        if op.startswith("s_cbranch"):
            totals["conditional_branch"] += 1
        if "saveexec" in op or re.search(r"\bexec(?:_lo|_hi)?\b", inst) and not op.startswith("s_cbranch"):
            totals["exec"] += 1
        if op.startswith("v_cndmask"):
            totals["cndmask"] += 1
    return dict(totals)


def assembly_blocks(ir, gpu, role, llvm, symbol):
    annotated = gpu / f"{role}.annotated.s"
    subprocess.run([llvm, "-O3", "-march=amdgcn", "-mcpu=gfx906", "-mattr=+sramecc",
                    "-amdhsa-code-object-version=4", "-asm-verbose=true", ir, "-o", annotated],
                   check=True)
    lines = annotated.read_text().split(f"\n{symbol}:", 1)[1]
    machine = read_isa(gpu / f"{role}.s")
    expected, labels = [], []
    name = None
    for line in lines.splitlines():
        if line.startswith(".Lfunc_end"):
            break
        if re.match(r"^(?:\.?L?BB\d+_\d+:|; %bb\.\d+:)", line):
            name = None
        if label := re.search(r"; (%[-\w.$]+)\s*$", line):
            name = label[1]
        if match := re.match(r"^[ \t]+(\w+)(?:[ \t]|$)", line):
            expected.append(match[1])
            labels.append(name)
    actual = [line.split()[0] for _, line in machine]
    index = defaultdict(list)
    matched = 0
    for a, b, size in SequenceMatcher(a=expected, b=actual, autojunk=False).get_matching_blocks():
        for i in range(size):
            if labels[a + i]:
                index[labels[a + i]].append(machine[b + i])
            matched += 1
    return index, {"matched": matched, "total": len(actual), "annotation_total": len(expected)}


def direct_control(k, block):
    names = {block}
    _, a, b = k.branches[block]
    exits = [k.blocks.get(name, [""])[-1] for name in (a, b)]
    if exits[0] == exits[1] and exits[0].startswith("br label "):
        names.update((a, b, exits[0][9:]))
    elif exits[0] == f"br label {b}":
        names.update((a, b))
    elif exits[1] == f"br label {a}":
        names.update((a, b))
    return names


def excerpt(index, names):
    return sorted({item for name in names for item in index.get(name, ())})


def profile(path, symbol, dispatches):
    with path.open() as stream:
        rows = [r for r in csv.DictReader(stream) if symbol in r["KernelName"]]
    rows.sort(key=lambda r: int(r["BeginNs"]))
    measured = rows[-15 * dispatches:]
    if len(measured) != 15 * dispatches:
        raise ValueError(f"incomplete profile {path}: {len(rows)} kernel dispatches")
    times = [(int(r["EndNs"]) - int(r["BeginNs"])) / 1000 for r in measured]
    return {"rows": rows, "measured": len(measured),
            "median": {counter: median(float(r[counter]) for r in measured) for counter in COUNTERS}
            | {"dispatch_us": median(times),
               "replay_us": median(sum(times[i:i + dispatches])
                                   for i in range(0, len(times), dispatches))}}


def campaign(work, case, extractor, llvm):
    symbol = CASES[case]
    folder = work / case
    gpu = folder / "gpu"
    paths = {role: folder / role / "final.ll" for role in ROLES}
    paths["original"] = folder / "input.ll"
    known = {row["id"] for row in compressed(CORPUS / "inventory-all.json.gz")["regions"]}
    cache = {}
    timelines = {}
    for role in ROLES[1:]:
        search = read(folder / role / "summary.json")
        if search["status"] != "completed":
            raise ValueError(f"{case}/{role}: {search['status']}")
        attempts = []
        for rnd in search["rounds"]:
            for attempt in rnd["attempts"]:
                if "directory" not in attempt:
                    continue
                directory = Path(attempt["directory"])
                committed = rnd["selected"] == str(directory)
                if not committed and role != "dataflow-ilp":
                    continue
                row = {"directory": directory.name, "selected": committed,
                       "kind": attempt["kind"], "candidate": attempt["candidate"],
                       "parent_TTI": rnd["parent_cost"], "cleaned_TTI": attempt.get("cost"),
                       "eligible": attempt.get("eligible"), "reason": attempt.get("reason")}
                report = directory / "structural/trial-0/trial.json"
                if report.is_file():
                    trial = read(report)
                    parent = Path(trial["parent_ir"])
                    stats = trial.get("dataflow_exact", {})
                    row.update(layout=trial["merge_path"], dataflow=stats, parent=str(parent),
                               cleaned_ir=trial["cleaned_ir"])
                    if committed or stats.get("region_id"):
                        if parent not in cache:
                            listing = subprocess.check_output([extractor, parent, COSTS,
                                                               folder / "extracted"], text=True)
                            cache[parent] = (Kernel(parent, symbol), {
                                r["occurrence"]["block"]: r for line in listing.splitlines()
                                if (r := json.loads(line))["occurrence"]["function"] == symbol})
                        kernel, listing = cache[parent]
                        split = trial["candidate"].split(":")[-3]
                        block = list(kernel.blocks)[int(split[1:])]
                        item = listing.get(block)
                        if item:
                            row["region"] = {"id": item["id"], "kind": item["kind"],
                                             "in_corpus": item["id"] in known, "split": block,
                                             "join": item["occurrence"]["join"]}
                            if stats.get("region_id"):
                                assert row["region"]["id"] == stats["region_id"], row
                attempts.append(row)
        assert sum(t["selected"] for t in attempts) == search["commits"], (case, role)
        timelines[role] = {"commits": search["commits"], "final_cost": search["final_cost"],
                           "seconds": search["elapsed_ms"] / 1000, "attempts": attempts}
    quotes = {role: json.loads(subprocess.check_output(["tools/run-llvm24-tti", path, symbol],
                                                      text=True)) for role, path in paths.items()}
    validation = {}
    for role in ROLES:
        with (gpu / f"validate-{role}/samples.csv").open() as stream:
            validation[role] = list(csv.DictReader(stream))
        assert validation[role] and all(r["full_output_passed"] == "1" for r in validation[role])
    whole = {}
    for role in ROLES:
        asm = read_isa(gpu / f"{role}.s")
        whole[role] = {"TTI": quotes[role]["cost"], "ISA": counts(asm),
                       "TTI_branches": {kind: sum(q["key"].startswith(kind + ":")
                                                   for q in quotes[role]["instruction_costs"])
                                        for kind in ("br.conditional", "br.unconditional")},
                       "TTI_control": sum(q["accepted_cost"] for q in quotes[role]["instruction_costs"]
                                          if q["key"].startswith("br.") and q["accepted_cost"] is not None)}
        if role != "original":
            assert whole[role]["TTI"] == timelines[role]["final_cost"], (case, role)
    anchor = Kernel(paths["anchor"], symbol)
    candidate = Kernel(paths["dataflow-ilp"], symbol)
    cmp_roles = ("anchor", "dataflow-ilp")
    annotated = {r: assembly_blocks(paths[r], gpu, r, llvm, symbol) for r in cmp_roles}
    anchor_locations = defaultdict(list)
    for name, (condition, _, _) in anchor.branches.items():
        anchor_locations[anchor.predicate(condition)].append(name)
    candidate_locations = {candidate.predicate(condition)
                           for condition, _, _ in candidate.branches.values()}
    final_predicates = [{"anchor_blocks": blocks, "predicate": signature}
                        for signature, blocks in anchor_locations.items()
                        if signature not in candidate_locations]
    targets = []
    for row in timelines["dataflow-ilp"]["attempts"]:
        info = row.get("dataflow", {})
        chosen = info.get("chosen", {})
        if not (row["selected"] and info.get("choice") == "fuse" and chosen.get("guard_branches") == 0):
            continue
        item = row.get("region")
        if not item:
            targets.append({"trial": row["directory"], "status": "unresolved split"})
            continue
        original, _ = cache[Path(row["parent"])]
        block = item["split"]
        condition = original.branches[block][0]
        signature = original.predicate(condition)
        parent_quotes = json.loads(subprocess.check_output(
            ["tools/run-llvm24-tti", row["parent"], symbol], text=True))["instruction_costs"]
        old = [name for name, values in anchor.branches.items() if anchor.predicate(values[0]) == signature]
        retained = [name for name, values in candidate.branches.items()
                    if candidate.predicate(values[0]) == signature]
        owners = {owner for value, blocks in candidate.selects.items()
                  if candidate.predicate(value) == signature for owner in blocks}
        anchor_selects = {owner for value, blocks in anchor.selects.items()
                          if anchor.predicate(value) == signature for owner in blocks}
        candidate_names = owners or ({block} if block in candidate.blocks and not block[1:].isdigit()
                                    else set())
        result = {"trial": row["directory"], "id": item["id"], "condition": original.values.get(condition),
                  "original_split": block, "anchor_blocks": old, "ilp_retained_branches": retained,
                  "TTI_control_parent": original.branch_cost(block, parent_quotes),
                  "TTI_control_solution": chosen.get("D_components", {}).get("control", 0),
                  "anchor_select_blocks": sorted(anchor_selects), "ilp_select_blocks": sorted(owners),
                  "ilp_neighborhood": sorted(candidate_names), "status": "unresolved"}
        if len(old) == 1 and candidate_names and not retained:
            old_names = direct_control(anchor, old[0])
            sequences = {"anchor": excerpt(annotated["anchor"][0], old_names),
                         "dataflow-ilp": excerpt(annotated["dataflow-ilp"][0], candidate_names)}
            if all(sequences.values()) and all(a[1]["matched"] == a[1]["total"] for a in annotated.values()):
                result.update(status="mapped", TTI_control_anchor=anchor.branch_cost(
                    old[0], quotes["anchor"]["instruction_costs"]), TTI_control_ilp=0,
                    isa={role: counts(seq) for role, seq in sequences.items()}, instructions=sequences,
                    anchor_neighborhood=sorted(old_names))
        elif retained:
            result["status"] = "condition still branches in final ILP IR"
        elif not old and anchor_selects and candidate_names:
            sequences = {"anchor": excerpt(annotated["anchor"][0], anchor_selects),
                         "dataflow-ilp": excerpt(annotated["dataflow-ilp"][0], candidate_names)}
            result.update(status="anchor already uses select",
                          TTI_control_anchor=0, TTI_control_ilp=0,
                          isa={role: counts(seq) for role, seq in sequences.items()},
                          instructions=sequences, anchor_neighborhood=sorted(anchor_selects))
        elif not old:
            result["status"] = "no equivalent predicate matched in final anchor IR"
        targets.append(result)
    return {"roles": whole, "greedy": timelines, "validation": validation,
            "timing": read(gpu / "timing/results.json"),
            "occupancy": (gpu / "profile/occupancy.txt").read_text().splitlines(),
            "profiles": {r: profile(gpu / f"profile/{r}.csv",
                                   "solve_nqueen_cuda_kernel" if case == "NQU64" else "evaluate",
                                   3 if case == "NQU64" else 1) for r in cmp_roles},
            "mapping": {r: annotated[r][1] for r in cmp_roles}, "removed_guards": targets,
            "unmatched_final_anchor_predicates": final_predicates}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for field in ("work", "extractor", "llc", "output"):
        parser.add_argument(field, type=Path)
    parser.add_argument("--case", choices=tuple(CASES), action="append")
    args = parser.parse_args()
    receipts = {name: campaign(args.work, name, args.extractor, args.llc)
                for name in args.case or CASES}
    # Python keeps full per-dispatch and per-candidate evidence in the compressed artifact.
    args.output.write_bytes(gzip.compress((json.dumps(receipts, indent=2) + "\n").encode(), mtime=0))


if __name__ == "__main__":
    main()
