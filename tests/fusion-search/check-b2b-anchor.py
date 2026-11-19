#!/usr/bin/env python3
import json
from pathlib import Path
import re
import subprocess
import sys
import tempfile


search, worker, opt = map(Path, sys.argv[1:])
fixtures = Path(__file__).parent / "b2b-anchor"
cases = (
    ("vllm-7", "quant", "B2", "B1", 25),
    ("HLLD", "HLLD", "B1", "B2", 146),
    ("MapAiry", "MapAiry", "B1", "B2", 347),
    ("Tigre4", "Tigre4", "B1", "B2", 91),
    ("no-phi", "diamond", "B1", "B2", 10),
)

with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    for name, fn, left, right, historical_tti in cases:
        layouts = {}
        for strategy in ("dp1", "anchor"):
            debug = root / f"{name}-{strategy}"
            result = debug.with_suffix(".ll")
            subprocess.run(
                [search, "--ir", fixtures / f"{name}.ll", "--function", fn,
                 "--split", "B0", "--left", left, "--right", right,
                 "--b2b-strategy", strategy, "--tti-worker", worker,
                 "--out", result, "--debug-dir", debug],
                check=True,
            )
            subprocess.run([opt, "-verify", "-disable-output", result], check=True)
            trial = debug / "trial-0"
            report = json.loads((trial / "trial.json").read_text())
            assert report["valid"] and report["score_result"]["status"] == "scored"
            score = report["score_result"]["metrics"]["work_after"]
            layouts[strategy] = (score, result.read_bytes())
            if strategy == "anchor":
                stats = report["anchor"]
                assert 1 <= stats["unique_normalized"] <= stats["generated"] <= 9
                assert stats["conflicts"] == 0
                if name == "no-phi":
                    assert stats["anchors"] == 0 and stats["segments"] == 1
                if name == "HLLD":
                    emissions = [row["anchor"]["emission"] for row in report["layout_profitability"]]
                    assert stats["emission"] == "before-split"
                    assert emissions.index("before-split") < emissions.index("merged-exit")
                if name == "vllm-7":
                    assert stats["mode"] == "tie-pair"
                    assert any(
                        {cutoff["left"], cutoff["right"]} == {"%s108", "%s112"}
                        for row in report["layout_profitability"]
                        if row["anchor"]["mode"] == "tie-cut"
                        for cutoff in row["anchor"]["cutoffs"]
                    )
                if name == "Tigre4":
                    assert any(
                        {cutoff["left"], cutoff["right"]} == {"%add494", "%add508"}
                        for row in report["layout_profitability"]
                        if row["anchor"]["mode"] == "tie-cut"
                        for cutoff in row["anchor"]["forward_cutoffs"]
                    )
        assert layouts["dp1"][0] == historical_tti, (name, layouts["dp1"][0])
        assert layouts["anchor"][0] <= historical_tti, (name, layouts["anchor"][0])
        if name == "vllm-7":
            assert layouts["dp1"] == layouts["anchor"]
            text = layouts["anchor"][1].decode()
            local = text.split("%upper = fcmp", 1)[1]
            assert len(re.findall(r" = select ", local)) == 9
            assert len(re.findall(r" = fcmp ", local)) == 4
            assert len(re.findall(r"call float @llvm\.copysign", local)) == 1
            assert not re.search(r"select i1 [^\n,]+, i1 ", local)
            assert "float 3.500000e+00, float 1.750000e+00" in local
            assert "float 5.000000e+00, float 1.250000e+00" in local
        print(name, historical_tti, "->", layouts["anchor"][0])
