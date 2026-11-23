"""Measure Step 9 on the frozen corpus, using the same driver as regression."""
import argparse
from collections import Counter
import csv
import gzip
import json
from pathlib import Path
import subprocess
from statistics import median

from regression import BUILD, COSTS, TESTS, load, report, target_input, unpack
from concurrent.futures import ThreadPoolExecutor

COLUMNS = ("anchor/original", "anchor/unified", "darm/original", "darm/unified", "dataflow/unified")


def bench(row, mode, output, pairing_only, extra_flags=()):
    directory = output / mode / row["id"]
    directory.mkdir(parents=True)
    source = unpack(TESTS / "corpus" / row["ir"], directory)
    target = row.get("modes", {}).get("real", {}).get("target_attributes")
    if target:
        source = target_input(source, directory, target)
    flags = ["--pairing-only"] if pairing_only else []
    try:
        result = report([BUILD / "dataflow_solver", source, COSTS, directory / "solutions",
                         f"--cost={mode}", f"--condition-source={row['condition_source']}",
                         *flags, *extra_flags], 660)
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        result = {"complete": False, "reason": str(error)}
    return {"row": row, "mode": mode, "result": result}


def parallel(tasks, work, jobs, extra_flags=()):
    with ThreadPoolExecutor(jobs) as pool:
        return list(pool.map(lambda task: bench(task[0], task[1], work, task[2], extra_flags), tasks))


def vector(obj, key=None):
    return (obj.get(key) or {}).get("T") if key else obj.get("T")


def differences(item, safety):
    row, mode, result = (item[k] for k in ("row", "mode", "result"))
    truth = row["modes"][mode]
    scheme = result if safety else result.get("schemes", {}).get("dataflow", {})
    minimum, policy = vector(scheme, "minimum"), vector(scheme, "selected")
    if minimum is None or policy is None:
        return None
    return (minimum[0] - truth["minimum_D_T"][0],
            tuple(a - b for a, b in zip(policy, truth["strategy_T"])))


def spread(counts):
    return ", ".join(f"{key}={number}" for key, number in sorted(counts.items()))


def summary(small):
    lines = []
    for mode in ("abstract", "real"):
        rows = [row for row in small if row["mode"] == mode]
        for safety in (False, True):
            diffs = [v for row in rows if (v := differences(row, safety)) is not None]
            td, policy = Counter(x[0] for x in diffs), Counter(x[1] for x in diffs)
            objective = Counter()
            for item in rows:
                result, row = item["result"], item["row"]
                scheme = result if safety else result.get("schemes", {}).get("dataflow", {})
                if t := vector(scheme, "selected"):
                    goal = row["modes"][mode]["strategy_T"]
                    metric = max(t[1:]) - max(goal[1:]) if row["condition_source"] == "workgroup-uniform" else t[0] - goal[0]
                    objective[metric] += 1
            label = "with safety net" if safety else "without safety net"
            lines.append(f"{mode} {label}: min T_D optimum {td[0]}/{len(rows)} [{spread(td)}]; "
                         f"§7.2 optimum {objective[0]}/{len(rows)} [{spread(objective)}]; "
                         f"§7.2 T match {policy[(0, 0, 0)]}/{len(rows)} [{spread(policy)}]")
        for key in ("minimum_winner", "winner"):
            counts = Counter(row["result"].get(key, "unavailable") for row in rows)
            lines.append(f"{mode} {key}: {spread(counts)}")
    return lines


def archived_reference():
    source = TESTS / "results/step5-small.json.gz"
    with gzip.open(source, "rt") as stream:
        return {(row["id"], row["mode"]): row for row in json.load(stream)
                if row["status"] == "agree"}


def small_pairing(args):
    rows = load(TESTS / "truth/small.json")["regions"]
    tasks = [(row, mode, False) for mode in ("abstract", "real") for row in rows
             if row["modes"][mode]["status"] == "priced"]
    output = args.work / "dataflow"
    output.mkdir()
    small = parallel(tasks, output, args.jobs)
    for line in summary(small):
        print(line)
    archive = archived_reference()
    for item in small:
        row, mode = item["row"], item["mode"]
        if why := explain(item, archive):
            print(f"REPORT {mode}/{row['id']} {differences(item, False)}: {why}")
    (output / "small.json").write_text(json.dumps(small) + "\n")


def table_tsv(path, headers, rows):
    with path.open("w", newline="") as stream:
        writer = csv.writer(stream, delimiter="\t", lineterminator="\n")
        writer.writerow(headers)
        writer.writerows(rows)


def five_columns(result):
    old, new = result.get("original_generators", {}), result.get("schemes", {})
    return [vector(old.get("anchor", {})), vector(new.get("anchor", {}), "generated_minimum"),
            vector(old.get("darm", {})), vector(new.get("darm", {}), "generated_minimum"),
            vector(new.get("dataflow", {}), "generated_minimum")]


def tuple_str(value):
    return "/".join(map(str, value)) if value else ""


def pair_keys(entry):
    return sorted((pair["left_index"], pair["right_index"], pair["recipe"])
                  for pair in entry.get("pairs", []))


def explain(item, archive):
    row, mode, result = (item[k] for k in ("row", "mode", "result"))
    diff = differences(item, False)
    if diff is None:
        return f"生成或计价未给出方案。{result.get('reason', '')}"
    if diff == (0, (0, 0, 0)):
        return None
    fresh = result["schemes"]["dataflow"]
    truth = row["modes"][mode]
    historical = archive[row["id"], mode]["reference"]["pareto_front"]
    chosen = pair_keys({"pairs": result["pairing"]["selected"]})
    current = fresh["pareto_front"]
    reasons = {}
    for kind, goal in (("D", truth["minimum_D_T"]), ("§7.2", truth["strategy_T"])):
        if (kind == "D" and not diff[0]) or (kind == "§7.2" and not any(diff[1])):
            continue
        target = lambda r: r["T"][0] == goal[0] if kind == "D" else r["T"] == goal
        plans = [entry for entry in historical if target(entry)]
        if not fresh["generation_complete"]:
            explanation = "生成未完备，无法单独归因于配对"
        elif any(target(entry) for entry in current):
            explanation = "生成前沿已包含目标，§7.2 同目标值的排序选择了另一向量"
        elif any(pair_keys(entry) == chosen for entry in plans):
            explanation = "历史最优方案采用同一配对，需检查生成或候选保留"
        else:
            alternatives = [pair_keys(entry) for entry in plans]
            explanation = f"配对为 {chosen}，历史前沿达到目标的配对为 {alternatives}；共用生成器已枚举当前配对"
            if not chosen and all(not c["gain"] for c in result["pairing"]["components"]):
                explanation += "，各分量配对收益为 0，生成后本可获得的控制收益未进入配对目标"
            if kind == "§7.2":
                t = fresh["selected"]["T"]
                if row["condition_source"] == "workgroup-uniform" and max(t[1:]) == max(goal[1:]):
                    explanation += "；工作组一致目标值相同"
        reasons.setdefault(explanation, []).append(kind)
    return "。".join(f"{'、'.join(goals)} {why}" for why, goals in reasons.items()) + "。"


def research(args):
    dest = args.results
    dest.mkdir(parents=True, exist_ok=True)
    small = load(args.small)
    corpus = load(TESTS / "corpus/inventory-b2b.json")["regions"]
    other = [(row, "real", True) for row in corpus if row["size_bucket"] != "small"]
    measurements = parallel(other, args.work / "pairing", args.jobs)
    medium = [(row, "real", False) for row in corpus
              if row["size_bucket"] == "medium" and row["left_ops"] + row["right_ops"] <= 16]
    generated = parallel(medium, args.work / "generation", args.jobs)
    (args.work / "measurements.json").write_text(json.dumps(measurements) + "\n")
    (args.work / "generated.json").write_text(json.dumps(generated) + "\n")
    write_research_report(small, corpus, measurements, generated, args.small, dest)


def write_research_report(small, corpus, measurements, generated, small_path, dest):
    by_id = {row["id"]: row for row in corpus}
    archive = archived_reference()
    lines = ["# 第 9 步 Dataflow 配对阶段", "", "## Small 档真值", "",
             "差距为实测减真值。最小 $T_D$ 差距按标量计，§7.2 差距按三个分量计。"]
    lines += ["", "```text", *summary(small), "```", "", "### 单独配对未达到真值的区域", ""]
    for item in small:
        why = explain(item, archive)
        if why:
            lines.append(f"- `{item['mode']}/{item['row']['id']}`，差距 `{differences(item, False)}`。{why}")
    lines += ["", "获胜数按最终选择归属。同一向量按 dataflow、anchor、DARM 的顺序打破平局。"
              "原始区域在目标持平且保留原样时单列。", "",
              "### 安全网配对提取与生成限制", ""]
    exceptions = []
    for item in [*small, *generated]:
        r, source = item["result"], item["row"]
        count = source["left_ops"] + source["right_ops"]
        if source["size_bucket"] == "large" or count > 16:
            continue
        for strategy in ("anchor", "darm"):
            alt = r.get("original_generators", {}).get(strategy, {})
            unified = r.get("schemes", {}).get(strategy, {})
            reason = alt.get("reason") or alt.get("cost_reason") or unified.get("reason")
            if reason:
                exceptions.append(f"- `{item['mode']}/{source['id']}` {strategy}。{reason}")
        if not r.get("complete"):
            exceptions.append(f"- `{item['mode']}/{source['id']}` dataflow。{r.get('reason', '')}")
    lines += exceptions or ["无。"]
    if any(x["row"]["id"].startswith("989fc49dfa13") and not x["result"].get("complete")
           for x in generated):
        lines += ["", "该区域的 lifetime intrinsic 在 LLVM 24 读入时被升级，逐指令报价无法和 LLVM 12 对齐。"
                  "其中的普通调用 `quant_decide` 也缺少整调用报价，与第 5b 步的诊断一致。"]

    lines += ["", "## 五种组合的真实代价", "",
              "统一生成列取各配对的最小 $T_D$，原生成列对原策略生成并清理后的 IR 报价。",
              "各列单独统计覆盖数，并在五种组合均有结果的交集上比较总和。",
              "逐区域三场景向量见 [step9-cross.tsv](step9-cross.tsv)。", ""]
    cross = []
    for item in [*small, *generated]:
        row, result = item["row"], item["result"]
        if item["mode"] != "real" or "schemes" not in result:
            continue
        cross.append((row["size_bucket"], row["id"], five_columns(result)))
    table_tsv(dest / "step9-cross.tsv", ["tier", "id", *COLUMNS],
              [[tier, uid, *(tuple_str(t) for t in vs)] for tier, uid, vs in cross])
    lines.append(f"Medium 中有 {len(generated)} 个抽取区域未超过 16 条的生成上限。")
    lines.append("")
    for tier in ("small", "medium"):
        groups = [v for group, uid, v in cross if group == tier]
        common = [v for v in groups if all(v)]
        lines += [f"### {tier}", "", f"有生成结果 {len(groups)} 个，五列交集 {len(common)} 个。", "",
                  "| 组合 | 可计价数 | 各列 $T_D$ 合计 | 交集 $T_D$ 合计 |", "|---|---:|---:|---:|"]
        for i, label in enumerate(COLUMNS):
            available = [v[i][0] for v in groups if v[i]]
            lines.append(f"| {label} | {len(available)} | {sum(available)} | {sum(v[i][0] for v in common)} |")
        lines.append("")

    lines += ["## 配对规模与时间", "", "时间包含配对所需的报价。逐区域分量大小和方法见 "
              "[step9-pairing.tsv](step9-pairing.tsv)。", "",
              "| 模式 | 档位 | 有结果 / 总数 | 最大候选数 | 最大分量 | 中位 ms | 最大 ms |",
              "|---|---|---:|---:|---:|---:|---:|"]
    timing = []
    all_rows = small + measurements
    for item in all_rows:
        row, res = item["row"], item["result"]
        cases = sorted({o["case"] for o in by_id[row["id"]]["occurrences"]})
        p = res.get("pairing")
        sizes = Counter((c["size"], c["method"]) for c in p["components"]) if p else {}
        timing.append([item["mode"], row["size_bucket"], row["id"], row["left_ops"]+row["right_ops"],
                       ",".join(cases), p["candidates"] if p else None,
                       p["component_count"] if p else None,
                       ",".join(f"{size}:{method}={count}" for (size, method), count in sorted(sizes.items())),
                       p["gain"] if p else None, f"{p['ms']:.3f}" if p else res.get("pairing_ms"),
                       "ok" if p else res.get("reason", "unavailable")])
    table_tsv(dest / "step9-pairing.tsv",
              ["mode", "tier", "id", "ops", "cases", "candidates", "component_count",
               "component_size_and_method_counts", "gain", "ms", "reason"], timing)
    for mode, tier in (("abstract", "small"), ("real", "small"), ("real", "medium"), ("real", "large")):
        rows = [x for x in all_rows if x["mode"] == mode and x["row"]["size_bucket"] == tier]
        p = [x["result"]["pairing"] for x in rows if x["result"].get("pairing")]
        peak = max((c["size"] for x in p for c in x["components"]), default=0)
        lines.append(f"| {mode} | {tier} | {len(p)} / {len(rows)} | "
                     f"{max(x['candidates'] for x in p)} | {peak} | "
                     f"{median(x['ms'] for x in p):.3f} | {max(x['ms'] for x in p):.3f} |")
    lines += ["", "### LUD8 长区域", "",
              "| 区域 | 操作数 | 候选数 | 最大分量 | ms |", "|---|---:|---:|---:|---:|"]
    lud = sorted((x for x in measurements if x["row"]["size_bucket"] == "large"
                  and any(o["case"].lower().startswith("lud8") for o in x["row"]["occurrences"])),
                 key=lambda x: -(x["row"]["left_ops"]+x["row"]["right_ops"]))
    for item in lud:
        row, p = item["row"], item["result"].get("pairing")
        if not p:
            continue
        peak = max((c["size"] for c in p["components"]), default=0)
        lines.append(f"| `{row['id'][:12]}` | {row['left_ops'] + row['right_ops']} | "
                     f"{p['candidates']} | {peak} | {p['ms']:.3f} |")
    pairing_errors = [x for x in measurements if not x["result"].get("pairing")]
    if pairing_errors:
        lines += ["", "### 无法完成配对测量的区域", ""]
        for item in pairing_errors:
            lines.append(f"- `{item['row']['id']}`。{item['result'].get('reason')}")
    context_dir = small_path.parent.parent / "context-dataflow/dataflow"
    context_report = load(context_dir / "summary.json")
    attempts = [load(path) for path in context_dir.glob("trial-*/structural/trial-0/trial.json")]
    trial = next(row for row in attempts if row.get("eligible") and
                 row.get("dataflow", {}).get("region_id", "").startswith("d23a7c228c5b"))
    chosen = trial["dataflow"]["chosen"]["T"]
    lines += ["", "## DCT8 上下文", "",
              "完整贪心流程接受了区域 `d23a7c228c5b` 的方案，配对包括 `sext` 和 `sdiv`。",
              f"该区域的真实代价向量为 `{chosen}`，最终 kernel TTI 为 **{context_report['final_cost']}**。", ""]
    (dest / "step9.md").write_text("\n".join(lines))
    print(f"Step 9: {len(small)} small runs, {len(measurements)} medium/large pairing-only runs, "
          f"{len(generated)} medium generator runs")
    for item in measurements:
        if not item["result"].get("pairing"):
            print(f"REPORT {item['row']['id']}: {item['result'].get('reason')}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("small", type=Path)
    parser.add_argument("work", type=Path)
    parser.add_argument("results", type=Path)
    parser.add_argument("--jobs", type=int, default=16)
    research(parser.parse_args())
