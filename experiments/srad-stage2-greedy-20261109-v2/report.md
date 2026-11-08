# SRAD stage 2 独立接入与复测（2026-11-09）

## 结论

完整 srad_cuda_2 四分支case已接入 cases/srad-stage2，C++正确性与GPU计时完成。新贪心没有提交融合；原始artifacts DARM融合2次。额外强制测试了一个静态0分候选。没有确认稳定收益，尤其1024²输入计时跨批波动大，不能用单一汇总百分比选优。

| 方案 | 融合次数 | 初测1024²/256² μs | 独立复测1024²/256² μs |
|---|---:|---:|---:|
| baseline | 0 | 208.960 / 21.600 | 204.961 / 21.280 |
| 新贪心两种清理 | 0 | 与baseline二进制相同 | 与baseline二进制相同 |
| 原始DARM | 2 | 252.000 / 22.080 | 215.360 / 21.760 |
| 强制trial0 | 1 | 165.920 / 21.920 | 209.120 / 21.760 |

这些是三批中位数的中位数，不代表1024²排名稳定。初测强制候选看似减少20.6%，复测变成增加2.0%，不得保留前一个数字作收益声明。
初测baseline 1024²三批：148.160、208.960、253.760 μs。
复测baseline 1024²三批：155.680、246.800、204.961 μs。
复测DARM：219.360、215.360、214.880 μs；强制候选：205.440、209.120、214.400 μs。
256²较稳定；复测DARM/强制候选汇总耗时均比baseline高约2.26%，仍不推断未枚举方案都无收益。

初测固定3批，每批3预热+15测量。因为初测跨批波动，随后预先固定一次独立复测：3批，每批10预热+30测量。两轮完整数据均保留，没有剔除或混合挑选样本。每轮三个唯一二进制循环轮换顺序；全部完整输出检查通过。计时均为C++ HIP event，不含CPU oracle、上传、下载。

## Case定义与校验

来源 /home/chh/darm-artifacts-repro/upstream/benchmarks/benchmarks/SRAD/srad_kernel.cu。保留原始完整源码和SHA256；HIP版本只增加include、BLOCK_SIZE16、extern C包装，并选取完整srad_cuda_2定义，没有抽取叶子helper，也没有改变条件或公式。

沿用cases/srad的256²/1024²随机图像和第一阶段独立CPU oracle的C/N/S/W/E作为第二阶段输入，lambda=0.5、q0sqr=0.1（后者在本kernel不用）。不是实测GPU输出反馈，不是完整两阶段solver计时。

独立C++ oracle按全局坐标夹紧南/东邻居，计算
d = C*N + C_south*S + C*W + C_east*E；
J_new = J + 0.25*lambda*d。
保持原式float和double字面量的运算精度次序，-ffp-contract=off。

每次launch前重置所有输入。完整J对CPU oracle用abs3e-5+rel3e-5检查，其余五输入逐字节不变，检查guards和有限值。相同二进制不重复伪造样本。

## 编译与搜索

LLVM12/gfx906，评分LLVM24 TTI。与stage1相同的公共准备：
frontend O3 → always-inline/O3/internalize(public=srad_cuda_2)/globaldce。
初始v1漏掉公共internalize/DCE，llc在与kernel无关的__ockl_printf_append_string_n触发SGPR spill断言；失败记录保留。v2采用stage1同一准备流程，清掉不可达库函数后成功。所有对照从同一post.ll出发，最终统一O3/llc/link。

新贪心structural=1、adjacent-only=0、rounds256、trials100000。两种模式各枚举3个合法候选，均无未知成本，提交0，以no_positive_candidate停止。
scoped-cfg：
- B11:B12:B13，%if.then128 + %if.else138：0分，成本236→236；已额外强制测。
- B9:B10:B12：−26。
- B9:B10:B13：−11。

这是原始四路源码优化后的LLVM CFG枚举结果，不是人为只挑其中两路。
原始artifacts DARM提交e9bc0540325ad9806313d34e84fc901496fd8be6，2次融合。
实现版本4edb0b3，本轮未修改评分或融合算法。
三种不同二进制均SGPR26、VGPR15、private segment0；没有证据把性能波动归因于寄存器差异。

## 复现及保存

musa：
- case：/home/chh/kernel-benchmark-suite/cases/srad-stage2/
- 结果：/home/chh/kernel-benchmark-suite/experiments/srad-stage2-greedy-20261109-v2/
- baseline：/home/chh/kernel-benchmark-suite/results/srad-stage2-baseline-binary-v1/kernel.hsaco

case的make_fixtures.cpp、fixture-manifest.json保存生成方式和每个输入哈希；build_binary.py提供独立完整构建，生成binary已确认与实测baseline字节相同。
prepare.py/build-plan.json保存搜索及构建；scoped-local/、scoped-cfg/保存每个trial IR和分数；forced-0-pair/manifest.json保存强制候选构建命令。
measure.py/measure/、confirm.py/measure-confirm/保存两轮原始准入、CSV、校验和哈希；summary.json与confirm-summary.json同时保留。

运行既有case基线：
```bash
cd /home/chh/kernel-benchmark-suite
./bench srad-stage2 validate --out results/srad-stage2-new-validation --warmup 3 --repeat 15
./bench srad-stage2 benchmark --out results/srad-stage2-new-timing --validated results/srad-stage2-new-validation --warmup 3 --repeat 15
```
输出目录需不存在。默认二进制是已验证的独立build profile结果。
