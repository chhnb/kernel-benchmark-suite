"""Generate the fixed FP64 Cholla HLLD input and analytic flux reference."""

import argparse
from array import array
from pathlib import Path
from random import Random
import struct
import sys


KERNEL = "_ZN3mhd26Calculate_HLLD_Fluxes_CUDAEPKdS1_S1_Pdidii"
SEED = 20261115
GAMMA = 5 / 3
BLOCK_SIZE = 128


def state(rng, vx):
    return (
        rng.uniform(.7, 1.3), vx, rng.uniform(-.4, .4), rng.uniform(-.4, .4),
        rng.uniform(.7, 1.3), rng.uniform(-.4, .4), rng.uniform(-.4, .4),
    )


def conserved(primitive, bx):
    density, u, v, w, pressure, by, bz = primitive
    energy = (
        pressure / (GAMMA - 1) + density * (u*u + v*v + w*w) / 2
        + (bx*bx + by*by + bz*bz) / 2
    )
    return density, density*u, density*v, density*w, energy, by, bz


def flux(primitive, energy, bx):
    density, u, v, w, pressure, by, bz = primitive
    total_pressure = pressure + (bx*bx + by*by + bz*bz) / 2
    return (
        density*u,
        density*u*u + total_pressure - bx*bx,
        density*u*v - bx*by,
        density*u*w - bx*bz,
        u*(energy + total_pressure) - bx*(u*bx + v*by + w*bz),
        by*u - bx*v,
        bz*u - bx*w,
    )


def write_arrays(path, fields):
    with path.open("wb") as output:
        for field in fields:
            if sys.byteorder != "little":
                field.byteswap()
            field.tofile(output)


def generate(directory, count):
    if count <= 0 or count % BLOCK_SIZE:
        raise ValueError("interface count must be a positive multiple of 128")
    directory.mkdir()
    rng = Random(SEED)
    left, right, reference = ([array("d") for _ in range(7)] for _ in range(3))
    bx_values = array("d")
    for i in range(count):
        bx = rng.uniform(.1, .6)
        case = i % 3
        vx = 6 if case == 0 else -6 if case == 1 else rng.uniform(-.6, .6)
        lhs = state(rng, vx)
        rhs = lhs if case == 2 else state(rng, vx + .2)
        left_values, right_values = conserved(lhs, bx), conserved(rhs, bx)
        # Supersonic cases use the upwind flux. Equal states use the physical flux.
        reference_values = (
            flux(rhs, right_values[4], bx) if case == 1 else flux(lhs, left_values[4], bx)
        )
        for fields, values in ((left, left_values), (right, right_values),
                               (reference, reference_values)):
            for field, value in zip(fields, values):
                field.append(value)
        bx_values.append(bx)
    for file, fields in (("left.bin", left), ("right.bin", right),
                         ("bx.bin", [bx_values]), ("flux.ref", reference)):
        write_arrays(directory / file, fields)
    with (directory / "flux.bin").open("wb") as output:
        output.truncate(count * 7 * 8)
    scalars = struct.pack("<i", count), struct.pack("<d", GAMMA), bytes(4), struct.pack("<i", 7)
    lines = [
        f"kernel {KERNEL}", f"grid {count // BLOCK_SIZE} 1 1", f"block {BLOCK_SIZE} 1 1",
        "buffer left left.bin readonly - 0 0", "buffer right right.bin readonly - 0 0",
        "buffer bx bx.bin readonly - 0 0", "buffer flux flux.bin f64 flux.ref 1e-9 1e-9",
        *(f"arg ptr {name}" for name in ("left", "right", "bx", "flux")),
        *(f"arg hex {value.hex()}" for value in scalars),
    ]
    (directory / "input.txt").write_text("\n".join(lines) + "\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path)
    parser.add_argument("count", type=int)
    args = parser.parse_args()
    generate(args.output, args.count)
