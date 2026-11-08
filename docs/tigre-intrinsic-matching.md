# TIGRE intrinsic 匹配修复与验证（2026-11-09）

修复位置：musa `/home/chh/kernel-benchmark-suite/tools/darm_pair_engine/InstructionMatch.cpp`。
原始 artifacts 仓库 `/home/chh/darm-artifacts-repro/upstream/code` 保持干净，HEAD 为 `e9bc0540325ad9806313d34e84fc901496fd8be6`。

## 为什么可以合并

两端对应调用具有相同语义时，可以先选择参数，再执行一个共享调用。例如以下是语义示意，不是直接复制的 LLVM 文本：

```
原来：if (p) r = sample(textureA, xA); else r = sample(textureB, xB);
融合：t = select(p, textureA, textureB);
      x = select(p, xA, xB);
      r = sample(t, x);
```

所以，参数不同本身不构成拒绝理由。相同参数直接复用，不同的普通参数由 RegionMelder 生成 select（其他融合路径也可能用 PHI）。相同调用类型只是匹配条件；序列对齐仍决定实际匹配。

| 操作 | 语义 | 本次处理 |
| --- | --- | --- |
| copysign | 使用一个值的幅值和另一个值的符号，不读内存 | 加入通用 pair matcher；vLLM 专用 local-compute 路径保持原样 |
| floor | 浮点向下取整，不读内存 | 匹配同一 intrinsic 和类型，保留浮点属性 |
| amdgcn.rcp | AMD 目标相关倒数运算，不读内存 | 共享同一 intrinsic，不改成 fdiv，不改变精度语义 |
| image.sample.lz.3d | 读取纹理 | 在当前无写入、无副作用且互斥的候选作用域内匹配；选择普通参数；不扩大为任意内存调用规则 |

同一家族的“操作匹配补全”，但纯计算与纹理读取的合法性条件不同。没有改变评分权重，也没有改用 O3 搜索。

## 实现边界

调用必须指向同一函数，参数/结果类型和调用约定一致；调用属性、fast-math flags、metadata 一致；拒绝 operand bundle、musttail 和 convergent 调用。纯计算要求 readnone，采样要求只读。标记为 immarg 的立即数参数必须相同，不能生成 select 替代立即数。

不兼容的调用不匹配，但仍可融合其周围计算：DARM 的 unmatched-call 路径保留各自执行条件。仅单边存在的采样同样保持条件保护。试融合整体仍经过 LLVM verifier、作用域合法性和未涉及函数检查。

本次仅开放 floor、copysign、amdgcn.rcp 与 image.sample.lz.3d。没有把所有 intrinsic 都开放；convergent、内存写入、其他未知 intrinsic 不在本次范围。

## 实际 TIGRE 原始 IR 变化

输入为 `results/tigre-baseline-binary-v1/post.ll`，函数 `_Z19kernelPixelDetector8GeometryPfiiP13__hip_texture`。
X 为 `%if.then485`，Y 为 `%if.then499`，Z 为 `%if.then513`。
X+Y 显式候选为 `B37:B38:B40`，走 `darm-B2R` 并使用区域复制。

下面是整个目标函数的静态调用数，不是每线程动态调用次数：

| 状态 | floor | amdgcn.rcp | image.sample |
| --- | ---: | ---: | ---: |
| 初始 IR | 18 | 9 | 3 |
| X+Y 试融合原始 IR，cleanup=none | 15 | 6 | 2 |
| 自动贪心第一轮 Y+Z | 15 | 6 | 2 |
| 自动贪心第二轮 X+(Y,Z) | 12 | 3 | 1 |

cleanup=none 代表没有额外清理，仍包含 DARM 必要的内部处理。采样数减少已经发生在原始融合 IR，无需依靠外部 O3 才合并调用。

搜索配置：`--structural 1 --adjacent-only 0 --cleanup scoped-local --scorer llvm24 --rounds 256 --trials 100000`。
实际执行 19 次 trial、提交 2 次，停止原因 `no_positive_candidate`。scoped-local 仅处理变化指令的简化、局部 CSE 和 DCE，不运行 CFG 整理或全函数 O3；DARM 本身内部处理仍存在。

第一轮 X+Y 和 X+Z 的静态收益各 32，Y+Z 为 49，选择 Y+Z；下一轮 X+(Y,Z) 收益 7，继续提交。三组轴向 R2R 候选为 -62，未提交。最终树为 `X+(Y,Z)`，并不是整个函数只剩一个基本块。

## 同批 GPU 验证与性能

AMD gfx906，TIGRE head64 phantom，50 个投影分成 6 批。C++ HIP event 计时，3 次预热、15 次测量，3 组轮换版本顺序。每组每批取中位数，再按批跨组取中位数并求和。全输出正确性、有限值和保护区检查通过。

| 版本 | 耗时（ms） | 相对未融合加速 |
| --- | ---: | ---: |
| 未融合基线 | 6.690241 | 1.000× |
| 原始 artifacts 自动 DARM | 3.905280 | 1.713× |
| 修复匹配器 + 新实现自动贪心 | 3.088162 | 2.166× |

新实现比原始自动 DARM 耗时降低 20.92%；三个轮换批次分别降低 20.89%、20.98%、20.79%。相对未融合降低 53.84%。所有版本最终使用同一 LLVM12 O3/llc 编译流程；这不等于搜索每次融合都运行 O3。

后端资源：原始 DARM SGPR=54、VGPR=57；新实现 SGPR=50、VGPR=44；两者 spill=0、private segment=0。性能结论限于这张卡与当前输入，不能推出所有 case 都同样获益。

## 验证与复现

- 完整 LLVM12/LLVM24 工具构建通过。
- 新增 intrinsic_matching 回归：纯操作匹配、未知 intrinsic 拒绝、立即数/收敛性限制、不同坐标选择后共享采样、不兼容采样保留条件、单边采样不投机执行、父状态不变。
- 既有 hybrid 与 scoped-local 测试通过。
- vLLM D16 局部递归融合回归仍完成 7 次融合。本次未重新测 vLLM GPU 性能。
- 最终源码构建后重跑 TIGRE 搜索，输出与已完成 GPU 验证和测量的 IR 字节一致。

完整实验位于 `/home/chh/kernel-benchmark-suite/experiments/tigre-intrinsic-match-20261109-v1/`。
`prepare.py` 保存搜索与共同后端编译流程；`measure.py` 使用现有 GPU admission 和 bench 接口；`summary.json` 保存性能汇总；`final-check.py` 保存最终回归流程。原始自动 DARM 对照工具未修改。

CPU 流程需经现有资源准入脚本运行，例如：

```
python3 /home/chh/kernel-benchmark-suite/experiments/saspoint5-cuda-v1/run_cpu.py UNIQUE_LABEL bash /home/chh/kernel-benchmark-suite/tests/postopt/build_intrinsic_matching.sh
```

重新实验应使用新输出目录，避免覆盖本次数据。
