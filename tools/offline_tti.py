#!/usr/bin/env python3
"""Record LLVM24 reports and replay them without loading LLVM24."""
import collections
import hashlib
import json
import os
from pathlib import Path
import sqlite3
import subprocess
import sys
import tempfile
import zlib

ROOT = Path(__file__).resolve().parents[1]
REVISION = "6be16f356d3e"


def compact(value):
    return json.dumps(value, separators=(",", ":"))


class Quotes:
    def __init__(self, mode, function):
        self.mode = mode
        self.function = function
        mode_name = os.environ.get("FUSION_TTI_COST_KIND", "throughput")
        kinds = {"throughput": "TCK_RecipThroughput", "latency": "TCK_Latency"}
        if mode_name not in kinds:
            raise ValueError("FUSION_TTI_COST_KIND must be throughput or latency")
        self.cost_kind = kinds[mode_name]
        database = Path(os.environ["FUSION_TTI_DB"]).resolve()
        self.overrides = []
        if "FUSION_TTI_OVERRIDES" in os.environ:
            if mode != "offline":
                raise ValueError("TTI overrides require offline mode")
            self.overrides = json.loads(Path(os.environ["FUSION_TTI_OVERRIDES"]).read_text())
            for rule in self.overrides:
                if not isinstance(rule.get("key"), str) or type(rule.get("cost")) is not int or rule["cost"] < 0:
                    raise ValueError("each override needs an instruction key and a nonnegative integer cost")
                if set(rule) - {"key", "cpu", "address_space", "alignment", "cost"}:
                    raise ValueError("unknown TTI override field")
        if mode == "record":
            self.db = sqlite3.connect(database, timeout=60)
            self.db.executescript("""
                CREATE TABLE IF NOT EXISTS reports (digest TEXT PRIMARY KEY, data BLOB NOT NULL);
                CREATE TABLE IF NOT EXISTS quotes (
                    key TEXT PRIMARY KEY, histogram TEXT NOT NULL, cost INTEGER
                );
            """)
            self.temp = tempfile.TemporaryDirectory(prefix="record-tti-")
            self.input = Path(self.temp.name) / "input.ll"
            self.child = subprocess.Popen(
                [ROOT / "build/llvm24-tti/llvm24-tti", "--serve-full", function],
                stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True)
        else:
            self.db = sqlite3.connect(database.as_uri() + "?mode=ro", uri=True, timeout=60)
        self.warning_log = Path(os.environ.get("FUSION_TTI_WARNINGS", str(database) + ".warnings"))
        self.warned = set()

    def warn(self, message):
        print(message, file=sys.stderr)
        try:
            with self.warning_log.open("a") as stream:
                stream.write(message + "\n")
        except OSError as error:
            print(f"cannot append offline TTI warnings to {self.warning_log}: {error}", file=sys.stderr)

    def close(self):
        if self.mode == "record":
            self.child.stdin.close()
            self.child.wait()
            self.temp.cleanup()
        self.db.close()

    def layout(self, ir):
        return json.loads(subprocess.check_output(
            [ROOT / "build/llvm24-tti/offline-tti-layout", self.function], input=ir))

    def quote_keys(self, layout):
        if self.cost_kind != "TCK_RecipThroughput":
            return [None] * len(layout["rows"])
        context = compact([REVISION, self.function, *(layout[k] for k in
                           ("triple", "cpu", "features", "layout", "attributes", "calling_conv"))])
        return [context + ":" + row["quote"] if row["quote"] is not None else None
                for row in layout["rows"]]

    def record(self, digest, ir):
        self.input.write_bytes(ir)
        self.child.stdin.write(str(self.input) + "\n")
        self.child.stdin.flush()
        report = json.loads(self.child.stdout.readline())
        if report is None:
            return None
        if report["source_revision"] != REVISION or report["cost_kind"] != self.cost_kind:
            raise ValueError("LLVM24 recording revision or cost kind mismatch")
        layout = self.layout(ir) if self.cost_kind == "TCK_RecipThroughput" else {"rows": []}
        rows = report["instruction_costs"]
        local_rows = layout["rows"]
        # Only record reusable keys when LLVM's IR upgrade preserved the positions.
        matches = len(local_rows) == len(rows) and all(
            (a["block_index"], a["instruction_index"]) == (b["block_index"], b["instruction_index"])
            for a, b in zip(local_rows, rows))
        if matches:
            for key, row in zip(self.quote_keys(layout), rows):
                if key is None or row["accepted_cost"] is None:
                    continue
                self.db.execute("""
                    INSERT INTO quotes VALUES (?, ?, ?)
                    ON CONFLICT(key) DO UPDATE SET cost = NULL
                    WHERE quotes.histogram != excluded.histogram OR quotes.cost != excluded.cost
                """, (key, row["key"], row["accepted_cost"]))
        self.db.execute("INSERT OR IGNORE INTO reports VALUES (?, ?)",
                        (digest, zlib.compress(compact(report).encode())))
        self.db.commit()
        return report

    def score(self, ir):
        # LLVM's ModuleID comment includes the path used to parse a snapshot.
        # Preserve all other text and include the selected function.
        canonical = ir.split(b"\n", 1)[1] if ir.startswith(b"; ModuleID = ") else ir
        # Leave existing throughput databases readable while isolating latency.
        namespace = b"latency\0" if self.cost_kind == "TCK_Latency" else b""
        digest = hashlib.sha256(namespace + self.function.encode() + b"\0" + canonical).hexdigest()
        entry = self.db.execute("SELECT data FROM reports WHERE digest = ?", (digest,)).fetchone()
        report = json.loads(zlib.decompress(entry[0])) if entry else None
        if report is not None and report["cost_kind"] != self.cost_kind:
            raise ValueError("offline TTI cost kind mismatch")
        if self.mode == "record":
            return report if report is not None else self.record(digest, ir)
        if report is not None and not self.overrides and (self.mode == "strict" or not report["unknown"]):
            return report
        if self.mode == "strict":
            message = f"offline TTI missing recorded request {digest} for {self.function}"
            self.warn(message)
            raise ValueError(message)

        layout = self.layout(ir)
        local_rows = layout["rows"]
        if report is not None and [(r["block_index"], r["instruction_index"]) for r in local_rows] != [
                (r["block_index"], r["instruction_index"]) for r in report["instruction_costs"]]:
            raise ValueError("cannot align override rows with recorded LLVM24 report")
        histogram = collections.Counter()
        output = []
        for index, (row, key) in enumerate(zip(local_rows, self.quote_keys(layout))):
            prior = report["instruction_costs"][index] if report is not None else None
            quote = (prior["key"], prior["accepted_cost"]) if prior is not None else None
            if quote is None and key is not None:
                quote = self.db.execute(
                    "SELECT histogram, cost FROM quotes WHERE key = ? AND cost IS NOT NULL", (key,)).fetchone()
            report_key, cost = quote if quote is not None else (row["key"], None)
            metadata = {**row, "cpu": layout["cpu"], "key": report_key}
            for rule in self.overrides:
                if all(metadata.get(field) == value for field, value in rule.items() if field != "cost"):
                    cost = rule["cost"]
            if cost is None:
                warning = (self.function, layout["cpu"], report_key, row["address_space"], row["alignment"])
                if warning not in self.warned:
                    self.warn(f"warning: offline TTI using default cost 1 for {warning}")
                    self.warned.add(warning)
                cost = 1
            histogram[f"{report_key}:cost{cost}"] += 1
            output.append({**{k: row[k] for k in ("block_index", "instruction_index", "ir")},
                           "key": report_key, "tti_cost": cost, "accepted_cost": cost, "reason": ""})
        total = sum(row["accepted_cost"] for row in output)
        return {"schema": "llvm24-tti-v1", "source_revision": REVISION,
                "scoring_backend": "offline", "cost_kind": self.cost_kind,
                **{k: layout[k] for k in ("triple", "cpu", "features")},
                "instructions": len(output), "unknown": 0, "modeled_cost": total, "cost": total,
                "zero": sum(row["accepted_cost"] == 0 for row in output),
                "histogram": dict(histogram), "instruction_costs": output}


def main():
    arg, function, *flags = sys.argv[1:]
    server = arg in ("--serve-summary", "--serve-full")
    summary = arg == "--serve-summary" or flags == ["--summary-only"]
    quotes = Quotes(os.environ["FUSION_TTI_MODE"], function)
    try:
        for path in sys.stdin if server else (arg,):
            try:
                report = quotes.score(Path(path.rstrip("\n")).read_bytes())
                if summary and report is not None:
                    report = {k: v for k, v in report.items() if k not in ("instruction_costs", "histogram")}
                if report is None and not server:
                    return 2
                print(compact(report), flush=True)
            except (OSError, ValueError, subprocess.SubprocessError) as error:
                print(error, file=sys.stderr)
                if quotes.mode == "strict" and "FUSION_TTI_STRICT_ERRORS" in os.environ:
                    with open(os.environ["FUSION_TTI_STRICT_ERRORS"], "a") as stream:
                        stream.write(str(error) + "\n")
                if not server:
                    return 2
                print("null", flush=True)
    finally:
        quotes.close()
    return 0


if __name__ == "__main__":
    sys.exit(main())
