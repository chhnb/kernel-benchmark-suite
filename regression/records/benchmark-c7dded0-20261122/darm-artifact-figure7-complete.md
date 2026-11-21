# DARM CGO 2022 artifact 复现

官方 Figure 7 的 7 组 benchmark 覆盖 25 个配置。22 个配置完成三档各 5 次计时及完整输出核对。

首轮在 LUD16 输出校验失败时停止。后续测量继续独立配置，并在每个异常档首次失败时结束该档计时。

[上游 benchmark 源码及说明](https://github.com/charitha22/cgo22ae-darm-benchmarks/tree/7f253257c619ad6b8d6529653dbbe0a0d3007195) · [上游计时矩阵](https://github.com/charitha22/cgo22ae-darm-benchmarks/blob/7f253257c619ad6b8d6529653dbbe0a0d3007195/scripts/run_speedups.sh) · [论文原始时比](https://github.com/charitha22/cgo22ae-darm-benchmarks/blob/7f253257c619ad6b8d6529653dbbe0a0d3007195/raw_numbers/lreal.csv)

## 测量设置

- EPYC + Radeon VII（gfx906）。前端、后端及设备库使用 ROCm 4.2.0 的 Clang/LLVM 12。HIP 运行库使用 ROCm 6.3.3。4.2 的运行库在当前驱动上未通过启动测试。
- DARM 使用 EPYC 上已有的 `auto-darm-opt` 执行原生 `-cfmelder`，阈值 0.2。branch fusion 使用同一工具的 `-run-branch-fusion-only`。 pass 二进制 SHA-256 为 `99fcb66d33562b1506a6a1bebaab8de9902f816a2aec9c04ef033c855f888324`。
- `opt` 入口暂时移除不兼容的 `G1` 数据布局项，并在后端前恢复。MS 的 O0 设备库 IR 额外处理旧 parser 不支持的 `poison` 和 `mustprogress`。MS 按官方 Makefile 保留 baseline O3 与两种 pass 档 O0 前端加 GVN / mem2reg 的设置。
- 保留官方运行参数、计时范围和每档 5 次。校验在计时范围外对完整回读结果取指纹，逐次对照各配置的 baseline。BIT 和 MS 同时要求上游排序检查通过，NQU 同时校验 2,279,184 个解。

## 实测与原始表

耗时为各档 5 次的中位数，单位 ms。加速倍数为 baseline 中位数除以该档中位数。LUD 用构建时 tile 大小标注，官方原始表标签是周边 kernel 的线程数（tile 的两倍）。

| 配置 | baseline ms | branch fusion ms | DARM ms | branch fusion 加速 | DARM 加速 | 论文 DARM 加速 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| BIT32 | 6.46686 | 6.47039 | 5.75230 | 0.9995× | 1.1242× | 1.1054× |
| BIT64 | 4.65711 | 4.65631 | 3.29327 | 1.0002× | 1.4141× | 1.4599× |
| BIT128 | 5.62573 | 5.62222 | 4.28606 | 1.0006× | 1.3126× | 1.2958× |
| BIT256 | 6.52736 | 6.56239 | 5.26511 | 0.9947× | 1.2397× | 1.2381× |
| PCM32 | 893.33500 | 708.21100 | 650.66100 | 1.2614× | 1.3730× | 1.3736× |
| PCM64 | 1020.28000 | 863.60500 | 780.01500 | 1.1814× | 1.3080× | 1.3086× |
| PCM128 | 1140.71000 | 929.35700 | 943.76200 | 1.2274× | 1.2087× | 1.2424× |
| PCM256 | 1644.58000 | 1604.23000 | 1467.24000 | 1.0252× | 1.1209× | 1.1211× |
| DCT4 | 151.04600 | 151.06400 | 151.01700 | 0.9999× | 1.0002× | 1.0008× |
| DCT8 | 38.92840 | 38.99680 | 38.97330 | 0.9982× | 0.9988× | 1.0000× |
| DCT16 | 14.62120 | 14.44960 | 14.49950 | 1.0119× | 1.0084× | 1.0103× |
| MS32 | 1212.25000 | 950.45000 | 952.77100 | 1.2754× | 1.2723× | 1.1810× |
| MS64 | 1216.50000 | 959.91300 | 960.14400 | 1.2673× | 1.2670× | 1.1796× |
| MS128 | 1217.73000 | 969.54500 | 960.65200 | 1.2560× | 1.2676× | 1.1742× |
| MS256 | 1223.19000 | 979.00700 | 978.69200 | 1.2494× | 1.2498× | 1.1627× |
| LUD8 | 521.97272 | 455.11935 | 455.31693 | 1.1469× | 1.1464× | 1.1565× |
| LUD16 | 262.78055 | — | — | — | — | 1.0814× |
| LUD32 | 289.93939 | — | — | — | — | 1.0992× |
| LUD64 | 262.94177 | 261.27841 | 265.20801 | 1.0064× | 0.9915× | 0.9932× |
| SRAD16 | 5.58110 | 5.67407 | 5.97261 | 0.9836× | 0.9344× | 0.9717× |
| SRAD32 | 5.41454 | 5.53278 | 5.85535 | 0.9786× | 0.9247× | 0.9273× |
| NQU64 | 751.25856 | 751.22839 | 631.51013 | 1.0000× | 1.1896× | 1.1897× |
| NQU96 | 519.94874 | 520.11192 | 438.37660 | 0.9997× | 1.1861× | 1.1864× |
| NQU128 | 403.72419 | 403.72418 | 340.28416 | 1.0000× | 1.1864× | 1.1872× |
| NQU256 | — | — | — | — | — | 1.1815× |

## 未通过校验的档位

- **LUD16 / branch_fusion** — Full output differs: /data/home/chh/simplify-v2/build/darm-paper-repro.AtXc3N/runs/LUD16/branch_fusion-1.log: 4092fb72bf7d2609 versus 8707a2327c4af95e
- **LUD16 / darm** — Full output differs: /data/home/chh/simplify-v2/build/darm-paper-repro.AtXc3N/runs/LUD16/darm-1.log: 4092fb72bf7d2609 versus 8707a2327c4af95e
- **LUD32 / branch_fusion** — Full output differs: /data/home/chh/simplify-v2/build/darm-paper-repro.AtXc3N/runs/LUD32/branch_fusion-1.log: e87f70930769d8a4 versus 84dcdb4e8d8926f6
- **LUD32 / darm** — Full output differs: /data/home/chh/simplify-v2/build/darm-paper-repro.AtXc3N/runs/LUD32/darm-1.log: e87f70930769d8a4 versus 84dcdb4e8d8926f6
- **NQU256 / baseline** — Output or timing verification failed: /data/home/chh/simplify-v2/build/darm-paper-repro.AtXc3N/runs/NQU256/baseline-1.log

LUD16 与 LUD32 的两个融合版本在各自配置内得到相同的完整输出指纹，与五次一致的 baseline 不同。LUD16 的两档设备代码对象也逐字节相同。现有数据只能确认输出差异，尚不能定位到元素或判断数值误差的大小。

NQU256 官方参数 `-g 15 512` 的 baseline 返回 1,147,159 个解，正确值为 2,279,184。原核函数的 block 归约从 offset 64 开始，256 线程配置下漏掉了线程 128–255。另建的诊断 baseline 加入 offset 128 后返回 2,279,184，正式表保留原 artifact 的校验结果。 [NQU 上游归约](https://github.com/charitha22/cgo22ae-darm-benchmarks/blob/7f253257c619ad6b8d6529653dbbe0a0d3007195/benchmarks/NQU/nqueen.hip.cpp#L385-L398)
