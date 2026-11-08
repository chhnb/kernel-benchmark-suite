# 局部 copysign BB 融合

2026-11-08，项目位于 musa `/home/chh/kernel-benchmark-suite`。

## 版本关系

上游 Git checkout 位于 `/home/chh/darm-artifacts-repro/upstream/code`，origin 为 `https://github.com/charitha22/cgo22ae-darm-code.git`，HEAD 为 `e9bc0540325ad9806313d34e84fc901496fd8be6`。本次未修改此 checkout。

当前搜索程序实际编译 suite 内 `tools/darm_pair_engine` 的修改版副本，并链接 LLVM12。suite 原先没有 Git；本次为 tools/tests 和顶层构建说明建立源码现状快照，再单独提交本功能。未配置 suite remote，未推送。提交身份使用客户端已有的 Git 身份，仅在 suite 仓库中配置。

更新：另有可选 `--local-union 1` 路线，支持入口条件并集和同前驱 diamond；详见 `local-union-fusion.md`。以下保留原 PHI 模式的说明与数据。

## 新模式

```text
--adjacent-only 1 --local-copysign 1 --cleanup none
```

默认关闭；不替换原始 DARM 自动配对、region replication 或一般 intrinsic 匹配规则。要求稳定邻接目录允许该候选，仍执行原有 trial 合法性检查。

新增 `tools/darm_pair_engine/LocalCopysignFusion.h` 提供局部变换，由 `fusion_search.cpp` 的 trial 入口调用。`fusion_search_llvm24_main.cpp` 暴露开关。所有拒绝检查先于变换，不支持时明确拒绝，不静默回退到区域复制。

## 第一版支持范围

- 两个不同叶子，每个恰好是一条标量 copysign intrinsic 和一条无条件跳转。
- 原始判断保留；两个叶子有不同的单一前驱、共同出口。
- 幅值是常量，符号输入相同，调用类型、调用约定、属性兼容；无 fast-math 标记、operand bundle、musttail。
- 调用结果仅在共同出口的 PHI 使用；其他出口 PHI 必须能无歧义合并。
- 不支持带 PHI 的已有融合组继续扩展，也不支持两个叶子具有同一前驱的直接 diamond；这些情况均保守拒绝。

变换在新块中建立幅值 PHI，克隆一条 copysign，连接原出口。前驱原有分支只重接被选中的叶子边；条件及真假方向不变。出口 PHI 中两条叶子边替换为一条新边，然后删除旧叶子。原调用到共享调用的映射交给现有逻辑状态跟踪。

这条专用路线绕过旧 intrinsic 匹配器对 copysign 的拒绝，没有把所有 intrinsic 一概标为可匹配。

## 真实 vLLM 例子

输入：`experiments/logical-state-vllm-20261108-v1/state-0.ll`，函数 `cache_eval`。

```bash
build/llvm24-tti/fusion-search-llvm24 \
  --ir experiments/logical-state-vllm-20261108-v1/state-0.ll \
  --function cache_eval \
  --split B100 --left B101 --right B103 \
  --adjacent-only 1 --local-copysign 1 --cleanup none \
  --scorer llvm24 \
  --out /tmp/vllm-local-new.ll \
  --debug-dir /tmp/vllm-local-new-debug
```

debug-dir 必须尚不存在。B/R 编号只适用于上面指定的输入快照。

实际生成：

```llvm
local.copysign:
  %local.magnitude = phi float
      [ 5.000000e-01, %if.else.i667 ],
      [ 1.000000e+00, %if.else4.i670 ]
  %local.result = tail call float @llvm.copysign.f32(
      float %local.magnitude, float %mul126.1) #3
  br label %quant_decide.exit685
```

函数静态成本 5423 → 5419，指令数 2248 → 2247。减少一次 copysign、一次无条件 br，增加一条 float PHI；当前 TTI 分别为 1、4、1，因此收益为 4。若 br=0，增量成本为零，不应把 +4 描述成实际 GPU 加速。

## 验证

测试 `tests/postopt/check_local_copysign.py`：

- 原始 8 叶子用例调用数从 8 降至 7，没有复制区域。
- 新组标签进入下一状态，trial 的 replication_required=false。
- 10,050 个不同输入位模式，在主机 O0、O3 下各做一次逐位前后比较；覆盖阈值及相邻可表示值、正负零、无穷、quiet/signaling NaN 和固定种子随机位模式。
- 带额外指令的叶子明确拒绝。
- LLVM verifier 通过。

实验目录：`experiments/local-bb-unit-20261108-v1`、`experiments/local-bb-vllm-20261108-v1`。没有进行 GPU 实测、全 suite 性能评估或新的自动 DARM 全流程运行。
