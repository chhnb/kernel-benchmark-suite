#!/usr/bin/env python3
"""Measure contextual B2B candidates along the frozen greedy traces."""
import argparse
from collections import Counter
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from check_step5_small import COSTS, read_solution
from collect_step6 import Kernel

ROLES = ("anchor", "darm")
CASES = ("DCT8", "NQU64", "PCM32", "SRAD16", "MapAiry")
BUILD = Path("build/llvm24-tti")
EXTRACT = Path("build/dataflow-corpus/step4a/extract_regions")


def write(path, value):
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False) + "\n")


def invoke(args, timeout=90):
    return subprocess.run(list(map(str, args)), text=True, capture_output=True, timeout=timeout)


def read(path):
    return json.loads(path.read_text())


def discover(work, folders):
    results = []
    cache = {}
    extracted = work / "regions"
    extracted.mkdir(exist_ok=True)
    for case, role, folder in folders:
        report = read(folder / "summary.json")
        if report["status"] != "completed":
            raise ValueError(folder)
        for index, rnd in enumerate(report["rounds"]):
            for attempt in rnd["attempts"]:
                attempt_dir = Path(attempt.get("directory", "."))
                source = attempt_dir / "structural/trial-0/trial.json"
                if not source.exists():
                    continue
                data = read(source)
                if data["fusion_plan"]["kind"] != "B2B":
                    continue
                symbol, split, left, right = data["candidate"].rsplit(":", 3)
                parent = Path(data["parent_ir"])
                if (parent, symbol) not in cache:
                    rows = subprocess.check_output([EXTRACT, parent, COSTS, extracted], text=True)
                    kernel = Kernel(parent, symbol)
                    cache[parent, symbol] = kernel, {
                        r["occurrence"]["block"]: r for line in rows.splitlines()
                        if (r := json.loads(line))["occurrence"]["function"] == symbol}
                kernel, listing = cache[parent, symbol]
                names = list(kernel.blocks)
                desc = listing.get(names[int(split[1:])]) if split.startswith("B") else None
                direct = (desc and desc.get("ir") and left.startswith("B") and right.startswith("B")
                          and set(kernel.branches.get(names[int(split[1:])], ())[1:]) ==
                          {names[int(left[1:])], names[int(right[1:])]})
                results.append({"case": case, "source_role": role, "round": index, "step": index + 1,
                                "committed": rnd["selected"] == str(attempt_dir), "trial": str(source),
                                "candidate": data["candidate"], "parent": str(parent), "symbol": symbol,
                                "parent_sha256": hashlib.sha256(parent.read_bytes()).hexdigest(),
                                "strategy_record": data, "region": desc, "direct": bool(direct)})
    return results


def search(source, symbol, blocks, role, folder):
    folder.mkdir(parents=True, exist_ok=True)
    result = folder / "result.json"
    if result.exists():
        return read(result)
    lr = [str(x) for k, v in zip(("--split", "--left", "--right"), blocks) for x in (k, v)]
    out = folder / "after.ll"
    command = [BUILD / "fusion-search-llvm24", "--ir", source, "--function", symbol, *lr,
               "--b2b-strategy", role, "--tti-worker", "tools/run-llvm24-tti",
               "--debug-dir", folder / "debug", "--out", out, "--ir-snapshots", "full"]
    process = subprocess.run(list(map(str, command)), text=True, capture_output=True, timeout=90,
                             env=os.environ | {"FUSION_OBSERVE_B2B_DP": os.devnull})
    report = folder / "debug/trial-0/trial.json"
    value = {"status": "ok" if process.returncode == 0 else "unavailable",
             "stderr": process.stderr, "ir": str(out) if out.exists() else None}
    if report.exists():
        record = read(report)
        value.update(record=record, raw=str(report.parent / "after-raw.ll"))
    write(result, value)
    return value


def direct_pair(path):
    k = Kernel(path, "region")
    names = list(k.blocks)
    name, (_, a, b) = next(iter(k.branches.items()))
    return [f"B{names.index(x)}" for x in (name, a, b)]


def solver_key(row):
    region = row["region"]
    hint = row["strategy_record"].get("anchor", {}).get("dataflow_hint")
    return region["id"], region["occurrence"]["condition_source"], json.dumps(hint, sort_keys=True)


def solver(row, args):
    region = row["region"]
    if not row["direct"]:
        return {"status": "unsupported", "reason": "candidate is not a direct extractable B2B"}
    source = args.work / "regions" / region["ir"]
    original = row["strategy_record"]
    hint = original.get("anchor", {}).get("dataflow_hint")
    key = hashlib.sha256(json.dumps(solver_key(row)).encode()).hexdigest()[:10]
    folder = args.work / "solutions" / f"{region['id']}-{key}"
    folder.mkdir(parents=True, exist_ok=True)
    report = folder / "result.json"
    if report.exists():
        return read(report)
    opt = []
    if hint and hint["pairs"]:
        hint_path = folder / "hint.json"
        write(hint_path, hint)
        opt = ["--anchor-hint", hint_path]
    data = read_solution([sys.executable, "tools/dataflow_b2b/ilp_solver", source, COSTS, folder,
                          "--cost", "real", "--seconds", str(args.seconds), "--condition-source",
                          region["occurrence"]["condition_source"], *opt], args.seconds + 10)
    data["folder"] = str(folder)
    write(report, data)
    return data


def quote(path, region):
    flags = ["--output-buffer"] if region.get("num_outputs", 0) > 1 else []
    report = read_solution([BUILD / "evaluate_cost", path, COSTS, "--cost=real",
                            "--after-cleanup", *flags], 90)
    report.pop("operations", None)
    return report


def book_keeping(report):
    values = report.get("record", {}).get("score_result", {}).get("metrics", {})
    return {key: values.get(key) for key in ("work_before", "work_after", "side_true_before",
                                            "side_true_after", "side_false_before", "side_false_after")}


def fingerprint(stats):
    return {key: stats.get(key) for key in ("dataflow_hint", "emission", "mode", "segments",
                                            "charged_segments", "anchor_count", "cutoffs")}


def measure(row, work):
    block = row["candidate"].rsplit(":", 3)[1:]
    key = hashlib.sha256(f"{row['parent']}:{row['candidate']}".encode()).hexdigest()[:14]
    folder = work / "comparisons" / key
    roles = ROLES if row["case"].startswith("LUD8") else ("anchor",)
    output = {}
    for role in roles:
        context = search(Path(row["parent"]), row["symbol"], block, role, folder / role)
        stat = book_keeping(context)
        record = context.get("record", {})
        if role == row["source_role"]:
            expected = row["strategy_record"].get("score_result", {}).get("metrics", {}).get("work_after")
            assert expected == stat["work_after"], (row["candidate"], expected, stat)
        score = {"kernel": stat, "context": context}
        if row["direct"] and context["status"] == "ok":
            region = row["region"]
            source = work / "regions" / region["ir"]
            subdir = folder / ("outlined-" + role)
            local = search(source, "region", direct_pair(source), role, subdir)
            if local["ir"]:
                selected = Path(local["ir"])
                if role == "anchor":
                    actual = fingerprint(record.get("anchor", {}))
                    plans = local["record"].get("layout_profitability", [])
                    matching = [p for p in plans if p["valid"] and fingerprint(p["anchor"]) == actual]
                    if not matching:
                        score["region_T"] = {"status": "unmatched_context_plan", "standalone": quote(selected, region)}
                    else:
                        plan = matching[0]["layout"]
                        named = subdir / "debug" / (plan + "-cleaned.ll")
                        score["region_T"] = quote(named if named.exists() else selected, region)
                        score["region_plan"] = plan
                else:
                    score["region_T"] = quote(selected, region)
                    score["region_plan"] = local["record"].get("merge_path")
                score["outlined"] = local
            else:
                score["region_T"] = {"status": "outlined_plan_unavailable", "reason": local["stderr"]}
        else:
            score["region_T"] = {"status": "not_direct" if not row["direct"] else context["status"]}
        output[role] = score
    return {"index": row["index"], "replays": output}


def scope(row, work):
    if not row["direct"]:
        return {}
    blocks = row["candidate"].rsplit(":", 3)[1:]
    key = hashlib.sha256(f"{row['parent']}:{row['candidate']}".encode()).hexdigest()[:14]
    folder = work / "comparisons" / key / "context-v2"
    folder.mkdir(exist_ok=True)
    binary = work / "step7_context"
    source = folder / "tagged.ll"
    tagged = invoke([binary, "tag", row["parent"], row["symbol"], *blocks, source])
    if tagged.returncode:
        return {"status": "tagging_failed", "reason": tagged.stderr}
    marked = int(tagged.stdout)
    result = {}
    for role, baseline in row["replays"].items():
        trial = search(source, row["symbol"], blocks, role, folder / role)
        after = book_keeping(trial).get("work_after")
        actual = trial.get("record", {})
        expected = baseline["context"].get("record", {})
        if (after != baseline["kernel"]["work_after"] or
                actual.get("merge_path") != expected.get("merge_path") or
                (role == "anchor" and fingerprint(actual.get("anchor", {})) !=
                 fingerprint(expected.get("anchor", {})))):
            result[role] = {"status": "marked_trial_changed", "expected": baseline["kernel"]["work_after"],
                            "actual": after}
            continue
        options = {}
        for name in ("raw", "ir"):
            path = trial.get(name)
            if path and Path(path).is_file():
                p = invoke([binary, "price", path, row["symbol"], "tools/run-llvm24-tti"])
                options[name] = json.loads(p.stdout) if p.returncode == 0 else {"error": p.stderr.strip()}
        quote = next((options[key] | {"snapshot": key} for key in ("raw", "ir")
                      if options.get(key, {}).get("outside_retained") == marked), {})
        result[role] = {"status": "ok" if quote else "scope_unverified", "marked": marked,
                        "price": quote, "options": options}
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("work", type=Path)
    parser.add_argument("--jobs", type=int, default=72)
    parser.add_argument("--seconds", type=int, default=120)
    parser.add_argument("--replay", action="store_true")
    parser.add_argument("--context", action="store_true")
    args = parser.parse_args()
    args.work = args.work.resolve()
    if args.context:
        manifest = read(args.work / "compared.json")
        keys = {}
        for row in manifest:
            keys.setdefault((row["parent"], row["candidate"]), row)
        with ThreadPoolExecutor(min(args.jobs, 24)) as pool:
            results = dict(zip(keys, pool.map(lambda row: scope(row, args.work), keys.values())))
        for row in manifest:
            row["scope"] = results[row["parent"], row["candidate"]]
        write(args.work / "context.json", manifest)
        return
    if args.replay:
        manifest = read(args.work / "candidates.json")
        keys = {}
        for i, row in enumerate(manifest):
            row["index"] = i
            keys.setdefault((row["parent"], row["candidate"], row["case"].startswith("LUD8")), row)
        with ThreadPoolExecutor(min(args.jobs, 24)) as pool:
            results = dict(zip(keys, pool.map(lambda row: measure(row, args.work), keys.values())))
        for row in manifest:
            key = (row["parent"], row["candidate"], row["case"].startswith("LUD8"))
            row.update(replays=results[key]["replays"])
        write(args.work / "compared.json", manifest)
        return
    folders = [(case, "anchor", args.work / case / "anchor") for case in CASES]
    bins = [("LUD8", role, args.work / "lud8" / f"_Z13lud_perimeterPfii-{role}") for role in ROLES]
    bins += [("LUD8-common", role, args.work / "lud8-common" / role) for role in ROLES]
    manifest = discover(args.work, folders + bins)
    write(args.work / "candidates.json", manifest)
    print(Counter((m["case"], m["direct"]) for m in manifest), flush=True)
    tasks = {}
    for row in manifest:
        if row["case"] in CASES and row["direct"]:
            tasks.setdefault(solver_key(row), row)
    with ThreadPoolExecutor(args.jobs) as pool:
        cache = dict(zip(tasks, pool.map(lambda row: solver(row, args), tasks.values())))
    for row in manifest:
        if row["case"] in CASES:
            row["ilp"] = cache[solver_key(row)] if row["direct"] else solver(row, args)
    write(args.work / "solved.json", manifest)


if __name__ == "__main__":
    main()
