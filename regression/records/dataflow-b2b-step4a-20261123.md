# Dataflow B2B 第 4a 步

在 epyc 的 `/data/home/chh/kernel-benchmark-suite-dataflow-b2b` 从 `a2ec5fc` 开始。端到端实验限定 DCT8。真实计价验收另外使用三个 small 区域，覆盖保留 PHI 的菱形和有访存的三角形。

## 计价和生成

- 真实模式使用与 fusion-search 相同的 LLVM 24 worker、修订 `6be16f356d3e`、`TCK_RecipThroughput`、函数 target CPU 和 feature 属性。按原始 IR 的块序和块内指令序对接逐指令报价。条件分支按其所在块计费，无条件分支按各自所在保护侧计费，PHI 和 select 使用自己的报价。抽取函数的 return 和多输出传输代码不计作区域操作。
- 原始区域真实报价保持原始分支和 PHI，便于和父 IR 上 fusion-search 的融合前报价逐项核对。LLVM 12 的 c_SL 仍用于报告 Fold 和拒绝保留应推测保护段的生成方案。抽象模式沿用原始 Fold 计费。
- 真实控制费用改变了 DP 的转移费用。每个保护结构用条件分支报价和实际存在的臂出口报价。评估器独立核对结果。最初的模拟 IR 多出一个跳到合成返回块的无条件分支，导致 78 个计价候选的控制费用核对失败。移除这条仅用于独立函数返回的跳转后，DCT8 的 320 个生成候选无 DP 计费不一致。候选沿用第 3b 步每组决策选择一个最低控制代价调度的枚举口径。
- 新策略复用语料库的区域分类、抽取和哈希。在完整独立函数上按真实模式求解，按原父分支的条件来源应用 §7.2。超过 10 条、验证失败或求解未完成的候选没有重写提交。只在显式使用新策略时，目录补充直接 B2B 菱形和三角形。
- 放回时直接在父 kernel 克隆求解结果的块，将参数重新绑定到原 SSA 值，将多输出传输写回改为原汇合 PHI 的入值，并保留汇合的其他前驱。单一前驱的边界直接合并。这样无需生成临时调用和输出数组。放回后照常运行项目清理、LLVM 24 全 kernel 裁决和贪心接受规则。第一次接入试跑遇到临时路径的 LLVM Twine 生命周期问题，改为持有路径字符串后重新运行。
- DCT8 的 IR 进入父 kernel 前后都通过 LLVM verifier。四个代码对象按项目 GPU 重放工具相同的 LLVM 12 后端和 ROCm 链接参数生成。DCT8 回放沿用项目 HIP 事件和完整输出验证接口，CPU 端执行 DCT 量化公式并保留短整型截断。输入采用 DARM 的 `srand(0)` 和 `rand()%255-128` 生成，图像为 4096 × 4096。项目历史完整运行目录已不存在，本步加入可重放的 DCT8 验证入口。回放输入 SHA-256 为 `ff47466bca25024e30539b454ddfa0649cb2136045866813889b7798003cc3f4`。
- 计时沿用 `measure_anchor_gpu.py` 的 12 轮、3 次预热、15 次重复、中位数和 10,000 次 bootstrap，增加四变体平衡顺序。`baseline`、`A`、`darm`、`N` 分别表示原始、anchor、darm、dataflow-exact。

[结果](../../tests/dataflow-b2b/results/step4a-dct8.md)

## 命令

```sh
cd /data/home/chh/kernel-benchmark-suite-dataflow-b2b
llvm="$HOME/v2-runtime/toolchains/llvm12-jammy/usr"
llvm_bin="$llvm/lib/llvm-12/bin"
rocm=/opt/rocm-6.3.3
export LLVM_CONFIG="$llvm_bin/llvm-config"
export LD_LIBRARY_PATH="$llvm/lib/x86_64-linux-gnu:$HOME/v2-runtime/toolchains/llvm24-pinned/lib:$rocm/lib"
export HIP_VISIBLE_DEVICES=0 ROCR_VISIBLE_DEVICES=0
work=build/dataflow-corpus/step4a
results="$work/e2e-final"
gpu="$work/gpu"
fn=_Z27CUDAkernelQuantizationShortPsi
costs=docs/dataflow-b2b/COST_TABLE.json
mkdir -p build/llvm24-tti "$work" "$results" "$gpu"
cp "$HOME/simplify-v2/build/artifact-14b.5ZY6U4/source/build/llvm24-tti/llvm24-tti" build/llvm24-tti/
tools/build-llvm24-tti --search-only
tools/build-decision-greedy
gzip -dc regression/greedy-v1/inputs/21a5ddb82636744c.ll.gz > "$work/DCT8.ll"
python3 tools/dataflow_b2b/check_real_cost.py build/llvm24-tti/evaluate_cost \
  tools/run-llvm24-tti "$work/parity"
region=tests/dataflow-b2b/corpus/regions/d23a7c228c5b39f95910f0b1d4eb8b9318e5c775.ll
build/llvm24-tti/reference_solver "$region" "$costs" "$work/real" --cost=real > "$work/real.json"
build/llvm24-tti/reference_solver "$region" "$costs" "$work/abstract" --c-sl=real > "$work/abstract.json"
build/dataflow-corpus/interpret_region-step3 "$region" "$work/real/0.ll"
python3 tools/dataflow_b2b/check_costs.py build/llvm24-tti/evaluate_cost

for role in anchor darm dataflow-exact; do
  build/decision-fuse/decision-greedy "$work/DCT8.ll" "$fn" "$PWD" "$results/$role" \
    --b2b-strategy "$role" --ir-snapshots full
done
tools/run-llvm24-tti "$work/DCT8.ll" "$fn" > "$results/original-tti.json"

python3 - "$gpu/input.bin" <<'PY'
from array import array
import ctypes
import sys
libc = ctypes.CDLL(None)
libc.srand(0)
data = array('h', (libc.rand() % 255 - 128 for _ in range(4096**2)))
with open(sys.argv[1], 'wb') as stream:
    data.tofile(stream)
PY

for role in original anchor darm dataflow-exact; do
  input="$results/$role/final.ll"
  [[ $role != original ]] || input="$work/DCT8.ll"
  "$llvm_bin/opt" -verify -disable-output "$input"
  "$llvm_bin/llc" -O3 -march=amdgcn -mcpu=gfx906 -mattr=+sramecc \
    -amdhsa-code-object-version=4 -filetype=obj "$input" -o "$gpu/$role.o"
  "$rocm/llvm/bin/ld.lld" -shared "$gpu/$role.o" -o "$gpu/$role.hsaco"
done
"$rocm/bin/hipcc" -O2 -DBENCH_HIP tests/dataflow-b2b/replay-dct8.cpp -o "$gpu/replay"
flock "$HOME/v2-runtime/gpu.lock" bash -c '
  set -e
  for role in original anchor darm dataflow-exact; do
    "$1/replay" --kernel "$1/$role.hsaco" --input "$1/input.bin" --output "$1/validate-$role"
    cmp "$1/validate-original/output.bin" "$1/validate-$role/output.bin"
    sha256sum "$1/validate-$role/output.bin"
  done
' _ "$gpu"
python3 regression/measure_anchor_gpu.py --runner "$gpu/replay" --input "$gpu/input.bin" \
  --output "$gpu/timing" --baseline "$gpu/original.hsaco" --reference "$gpu/anchor.hsaco" \
  --darm "$gpu/darm.hsaco" --candidate "$gpu/dataflow-exact.hsaco" \
  --lock "$HOME/v2-runtime/gpu.lock" --warmup 3 --repeat 15
```
