# Hypersonic：不包含 Jump Threading 的 LLVM12 优化流水线

2026-11-09。已实现并运行，尚未将它设为 suite 全部 case 的默认构建方式，也尚未在此输入上完成新的 DARM 融合搜索。

## 实现与控制变量

新增 C++ 工具 tools/pipeline_without_jt.cpp：使用 LLVM12 legacy PassManagerBuilder 生成 O2/O3 流水线，安装 gfx906 TargetMachine 的优化扩展；标准函数级准备先执行，模块级 pass 入队时仅丢弃名称为 Jump Threading 的 pass。为每个优化等级分别运行 skip=0 与 skip=1，两个 pass 清单逐行一致，仅两处 KEEP Jump Threading 变为 SKIP Jump Threading，且程序检查实际移除数量为 2。

这是基于 LLVM12 构建器、AMD 目标扩展的受控流水线，不声称完整复刻 clang 驱动的所有前端扩展和流水线配置。正常版本与 no-JT 版本之间只改变 JT 过滤。正常版本重现了 L1 统一入口消失的现象。

输入不是已经过 O2 的 start.ll。重放同源源码、头文件、gfx906 和 bitcode 库的 clang -cc1 命令，增加 -disable-llvm-passes，生成 frontend.ll；保留 O2 的前端语义属性。随后两种流水线读取同一份 frontend.ll。没有使用 jump-threading-threshold=0 冒充完全禁用，也没有用 opt-bisect 截断之后的优化。

## 结构结果

| 版本 | 完整 kernel 块数 | 条件 br | L1 主体块数 | L1 入口 |
|---|---:|---:|---:|---|
| 之前 O0+SROA+mem2reg | 467 | 170 | 30 | 单入口 |
| 本次正常 O2 | 56 | 31 | 5 | 两个入口 |
| 本次 O2 不含 JT | 59 | 31 | **6** | **单入口** |
| 本次正常 O3 | 56 | 31 | 5 | 两个入口 |
| 本次 O3 不含 JT | 59 | 31 | **6** | **单入口** |

O2/O3 no-JT 的完整 L1 为 B8～B13，共 104 条指令。唯一外部进入边 B7→B8，唯一外部离开边 B13→B23。入口 if.then29，出口 if.end52。无循环，所有叶内路径均流向出口，因此完整逻辑 L1 可圈成 SESE。

```text
外部 → B8 if.then29：统一判断
          ├→ B9：边界状态计算 ──────────┐
          └→ B10：mask 判断            │
                 ├→ B11：墙面处理 ────┤
                 └→ B12：邻居读取 ────┤
                                       ↓
                                B13：结果 PHI、UR 读取
                                       ↓
                                B23 if.end52
```

RegionInfo 的 canonical R20 是 B8～B12、出口 B13；完整逻辑 L1 还包含直线尾块 B13。不要混淆这两个范围。后续叶子枚举仍需将这个尾块和输出映射纳入完整逻辑单元。

## 后端与执行验证

两份 O2 流水线输出都执行相同的 internalize（保留 face_kernel、d_cfg）和 globaldce 去除无用库代码，然后通过 suite 原有公共最终 O3/llc/link。注意这个最终 O3 允许 JT；保持 SESE 的阶段是它之前的搜索输入。

最终两份 GPU binary **字节完全相同**，所以只验证和计时一次，并记录别名，不伪造两组独立样本。gfx906 的两个固定快照完整输出检查通过；3 预热+15 测量，3 批，C++ HIP event。中位耗时约 1816.961 / 1816.641 μs。没有融合收益主张；这是相同二进制的执行确认。一次启动前 admission 拒绝后按入口有界重试成功；本轮没有 GPU 执行失败。

这表明本例可以在搜索前保留 SESE，同时最终代码生成恢复完整优化。不能先运行最终 O3 再期待原来的逻辑入口还存在，也不能从此例推导所有 case 禁用 JT 都会保持所有区域边界。

之前 SESE 局部清理实验的低优化 baseline 在计时中发生过 GPU fault，那轮结果保持未验收，与本轮成功记录分开保存。

## 使用

以下是新工具的参数，不是 stock opt 自带的 skip 开关：

```bash
/home/chh/kernel-benchmark-suite/build/llvm24-tti/pipeline-without-jt \
  --input frontend.ll --out no-jt.ll --log passes.tsv \
  --level 2 --skip-jump-threading=1 \
  -amdgpu-early-inline-all=true -amdgpu-function-calls=false
```

当前工具针对本实验 gfx906；--level 3 得到 O3 no-JT。pipeline-without-jt 虽保存在历史名为 llvm24-tti 的构建目录中，其实现链接和执行的是 LLVM12。

## 文件

musa /home/chh/kernel-benchmark-suite/experiments/hypersonic-no-jt-20261109-v1/：

- frontend-command.json / frontend.ll：优化前输入与命令。
- O2-normal.ll / O2-no-jt.ll / O3-normal.ll / O3-no-jt.ll：四份完整优化 IR。
- *-passes.tsv：正常/跳过 pass 清单。
- *-inventory.json、structure.json：CFG/Region 和 L1 边界。
- build.sh、prepare.py、compile.py、measure.py：可重放入口。
- pair/：共同最终 O3 后 IR、GPU binary、hash 和资源记录。
- measure/、summary.json、verification.json：验证、计时与二进制身份。

成功 CPU 日志：region-fusion-lab/work/hypersonic-no-jt-20261109-v3、hypersonic-no-jt-codegen-20261109-v1。
