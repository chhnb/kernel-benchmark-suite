#!/usr/bin/env python3
"""Run the dataflow B2B regression against the checked-in fixtures."""
import argparse
from concurrent.futures import ThreadPoolExecutor
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
from time import monotonic

ROOT = Path(__file__).resolve().parents[2]
TESTS = ROOT / "tests/dataflow-b2b"
BUILD = ROOT / "build/llvm24-tti"
COSTS = ROOT / "docs/dataflow-b2b/COST_TABLE.json"
MODES = ("abstract", "real")


def load(path):
    return json.loads(path.read_text())


def call(command, timeout):
    return subprocess.run(list(map(str, command)), cwd=ROOT, text=True, capture_output=True,
                          timeout=timeout, check=False)


def report(command, timeout=600):
    result = call(command, timeout)
    try:
        data = json.loads(result.stdout)
    except ValueError as error:
        raise ValueError(result.stderr.strip() or result.stdout.strip() or str(error)) from error
    if result.returncode:
        raise ValueError(f"exit {result.returncode}: {data}")
    return data


def unpack(source, directory):
    if source.suffix != ".gz":
        return source
    dest = directory / source.stem
    dest.write_bytes(gzip.decompress(source.read_bytes()))
    return dest


def select(front, baseline, condition):
    admissible = [v for v in front if condition != "data"
                  or (v[1] <= baseline[1] and v[2] <= baseline[2])]
    if condition == "workgroup-uniform":
        return min([baseline, *sorted(admissible)], key=lambda v: max(v[1:]))
    return min([baseline, *admissible])


def micro(_):
    checks = (
        ("fixtures", 16, [sys.executable, TESTS / "check-micro.py"], "verifier OK;"),
        ("schemes", 34, [sys.executable, ROOT / "tools/dataflow_b2b/check_costs.py",
                         BUILD / "evaluate_cost"], r": \[\d+, \d+, \d+\]$"),
    )
    successes, total = 0, 0
    for name, expected, cmd, marker in checks:
        result = call(cmd, 120)
        print(result.stdout, end="")
        if result.stderr:
            print(result.stderr, end="")
        count = sum(bool(re.search(marker, line)) for line in result.stdout.splitlines())
        if result.returncode and count == expected:
            count = 0
        print(f"{name}: {count}/{expected}")
        successes += min(count, expected)
        total += expected
    return successes, total


def check_all(items, jobs, check):
    def run(item):
        name, value = item
        try:
            check(value)
        except (OSError, KeyError, ValueError, subprocess.SubprocessError) as error:
            return name, str(error)
        return name, None

    with ThreadPoolExecutor(jobs) as pool:
        results = list(pool.map(run, items))
    failures = [(name, reason) for name, reason in results if reason]
    for name, reason in failures:
        print(f"FAIL {name}: {reason}")
    return len(results) - len(failures), len(results)


def fold(args):
    rows = load(TESTS / "corpus/inventory-b2b.json")["regions"]
    if len(rows) != 376:
        raise ValueError(f"expected 376 B2B regions, found {len(rows)}")

    def check(row):
        source = TESTS / "corpus" / row["ir"]
        if source.suffix == ".gz":
            directory = args.work / "fold" / row["id"]
            directory.mkdir(parents=True)
            source = unpack(source, directory)
        result = report([args.work / "check_fold_oracle", source, COSTS], 90)
        guards = result["guards"]
        if (result["status"] != "ok" or len(guards) != 1 or
                guards[0]["predicted"] != guards[0]["actual"] or
                guards[0]["actual"] != row["original_folds"]):
            raise ValueError(f"expected Fold={row['original_folds']}, got {result}")

    return check_all([(r["id"], r) for r in rows], args.jobs, check)


def target_input(source, directory, attributes):
    text = source.read_text()
    group = re.search(r"^define .* #(\d+) \{", text, re.M)
    if not group:
        raise ValueError("source has no generated function attribute group")
    header = "^attributes #" + group[1] + r" = \{ "
    original = next((line for line in text.splitlines() if re.match(header, line)), "")
    if not original or any(f'"{key}"=' in original for key in attributes):
        raise ValueError("target attribute group not suitable for augmentation")
    attributes_ir = " ".join(f'"{key}"="{value}"' for key, value in attributes.items())
    updated = re.sub(header, lambda match: match[0] + attributes_ir + " ", text, count=1, flags=re.M)
    result = directory / "with-target.ll"
    result.write_text(updated)
    return result


def truth(args):
    rows = load(TESTS / "truth/small.json")["regions"]
    unpriced = {row["id"] for row in rows if all(
        row["modes"][mode]["status"] == "unpriced" for mode in MODES)}
    if len(rows) != 188 or unpriced != {"b670a987cbd0b880da2265106c8e56fc5708a607"}:
        raise ValueError("unexpected small-tier fixture coverage")
    print("Excluded b670a987cbd0: ordinary call has no accepted quote in either mode")

    def check(task):
        row, mode = task
        expected = row["modes"][mode]
        directory = args.work / "truth" / mode / row["id"]
        directory.mkdir(parents=True)
        source = unpack(TESTS / "corpus" / row["ir"], directory)
        if target := expected.get("target_attributes"):
            source = target_input(source, directory, target)
        result = report([BUILD / "reference_solver", source, COSTS, directory / "solutions",
                         "--c-sl=real", f"--cost={mode}"], 620)
        if not result["complete"]:
            raise ValueError(f"incomplete enumeration: {result.get('reason')}")
        original = result["original_T"]
        front = [scheme["T"] for scheme in result["pareto_front"]]
        if original != expected["original_T"]:
            raise ValueError(f"original {original} != {expected['original_T']}")
        best = min([original, *front])
        policy = select(front, original, row["condition_source"])
        if best[0] != expected["minimum_D_T"][0] or policy != expected["strategy_T"]:
            raise ValueError(f"min_D={best[0]}, §7.2={policy}; expected "
                             f"{expected['minimum_D_T'][0]}, {expected['strategy_T']}")

    passed = 0
    for mode in MODES:
        items = [(f"{mode}/{r['id']}", (r, mode)) for r in rows if r["id"] not in unpriced]
        n, total = check_all(items, args.jobs, check)
        print(f"{mode}: {n}/{total}")
        passed += n
    return passed, 2 * (len(rows) - len(unpriced))


def context(args, strategy="dataflow-exact"):
    manifest = load(TESTS / "context/candidates.json")
    candidate = next(row for row in manifest["candidates"] if row["case"] == "DCT8" and
                     row["region_id"].startswith("d23a7c228c5b"))
    parent = candidate["parent"]
    directory = args.work / ("context" if strategy == "dataflow-exact" else "context-dataflow")
    directory.mkdir()
    source = unpack(TESTS / "context" / parent["ir"], directory)
    if hashlib.sha256(source.read_bytes()).hexdigest() != parent["sha256"]:
        raise ValueError("DCT8 parent SHA-256 mismatch")
    function = candidate["function"]
    checked_pair = int(strategy == "dataflow")
    if checked_pair:
        # Test the standalone choice on the actual isolated region used by the
        # pipeline, with the condition source captured in its parent context.
        uid = candidate["region_id"]
        region = next(row for row in load(TESTS / "corpus/inventory-b2b.json")["regions"]
                      if row["id"] == uid)
        region_ir = unpack(TESTS / "corpus" / region["ir"], directory)
        plan = report([BUILD / "dataflow_solver", region_ir, COSTS, directory / "pairing", "--cost=real",
                       f"--condition-source={candidate['location']['condition_source']}"], 240)
        chosen = plan.get("selected", {})
        groups = [*plan.get("schemes", {}).values(), *plan.get("subsets", [])]
        ops = {row["left_index"]: row["opcode"] for scheme in groups for row in scheme.get("pairing", [])}
        selected_ops = {ops.get(match["left_index"]) for match in chosen.get("pairs", [])}
        if not {"sext", "sdiv"}.issubset(selected_ops):
            raise ValueError(f"DCT8 {uid} selected pairs lack sext/sdiv: {chosen}")
        print(f"DCT8 {uid[:12]}: sext and sdiv paired; T={chosen['T']}")
    search = directory / strategy
    run = call([ROOT / "build/decision-fuse/decision-greedy", source, function, ROOT, search,
                "--b2b-strategy", strategy, "--ir-snapshots", "compact"], 240)
    if run.returncode:
        raise ValueError(run.stderr or run.stdout)
    actual = report([ROOT / "tools/run-llvm24-tti", search / "final.ll", function], 90)["cost"]
    recorded = load(search / "summary.json")["final_cost"]
    if actual != 44 or actual != recorded:
        raise ValueError(f"DCT8 final expected 44, got {actual} (greedy recorded {recorded})")
    print(f"DCT8 {strategy} kernel TTI: {actual}")
    return 1 + checked_pair, 1 + checked_pair


def check_native_commits(search, compare_rejected=False):
    checked = 0
    for step, row in enumerate((r for r in load(search / "summary.json")["rounds"]
                                if r.get("selected")), 1):
        path = Path(row["selected"]) / "structural/trial-0/trial.json"
        if not path.is_file():
            continue
        trial = load(path)
        logs = trial.get("dataflow", trial.get("dataflow_exact", {}))
        bound = logs.get("native_anchor_kernel_TTI")
        if bound is None or not (logs["native_anchor_eligible"] or compare_rejected):
            continue
        if row["selected_cost"] > bound:
            raise ValueError(f"step {step} {trial['candidate']}: {row['selected_cost']} > {bound}")
        checked += 1
    if not checked:
        raise ValueError("no audited B2B commit")
    print(f"{search.name}: {checked} committed B2B trials audited")


def native_layouts(args):
    dct = args.work / "context-dataflow" / "dataflow"
    # The DCT8 anchor trial quotes 62, but does not accept that layout.
    check_native_commits(dct, compare_rejected=True)
    fixtures = load(TESTS / "context/native-layouts.json")
    release = load(ROOT / "regression/golden/20261120-anchor-release/manifest.json")

    def probe(task):
        index, spec = task
        workspace = args.work / "native-layout" / str(index)
        workspace.mkdir(parents=True)
        source = unpack(TESTS / "context" / spec["ir"], workspace)
        if hashlib.sha256(source.read_bytes()).hexdigest() != spec["sha256"]:
            raise ValueError("unexpected parent hash")
        trace = workspace / "trace"
        run = call([BUILD / "fusion-search-llvm24", "--ir", source, "--function", spec["function"],
                    "--split", spec["split"], "--left", spec["left"], "--right", spec["right"],
                    "--out", workspace / "fused.ll", "--debug-dir", trace, "--ir-snapshots", "compact",
                    "--b2b-strategy", "anchor-unified", "--dataflow-solver", BUILD / "dataflow_solver",
                    "--dataflow-costs", COSTS, "--tti-worker", ROOT / "tools/run-llvm24-tti"], 180)
        if run.returncode:
            raise ValueError(run.stderr or run.stdout)
        trial = load(trace / "trial-0/trial.json")
        stats = trial["dataflow_exact"]
        native, selected = stats["native_anchor_kernel_TTI"], stats["chosen"]["kernel_TTI"]
        if not (stats["native_anchor_eligible"] and trial["eligible"] and selected <= native == spec["native_tti"]):
            raise ValueError(f"unexpected selection: chosen={selected} anchor={native}")
        print(f"{spec['case']}: chosen {selected} <= native {native}")

    def srad(_):
        import tarfile
        root = ROOT / "regression/golden/20261120-anchor-release"
        fixture = next(r for r in release["cases"] if r["case"] == "SRAD16")
        directory = args.work / "native-layout" / "SRAD16"
        directory.mkdir(parents=True)
        source = directory / "input.ll"
        with tarfile.open(root / release["archive"]["file"], "r:gz") as archive:
            source.write_bytes(archive.extractfile(fixture["input"]["archive_entry"]).read())
        if hashlib.sha256(source.read_bytes()).hexdigest() != fixture["input"]["sha256"]:
            raise ValueError("unexpected SRAD16 input")
        run = call([ROOT / "build/decision-fuse/decision-greedy", source, fixture["function"],
                    ROOT, directory / "dataflow", "--b2b-strategy", "dataflow",
                    "--ir-snapshots", "compact"], 180)
        if run.returncode:
            raise ValueError(run.stderr or run.stdout)
        check_native_commits(directory / "dataflow")

    items = [(spec["case"], (probe, (i, spec))) for i, spec in enumerate(fixtures)]
    items.append(("SRAD16", (srad, None)))
    passed, total = check_all(items, args.jobs, lambda item: item[0](item[1]))
    return 1 + passed, 1 + total


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("work", type=Path)
    parser.add_argument("--jobs", type=int, default=12)
    args = parser.parse_args()
    if args.jobs < 1:
        parser.error("--jobs must be positive")
    from measure_generation import anchor_parity_goals, empty_placement, pairing_gates, small_generation

    stages = (("Micro", micro, 50), ("Fold oracle", fold, 376),
              ("Small truth", truth, 374), ("Context", context, 1),
              ("Dataflow context", lambda args: context(args, strategy="dataflow"), 2),
              ("Scalable vs subset DP", small_generation, 374), ("Pairing goals", pairing_gates, 4),
              ("Empty pairing", empty_placement, 373), ("Anchor parity goals", anchor_parity_goals, 15),
              ("Native layout bounds", native_layouts, 4))
    results = []
    suite_start = monotonic()
    for name, run, total in stages:
        print(f"\n== {name} ==", flush=True)
        start = monotonic()
        try:
            passed, total = run(args)
        except (OSError, ValueError, KeyError, StopIteration, subprocess.SubprocessError) as error:
            print(f"FAIL {name}: {error}")
            passed = 0
        results.append((name, passed, total, monotonic() - start))
    print("\n== Summary ==")
    for name, passed, total, seconds in results:
        print(f"{name}: {passed}/{total} ({seconds:.2f} s)")
    passed = sum(row[1] for row in results)
    total = sum(row[2] for row in results)
    print(f"Total: {passed}/{total} ({monotonic() - suite_start:.2f} s)")
    return int(passed != total)


if __name__ == "__main__":
    sys.exit(main())
