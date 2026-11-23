#!/usr/bin/env python3
"""Substitute one measured candidate in an otherwise unchanged anchor trace."""
import argparse
from concurrent.futures import ThreadPoolExecutor
import os
import json
from pathlib import Path
import subprocess

from measure_step7 import CASES, invoke, read, write


def trial_dir(row):
    return Path(row["trial"]).parents[2].name


def comparison_price(row):
    measurement = row["scope"].get("anchor", {})
    clean = measurement.get("options", {}).get("ir", {})
    if clean.get("T") and clean.get("outside_retained") == measurement.get("marked"):
        return clean, "context-cleaned"
    outlined = row["replays"]["anchor"]["region_T"]
    if outlined.get("T"):
        return outlined, "same-plan-outlined-cleaned"
    return {}, "unpriced-cleaned"


def choices(rows, solver):
    result = []
    for i, row in enumerate(rows):
        if row["case"] not in CASES or not row["direct"]:
            continue
        anchor, basis = comparison_price(row)
        run = solver[i]["ilp"]
        for objective in ("min_D", "strategy"):
            choice = run.get(objective, {})
            if anchor.get("T") and choice.get("T"):
                value = choice["T"][0]
                result.append({"case": row["case"], "row": i, "objective": objective,
                               "regret": anchor["T"][0] - value, "anchor_T": anchor["T"], "basis": basis,
                               "optimal": choice["optimal"], "choice": choice,
                               "solver_folder": run["folder"]})
    return result


def report_base(work, case):
    return read(work / case / "anchor/summary.json")


def try_replay(work, row, item):
    region = row["region"]
    choice = item["choice"]
    if choice.get("original"):
        art = work / "regions" / region["ir"]
    elif choice.get("ir"):
        art = Path(item["solver_folder"]) / choice["ir"]
    else:
        return {"status": "solver_IR_unavailable"}
    base = report_base(work, row["case"])
    folder = work / row["case"] / "replacement-clean"
    folder.mkdir(exist_ok=True)
    replaced = folder / "replacement.ll"
    block = row["candidate"].rsplit(":", 3)[1:]
    step = invoke([work / "step7_context", "replace", row["parent"], row["symbol"],
                   *block, art, replaced])
    if step.returncode:
        return {"status": "cannot_reinsert", "reason": step.stderr}
    cost = invoke(["tools/run-llvm24-tti", replaced, row["symbol"]])
    if cost.returncode:
        return {"status": "cannot_quote", "reason": cost.stderr}
    base_round = base["rounds"][row["round"]]
    config = {"round": row["round"], "trial": trial_dir(row), "candidate": row["candidate"],
              "parent_cost": base_round["parent_cost"], "ir": str(replaced),
              "cost": json.loads(cost.stdout)["cost"]}
    output = folder / "anchor"
    if not (output / "final.ll").exists():
        config_path = folder / "override.json"
        write(config_path, config)
        with (folder / "output.log").open("w") as log:
            process = subprocess.run([str(work / "step7_replay"), str(work / row["case"] / "input.ll"),
                                      row["symbol"], str(Path.cwd()), str(output),
                                      "--b2b-strategy", "anchor", "--ir-snapshots", "compact"],
                                     env=os.environ | {"STEP7_OVERRIDE": str(config_path),
                                                       "DECISION_GREEDY_JOBS": "12"},
                                     stdout=log, stderr=subprocess.STDOUT, timeout=600)
        if process.returncode:
            return {"status": "replay_failed", "reason": (folder / "output.log").read_text()[-1000:]}
    after = read(output / "summary.json")
    base_prefix = [(r["selected_cost"], Path(r["selected"]).name)
                   for r in base["rounds"][:row["round"]] if r["selected"]]
    replay_prefix = [(r["selected_cost"], Path(r["selected"]).name)
                     for r in after["rounds"][:row["round"]] if r["selected"]]
    if base_prefix != replay_prefix:
        raise ValueError(f"{row['case']} prefix changed unexpectedly")
    after_round = after["rounds"][row["round"]]
    selected = Path(after_round["selected"])
    assert selected.name == config["trial"]
    observed = read(selected / "structural/trial-0/trial.json")["parent_ir"]
    lines = lambda path: Path(path).read_text().splitlines()[1:]
    if lines(observed) != lines(row["parent"]):
        raise ValueError(f"{row['case']} prepared parent changed unexpectedly")
    return {"status": "completed", "selected_trial": config["trial"], "at_step_TTI": config["cost"],
            "final": after["final_cost"], "baseline": base["final_cost"], "commits": after["commits"],
            "prefix_commits": len(base_prefix)}


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("work", type=Path)
    a = p.parse_args()
    work = a.work.resolve()
    rows, solved = (read(work / name) for name in ("context.json", "solved.json"))
    assert all((x["parent"], x["candidate"]) == (y["parent"], y["candidate"]) for x, y in zip(rows, solved))
    priced = choices(rows, solved)
    def evaluate(case):
        candidates = [r for r in priced if r["case"] == case and r["objective"] == "min_D"]
        if not candidates:
            return {"case": case, "status": "no_comparable_solution"}
        best = min(candidates, key=lambda r: (-r["regret"], -r["optimal"], r["row"]))
        row = rows[best["row"]]
        replay = try_replay(work, row, best)
        return best | replay | {"step": row["step"], "region": row["region"]["id"]}

    with ThreadPoolExecutor(5) as workers:
        results = list(workers.map(evaluate, CASES))
    write(work / "paths.json", results)


if __name__ == "__main__":
    main()
