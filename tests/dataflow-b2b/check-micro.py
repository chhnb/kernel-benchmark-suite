#!/usr/bin/env python3
"""Verify the micro fixtures and hash native execution on reproducible inputs."""

import argparse
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

MICRO = Path(__file__).resolve().parent / "micro"
LLVM12_BIN = (
    Path.home() / "v2-runtime/toolchains/llvm12-jammy/usr/lib/llvm-12/bin"
)
AMDGPU_TRIPLE = re.compile(r'^target triple = "amdgcn-amd-amdhsa"$', re.MULTILINE)
SIGNATURE = re.compile(
    r"^define\s+(?:zeroext\s+)?(\w+)\s+@([A-Za-z_]\w*)\s*\(([^)]*)\)",
    re.MULTILINE,
)
PARAMETER = re.compile(
    r"(i1|i32|i64|float|double|i8|i16)(\*)?\s+(?:zeroext\s+)?%([A-Za-z_]\w*)"
)
C_TYPES = {
    "i1": "_Bool",
    "i8": "int8_t",
    "i16": "int16_t",
    "i32": "int32_t",
    "i64": "int64_t",
    "float": "float",
    "double": "double",
    "void": "void",
}
SAMPLES = 1000

C_SUPPORT = """\
#include <inttypes.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>

enum { ARRAY_SIZE = 16 };
static uint64_t state;
static uint64_t digest;

static uint32_t next_word(void) {
    state ^= state >> 12;
    state ^= state << 25;
    state ^= state >> 27;
    return (state * UINT64_C(2685821657736338717)) >> 32;
}

/* The fixtures can divide two integer arguments. Exclude zero and overflow. */
static __attribute__((unused)) int32_t sample_int(void) {
    uint32_t word = next_word();
    int32_t magnitude = (word % 32) + 1;
    return word & 32 ? -magnitude : magnitude;
}

static void hash_bytes(const void *data, size_t size) {
    const unsigned char *bytes = data;
    for (size_t i = 0; i < size; ++i) {
        digest ^= bytes[i];
        digest *= UINT64_C(1099511628211);
    }
}
"""


def require(condition, message):
    if not condition:
        raise ValueError(message)


def read_expectation(path):
    expect = json.loads(path.read_text())
    require(isinstance(expect, dict), "expected an object")
    fold = expect.get("original_folds")
    require(
        isinstance(fold, dict)
        and type(fold.get("value")) is bool
        and isinstance(fold.get("reason"), str)
        and fold["reason"].strip(),
        "original_folds must contain a boolean value and a reason",
    )
    require(expect.get("enumeration") == "partial", 'enumeration must be "partial"')
    schemes = expect.get("schemes")
    require(isinstance(schemes, dict) and "original" in schemes, "missing original scheme")

    for name, scheme in schemes.items():
        require(isinstance(scheme, dict), f"{name} must be an object")
        for key in ("recipes", "pairs", "guard_segments", "selects"):
            values = scheme.get(key)
            require(
                isinstance(values, list)
                and all(isinstance(value, str) and value.strip() for value in values),
                f"{name}.{key} must be a list of nonempty strings",
            )
        require(scheme["recipes"], f"{name} must list its recipes")
        for key in ("T", "delta"):
            vector = scheme.get(key)
            require(
                isinstance(vector, list) and len(vector) == 3
                and all(type(value) is int for value in vector),
                f"{name}.{key} must be a three-integer vector",
            )
        require(min(scheme["T"]) >= 0, f"{name} has a negative execution cost")

    base = schemes["original"]["T"]
    eligible = set()
    for name, scheme in schemes.items():
        delta = [a - b for a, b in zip(base, scheme["T"])]
        require(scheme["delta"] == delta, f"{name}.delta must equal original.T - T")
        if delta[0] > 0 and min(delta[1:]) >= 0:
            eligible.add(name)

    def dominates(a, b):
        return a != b and all(x <= y for x, y in zip(a, b))

    frontier = {
        name for name, scheme in schemes.items()
        if not any(dominates(other["T"], scheme["T"]) for other in schemes.values())
    }
    declared = expect.get("pareto_front")
    require(
        isinstance(declared, list) and all(isinstance(name, str) for name in declared)
        and len(declared) == len(frontier) and set(declared) == frontier,
        f"pareto_front must equal {sorted(frontier)}",
    )
    choice = expect.get("conservative_choice")
    require(
        isinstance(choice, str) and choice in (eligible or {"original"}),
        "conservative_choice violates the conservative rule",
    )


def random_value(ty):
    if ty == "i1":
        return "(next_word() & 1)"
    if ty in ("float", "double"):
        return "(sample_int() / 8.0)"
    return "sample_int()"


def generate_driver(ir):
    signatures = SIGNATURE.findall(ir)
    require(len(signatures) == 1, "expected one micro function definition")
    result, name, args = signatures[0]
    require(result in ("void", "i1", "i32", "i64", "float", "double"),
            f"unsupported result type {result}")
    parameters = []
    for arg in args.split(","):
        match = PARAMETER.fullmatch(arg.strip())
        require(match, f"unsupported parameter {arg.strip()}")
        parameters.append(match.groups())

    require(parameters[0] == ("i1", None, "C"), "first parameter must be i1 %C")
    prototype = ", ".join(C_TYPES[ty] + (pointer or "") for ty, pointer, _ in parameters)
    setup, actual, observations = [], ["condition != 0"], []
    inputs_by_type = {}
    for index, (ty, pointer, param) in enumerate(parameters[1:], start=1):
        c_type = C_TYPES[ty]
        variable = f"arg{index}"
        value = random_value(ty)
        if pointer:
            setup.extend((
                f"            {c_type} {variable}[ARRAY_SIZE];",
                "            for (size_t i = 0; i < ARRAY_SIZE; ++i)",
                f"                {variable}[i] = {value};",
            ))
            observations.append(f"            hash_bytes({variable}, sizeof {variable});")
            # Output arrays remain independent. Exercise aliasing among equally
            # typed input pointers on half of the iterations.
            other = inputs_by_type.get(ty) if param != "out" else None
            if param != "out":
                inputs_by_type.setdefault(ty, variable)
            actual.append(f"(sample % 2 ? {other} : {variable})" if other else variable)
        else:
            setup.append(f"            {c_type} {variable} = {value};")
            actual.append(variable)

    call = f"{name}({', '.join(actual)})"
    if result == "void":
        setup.append(f"            {call};")
    else:
        setup.append(f"            {C_TYPES[result]} result = {call};")
        observations.insert(0, "            hash_bytes(&result, sizeof result);")
    body = "\n".join(setup + observations)
    return C_SUPPORT + f"""
extern {C_TYPES[result]} {name}({prototype});

int main(void) {{
    for (int condition = 1; condition >= 0; --condition) {{
        state = UINT64_C(0xb8a6f351e952f92d);
        digest = UINT64_C(14695981039346656037);
        for (int sample = 0; sample < {SAMPLES}; ++sample) {{
{body}
        }}
        printf("C=%d %016" PRIx64 "\\n", condition, digest);
    }}
    return 0;
}}
"""


def run(command, *, capture=False):
    return subprocess.run(command, check=True, text=True, capture_output=capture)


def check_case(path, opt, clang, host_triple, temp):
    read_expectation(path.with_suffix("") / "expect.json")
    run([opt, "-verify", "-disable-output", path])
    ir = path.read_text()
    host_ir, count = AMDGPU_TRIPLE.subn(f'target triple = "{host_triple}"', ir)
    require(count == 1, "expected one AMDGPU target triple")
    code = re.sub(r";[^\n]*", "", ir)
    if re.search(r"\bconvergent\b", code):
        print(f"{path.stem}: verifier OK; host skipped (convergent)", flush=True)
        return False

    native = temp / "native.ll"
    driver = temp / "driver.c"
    binary = temp / "driver"
    native.write_text(host_ir)
    driver.write_text(generate_driver(ir))
    run([clang, "-std=c11", "-O0", "-Wall", "-Wextra", "-Werror", driver, native, "-o", binary])
    hashes = run([binary], capture=True).stdout.splitlines()
    require(
        len(hashes) == 2
        and all(re.fullmatch(fr"C={c} [0-9a-f]{{16}}", line)
                for c, line in zip((1, 0), hashes)),
        "unexpected native hash output",
    )
    print(f"{path.stem}: verifier OK; {'; '.join(hashes)}", flush=True)
    return True


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    bin_dir = Path(os.environ.get("KBS_LLVM12_BIN", LLVM12_BIN))
    parser.add_argument("--opt", default=os.environ.get("LLVM12_OPT", str(bin_dir / "opt")))
    parser.add_argument("--clang", default=shutil.which("clang") or str(bin_dir / "clang"))
    args = parser.parse_args()

    version = run([args.opt, "--version"], capture=True).stdout
    require(re.search(r"LLVM version 12\.", version), f"expected LLVM 12 opt, got {version.strip()}")
    host = run([args.clang, "-dumpmachine"], capture=True).stdout.strip()
    paths = sorted(MICRO.glob("*.ll"))
    require(paths, f"no micro tests in {MICRO}")
    expect_paths = {path.with_suffix("") / "expect.json" for path in paths}
    require(set(MICRO.glob("*/expect.json")) == expect_paths, "IR/expectation files do not match")

    print(f"opt: {args.opt} ({version.splitlines()[0].strip()})", flush=True)
    print(f"clang: {args.clang} (host {host})", flush=True)
    native = 0
    failures = 0
    with tempfile.TemporaryDirectory(prefix="dataflow-micro-") as directory:
        for path in paths:
            try:
                native += check_case(path, args.opt, args.clang, host, Path(directory))
            except (OSError, ValueError, subprocess.CalledProcessError) as error:
                failures += 1
                print(f"FAIL {path.name}: {error}", file=sys.stderr)
    passed = len(paths) - failures
    print(f"{'OK' if not failures else 'FAIL'}: {passed} verifiers and expectations; "
          f"{native} native runs ({SAMPLES} samples per condition); {passed - native} host skip")
    return int(bool(failures))


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        print(f"check-micro: {error}", file=sys.stderr)
        sys.exit(1)
