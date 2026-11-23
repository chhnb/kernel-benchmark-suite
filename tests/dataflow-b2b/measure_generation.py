"""Regression and corpus measurements for the scalable dataflow generator."""
from argparse import ArgumentParser
from collections import Counter
from concurrent.futures import ThreadPoolExecutor
import json
from pathlib import Path
from statistics import median
import subprocess

from measure_pairing import parallel, table_tsv, tuple_str, vector
from regression import BUILD, COSTS, TESTS, load, report


GATES = ("00bc16cfd8ae", "e3b15e5220a0", "ed0b563f1288", "4f045e74e33a")
STRATEGIES = ("anchor/original", "anchor/unified", "darm/original", "darm/unified", "dataflow/unified")


def plans(result):
    yield from result.get("schemes", {}).items()
    for i, scheme in enumerate(result.get("subsets", [])):
        yield f"subset-{i}", scheme


def small_generation(args):
    truth = load(TESTS / "truth/small.json")["regions"]
    jobs = [(row, mode, False) for mode in ("abstract", "real") for row in truth
            if row["modes"][mode]["status"] == "priced"]
    work = args.work / "scalable"
    work.mkdir()
    items = parallel(jobs, work, args.jobs, ["--compare-dp"])
    (work / "small.json").write_text(json.dumps(items) + "\n")
    good = raw = pairs = 0
    for item in items:
        result, row, mode = (item[key] for key in ("result", "row", "mode"))
        misses = 0
        if not result.get("complete"):
            misses += 1
            print(f"FAIL {mode}/{row['id']}: {result.get('reason', 'no generation')}")
        for name, scheme in plans(result):
            dp, policy = scheme.get("dp_minimum"), scheme.get("dp_policy")
            if dp is None or policy is None:
                misses += 1
                print(f"FAIL {mode}/{row['id']}/{name}: {scheme.get('reason', 'DP comparison missing')}")
                continue
            pairs += 1
            if scheme.get("discrepancy"):
                raw += 1
                print(f"LIST {mode}/{row['id']}/{name}: "
                      f"min {scheme.get('list_minimum')} / DP {dp}, "
                      f"§7.2 {scheme.get('list_policy')} / DP {policy}; {scheme['discrepancy']}")
            if scheme["minimum"]["T"][0] != dp[0] or scheme["selected"]["T"] != policy:
                misses += 1
                print(f"FAIL {mode}/{row['id']}/{name}: disagreeing minimum or §7.2 vector")
        good += not misses
    print(f"Scalable vs DP: {good}/{len(items)} region/mode runs; "
          f"{pairs} fixed-plan comparisons, {raw} raw differences")
    return good, len(items)


def pairing_gates(args):
    items = load(args.work / "scalable/small.json")
    passing = 0
    for prefix in GATES:
        good = True
        checked = set()
        for item in items:
            result, row, mode = (item[key] for key in ("result", "row", "mode"))
            if not row["id"].startswith(prefix) or (mode != "real" and prefix != GATES[-1]):
                continue
            checked.add(mode)
            scheme = result.get("without_safety_net", {})
            minimum = vector(scheme, "minimum")
            selected = vector(scheme, "selected")
            expected = row["modes"][mode]
            ok = (selected == expected["strategy_T"] and minimum is not None and
                  minimum[0] == expected["minimum_D_T"][0])
            good &= ok
            print(f"{'OK' if ok else 'FAIL'} {prefix}/{mode}: min={minimum}; §7.2={selected}; "
                  f"truth min_D={expected['minimum_D_T'][0]}; truth §7.2={expected['strategy_T']}")
        required = {"real", "abstract"} if prefix == GATES[-1] else {"real"}
        if checked != required:
            print(f"FAIL {prefix}: missing modes {required - checked}")
        passing += good and checked == required
    return passing, len(GATES)


def original_policy(t, baseline, source):
    if not t or not baseline:
        return None
    if source == "workgroup-uniform":
        return min((baseline, t), key=lambda v: max(v[1:]))
    if source == "data" and (t[1] > baseline[1] or t[2] > baseline[2]):
        return baseline
    return min(baseline, t)


def comparison(item):
    result, row = item["result"], item["row"]
    base, source = result.get("original_T"), row["condition_source"]
    schemes, old = result.get("schemes", {}), result.get("original_generators", {})
    new = schemes.get("dataflow", {})
    new_policy = vector(result.get("without_safety_net", {}), "selected")
    values, policy = [], []
    for name in ("anchor", "darm"):
        orig, unified = old.get(name, {}), schemes.get(name, {})
        values.extend((vector(orig), vector(unified, "generated_minimum")))
        policy.extend((original_policy(vector(orig), base, source),
                       vector(unified, "selected") if unified.get("generated_minimum") else None))
    values.append(vector(new, "generated_minimum"))
    policy.append(new_policy if new.get("generated_minimum") else None)
    return values, policy


def semantic_tasks(item, corpus, work):
    row = item["row"]
    folder = work / item["mode"] / row["id"]
    source = folder / "with-target.ll"
    if not source.exists():
        relative = TESTS / "corpus" / corpus[row["id"]]["ir"]
        source = folder / relative.stem if relative.suffix == ".gz" else relative
    solutions = folder / "solutions"
    paths = {entry[k] for _, scheme in plans(item["result"])
             for entry in scheme.get("pareto_front", []) for k in ("ir", "replacement_ir") if k in entry}
    for path in sorted(paths):
        yield item["mode"], row["id"], source, solutions / path


def check_semantics(task):
    mode, uid, source, solution = task
    try:
        run = subprocess.run([BUILD / "interpret_region", source, solution],
                             timeout=120, check=False, text=True, capture_output=True)
        check = json.loads(run.stdout)
    except subprocess.TimeoutExpired:
        check = {"status": "unsupported", "reason": "interpreter time limit (120 s)"}
    except (OSError, ValueError) as error:
        check = {"status": "unsupported", "reason": str(error)}
    return [mode, uid, solution.name, check.get("status", "unsupported"), check.get("reason", "ok")]


def verify_solutions(small, others, corpus, small_work, work, workers):
    runs = [(item, small_work) for item in small] + [(item, work) for item in others]
    tasks = [task for item, folder in runs for task in semantic_tasks(item, corpus, folder)]
    with ThreadPoolExecutor(workers) as pool:
        return list(pool.map(check_semantics, tasks))


def write_summary(small, others, corpus, sem, dest, diagnosis=None, small_work=None, work=None):
    dest.mkdir(parents=True, exist_ok=True)
    rows = [item for item in small if item["mode"] == "real"] + others
    prefix = "step10a2" if diagnosis else "step10a"
    lines = ["# 第 10a′ 步 最小割布置与大区域诊断" if diagnosis else "# 第 10a 步 可扩展的统一生成", ""]
    if diagnosis:
        lines.extend(["## 修改前诊断", "", diagnosis.read_text().strip(), ""])
    lines.extend(["## 配对目标和 small 固定配对", ""])
    for item in small:
        key = item["row"]["id"]
        if any(key.startswith(prefix) for prefix in GATES):
            scheme = item["result"].get("without_safety_net", {})
            lines.append(f"- `{item['mode']}/{key[:12]}`。不含安全网，最小 D 对应 "
                         f"`{vector(scheme, 'minimum')}`，§7.2 选择 `{vector(scheme, 'selected')}`。")
    checked = [scheme for item in small for _, scheme in plans(item["result"])
               if scheme.get("dp_minimum") is not None]
    diffs = sum(bool(scheme.get("discrepancy")) for scheme in checked)
    lines += ["", f"两种模式共 {len(small)} 次区域运行，{len(checked)} 次固定配对比较，"
              f"列表搜索与 DP 的最小 $T_D$ 或 §7.2 向量差异 {diffs} 次。"]
    if diffs:
        lines += ["", "### 原始列表搜索与子集 DP 的差异", ""]
    for item in small:
        for name, scheme in plans(item["result"]):
            if scheme.get("discrepancy"):
                lines.append(f"- `{item['mode']}/{item['row']['id']}/{name}`。列表最小 "
                             f"`{scheme['list_minimum']}`、§7.2 `{scheme['list_policy']}`。"
                             f"DP 对应为 `{scheme['dp_minimum']}`、`{scheme['dp_policy']}`。"
                             f"归类为 {scheme['discrepancy']}。")
    lines += ["", "## 各档生成和开销", "",
              "| 档位 | 有新配对生成结果 / 总数 | 生成中位 ms | 生成最大 ms |",
              "|---|---:|---:|---:|"]
    for tier in ("small", "medium", "large"):
        batch = [x for x in rows if corpus[x["row"]["id"]]["size_bucket"] == tier]
        timings = [s["generation_ms"] for x in batch
                   if (s := x["result"].get("schemes", {}).get("dataflow", {})).get("generated_minimum")]
        lines.append(f"| {tier} | {len(timings)}/{len(batch)} | {median(timings):.3f} | {max(timings):.3f} |")
    lines += ["", "计时为最高分新配对进入统一生成到报价和写出前沿的时间。Small 还运行独立的 DP 对拍。", "",
              "### 生成失败与对照缺项", ""]
    for item in rows:
        result, row = item["result"], item["row"]
        if not result.get("schemes"):
            lines.append(f"- `{row['id']}`。{result.get('reason', '没有生成结果')}")
            continue
        for name, scheme in plans(result):
            if not scheme.get("generated_minimum") or scheme.get("reason"):
                if name in result.get("original_generators", {}) and result["original_generators"][name].get("reason") == scheme.get("reason"):
                    continue
                lines.append(f"- `{row['id']}/{name}`。{scheme.get('reason') or '没有可计价的生成方案'}")
        for name, orig in result.get("original_generators", {}).items():
            if reason := orig.get("reason") or orig.get("cost_reason"):
                lines.append(f"- `{row['id']}/{name}/original`。{reason}")
    lines += ["", "`989fc49dfa13` 带有在 LLVM 24 读入时升级的 lifetime intrinsic，逐指令报价无法对齐。"
              "其中的普通调用 `quant_decide` 也无整调用报价。"
              "`696f915b5378` 的内联汇编 `rcp.approx.ftz.f32` 没有可接受的 LLVM 24 报价。",
              "`25146e46e0f2` 有 6,145 条操作，anchor 原生成超时（120 秒）。"
              "该区域仍有 DARM 和新配对的统一生成报价。"]
    lines += ["", "### LUD8 的六个长区域", "",
              "保护段、select、流出和第一列 $T$ 属于最高分配对的最小 $T_D$ 生成结果。"
              "§7.2 的 $T$ 计入配对子集和原始区域。", "",
              "| 区域 | 操作数 | 分支 / 保护段 | select | 流出 | 固定配对最小 $T_D$ 的 $T$ | §7.2 的 $T$ |",
              "|---|---:|---:|---:|---:|---|---|"]
    for item in others:
        row, result = item["row"], item["result"]
        if row["size_bucket"] != "large" or not any(o["case"].lower().startswith("lud8") for o in row["occurrences"]):
            continue
        best = result.get("schemes", {}).get("dataflow", {}).get("generated_minimum") or {}
        selected = result.get("without_safety_net", {}).get("selected", {})
        lines.append(f"| `{row['id'][:12]}` | {row['left_ops'] + row['right_ops']} | "
                     f"{best.get('guard_branches','—')} / {best.get('guard_segments','—')} | "
                     f"{best.get('selects','—')} | {best.get('escaping_values','—')} | "
                     f"{best.get('T','—')} | {selected.get('T','—')} |")
    lines += ["", "## 五种组合", "",
              "无约束列按最高分新配对、anchor 配对或 DARM 配对各自找到的最小 $T_D$。"
              "§7.2 列包含原区域候选，新配对额外考虑配对子集。"
              "原生成列对已清理的原策略 IR 报价。下表在每档五列均可计价的共同区域比较总和。", "",
              "| 档位 | 共同区域 | 组合 | 自身可报价数 | 自身最小 $T_D$ | 交集最小 $T_D$ | 自身 §7.2 合计 | 交集 §7.2 合计 |",
              "|---|---:|---|---:|---:|---:|---|---|"]
    cross = []
    for tier in ("small", "medium", "large"):
        batch = [(x["row"]["id"], *comparison(x)) for x in rows
                 if corpus[x["row"]["id"]]["size_bucket"] == tier]
        complete = [(uid, a, b) for uid, a, b in batch if all(a) and all(b)]
        for i, name in enumerate(STRATEGIES):
            available = [(a[i], b[i]) for _, a, b in batch if a[i] and b[i]]
            own = [sum(b[j] for _, b in available) for j in range(3)]
            t = [sum(b[i][j] for _, _, b in complete) for j in range(3)]
            lines.append(f"| {tier} | {len(complete)} | {name} | {len(available)} | "
                         f"{sum(a[0] for a, _ in available)} | {sum(a[i][0] for _, a, _ in complete)} | "
                         f"{tuple_str(own)} | {tuple_str(t)} |")
        for i, engine in ((0, "anchor"), (2, "DARM")):
            delta = [tuple(b[i][j] - b[i+1][j] for j in range(3)) for _, _, b in complete]
            savings = tuple(sum(column) for column in zip(*delta)) if delta else (0, 0, 0)
            d_gain = sum(d > 0 for d, l, r in delta)
            uniform_gain = sum(d > 0 and min(l, r) >= 0 and max(l, r) > 0 for d, l, r in delta)
            cross.append((tier, engine, savings, d_gain, uniform_gain))
    lines += ["", "固定配对改用统一生成后的 §7.2 净收益按 $(D,L,R)$ 计。"
              "一致场景也有收益的统计要求两侧均无损且至少一侧改善。"]
    for tier, name, savings, d_gain, uniform_gain in cross:
        lines.append(f"- {tier} {name}，净收益 `{savings}`。分歧有收益 {d_gain} 个，其中一致场景也有收益 {uniform_gain} 个。")
    detail = []
    for x in rows:
        uid = x["row"]["id"]
        a, b = comparison(x)
        ms = x["result"].get("schemes", {}).get("dataflow", {}).get("generation_ms")
        detail.append([corpus[uid]["size_bucket"], uid, f"{ms:.3f}" if ms is not None else "—",
                       *(tuple_str(t) or "—" for t in a+b)])
    table_tsv(dest / f"{prefix}-cross.tsv",
              ["tier", "id", "dataflow_generation_ms",
               *(x+"/minD" for x in STRATEGIES), *(x+"/policy" for x in STRATEGIES)], detail)
    lines += ["", f"逐区域代价见 [{prefix}-cross.tsv]({prefix}-cross.tsv)。", ""]
    if diagnosis:
        lines += fixed_pair_regressions(rows, corpus, small_work, work)
    lines += ["## 有界解释器", "", "对每个留存的统一生成 IR 文件去重后运行差分。原 IR 用作参照。", ""]
    counts = Counter(row[3] for row in sem)
    lines += [f"状态计数 `{dict(sorted(counts.items()))}`。",
              f"每个未验证或不一致的区域、具体方案和原因见 [{prefix}-semantics.tsv]({prefix}-semantics.tsv)。"]
    table_tsv(dest / f"{prefix}-semantics.tsv", ["mode", "id", "ir", "status", "reason"], sem)
    (dest / f"{prefix}.md").write_text("\n".join(lines)+"\n")
    print("Semantic statuses:", dict(sorted(counts.items())))


def billed_terms(ir, original, outputs):
    flags = ["--original"] if original else ["--after-cleanup"]
    if outputs > 1:
        flags.append("--output-buffer")
    priced = report([BUILD / "evaluate_cost", ir, COSTS, "--cost=real", *flags], 90)
    counts = Counter()
    for op in priced["operations"]:
        for scenario in op["scenarios"]:
            counts[op["kind"], scenario] += op["cost"]
    return counts


def fixed_pair_regressions(items, corpus, small_work, work):
    lines = ["## 固定配对后仍有退化的区域", "",
             "任一场景的 §7.2 代价上升即列出。差值均为统一减原生成。", ""]
    for index, strategy in ((0, "anchor"), (2, "darm")):
        counts, d_losses = Counter(), Counter()
        section = []
        for item in items:
            row, result = item["row"], item["result"]
            origin = result.get("original_generators", {}).get(strategy, {})
            scheme = result.get("schemes", {}).get(strategy, {})
            _, policy = comparison(item)
            old, new = policy[index:index+2]
            if not old or not new:
                continue
            delta = tuple(b-a for a, b in zip(old, new))
            if max(delta) <= 0:
                continue
            uid, tier = row["id"], corpus[row["id"]]["size_bucket"]
            counts[tier] += 1
            d_losses[tier] += delta[0] > 0
            chosen = scheme["selected"]
            minimum = scheme["generated_minimum"]
            old_is_original = old != origin.get("T") or origin.get("status") == "unchanged_triangle"
            counts_old = origin if not old_is_original else {}
            guards = tuple(counts_old.get(key, 0) for key in ("guard_branches", "selects", "escaping_values"))
            generated = tuple(chosen.get(key, 0) for key in ("guard_branches", "selects", "escaping_values"))
            tags = (f"原布局 {origin.get('layout') or strategy}，统一侧选择了"
                    f"{'原区域' if chosen.get('original') else '生成结果'}")
            if chosen.get("original"):
                tags += f"，最低 D 的生成候选为 `{minimum['T']}`"
            if row["condition_source"] == "thread-pattern" and delta[0] <= 0:
                tags += "。该条件按 D 选择，安全操作的推测可能增加整侧执行的指令"
            if scheme.get("cleanup_unpriced"):
                tags += f"，部分清理形态不可报价（{scheme['cleanup_reason']}）"
            root = small_work if tier == "small" else work
            if root is not None:
                directory = root / "real" / uid / "solutions"
                old_ir = directory / ("original.ll" if old_is_original else f"{strategy}/cleaned.ll")
                try:
                    num_outputs = corpus[uid]["num_outputs"]
                    prior = billed_terms(old_ir, old_is_original, num_outputs)
                    after = billed_terms(directory / chosen["ir"], chosen.get("original"), num_outputs)
                    difference = {}
                    for key in sorted({key for key, scene in set(prior) | set(after)}):
                        change = tuple(after[key, scene] - prior[key, scene] for scene in "DLR")
                        if any(change):
                            difference[key] = change
                    tags += f"，逐计费项改变量 `{difference}`"
                except (OSError, ValueError, subprocess.SubprocessError) as error:
                    tags += f"，逐项报价失败（{error}）"
            section.append(f"- `{uid}`（{tier}），`{old}` → `{new}`，Δ `{delta}`。{tags}。"
                           f"分支、select、流出 `{guards}` → `{generated}`。")
        lines += [f"### {strategy}", "",
                  f"small {counts['small']} 个，medium {counts['medium']} 个，large {counts['large']} 个。"
                  f"只计 $T_D$ 上升时，分别为 {d_losses['small']}、{d_losses['medium']}、{d_losses['large']} 个。", "",
                  *section, ""]
    return lines

def main():
    parser = ArgumentParser(description=__doc__)
    parser.add_argument("small", type=Path)
    parser.add_argument("work", type=Path)
    parser.add_argument("results", type=Path)
    parser.add_argument("--jobs", type=int, default=24)
    parser.add_argument("--diagnosis", type=Path, help="emit Step 10a′ reports with the read-only diagnosis")
    args = parser.parse_args()
    inventory = load(TESTS / "corpus/inventory-b2b.json")["regions"]
    corpus = {row["id"]: row for row in inventory}
    small = load(args.small)
    others = parallel([(row, "real", False) for row in inventory if row["size_bucket"] != "small"],
                      args.work, args.jobs)
    (args.work / "other.json").write_text(json.dumps(others) + "\n")
    sem = verify_solutions(small, others, corpus, args.small.parent, args.work, args.jobs)
    write_summary(small, others, corpus, sem, args.results, args.diagnosis, args.small.parent, args.work)
    print(f"Measured {len(small)} small mode/region runs and {len(others)} medium/large regions")


if __name__ == "__main__":
    main()
