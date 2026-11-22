# KBS AMD 构建 artifact

发布口径为合并 13b 后的 `25e9a5a`，覆盖 15 个 AMD case，含 LUD8。

需要 Linux、C++17、CMake、共享库版 LLVM 12、zlib、`patch`、`xz` 和 `sha256sum`。发布后端用 ROCm 的链接器。LUD8 使用原发布 ROCm 4.2 的 LLVM 后端。配置发布工具链路径后构建和复验。

```sh
cmake -S artifact -B build/artifact -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_CONFIG=/path/to/llvm12/bin/llvm-config
cmake --build build/artifact --parallel
export KBS_ROCM=/opt/rocm-6.3.3
export KBS_LUD_ROCM42_BIN=/opt/rocm-4.2.0/llvm/bin
build/artifact/kbs list
build/artifact/kbs build --variant anchor --case PCM32 --out pcm32-anchor
build/artifact/kbs verify --out artifact-verification
```

每次构建生成 `kernel.hsaco` 和 `build.json`，记录设备对象 SHA-256 和端到端构建耗时。输出目录需为新目录。`KBS_DATA` 可指向包含 manifest、inputs、tables 的另一目录，`KBS_LLVM12_BIN` 可覆盖配置时的 LLVM 12 bin 目录。工具链共享库按安装方式设置在动态加载器路径中。

`manifest.json` 的 `frozen` 用于确定重建。`fastest_original` 按冻结输入登记对外比较对象和中位耗时（μs）。A/A 超限时该输入无可靠中位数。LUD8 的 base 来自共同父 IR 的未融合版，后端为发布的 ROCm 4.2 O3、llc O2 和设备链接。

- `--darm-pristine` 使用原版插件，沿用 case 的例外选项。适用于 `darm` 和 `bf`。
- `--darm-original` 使用原版插件及默认 DARM 参数，复现 vLLM 的 360 秒超时。超时退出码为 124。
- 〔1〕vLLM 的 BF 不可用，单独构建退出 3。原版静态工具、pristine 与补丁插件均生成 verifier 拒绝的 IR。全量验证列出该例外，其余编译失败或对象差异使验证失败。

Anchor 搜索使用发布线源码与 LLVM 12。运行时只查询 `kbs-tti-v2` 表，缺项报错。表头保存格式版本、录制 worker 的 SHA-256、报价键字典及查询数。查询键包括调用模式、报价范围、函数和 IR 内容，略去 LLVM 打印的路径注释 `; ModuleID = ...`。记录保留函数代价与计数、兼容调整标记，以及按块及指令顺序排列的整数报价和字典下标。回放用报价重建直方图。条目排序后按 case 整体 XZ 压缩。

SRAD-stage2 的 artifact 计时清单保留 `/256`。此前 `/1024` 的 A/A 数据继续保存在历史记录。

录制时使用开发构建中的同一 `run-llvm24-tti` 协议。将 `runtime/tools/run-llvm24-tti` 放到发布工具的路径覆盖层，设置 `KBS_CASE`、`KBS_RECORD_DIR`（新建目录）、`KBS_LIVE_TTI`（发布 LLVM 24 wrapper 的绝对路径），然后运行该冻结输入的发布 `decision-greedy`。用 `run-llvm24-tti --pack DIR FILE WORKER_SHA256` 写出排序表。每个 case 录制目录独立，原始二进制及 GPU 回执保存在发布验证环境。 [14a 记录](../regression/records/artifact-14a-20261122.md)

## 运行与报告

计时覆盖 LUD8、NQU64、PCM32、vLLM、MapAiry、tigre、HLLD、MS32、SRAD16、SRAD32、Landau、SW2D、CED、TPACF、SRAD-stage2，共 15 个 AMD case、17 个冻结计时输入。SasPoint5 和 HiPIMS-George 使用 CUDA，独立 LLVM 12 artifact 的运行目标为 gfx906。SRAD-stage2/1024 只做编译验收。

在上面的 CMake 命令中增加 `-DKBS_GPU_RUNNERS=ON`，用 ROCm 的 `hipcc` 构建 HIP runner，并显式选择一个 gfx906 设备。需要 GNU tar、zstd，以及下载远程存档时的 curl。构建及运行由 C++ 和编译、解包工具完成。

```sh
export ROCR_VISIBLE_DEVICES=0
build/artifact/kbs run --variant anchor --case vllm/64K
build/artifact/kbs compare --objects artifact-verification
build/artifact/kbs compare --quick --objects artifact-verification
build/artifact/kbs compare --case PCM32 --case Landau --force --objects artifact-verification
build/artifact/kbs report
build/artifact/kbs report --quick
```

默认结果目录为 `kbs-results`，可用 `--out DIR` 覆盖。完整和快速比较分别写入 `full`、`quick`。`--objects` 可复用 `kbs verify` 重建的产物和编译时间。省略时按需构建并复用每个对象。运行前逐个核对对象、输入、参考输出和存档的 SHA-256。vLLM、MapAiry、MS32、PCM32、NQU64 的输入和参考由 C++ 生成。LUD8 的输入由 C++ 生成，参考输出来自已校验的发行回执。SRAD-stage2 从冻结存档提取输入与系数，现场生成 J 的参考输出。其余输入从冻结存档提取。`run-manifest.json` 登记文件摘要、计时协议及存档 URI。将同名存档放到本地镜像目录后，设置 `KBS_ARCHIVE_DIR` 即可从镜像读取。当前存档位于 EPYC 的 `/data/home/chh/v2-runtime/artifact-14b`。

`darm` 使用可确定重建的补丁版，`darm-best` 加载 14a 登记的原版对象，只供运行。CED 和 SW2D 的原版对象已有冻结哈希，14a 没有通过 A/A 的最优形态计时。报告明确标出这两个输入的比较口径。相同对象 SHA-256 的变体共用样本。A/A 刻意使用两份相同对象作为独立角色。A/A 合格要求配对中位时比偏离 1 至多 1%，比值跨度至多 3%。完整模式遵循发布、31/61 次中位数、HIP Graph 和 pinned 分块协议。PCM32 用 pinned 分块回读，LUD8 用 pinned 分块上传及回读。快速模式使用 3 个窗口，通常每窗口 11 个样本。vLLM、MS32、PCM32 沿用其单样本窗口。A/A 一次，区间仅供参考。每个正式样本校验完整输出，失败停止。A/A 超限的输入落盘为未可靠计时，随后继续。

`run` 每个输入计一次。只有一个输入时可以直接传 case 名，多输入 case 可用 case 名跑各输入，或指定完整输入名。

`compare` 默认运行所有输入。重复 `--case` 可选择多个 case 或冻结输入。每完成一个输入就原子写入回执，续跑会跳过已完成的输入。用 `--force` 可重跑指定输入。两种模式分别从完成回执生成 Markdown 和 CSV 报告，并列出缺失输入。原始时值、A/A、命令和日志在各输入的 attempt 目录下。默认通过本机文件锁串行使用 GPU，实验室可将 `KBS_GPU_LOCK` 指向共享计时锁。
