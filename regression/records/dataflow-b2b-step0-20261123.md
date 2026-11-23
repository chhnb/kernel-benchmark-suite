# Dataflow B2B 第 0 步

分支起点为 `630e1ed5910f3fa7968c87748aca7207419d8199`。

## 新增文件

- `docs/dataflow-b2b/PROBLEM.md`
- `docs/dataflow-b2b/COST_TABLE.json`
- `tools/dataflow_b2b/README.md`
- `tests/dataflow-b2b/README.md`
- `regression/records/dataflow-b2b-step0-20261123.md`

## JSON 校验

```sh
python3 -m json.tool docs/dataflow-b2b/COST_TABLE.json
```

退出状态为 `0`。

```json
{
    "description": "Abstract cost table for dataflow-b2b micro tests (steps 1-3). Real TTI quotes replace it from step 4.",
    "op": {
        "add": 1,
        "sub": 1,
        "and": 1,
        "or": 1,
        "xor": 1,
        "shl": 1,
        "lshr": 1,
        "ashr": 1,
        "icmp": 1,
        "fcmp": 1,
        "mul": 2,
        "fadd": 2,
        "fsub": 2,
        "fmul": 2,
        "sdiv": 8,
        "udiv": 8,
        "srem": 8,
        "urem": 8,
        "fdiv": 8,
        "zext": 1,
        "sext": 1,
        "trunc": 1,
        "bitcast": 0,
        "getelementptr": 1,
        "load": 4,
        "store": 4,
        "select": 1
    },
    "select_i1_folded_to_condition": 0,
    "guard_segment_control": 3,
    "guard_escape_merge": 1,
    "size_latency": "use the op table above as c_SL in micro tests",
    "fold_threshold": 7,
    "fold_max_phis": 3
}
```
