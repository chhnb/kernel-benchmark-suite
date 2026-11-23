#!/usr/bin/env python3
"""Collect evidence from the DCT8 and PCM32 step 4b runs."""
import argparse
from collections import Counter
import csv
import gzip
import json
from pathlib import Path
import re
from statistics import median
import subprocess

CORPUS = Path("tests/dataflow-b2b/corpus")
RESULTS = Path("tests/dataflow-b2b/results")
COSTS = Path("docs/dataflow-b2b/COST_TABLE.json")
KERNEL = "_Z3pcmPi"
PCM_ROLES = ("anchor", "darm", "dataflow-exact")


def load(path):
    return json.loads(path.read_text())


def compressed(path):
    with gzip.open(path) as stream:
        return json.load(stream)


def instruction_class(opcode):
    if opcode.startswith(("global_", "flat_", "buffer_", "ds_", "image_", "scratch_",
                          "s_load_", "s_store_", "s_buffer_")):
        return "memory"
    if opcode.startswith(("s_branch", "s_cbranch", "s_setpc", "s_swappc")):
        return "branch"
    if opcode.startswith(("s_waitcnt", "s_barrier", "s_endpgm", "s_nop")):
        return "wait_barrier_end"
    if opcode.startswith("v_"):
        return "VALU"
    if opcode.startswith("s_"):
        return "SALU"
    return "other"


def disassembly(path, ranges):
    text = path.read_text()
    instructions = [(int(pc, 16), instruction_class(opcode)) for opcode, pc in
                    re.findall(r"^\s+(\w+).*?// ([0-9A-F]+):", text, re.M)]
    assert instructions, path
    entries = {int(pc, 16) for pc in re.findall(r"^([0-9a-f]+) <[^>]+>:", text, re.M)}
    blocks = {}
    counts = None
    for pc, kind in instructions:
        if counts is None or pc in entries:
            counts = Counter()
            blocks[hex(pc)] = counts
        counts[kind] += 1
        if kind == "branch":
            counts = None
    return {key: dict(Counter(kind for pc, kind in instructions if start <= pc <= end))
            for key, (start, end) in ranges.items()} | {
                "whole_kernel": dict(Counter(kind for _, kind in instructions)),
                "machine_blocks": {pc: dict(items) for pc, items in blocks.items()}}


def profile(path):
    with path.open() as stream:
        rows = list(csv.DictReader(stream))
    assert len(rows) == 18 and len({row["Index"] for row in rows}) == 18, path
    rows.sort(key=lambda row: int(row["BeginNs"]))
    measured = rows[3:]
    fields = ("Wavefronts", "VALUInsts", "SALUInsts", "VALUBusy", "MemUnitBusy",
              "MemUnitStalled", "lds", "scr", "arch_vgpr", "sgpr", "wave_size")
    return {"dispatches": rows, "measured_medians": {
        **{field: median(float(row[field]) for row in measured) for field in fields},
        "kernel_us": median((int(row["EndNs"]) - int(row["BeginNs"])) / 1000
                            for row in measured)}}


def block_names(parent):
    text = parent.read_text()
    body = text.split(f"@{KERNEL}(", 1)[1].split("\n}", 1)[0]
    labels = ["%" + name for name in re.findall(r"^([-\w.$]+):", body, re.M)]
    args, instructions = body.split("{\n", 1)
    if not re.match(r"^[-\w.$]+:", instructions.lstrip()):
        unnamed = re.findall(r"\s%(\d+)\b", args.rsplit(")", 1)[0])
        labels.insert(0, "%" + str(len(unnamed)))
    return labels


def pcm_trials(work, extractor):
    b2b = load(CORPUS / "inventory-b2b.json")["regions"]
    all_rows = compressed(CORPUS / "inventory-all.json.gz")["regions"]
    known = {row["id"] for row in [*all_rows, *b2b]}
    small = compressed(RESULTS / "step3b-small-raw.json.gz")
    cached = {}
    out = work / "extracted"

    def root_region(parent, candidate):
        if parent not in cached:
            listing = subprocess.check_output([extractor, parent, COSTS, out], text=True)
            cached[parent] = (block_names(parent), {row["occurrence"]["block"]: row
                              for line in listing.splitlines() if (row := json.loads(line))
                              ["occurrence"]["function"] == KERNEL})
        names, rows = cached[parent]
        split, left, right = candidate.split(":")[-3:]
        root = rows[names[int(split[1:])]]
        if root["kind"].startswith("b2b") and left.startswith("B") and right.startswith("B"):
            text = parent.read_text()
            body = text.split(f"@{KERNEL}(", 1)[1].split("\n}", 1)[0]
            label = root["occurrence"]["block"][1:] + ":"
            block = (body.split(label, 1)[-1] if label in body else body.split("{\n", 1)[1])
            branch = next(line for line in block.splitlines() if line.lstrip().startswith("br i1"))
            targets = re.findall(r"label (%[-\w.$]+)", branch)
            direct = set(targets) == {names[int(left[1:])], names[int(right[1:])]}
        else:
            direct = False
        return {"id": root["id"], "kind": root["kind"], "in_corpus": root["id"] in known,
                "relation": "exact_b2b" if direct else "split_root",
                "block": root["occurrence"]["block"], "join": root["occurrence"]["join"]}

    summaries = {}
    for role in PCM_ROLES:
        search = load(work / role / "summary.json")
        trials = []
        for round_index, round_report in enumerate(search["rounds"]):
            for attempt in round_report["attempts"]:
                folder = Path(attempt["directory"])
                accepted = round_report["selected"] == attempt["directory"]
                if attempt["kind"] != "structural":
                    trials.append({"round": round_index, "candidate": attempt["candidate"],
                                   "trial": folder.name, "accepted": accepted,
                                   "kind": attempt["kind"], "reason": attempt.get("reason"),
                                   "parent_TTI": round_report["parent_cost"],
                                   "cleaned_TTI": attempt.get("cost")})
                    continue
                file = folder / "structural/trial-0/trial.json"
                assert file.is_file(), file
                report = load(file)
                info = report.get("dataflow_exact", {})
                region = root_region(Path(report["parent_ir"]), report["candidate"])
                if info.get("region_id"):
                    assert info["region_id"] == region["id"], report["candidate"]
                record = {"round": round_index, "trial": folder.name,
                          "candidate": report["candidate"], "accepted": accepted,
                          "stage": attempt["stage"], "eligible": attempt["eligible"],
                          "plan_kind": report["fusion_plan"]["kind"],
                          "layout": report["merge_path"], "parent_ir": report["parent_ir"],
                          "region": region, "reason": attempt.get("reason", report["reason"]),
                          "parent_TTI": round_report["parent_cost"],
                          "cleaned_TTI": report["score_result"]["metrics"].get("work_after")}
                if info:
                    record["dataflow_exact"] = info
                if info.get("handler") == "reference_solver" and region["id"] in small:
                    old = small[region["id"]]
                    t = old.get("strategy_choice")
                    entry = next((s for s in old["pareto_front"] if s["T"] == t), {})
                    record["step3b"] = {"original_T": old["original_T"], "choice_T": t,
                                        "pairs": entry.get("pairs"), "recipes": entry.get("recipes")}
                trials.append(record)
        assert sum(t["accepted"] for t in trials) == search["commits"]
        summaries[role] = {"initial_TTI": search["initial_cost"], "final_TTI": search["final_cost"],
                           "commits": search["commits"], "trials": trials}
    return summaries


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("work", type=Path)
    parser.add_argument("extractor", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--static-only", action="store_true")
    args = parser.parse_args()
    dct, pcm = (args.work / name for name in ("dct8", "pcm32"))
    dct_profiles = {role: profile(dct / f"{role}-supported.csv")
                    for role in ("anchor", "dataflow-exact")}
    dct_profiles["anchor"]["assembly"] = disassembly(dct / "anchor.s", {
        "entry": (0x1900, 0x199C), "fallthrough_A": (0x19A0, 0x19EC),
        "second_check": (0x19F0, 0x19F8), "fallthrough_B": (0x19FC, 0x1A48),
        "join": (0x1A50, 0x1A6C), "quantization_region": (0x1980, 0x1A50)})
    dct_profiles["dataflow-exact"]["assembly"] = disassembly(dct / "dataflow-exact.s", {
        "single_block": (0x1900, 0x19FC), "quantization_region": (0x1988, 0x19EC)})
    evidence = {"DCT8": {"profiles": dct_profiles, "occupancy": (dct / "occupancy.txt").read_text()},
                "PCM32": {"greedy": pcm_trials(pcm, args.extractor),
                          "original_TTI": load(pcm / "original-tti.json")["modeled_cost"],
                          "fallback_check": load(pcm / "fallback-test/verified.json"),
                          "occupancy": (pcm / "occupancy.txt").read_text()}}
    if not args.static_only:
        data = evidence["PCM32"]
        data["profiles"] = {role: profile(pcm / "profile" / f"{role}.csv") |
                             {"assembly": disassembly(pcm / "profile" / f"{role}.s", {})}
                             for role in PCM_ROLES}
        data["timing"] = load(pcm / "gpu/timing/results.json")
        assert len(data["timing"]["rounds"]) == 12
        data["validation"] = {}
        for role in ("original", *PCM_ROLES):
            log = (pcm / "gpu" / f"validate-{role}.log").read_text().strip()
            assert log == "PASS 268435456 CPU reference elements per launch", (role, log)
            data["validation"][role] = log
    args.output.write_text(json.dumps(evidence, indent=2) + "\n")


if __name__ == "__main__":
    main()
