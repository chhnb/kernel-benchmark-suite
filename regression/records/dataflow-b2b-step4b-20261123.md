# Dataflow B2B 第 4b 步

起点 `9f7b31b`，在 epyc 的 `/data/home/chh/kernel-benchmark-suite-dataflow-b2b` 工作。正式运行仅包含 DCT8 和 PCM32。DCT8 复用第 4a 步代码对象和输入。

## 规模回退和归因

`dataflow-exact` 在两侧合计超过 10 条非终结、非调试指令时记 `anchor_fallback`。后续调用原 anchor 计划生成、同一 uniform gate 和同一真实 TTI 裁决。目录只为参考求解器补充 small 候选。对于原流程支持的间接 B2B 或区域级候选，沿用 anchor 及原有区域生成机制。

第一次 PCM32 试跑暴露了一个既有接入缺口。带独立出口的间接 B2B 在默认 anchor 路径有合法方案，超出独立抽取覆盖范围，旧 exact 路径未调用 anchor 生成。这次让未被独立求解器处理的候选照常走默认生成，重新生成并验证四个正式变体。第一轮试跑的 GPU 数据未用于统计。

对真实 PCM32 搜索没有出现的规模回退，在第一个 PCM32 菱形的两臂各追加四条算术指令，用原输入的同一块位置显式发起两个试验，核对回退理由、布局、完整裁决和清理后 IR。该输入只用于验证回退。区域 ID 用相同抽取工具从每个试验对应的父 IR 重建，直接菱形的 ID 还与求解器记录交叉核对。间接或区域级试验记录其分支根的结构哈希和原块 ID。动态产生的新根注明未收录。

## 设备验证和采集

- PCM32 使用项目冻结的 1 GiB 输入和 1 GiB CPU 参考，校验发布 manifest 中的 SHA-256。验证模式重新执行 32,768 组 CPU 排序，核对参考文件，然后核对每版 GPU 输出。沿用 LLVM12 gfx906 后端和 ROCm 链接器。
- 计时采用第 4a 步同一驱动的四角色平衡轮换，12 轮，每轮每角色预热 3 次、计时 15 次，计算轮内和跨轮中位数及 10,000 次 bootstrap。PCM32 的输入从设备上保留的一份原件恢复，校验用 4 MiB pinned buffer 分块读回 1 GiB。两者均在计时事件之外。设备保持相同频率配置。
- 系统 ROCm 目录未装 profiler，使用 epyc 既有的 ROCm 6.3.3 rocprof 解包副本。首次请求 `SQ_WAVE_CYCLES` 的两个 DCT8 命令退出 134，生成的 CSV 没有计数行。去除该硬件不支持的指标后，两版均得到 18 条完整记录。与发布指标表核对，gfx906 未暴露动态 wave 驻留率。用 `hipModuleOccupancyMaxActiveBlocksPerMultiprocessor` 补充静态资源上限，记录时区分驻留上限、实际 dispatch 的 wave 数和动态占用率。
- ROCProfiler 时间取 `EndNs - BeginNs`。GPU 正式时间用未插桩 HIP 事件。PCM32 的 profiler dispatch ID 跳过恢复输入的设备拷贝。统计按 kernel 开始时间排序，再丢弃前 3 个预热样本。所有 profile 和正式计时使用相同 kernel 输入和发射配置。[AMD rocprof 文档](https://rocm.docs.amd.com/projects/rocprofiler/en/docs-6.4.1/how-to/using-rocprof.html)

## 重放命令

```sh
cd /data/home/chh/kernel-benchmark-suite-dataflow-b2b
llvm="$HOME/v2-runtime/toolchains/llvm12-jammy/usr"
llvm_bin="$llvm/lib/llvm-12/bin"
rocm=/opt/rocm-6.3.3
export LLVM_CONFIG="$llvm_bin/llvm-config"
export LD_LIBRARY_PATH="$llvm/lib/x86_64-linux-gnu:$HOME/v2-runtime/toolchains/llvm24-pinned/lib:$rocm/lib"
export HIP_VISIBLE_DEVICES=0 ROCR_VISIBLE_DEVICES=0
export DECISION_GREEDY_JOBS=6
w="$PWD/build/dataflow-corpus/step4b"
pcm="$w/pcm32"
dct="$w/dct8"
gpu="$pcm/gpu"
old="$PWD/build/dataflow-corpus/step4a/gpu"
fixtures="$HOME/simplify-v2/build/dp1-removal/sort-materials"
prof="$HOME/simplify-v2/build/b2b-layouts/anchor-heldout/rocm/prof/opt/rocm-6.3.3"
lock="$HOME/v2-runtime/gpu.lock"
mkdir -p "$pcm" "$dct" "$gpu" "$pcm/profile"

tools/build-llvm24-tti --search-only
tools/build-decision-greedy
gzip -dc regression/greedy-v1/inputs/db3b35287f1ef284.ll.gz > "$pcm/input.ll"
sha256sum "$pcm/input.ll" "$fixtures/PCM32.input" "$fixtures/PCM32.reference"
python3 tests/dataflow-b2b/check-step4b-fallback.py "$pcm"
tools/run-llvm24-tti "$pcm/input.ll" _Z3pcmPi > "$pcm/original-tti.json"

for role in anchor darm dataflow-exact; do
  build/decision-fuse/decision-greedy "$pcm/input.ll" _Z3pcmPi "$PWD" "$pcm/$role" \
    --b2b-strategy "$role" --ir-snapshots compact
done

for role in original anchor darm dataflow-exact; do
  ir="$pcm/$role/final.ll"
  [[ $role != original ]] || ir="$pcm/input.ll"
  "$llvm_bin/opt" -verify -disable-output "$ir"
  "$llvm_bin/llc" -O3 -march=amdgcn -mcpu=gfx906 -mattr=+sramecc \
    -amdhsa-code-object-version=4 -filetype=obj "$ir" -o "$gpu/$role.o"
  "$rocm/llvm/bin/ld.lld" -shared "$gpu/$role.o" -o "$gpu/$role.hsaco"
done
"$rocm/bin/hipcc" -O2 -DBENCH_HIP tests/dataflow-b2b/replay-pcm32.cpp -o "$gpu/replay"
for role in original anchor darm dataflow-exact; do
  flock "$lock" "$gpu/replay" --kernel "$gpu/$role.hsaco" --input "$fixtures" \
    --output "$gpu/validate-$role" > "$gpu/validate-$role.log"
done
python3 regression/measure_anchor_gpu.py --runner "$gpu/replay" --input "$fixtures" \
  --output "$gpu/timing" --baseline "$gpu/original.hsaco" --reference "$gpu/anchor.hsaco" \
  --darm "$gpu/darm.hsaco" --candidate "$gpu/dataflow-exact.hsaco" \
  --lock "$lock" --warmup 3 --repeat 15

export LD_LIBRARY_PATH="$prof/lib:$LD_LIBRARY_PATH"
"$prof/bin/rocprof" --list-basic > "$dct/basic.log" 2>&1 || true
"$prof/bin/rocprof" --list-derived > "$dct/derived.log" 2>&1 || true
metrics='pmc: Wavefronts VALUInsts SALUInsts VALUBusy MemUnitBusy MemUnitStalled'
printf '%s\nkernel: CUDAkernelQuantizationShort\n' "$metrics" > "$dct/metrics.txt"
printf '%s\nkernel: pcm\n' "$metrics" > "$pcm/profile/metrics.txt"
for role in anchor dataflow-exact; do
  "$rocm/llvm/bin/llvm-objdump" -d --mcpu=gfx906 "$old/$role.hsaco" > "$dct/$role.s"
  flock "$lock" timeout 120 "$prof/bin/rocprof" -i "$dct/metrics.txt" --timestamp on \
    -o "$dct/$role-supported.csv" "$old/replay" --kernel "$old/$role.hsaco" \
    --input "$old/input.bin" --mode benchmark --warmup 3 --repeat 15 \
    --output "$dct/$role-supported-replay"
done
for role in anchor dataflow-exact darm; do
  "$rocm/llvm/bin/llvm-objdump" -d --mcpu=gfx906 "$gpu/$role.hsaco" > "$pcm/profile/$role.s"
  flock "$lock" timeout 240 "$prof/bin/rocprof" -i "$pcm/profile/metrics.txt" --timestamp on \
    -o "$pcm/profile/$role.csv" "$gpu/replay" --kernel "$gpu/$role.hsaco" \
    --input "$fixtures" --mode benchmark --warmup 3 --repeat 15 \
    --output "$pcm/profile/$role-replay"
done
"$rocm/bin/hipcc" -O2 tests/dataflow-b2b/query-gfx906-occupancy.cpp -o "$w/occupancy"
"$w/occupancy" _Z27CUDAkernelQuantizationShortPsi 64 "$old"/{anchor,dataflow-exact}.hsaco > "$dct/occupancy.txt"
"$w/occupancy" _Z3pcmPi 32 "$gpu"/{anchor,dataflow-exact,darm}.hsaco > "$pcm/occupancy.txt"
python3 tools/dataflow_b2b/collect_step4b.py "$w" build/dataflow-corpus/step4a/extract_regions \
  tests/dataflow-b2b/results/step4b-evidence.json
```

[结果](../../tests/dataflow-b2b/results/step4b.md)
