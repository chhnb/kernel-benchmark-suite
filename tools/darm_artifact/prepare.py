#!/usr/bin/env python3
"""Verify the pinned source files before applying the recorded patch series."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys

source = Path(__file__).resolve().parent
provenance = json.loads((source / "provenance.json").read_text())
output = Path(sys.argv[1]).resolve()
output.mkdir(parents=True, exist_ok=True)
for name, expected in provenance["source_sha256"].items():
    data = (source / name).read_bytes()
    digest = hashlib.sha256(data).hexdigest()
    if digest != expected:
        raise SystemExit(f"{name}: SHA256 {digest}, expected {expected}")
    (output / name).write_bytes(data)
for patch in provenance["patches"]:
    subprocess.run(["patch", "--batch", "--forward", "-p1", "-i",
                    source / patch["file"]], cwd=output, check=True)
