#!/usr/bin/env python3
"""Version 1 acceptance rules for the whole-function Greedy driver."""

import argparse
from collections import Counter, defaultdict
import hashlib
import json
import math
import os
from pathlib import Path
import re
import subprocess
import tempfile
import time

from compile_kernel import compile_kernel


RULE_VERSION = 1
MAX_THROUGHPUT_LOSS = 128
LANE_LIMIT_NUMERATOR = 11
LANE_LIMIT_DENOMINATOR = 10
ROOT = Path(__file__).resolve().parents[1]
ROCM = Path("/opt/rocm-6.3.3")

# AMD Vega 7nm ISA 70655, compute-unit overview and LDS chapter:
# wave64, four SIMD16, 32 LDS banks at four bytes per bank per clock.
# https://docs.amd.com/v/u/en-US/vega-7nm-shader-instruction-set-architecture
WAVE_SIZE = 64
SIMDS_PER_CU = 4
SIMD_LANES = 16
LDS_BYTES_PER_CYCLE = 32 * 4
# AMD GCN Architecture: A Crash Course, slide 29 (scheduler arbitration):
# one issue per CU cycle each for VMEM, Branch/Message, and shared SALU/SMEM.
# https://dci.dci-gitlab.cines.fr/webextranet/_downloads/7ce42fb9fb3b40a6ebe4b5ba7d25b657/GCN_Architecture.pdf
VECTOR_MEMORY_CYCLES = 1
SCALAR_ISSUE_CYCLES = 1
CONDITIONAL_BRANCH_CYCLES = 1

# MI50 values from AMD ROCm's accelerator specifications and AMDGPU's
# IsaInfo allocation rules. The register counts below are per SIMD.
# https://rocm.docs.amd.com/en/docs-6.3.1/reference/gpu-arch-specs.html
# https://llvm.org/docs/doxygen/AMDGPUBaseInfo_8cpp_source.html
VGPRS_PER_SIMD = 256
SGPRS_PER_SIMD = 800
WAVES_PER_SIMD = 10
VGPR_GRANULE = 4
SGPR_GRANULE = 16
LDS_BYTES_PER_CU = 65536
LDS_GRANULE = 512
WORKGROUP_BARRIERS = 16
CATEGORIES = ("valu", "salu", "lds", "global", "scalar_memory", "branch", "exec")


class Unsupported(ValueError):
    pass


def capture(*command):
    return subprocess.check_output(command, text=True)


def rounded(count, granule):
    return math.ceil(count / granule) * granule


def occupancy(note):
    """Static resident wave count per CU at the declared workgroup size."""
    if note["wavefront_size"] != WAVE_SIZE:
        raise Unsupported("R/RB require wave64")
    lanes = note["required_workgroup_size"] or note["max_flat_workgroup_size"]
    waves = math.ceil(lanes / WAVE_SIZE)
    if not waves:
        raise Unsupported("missing workgroup size")
    vgprs = max(VGPR_GRANULE, rounded(note["vgpr_count"], VGPR_GRANULE))
    sgprs = max(SGPR_GRANULE, rounded(note["sgpr_count"], SGPR_GRANULE))
    per_simd = min(WAVES_PER_SIMD, VGPRS_PER_SIMD // vgprs, SGPRS_PER_SIMD // sgprs)
    groups = ((per_simd * SIMDS_PER_CU) // waves)
    if waves > 1:
        groups = min(groups, WORKGROUP_BARRIERS)
    lds = rounded(note["group_segment_fixed_size"], LDS_GRANULE)
    if lds:
        groups = min(groups, LDS_BYTES_PER_CU // lds)
    return groups * waves


def kernel_note(notes, function):
    fields = ("sgpr_count", "vgpr_count", "sgpr_spill_count", "vgpr_spill_count",
              "group_segment_fixed_size", "max_flat_workgroup_size", "wavefront_size")
    kernels = re.split(r"(?m)^  - (?=\.)", notes)
    for kernel in kernels:
        if re.search(rf"(?m)^    \.name:\s+{re.escape(function)}\s*$", kernel):
            result = {}
            for field in fields:
                entry = re.search(rf"(?m)^    \.{field}:\s+(\d+)\s*$", kernel)
                if not entry:
                    raise Unsupported(f"missing code object property {field}")
                result[field] = int(entry[1])
            required = re.search(r"(?m)^    \.reqd_workgroup_size:\s*$\n"
                                 r"\s+- (\d+)\n\s+- (\d+)\n\s+- (\d+)", kernel)
            result["required_workgroup_size"] = (
                math.prod(map(int, required.groups())) if required else 0
            )
            result["occupancy_waves_per_cu"] = occupancy(result)
            return result
    raise Unsupported("kernel metadata is unavailable")


def natural_loops(graph, entry):
    predecessors = defaultdict(set)
    reachable = set()
    pending = [entry]
    while pending:
        node = pending.pop()
        if node in reachable:
            continue
        reachable.add(node)
        for successor in graph[node]:
            predecessors[successor].add(node)
            pending.append(successor)
    dominators = {node: set(reachable) for node in reachable}
    dominators[entry] = {entry}
    changed = True
    while changed:
        changed = False
        for node in sorted(reachable - {entry}):
            found = set.intersection(*(dominators[p] for p in predecessors[node])) | {node}
            if found != dominators[node]:
                dominators[node] = found
                changed = True
    bodies = defaultdict(set)
    for latch in sorted(reachable):
        for header in graph[latch]:
            if header not in dominators[latch]:
                continue
            body = bodies[header]
            body.add(header)
            pending = [latch]
            while pending:
                node = pending.pop()
                if node in body:
                    continue
                body.add(node)
                pending.extend(predecessors[node])
    return bodies


DISASSEMBLY = re.compile(
    r"(?m)^[ \t]+(\S+)[ \t]*(.*?)[ \t]*//[ \t]*([\da-fA-F]+):"
    r"[ \t]*([\da-fA-F]{8}(?:[ \t]+[\da-fA-F]{8})*)[ \t]*$"
)
SYMBOL = re.compile(
    r"(?m)^\s*\d+:\s+([\da-fA-F]+)\s+(\d+)\s+(\S+)\s+\S+\s+\S+\s+\S+\s+(\S+)\s*$"
)


def machine_code(text, start, size):
    """Recover real branches from the gfx906 SOPP signed word displacement."""
    instructions = {}
    sizes = {}
    for match in DISASSEMBLY.finditer(text):
        opcode, operands, address, words = match.groups()
        pc = int(address, 16)
        if start <= pc < start + size:
            if not re.fullmatch(r"[a-z][a-z0-9_]*", opcode):
                raise Unsupported(f"unalysed machine opcode at {pc:#x}")
            words = words.split()
            instructions[pc] = (opcode, operands, int(words[0], 16))
            sizes[pc] = 4 * len(words)
    addresses = sorted(instructions)
    if (not addresses or addresses[0] != start or
            any(pc + sizes[pc] != after for pc, after in
                zip(addresses, addresses[1:] + [start + size], strict=True))):
        raise Unsupported("kernel disassembly is incomplete")
    entries = {start}
    transfers = {}
    for pc, following in zip(addresses, addresses[1:] + [None], strict=True):
        opcode, _, word = instructions[pc]
        if opcode == "s_branch" or opcode.startswith("s_cbranch_"):
            # Vega 7nm ISA, SOPP. Branch target is PC + 4 + 4*SImm16.
            offset = word & 0xFFFF
            if offset >= 0x8000:
                offset -= 0x10000
            dest = pc + 4 + 4 * offset
            if dest not in instructions:
                raise Unsupported(f"unresolved branch in kernel at {pc:#x}")
            targets = [dest]
            if opcode != "s_branch" and following is not None:
                targets.append(following)
        elif opcode.startswith(("s_endpgm", "s_setpc", "s_rfe")):
            targets = []
        else:
            continue
        transfers[pc] = targets
        entries.update(targets)
        if following is not None:
            entries.add(following)
    graph, blocks = {}, {}
    current = None
    previous = None
    for pc in addresses:
        if pc in entries:
            if previous is not None:
                graph[current] = transfers.get(previous, [pc])
            current = pc
            blocks[current] = []
        blocks[current].append(instructions[pc])
        previous = pc
    graph[current] = transfers.get(previous, [])
    return graph, blocks


def classify(opcode, operands):
    if opcode.startswith("s_cbranch_"):
        return "branch"
    if opcode.startswith("ds_"):
        return "lds"
    if opcode.startswith(("global_", "flat_", "buffer_", "tbuffer_", "image_")):
        return "global"
    if opcode.startswith(("s_load_", "s_store_", "s_buffer_", "s_dcache_")):
        return "scalar_memory"
    if (opcode.startswith("v_cmpx_") or "saveexec" in opcode or
            "wrexec" in opcode or (opcode.startswith("s_") and
                                    re.search(r"\bexec(?:_lo|_hi)?\b", operands))):
        return "exec"
    if opcode.startswith("v_"):
        return "valu"
    if opcode.startswith("s_") and not opcode.startswith(
        ("s_branch", "s_wait", "s_nop", "s_barrier", "s_end", "s_sleep",
         "s_setpc", "s_swappc", "s_getpc", "s_setprio", "s_sendmsg")
    ):
        return "salu"
    return None


def lds_cycles(opcode):
    # Vega 7nm ISA: DS read2/write2 transfers two elements per lane.
    # B/U/I suffixes give element width. Unwidth-qualified DS lane
    # permutes and queue/counter operations take one dword per lane.
    width = re.search(r"_[bui](8|16|32|64|96|128)(?:_|$)", opcode)
    element_bytes = int(width[1]) // 8 if width else 4
    multiplier = 2 if opcode.startswith(("ds_read2", "ds_write2")) else 1
    return max(1, WAVE_SIZE * element_bytes * multiplier / LDS_BYTES_PER_CYCLE)


def machine_metrics(binary, listing, function, trips):
    readelf = ROCM / "llvm/bin/llvm-readelf"
    objdump = ROCM / "llvm/bin/llvm-objdump"
    symbols = [(int(addr, 16), int(size), kind, name)
               for addr, size, kind, name in SYMBOL.findall(capture(readelf, "-sW", binary))]
    functions = {(addr, size) for addr, size, kind, name in symbols
                 if kind == "FUNC" and name == function and size}
    if len(functions) != 1:
        raise Unsupported("function range is unavailable")
    start, size = functions.pop()
    asm = listing.read_text()
    labels = dict(re.findall(r"(?m)^(BB\d+_\d+):[ \t]*;[ \t]*(%\S+)", asm))
    address_to_ir = {address: labels[label] for address, _, _, label in symbols
                     if start <= address < start + size and label in labels}
    text = capture(objdump, "-d", f"--start-address={start}", f"--stop-address={start+size}", binary)
    graph, blocks = machine_code(text, start, size)
    loops = natural_loops(graph, start)
    weights = defaultdict(lambda: 1)
    trip_report = []
    for header, body in sorted(loops.items()):
        ir_header = address_to_ir.get(header)
        trip = trips.get(ir_header, 0)
        for block in body:
            weights[block] *= trip or 8
        trip_report.append({"offset": header - start, "ir_header": ir_header, "trip_count": trip})
    counts = Counter(dict.fromkeys(CATEGORIES, 0))
    lanes = {"readlane": 0, "writelane": 0}
    cycles = dict.fromkeys(("vector", "scalar", "lds", "global", "branch"), 0)
    for block, instructions in blocks.items():
        for opcode, operands, _ in instructions:
            for label in lanes:
                lanes[label] += opcode.startswith(f"v_{label}_")
            category = classify(opcode, operands)
            if block not in weights or category is None:
                continue
            weight = weights[block]
            counts[category] += weight
            # wave64 / (four SIMD16) is one VALU slot-cycle per CU.
            if category == "valu" or (category == "exec" and opcode.startswith("v_")):
                cycles["vector"] += weight * WAVE_SIZE / (SIMDS_PER_CU * SIMD_LANES)
            elif category in ("salu", "scalar_memory", "exec"):
                cycles["scalar"] += weight * SCALAR_ISSUE_CYCLES
            elif category == "global":
                cycles["global"] += weight * VECTOR_MEMORY_CYCLES
            elif category == "branch":
                cycles["branch"] += weight * CONDITIONAL_BRANCH_CYCLES
            else:
                cycles["lds"] += weight * lds_cycles(opcode)
    return {
        **kernel_note(capture(readelf, "--notes", binary), function),
        **lanes,
        "hsaco_sha256": hashlib.sha256(binary.read_bytes()).hexdigest(),
        "instructions": dict(counts),
        "cycles": cycles,
        "loops": trip_report,
        "work": counts["valu"] + counts["lds"] + counts["branch"],
        "bottleneck": max(cycles.values()),
    }


def analyse(path, function, machine, cache):
    digest = hashlib.sha256(path.read_bytes() + b"\0" + function.encode()).hexdigest()
    key = cache / f"v{RULE_VERSION}-{digest}-{'machine' if machine else 'ir'}.json"
    if key.exists():
        return json.loads(key.read_text()) | {"cache_hit": True, "compile_seconds": 0}
    llvm_config = os.environ.get("LLVM_CONFIG", ROOT / "build/llvm12-jammy/usr/bin/llvm-config-12")
    llvm = Path(capture(llvm_config, "--bindir").strip())
    with tempfile.TemporaryDirectory(prefix="accept-", dir=cache) as dir_name:
        directory = Path(dir_name)
        optimized = directory / "o3.ll"
        started = time.perf_counter()
        # Give unnamed IR blocks stable names before the LLVM12/LLVM24 split.
        capture(llvm / "opt", path, "-O3", "-instnamer", "-verify-each", "-S", "-o", optimized)
        optimize_seconds = time.perf_counter() - started
        worker = ROOT / "build/llvm24-tti/llvm24-tti"
        result = {"ir": json.loads(capture(worker, "--accept-ir", optimized, function))}
        compile_seconds = 0
        if machine:
            source = optimized.read_text()
            if not re.search(r'(?m)^target triple = "amdgcn-amd-amdhsa"$', source):
                raise Unsupported("R/RB require amdgcn-amd-amdhsa gfx906")
            binary = directory / "kernel.hsaco"
            listing = directory / "kernel.s"
            start = time.perf_counter()
            compile_kernel(optimized, binary, llvm, ROCM, preopt=False)
            capture(llvm / "llc", optimized, "-O3", "-mtriple=amdgcn-amd-amdhsa",
                    "-mcpu=gfx906", "-mattr=+sramecc,-xnack",
                    "-amdhsa-code-object-version=4", "-filetype=asm", "-o", listing)
            compile_seconds = optimize_seconds + time.perf_counter() - start
            result["machine"] = machine_metrics(binary, listing, function, result["ir"]["trip_counts"])
        published = directory / "report.json"
        published.write_text(json.dumps(result) + "\n")
        published.replace(key)
    return result | {"cache_hit": False, "compile_seconds": compile_seconds}


def verdict(parent, candidate, rule):
    if rule == "RIR":
        old, new = parent["ir"], candidate["ir"]
        checks = {"weighted_work": new["work"] < old["work"],
                  "vgpr_peak": new["vgpr_peak"] <= old["vgpr_peak"]}
        rank = new["work"]
    else:
        old, new = parent["machine"], candidate["machine"]
        checks = {slot: new[slot] <= old[slot]
                  for slot in ("vgpr_spill_count", "sgpr_spill_count")}
        checks.update({lane: new[lane] * LANE_LIMIT_DENOMINATOR <=
                       old[lane] * LANE_LIMIT_NUMERATOR for lane in ("readlane", "writelane")})
        checks["occupancy"] = new["occupancy_waves_per_cu"] >= old["occupancy_waves_per_cu"] > 0
        if rule == "R":
            checks["weighted_work"] = new["work"] < old["work"]
            rank = new["work"]
        else:
            former_bottlenecks = [unit for unit, cycles in old["cycles"].items()
                                  if cycles == old["bottleneck"]]
            new_limit = max(new["cycles"][unit] for unit in former_bottlenecks)
            checks["bottleneck"] = new_limit < old["bottleneck"]
            checks["other_resource"] = new["bottleneck"] <= new_limit
            rank = new["bottleneck"]
    return {"accepted": all(checks.values()), "checks": checks, "rank": rank}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("parent", type=Path)
    parser.add_argument("candidate", type=Path)
    parser.add_argument("function")
    parser.add_argument("--rule", choices=("tti", "RIR", "R", "RB", "all"), required=True)
    parser.add_argument("--tti-loss", type=float)
    parser.add_argument("--tti-accepted", type=int, choices=(0, 1), required=True)
    parser.add_argument("--cache", type=Path, required=True)
    args = parser.parse_args()
    if args.tti_loss is not None and not math.isfinite(args.tti_loss):
        parser.error("TTI loss must be finite")
    args.cache.mkdir(parents=True, exist_ok=True)
    report = {"version": RULE_VERSION, "throughput_loss": args.tti_loss,
              "decisions": {"tti": {"accepted": bool(args.tti_accepted)}}}
    states = {}
    for rule in (("RIR", "R", "RB") if args.rule == "all" else (args.rule,)):
        if rule == "tti":
            continue
        machine = rule in ("R", "RB")
        if machine and os.environ.get("FUSION_TTI_COST_KIND", "throughput") != "throughput":
            parser.error("R and RB require throughput TTI quotes")
        if machine and args.tti_loss is None:
            report["decisions"][rule] = {"accepted": False, "reason": "throughput_quote_unavailable"}
            continue
        if machine and args.tti_loss > MAX_THROUGHPUT_LOSS:
            report["decisions"][rule] = {"accepted": False, "reason": "throughput_prefilter"}
            continue
        try:
            if machine not in states:
                states[machine] = {
                    "parent": analyse(args.parent, args.function, machine, args.cache),
                    "candidate": analyse(args.candidate, args.function, machine, args.cache),
                }
            pair = states[machine]
            report["decisions"][rule] = verdict(pair["parent"], pair["candidate"], rule)
            report["machine" if machine else "ir"] = pair
        except Unsupported as error:
            report["decisions"][rule] = {"accepted": False, "reason": str(error)}
    print(json.dumps(report, allow_nan=False))


if __name__ == "__main__":
    main()
