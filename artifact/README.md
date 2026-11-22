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
