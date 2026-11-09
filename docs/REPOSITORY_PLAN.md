# 仓库精简方案

## 原则

先收敛职责和入口，再移动文件，最后清理可再生数据。精简不是删除失败实验，也不是重写已有引擎。当前大量脚本与manifest使用绝对路径，直接搬目录会破坏复现。

本轮已完成README/STATUS导航、主线/benchmark/问题/整理方案四页；未移动或删除代码、case、输入、工具链、实验。

## 现状快照

2026-11-10在musa统计，du值为目录磁盘占用快照，非互斥可释放空间承诺：

| 目录 | 占用 | 主要问题/处理 |
|---|---:|---|
| experiments | 8.2GB | 约83018文件、135受Git跟踪；摘要/脚本与大量trial IR混放 |
| cases | 5.5GB | 源码、依赖、输入混放；约2746文件，仅8受Git跟踪 |
| regression | 2.7GB | 历史真数据快照和新的无输入协议并存 |
| work | 2.5GB | 临时或复现实验工作目录；逐项查引用后迁移 |
| build | 2.3GB | 构建缓存和多个工具变体，可再生性需先验收 |
| analysis | 774MB | 静态报告与早期大批枚举记录 |
| toolchains | 754MB | 不是普通缓存，清单与安装规则应保留 |
| results | 190MB | 运行/构建证据，需先区分当前依赖与历史 |

代码与文档体积很小：tools约1.2MB、docs约3.9MB、tests约3.2MB。主要的可读性问题是职责和版本混在一起，磁盘问题则主要来自输入、IR、trial与二进制。

## 建议最终结构（尚未实施）

```text
README.md
CMakeLists.txt
src/
  fusion/       # 候选/逻辑身份、trial、cleanup、搜索；LLVM12
  darm/         # 修改副本，明确上游commit与补丁
  scoring/      # LLVM24 TTI worker与接口
runner/         # 通用C++运行时
cases/<case>/
  case.json     # provenance、ABI、baseline profile、输入/验证入口
  source/       # 自有薄封装或固定上游补丁/获取清单
  harness/      # 必要的专用C++运行时
  inputs/       # 生成代码/manifest，非大数据包
configs/        # 设备/工具链/策略；与case源码解耦
scripts/        # 少量构建、准入、运行、报告编排
regression/
  catalog.json  # frozen身份、输入协议、门槛
  records/      # 小型结构化结果
  generators/   # 可再生输入/CPU oracle
  recipes/      # 冻结优胜方案如何从源码/IR重建
tests/         # 引擎合法性/运行时等价/回归测试
 docs/          # 少量当前主线页面；历史页面有日期与状态
 archive/       # 旧实验代码/报告，不再作为主线隐式依赖
```

`build/`、统一的 `runs/`、下载的toolchain、真实输入数据存储与上面受版本控制的源码树分开。目录名是建议，不是在宣称已实现。首轮仍保留现有paths，不急于移动tools。

## 分阶段实施与验收

| 阶段 | 动作 | 验收 |
|---|---|---|
| 1：文档与导航（本轮） | 根README只保留目标/入口；旧STATUS标历史；主线、构建、问题、精简四页 | 链接/实际profile/CLI核对，不运行不必要GPU测试 |
| 2：版本管理完整性 | 清点当前8程序必需源码/补丁/脚本；标外部依赖；纳入小型必需文件；建立统一case registry | 新目录可取得源码并重建baseline；没有意外把GB输入或二进制加入Git |
| 3：统一入口和配置 | 公共CPU/GPU准入入口；统一case/strategy/toolchain配置；候选选择与ABI分离；AMD/CUDA明确分派 | 同一份manifest可重建、搜索、验证和报告；生成命令透明 |
| 4：拆分代码 | 从fusion_search.cpp逐步提取inventory、trial、cleanup、search；旧入口作为显式legacy实验 | 每次小改跑C++合法性及正负case回归，保留行为对照 |
| 5：实验归档 | 保留每组结论/复现脚本/参数/关键IR/CSV/hashes；将旧试验归档；依赖由清单或重建规则替代 | 主线不依赖archive内未声明文件，冻结方案可重建 |
| 6：空间清理 | 删除已证明可再生的重复binary、非关键trial IR、临时输入；不压缩 | 清理前列精确路径/大小/引用/再生命令；清理后关键回归仍可运行 |

不建议现在把全部tools删除重建，或只保留性能最好的case。负分、0融合、非法区域拒绝和输入敏感反例都属于研究证据。

## 每次run最小保留内容

源码/工具链/配置身份、共同baseline哈希、输入生成规则/种子、候选摘要与停止原因、所选融合序列、raw与cleaned关键IR、最终二进制hash和资源、完整输出验证结果、原始计时CSV与汇总。实际冻结reference二进制可在外部artifact目录保存；必须补上可重建recipe，不能只保留hash。

拒绝的数千trial默认建议只保留候选、理由和分数；verifier失败或正在分析的trial按需留IR。当前observer尚未实现这种保留策略，所以不能现在删除后声称一定可重现全部失败。

## Git与数据

Git纳入源文件、补丁、构建/生成器、测试、配置、清单、Markdown和小型结果。外部数据不纳入；保存来源/生成方式/哈希。不要一次 `git add .`：当前未跟踪内容既有必需源码也有大产物，必须逐类清点。增加remote应在清单完整之后单独进行，本轮没有创建或推送remote。
