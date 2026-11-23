#!/usr/bin/env python3
"""Collect the pinned input sources and accepted Greedy parents on epyc."""

import argparse
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
ROSTER = {
    "BIT": (32, 64, 128, 256),
    "DCT": (4, 8, 16),
    "LUD": (8, 16, 32, 64, 128),
    "MS": (32, 64, 128, 256),
    "NQU": (64, 96, 128, 256),
    "PCM": (32, 64, 128, 256),
    "SRAD": (16, 32),
}
ARTIFACT = "7d2e45b77e5502eeab42bea43f696ccb89172e58"
ORDERED = Path("regression/greedy-v1/manifest-ordered-20261119.json")
STEP0 = "d4ad2e89f4704c408165e002c4082e90e7f949dc"
VALIDATION = "regression/greedy-v1/tree-domain-reactivation-validation.json"
CASE_ALIAS = {
    "MapAiry": "boost-mapairy",
    "HLLD": "cholla-hlld",
    "NQU64": "nqu64",
    "MS32": "ms32",
    "PCM32": "pcm32",
    "SRAD16": "srad",
    "SRAD32": "srad",
    "Landau": "boost-landau",
    "SW2D": "sw2d",
    "CED": "ced",
    "TPACF": "tpacf",
    "SRAD-stage2": "srad-stage2",
    "LUD8": "lud8",
    "tigre": "tigre-siddon",
    "vllm": "vllm-quant",
}


def git(*args):
    return subprocess.check_output(["git", "-C", ROOT, *args])


def decode(path, data):
    return gzip.decompress(data) if path.endswith(".gz") else data


def load_ir(source):
    path = source["path"]
    commit = source.get("git_commit")
    data = git("show", f"{commit}:{path}") if commit else (ROOT / path).read_bytes()
    return decode(path, data)


def block_size(case):
    match = re.fullmatch(r"(?:BIT|DCT|LUD|MS|NQU|PCM|SRAD)([0-9]+)(?:-.*)?", case, re.I)
    return int(match[1]) if match else None


def collect(work, output):
    sources = []
    rejected = []
    registered = set()

    def add(category, case, path, *, size=None, commit=None, expected=None, **generation):
        source = {
            "category": category,
            "case": case,
            "block_size": size if size is not None else block_size(case),
            "path": str(path),
            "generation": generation,
        }
        if commit:
            source["git_commit"] = commit
        if not commit and not (ROOT / path).is_file():
            rejected.append({**source, "reason": "IR file was not present"})
            return
        source["sha256"] = hashlib.sha256(load_ir(source)).hexdigest()
        if expected and expected != source["sha256"]:
            raise ValueError(f"{path}: {source['sha256']} != recorded hash {expected}")
        key = category, case, str(path), generation.get("step"), generation.get("run_record")
        if key not in registered:
            registered.add(key)
            sources.append(source)
        return source

    ordered = json.loads((ROOT / ORDERED).read_text())
    roster = {(case, size) for case, sizes in ROSTER.items() for size in sizes}
    found = set()
    for item in ordered["cases"]:
        match = re.fullmatch(r"([A-Z]+)(\d+)(?:-.*)?", item["case"])
        if not match:
            continue
        case, size = match[1], int(match[2])
        if (case, size) not in roster or (case, size) in found:
            continue
        add("darm", case, ORDERED.parent / item["input"], size=size,
            commit=STEP0, expected=item["input_sha256"], manifest=str(ORDERED),
            original_path=item["source"])
        found.add((case, size))

    for row in json.loads((work / "compiled.json").read_text()):
        case, size = row["case"], row["block_size"]
        if row["ok"]:
            path = (output / "sources" / f"{case}{size}.ll").relative_to(ROOT)
            (ROOT / path).parent.mkdir(parents=True, exist_ok=True)
            (ROOT / path).write_bytes(Path(row["path"]).read_bytes())
            generation = dict(row["generation"])
            generation["upstream_path"] = generation.pop("path")
            add("darm", case, path, size=size, **generation)
            found.add((case, size))
        else:
            rejected.append({"category": "darm", "case": case, "block_size": size,
                             "reason": row["error"], "generation": row["generation"]})
    for case, size in sorted((roster | {("gpu_example", 32)}) - found):
        if not any(r["case"] == case and r["block_size"] == size for r in rejected):
            rejected.append({"category": "darm", "case": case, "block_size": size,
                             "reason": "no matching manifest row or successful upstream compilation"})
    for name in ("SB1", "SB2", "SB3", "SB4"):
        rejected.append({"category": "darm", "case": name, "block_size": None,
                         "reason": "upstream synthetic benchmark source is not public"})

    tracked = git("ls-tree", "-r", "--name-only", STEP0, "cases").decode().splitlines()
    for name in tracked:
        if name.endswith((".ll", ".ll.gz", ".bc", ".bc.gz")):
            add("project", Path(name).parts[1], name, commit=STEP0, origin="tracked case IR")

    release_cases = json.loads(git("show", f"{ARTIFACT}:artifact/manifest.json"))["cases"]
    listed = git("ls-tree", "-r", "--name-only", ARTIFACT, "artifact/inputs").decode().splitlines()
    mapped = set()
    for case in release_cases:
        name, digest = case["name"], case["input_sha256"]
        path = f"artifact/inputs/{digest}.ll.gz"
        if path not in listed:
            raise ValueError(f"artifact manifest does not resolve: {path}")
        mapped.add(path)
        add("project", name, path, commit=ARTIFACT, expected=digest,
            origin="artifact/run", manifest="artifact/manifest.json")
        alias = CASE_ALIAS[name]
        config = f"cases/{alias}/case.json"
        if not any(row["case"] == alias and row["sha256"] == digest for row in sources):
            add("project", alias, path, size=block_size(name), commit=ARTIFACT,
                expected=digest, origin="artifact/run input for case", case_config=config)
    for path in sorted(set(listed) - mapped):
        digest = Path(path).name.split(".")[0]
        add("project", "artifact-" + digest[:12], path, commit=ARTIFACT, expected=digest,
            origin="unmapped artifact/run input")

    for alias in ("vllm-quant-kv-dump", "vllm-quant-large", "vllm-quant-qwen64k"):
        config = f"cases/{alias}/case.json"
        base = json.loads((ROOT / "cases/vllm-quant/case.json").read_text())["runtime"]
        variant = json.loads((ROOT / config).read_text())["runtime"]
        if base["default_kernel"] != variant["default_kernel"]:
            raise ValueError(f"{config} does not reuse the vLLM device kernel")
        add("project", alias, "cases/vllm-quant/start.ll", commit=STEP0,
            origin="shared vllm-quant runtime kernel", case_config=config,
            runtime_kernel=variant["default_kernel"])

    # These locations are actual input IR from the documented comparison runs.
    history = Path.home() / "simplify-v2/build"
    historical = {
        "hypersonic": [
            ("", "regression/greedy-v1/manifest-ordered-20261119.json"),
        ],
        "cudaflow-particles": [
            ("b2b-layouts/anchor-default/CUDAflow/start.ll",
             "regression/records/b2b-anchor-ablation-20261120.md"),
        ],
        "hipims": [
            ("region-audit/extra/HiPIMS-HLLC/start.ll",
             "regression/records/region-fusion-audit-20261120.md"),
            ("b2b-layouts/anchor-ablation/heldout/HiPIMS-George/start.ll",
             "regression/records/b2b-anchor-ablation-20261120.md"),
        ],
        "boost-saspoint5": [
            ("b2b-layouts/anchor-ablation/heldout/SasPoint5/start.ll",
             "regression/records/b2b-anchor-ablation-20261120.md"),
        ],
    }
    for name, inputs in historical.items():
        for relative, record in inputs:
            if relative:
                add("project", name, history / relative, origin="epyc historical input",
                    run_record=record)
            else:
                item = next(row for row in ordered["cases"] if row["case"] == name)
                add("project", name, ORDERED.parent / item["input"], commit=STEP0,
                    expected=item["input_sha256"], origin="archived exact historical input",
                    run_record=record, original_path=item["source"])
    names = {Path(name).parts[1] for name in tracked if name.count("/") >= 2}
    present = {row["case"] for row in sources if row["category"] == "project"}
    for case in sorted(names - present):
        reason = "no verifiable historical input IR found on epyc"
        if case == "reentry":
            reason += "; historical LLVM12 HIP build failed, and ROCm 6 input used opaque pointers"
        rejected.append({"category": "project", "case": case, "block_size": block_size(case),
                         "reason": reason, "run_record": "regression/records/b2b-anchor-ablation-20261120.md"})

    def snapshot_series(summary, case, record):
        data = json.loads(summary.read_text())
        if data.get("status") != "completed":
            rejected.append({"category": "snapshot", "case": case, "block_size": block_size(case),
                             "reason": "Greedy run did not complete", "run_record": str(summary)})
            return
        rounds = [i for i in data["rounds"] if i.get("selected") and "selected_cost" in i]
        if len(rounds) != data["commits"]:
            raise ValueError(f"{summary}: accepted rounds do not match commit count")
        previous = None
        for step, row in enumerate(rounds, start=1):
            selected = Path(row["selected"])
            parent = Path(row["parent"])
            path = selected / "fused.ll"
            if not path.is_file():
                path = summary.parent / selected.name / "fused.ll"
            if not path.is_file() and step == len(rounds):
                terminal = summary.parent / "final.ll"
                if terminal.is_file():
                    path = terminal
            if previous and parent.name == "fused.ll" and previous.parent.name != parent.parent.name:
                raise ValueError(f"{summary}: step {step} does not use the previous committed parent")
            add("snapshot", case, path, origin="committed Greedy parent",
                step=step, commit_count=data["commits"], previous_parent=str(parent),
                saved_directory=str(summary.parent), run_record=str(summary), repository_record=record,
                selected_cost=row["selected_cost"])
            previous = path

    domain = Path.home() / "domain-reactivation/build"
    freeze = domain / "frozen-parity"
    summaries = sorted(freeze.glob("*/summary.json"))
    if not summaries:
        raise ValueError(f"no frozen Greedy series in {freeze}")
    for path in summaries:
        snapshot_series(path, path.parent.name, VALIDATION)

    snapshot_series(domain / "PCM256-0/summary.json", "PCM256", VALIDATION)
    held = history / "b2b-layouts/anchor-ablation/heldout"
    for name in ("CED", "HiPIMS-George", "SasPoint5", "SRAD-stage2", "TPACF"):
        path = held / name / "A/summary.json"
        if path.is_file():
            snapshot_series(path, name, "regression/records/b2b-anchor-ablation-20261120.md")

    totals = {}
    for row in sources:
        totals[row["category"]] = totals.get(row["category"], 0) + 1
    print(f"Sources: {totals}; exclusions: {len(rejected)}")
    for case in ("LUD8", "PCM32", "NQU64", "SRAD16", "MS32", "MapAiry"):
        found_steps = [r for r in sources if r["category"] == "snapshot"
                       and (r["case"] == case or r["case"].startswith(case + "-"))]
        print(case, "saved steps:", len(found_steps))
    output.mkdir(parents=True, exist_ok=True)
    with (output / "sources.json").open("w") as file:
        json.dump({"sources": sources, "excluded": rejected}, file, indent=2)
        file.write("\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--work", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    collect(args.work.resolve(), args.output.resolve())
