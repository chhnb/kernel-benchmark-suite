# SRAD 测量方式对照

这套诊断程序用发布归档中的 DP1 做 A/A。它生成实验用 replay 和 TIGRE harness，正常 runner 的测量路径保持原样。样本路径来自 EPYC 上的发布归档和历史 fixture 目录，见 compare.py。重跑时先核对这些路径指向同一组 HSACO 和输入。

在该分支的仓库根目录执行以下命令。目标目录必须是新的。编译器路径使用 EPYC 上的 ROCm 6.3.3。

```sh
trial=build/srad-measurement-repeat
mkdir "$trial"
cp regression/srad_measurement/*.py regression/srad_measurement/*.hpp \
  regression/srad_measurement/output_check_test.cpp "$trial/"
g++ -std=c++17 -Wall -Wextra -Werror -O2 "$trial/output_check_test.cpp" \
  -o "$trial/output-check-test"
"$trial/output-check-test"
python3 "$trial/experiment.py"
/opt/rocm-6.3.3/bin/hipcc -O2 -std=c++17 -I runner -DBENCH_HIP -x hip \
  "$trial/replay.cpp" -o "$trial/replay"
/opt/rocm-6.3.3/bin/hipcc -O2 -std=c++17 -I runner -I cases/tigre-siddon/harness \
  "$trial/tigre.hip" -o "$trial/tigre"
python3 -u "$trial/compare.py"
```

计时和选择结果见 [SRAD 稳定性记录](../records/srad-stability-20261120.md)。每次校准和试跑都写入单独的目录，校验出错后测量进程退出。
