# B2B 布局使用统计

默认版本 A 为 `9dc661c`。vLLM 64K 和 128K 共享同一个编译产物，布局只统计一次。
生成数包含清理后重复的布局。候选内第一包含并列，选中数按运行时的并列顺序仅计一次。最终提交按 driver 的 selected 记录连接候选与轮次。

| 布局族 | 生成 | 重复 | 已评分 | 候选内第一含并列 | 候选内选中 | 最终提交 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `aligned-hoist` | 15 | 0 | 15 | 1 | 1 | 0 |
| `binary-common-dp` | 7 | 0 | 7 | 0 | 0 | 0 |
| `common-dp` | 188 | 0 | 188 | 9 | 7 | 0 |
| `common-dp-suffix` | 19 | 0 | 19 | 2 | 2 | 0 |
| `common-join-dp` | 55 | 2 | 53 | 2 | 2 | 1 |
| `join-dp` | 245 | 8 | 237 | 4 | 2 | 0 |
| `prefix` | 1006 | 0 | 1006 | 748 | 748 | 90 |
| `prefix-join-dp` | 83 | 0 | 83 | 6 | 3 | 0 |
| `prefix-merged-exit` | 720 | 16 | 704 | 699 | 3 | 2 |
| `prefix-suffix` | 56 | 0 | 56 | 23 | 23 | 6 |
| `segment-dp` | 8601 | 3099 | 5502 | 773 | 433 | 173 |
| `separate` | 212 | 0 | 212 | 212 | 212 | 1 |
| `suffix` | 89 | 0 | 89 | 10 | 10 | 1 |

| Case | B2B 布局生成 | B2B 布局评分 | B2B 最终提交 | 全部提交 | 审计运行秒数 |
| --- | ---: | ---: | ---: | ---: | ---: |
| vLLM | 5852 | 4124 | 224 | 224 | 157.198 |
| Map-Airy | 3956 | 2691 | 21 | 32 | 64.138 |
| TIGRE | 247 | 162 | 3 | 6 | 3.043 |
| HLLD | 78 | 78 | 2 | 4 | 1.706 |
| NQU64 | 9 | 8 | 0 | 1 | 0.223 |
| MS32 | 114 | 114 | 1 | 1 | 0.677 |
| PCM32 | 162 | 130 | 17 | 17 | 3.391 |
| SRAD16 | 439 | 432 | 3 | 3 | 2.219 |
| SRAD32 | 439 | 432 | 3 | 3 | 2.253 |

## 裁剪判据

- 生成过、从未获最高分且未提交的布局族 `binary-common-dp`
- 获过最高分但未提交的布局族 `aligned-hoist` `common-dp` `common-dp-suffix` `join-dp` `prefix-join-dp`

## 布局实例

| 布局族 | 观察 | Case | 轮次 | 试跑目录 | 布局 | 候选 |
| --- | --- | --- | ---: | --- | --- | --- |
| `aligned-hoist` | `best` | `NQU64` | `0` | `trial-9` | `single-branch-aligned-hoist` | `_Z24solve_nqueen_cuda_kerneliiPjS_S_S_i:B21:B20:B19` |
| `common-dp` | `best` | `TIGRE` | `0` | `trial-1` | `single-branch-common-dp` | `_Z19kernelPixelDetector8GeometryPfiiP13__hip_texture:B5:B6:B8` |
| `common-dp-suffix` | `best` | `SRAD16` | `0` | `trial-5` | `single-branch-common-dp-suffix` | `_Z11srad_cuda_1PfS_S_S_S_S_iif:B24:B25:B28` |
| `common-join-dp` | `commit` | `Map-Airy` | `32` | `trial-308` | `single-branch-common-join-dp-2` | `evaluate:B5:B62:B61` |
| `join-dp` | `best` | `Map-Airy` | `1` | `trial-204` | `single-branch-join-dp` | `evaluate:B79:B74:B75` |
| `prefix` | `commit` | `vLLM` | `98` | `trial-1003` | `single-branch-prefix` | `cache_eval:B52:B51:B53` |
| `prefix-join-dp` | `best` | `Map-Airy` | `1` | `trial-201` | `single-branch-prefix-join-dp` | `evaluate:B78:B74:B80` |
| `prefix-merged-exit` | `commit` | `HLLD` | `0` | `trial-7` | `single-branch-prefix-merged-exit` | `_ZN3mhd26Calculate_HLLD_Fluxes_CUDAEPKdS1_S1_Pdidii:B20:B23:B22` |
| `prefix-suffix` | `commit` | `Map-Airy` | `1` | `trial-20` | `single-branch-prefix-suffix` | `evaluate:B102:B101:B103` |
| `segment-dp` | `commit` | `vLLM` | `96` | `trial-1000` | `single-branch-segment-dp` | `cache_eval:B52:B53:B54` |
| `separate` | `commit` | `HLLD` | `2` | `trial-30` | `single-branch-separate` | `_ZN3mhd26Calculate_HLLD_Fluxes_CUDAEPKdS1_S1_Pdidii:B14:B17:B18` |
| `suffix` | `commit` | `Map-Airy` | `9` | `trial-99` | `single-branch-suffix` | `evaluate:B92:B89:B93` |

## 已提交的 B2B

| Case | 第几次提交 | 轮次（从 0 开始） | 试跑目录 | 候选 | 布局 | 非 CFG 工作收益 | CFG／PHI 收益 |
| --- | ---: | ---: | --- | --- | --- | ---: | ---: |
| HLLD | 2 | 0 | `trial-7` | `_ZN3mhd26Calculate_HLLD_Fluxes_CUDAEPKdS1_S1_Pdidii:B20:B23:B22` | `single-branch-prefix-merged-exit` | 91 | 11 |
| HLLD | 4 | 2 | `trial-30` | `_ZN3mhd26Calculate_HLLD_Fluxes_CUDAEPKdS1_S1_Pdidii:B14:B17:B18` | `single-branch-separate` | -1 | 4 |
| MS32 | 1 | 0 | `trial-4` | `_Z13gpu_mergesortPlS_lllP4dim3S1_:B16:B17:B18` | `single-branch-prefix-merged-exit` | -7 | 13 |
| Map-Airy | 1 | 0 | `trial-5` | `evaluate:B98:B97:B99` | `single-branch-prefix-suffix` | 248 | -20 |
| Map-Airy | 2 | 1 | `trial-20` | `evaluate:B102:B101:B103` | `single-branch-prefix-suffix` | 248 | -20 |
| Map-Airy | 4 | 3 | `trial-49` | `evaluate:B100:B99:B101` | `single-branch-prefix-suffix` | 248 | -20 |
| Map-Airy | 6 | 5 | `trial-74` | `evaluate:B100:B99:B101` | `single-branch-prefix-suffix` | 248 | -20 |
| Map-Airy | 8 | 7 | `trial-86` | `evaluate:B6:B5:B7` | `single-branch-segment-dp-4` | 57 | -10 |
| Map-Airy | 9 | 8 | `trial-92` | `evaluate:B88:B87:B89` | `single-branch-segment-dp-4` | 49 | -6 |
| Map-Airy | 10 | 9 | `trial-99` | `evaluate:B92:B89:B93` | `single-branch-suffix` | 24 | -6 |
| Map-Airy | 11 | 0 | `trial-109` | `evaluate:B10:B11:B12` | `single-branch-prefix` | 9 | 0 |
| Map-Airy | 13 | 0 | `trial-119` | `evaluate:B17:B18:B19` | `single-branch-prefix` | 9 | 0 |
| Map-Airy | 15 | 0 | `trial-129` | `evaluate:B24:B25:B26` | `single-branch-prefix` | 9 | 0 |
| Map-Airy | 17 | 0 | `trial-139` | `evaluate:B31:B32:B33` | `single-branch-prefix` | 9 | 0 |
| Map-Airy | 19 | 0 | `trial-149` | `evaluate:B38:B39:B40` | `single-branch-prefix` | 9 | 0 |
| Map-Airy | 21 | 0 | `trial-159` | `evaluate:B44:B45:B46` | `single-branch-prefix` | 9 | 0 |
| Map-Airy | 23 | 0 | `trial-169` | `evaluate:B47:B48:B49` | `single-branch-prefix` | 20 | 0 |
| Map-Airy | 24 | 0 | `trial-181` | `evaluate:B76:B74:B75` | `single-branch-prefix` | 70 | 11 |
| Map-Airy | 25 | 1 | `trial-202` | `evaluate:B78:B75:B80` | `single-branch-prefix` | 69 | 11 |
| Map-Airy | 26 | 2 | `trial-216` | `evaluate:B77:B74:B78` | `single-branch-prefix` | 69 | 11 |
| Map-Airy | 27 | 3 | `trial-227` | `evaluate:B63:B74:B75` | `single-branch-segment-dp-4` | 28 | 0 |
| Map-Airy | 29 | 21 | `trial-277` | `evaluate:B54:B65:B64` | `single-branch-segment-dp-32` | 3 | 17 |
| Map-Airy | 30 | 32 | `trial-308` | `evaluate:B5:B62:B61` | `single-branch-common-join-dp-2` | 7 | -2 |
| Map-Airy | 31 | 43 | `trial-339` | `evaluate:B5:B62:B61` | `single-branch-segment-dp-13` | 3 | 4 |
| PCM32 | 1 | 0 | `trial-0` | `_Z3pcmPi:B9:B10:B11` | `single-branch-prefix` | -2 | 17 |
| PCM32 | 2 | 1 | `trial-2` | `_Z3pcmPi:B9:B25:B24` | `single-branch-prefix` | -2 | 17 |
| PCM32 | 3 | 2 | `trial-4` | `_Z3pcmPi:B9:B25:B24` | `single-branch-prefix` | -2 | 17 |
| PCM32 | 4 | 3 | `trial-6` | `_Z3pcmPi:B9:B25:B24` | `single-branch-prefix` | -2 | 17 |
| PCM32 | 5 | 4 | `trial-8` | `_Z3pcmPi:B9:B25:B24` | `single-branch-prefix` | -2 | 17 |
| PCM32 | 6 | 5 | `trial-10` | `_Z3pcmPi:B9:B25:B24` | `single-branch-prefix` | -2 | 17 |
| PCM32 | 7 | 6 | `trial-12` | `_Z3pcmPi:B9:B25:B24` | `single-branch-prefix` | -2 | 17 |
| PCM32 | 8 | 7 | `trial-14` | `_Z3pcmPi:B9:B25:B24` | `single-branch-prefix` | -2 | 17 |
| PCM32 | 9 | 0 | `trial-16` | `_Z3pcmPi:B0:B2:B1` | `single-branch-segment-dp` | 1 | 9 |
| PCM32 | 10 | 1 | `trial-17` | `_Z3pcmPi:B13:B14:B15` | `single-branch-prefix` | -2 | 17 |
| PCM32 | 11 | 2 | `trial-19` | `_Z3pcmPi:B12:B19:B18` | `single-branch-prefix` | -2 | 17 |
| PCM32 | 12 | 3 | `trial-21` | `_Z3pcmPi:B12:B19:B18` | `single-branch-prefix` | -2 | 17 |
| PCM32 | 13 | 4 | `trial-23` | `_Z3pcmPi:B12:B19:B18` | `single-branch-prefix` | -2 | 17 |
| PCM32 | 14 | 5 | `trial-25` | `_Z3pcmPi:B12:B19:B18` | `single-branch-prefix` | -2 | 17 |
| PCM32 | 15 | 6 | `trial-27` | `_Z3pcmPi:B12:B19:B18` | `single-branch-prefix` | -2 | 17 |
| PCM32 | 16 | 7 | `trial-29` | `_Z3pcmPi:B12:B19:B18` | `single-branch-prefix` | -2 | 17 |
| PCM32 | 17 | 8 | `trial-31` | `_Z3pcmPi:B12:B19:B18` | `single-branch-prefix` | -2 | 17 |
| SRAD16 | 1 | 0 | `trial-1` | `_Z11srad_cuda_1PfS_S_S_S_S_iif:B28:B29:B30` | `single-branch-prefix-suffix` | 3 | 11 |
| SRAD16 | 2 | 0 | `trial-6` | `_Z11srad_cuda_1PfS_S_S_S_S_iif:B26:B27:B28` | `single-branch-segment-dp-13` | 2 | 11 |
| SRAD16 | 3 | 1 | `trial-8` | `_Z11srad_cuda_1PfS_S_S_S_S_iif:B22:B23:B25` | `single-branch-segment-dp-28` | -5 | 11 |
| SRAD32 | 1 | 0 | `trial-1` | `_Z11srad_cuda_1PfS_S_S_S_S_iif:B28:B29:B30` | `single-branch-prefix-suffix` | 3 | 11 |
| SRAD32 | 2 | 0 | `trial-6` | `_Z11srad_cuda_1PfS_S_S_S_S_iif:B26:B27:B28` | `single-branch-segment-dp-13` | 2 | 11 |
| SRAD32 | 3 | 1 | `trial-8` | `_Z11srad_cuda_1PfS_S_S_S_S_iif:B22:B23:B25` | `single-branch-segment-dp-28` | -5 | 11 |
| TIGRE | 4 | 0 | `trial-11` | `_Z19kernelPixelDetector8GeometryPfiiP13__hip_texture:B24:B23:B25` | `single-branch-segment-dp-3` | 65 | 11 |
| TIGRE | 5 | 1 | `trial-14` | `_Z19kernelPixelDetector8GeometryPfiiP13__hip_texture:B24:B23:B25` | `single-branch-segment-dp-9` | 68 | 0 |
| TIGRE | 6 | 0 | `trial-15` | `_Z19kernelPixelDetector8GeometryPfiiP13__hip_texture:B23:B24:B25` | `single-branch-segment-dp` | 0 | 4 |
| vLLM | 1 | 0 | `trial-12` | `cache_eval:B55:B54:B56` | `single-branch-prefix` | 1 | 0 |
| vLLM | 2 | 1 | `trial-20` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 3 | 2 | `trial-27` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 4 | 3 | `trial-33` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 0 | 11 |
| vLLM | 5 | 4 | `trial-40` | `cache_eval:B39:B41:B40` | `single-branch-prefix` | 1 | 0 |
| vLLM | 6 | 5 | `trial-42` | `cache_eval:B37:B38:B39` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 7 | 6 | `trial-43` | `cache_eval:B35:B37:B36` | `single-branch-segment-dp-2` | 0 | 16 |
| vLLM | 8 | 7 | `trial-45` | `cache_eval:B37:B36:B38` | `single-branch-prefix` | 1 | 0 |
| vLLM | 9 | 8 | `trial-53` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 10 | 9 | `trial-60` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 11 | 10 | `trial-66` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 0 | 11 |
| vLLM | 12 | 11 | `trial-73` | `cache_eval:B39:B41:B40` | `single-branch-prefix` | 1 | 0 |
| vLLM | 13 | 12 | `trial-75` | `cache_eval:B37:B38:B39` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 14 | 13 | `trial-76` | `cache_eval:B35:B37:B36` | `single-branch-segment-dp-2` | 0 | 16 |
| vLLM | 15 | 14 | `trial-78` | `cache_eval:B37:B36:B38` | `single-branch-prefix` | 1 | 0 |
| vLLM | 16 | 15 | `trial-86` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 17 | 16 | `trial-93` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 18 | 17 | `trial-99` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 0 | 11 |
| vLLM | 19 | 18 | `trial-106` | `cache_eval:B39:B41:B40` | `single-branch-prefix` | 1 | 0 |
| vLLM | 20 | 19 | `trial-108` | `cache_eval:B37:B38:B39` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 21 | 20 | `trial-109` | `cache_eval:B35:B37:B36` | `single-branch-segment-dp-2` | 0 | 16 |
| vLLM | 22 | 21 | `trial-111` | `cache_eval:B37:B36:B38` | `single-branch-prefix` | 1 | 0 |
| vLLM | 23 | 22 | `trial-119` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 24 | 23 | `trial-126` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 25 | 24 | `trial-132` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 0 | 11 |
| vLLM | 26 | 25 | `trial-139` | `cache_eval:B39:B41:B40` | `single-branch-prefix` | 1 | 0 |
| vLLM | 27 | 26 | `trial-141` | `cache_eval:B37:B38:B39` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 28 | 27 | `trial-142` | `cache_eval:B35:B37:B36` | `single-branch-segment-dp-2` | 0 | 16 |
| vLLM | 29 | 28 | `trial-144` | `cache_eval:B37:B36:B38` | `single-branch-prefix` | 1 | 0 |
| vLLM | 30 | 29 | `trial-152` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 31 | 30 | `trial-159` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 32 | 31 | `trial-165` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 0 | 11 |
| vLLM | 33 | 32 | `trial-172` | `cache_eval:B39:B41:B40` | `single-branch-prefix` | 1 | 0 |
| vLLM | 34 | 33 | `trial-174` | `cache_eval:B37:B38:B39` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 35 | 34 | `trial-175` | `cache_eval:B35:B37:B36` | `single-branch-segment-dp-2` | 0 | 16 |
| vLLM | 36 | 35 | `trial-177` | `cache_eval:B37:B36:B38` | `single-branch-prefix` | 1 | 0 |
| vLLM | 37 | 36 | `trial-185` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 38 | 37 | `trial-192` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 39 | 38 | `trial-198` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 0 | 11 |
| vLLM | 40 | 39 | `trial-205` | `cache_eval:B39:B41:B40` | `single-branch-prefix` | 1 | 0 |
| vLLM | 41 | 40 | `trial-207` | `cache_eval:B37:B38:B39` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 42 | 41 | `trial-208` | `cache_eval:B35:B37:B36` | `single-branch-segment-dp-2` | 0 | 16 |
| vLLM | 43 | 42 | `trial-210` | `cache_eval:B37:B36:B38` | `single-branch-prefix` | 1 | 0 |
| vLLM | 44 | 43 | `trial-218` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 45 | 44 | `trial-225` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 46 | 45 | `trial-231` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 0 | 11 |
| vLLM | 47 | 46 | `trial-238` | `cache_eval:B39:B41:B40` | `single-branch-prefix` | 1 | 0 |
| vLLM | 48 | 47 | `trial-240` | `cache_eval:B37:B38:B39` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 49 | 48 | `trial-241` | `cache_eval:B35:B37:B36` | `single-branch-segment-dp-2` | 0 | 16 |
| vLLM | 50 | 49 | `trial-243` | `cache_eval:B37:B36:B38` | `single-branch-prefix` | 1 | 0 |
| vLLM | 51 | 50 | `trial-251` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 52 | 51 | `trial-258` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 53 | 52 | `trial-264` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 0 | 11 |
| vLLM | 54 | 53 | `trial-271` | `cache_eval:B39:B41:B40` | `single-branch-prefix` | 1 | 0 |
| vLLM | 55 | 54 | `trial-273` | `cache_eval:B37:B38:B39` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 56 | 55 | `trial-274` | `cache_eval:B35:B37:B36` | `single-branch-segment-dp-2` | 0 | 16 |
| vLLM | 57 | 56 | `trial-276` | `cache_eval:B37:B36:B38` | `single-branch-prefix` | 1 | 0 |
| vLLM | 58 | 57 | `trial-284` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 59 | 58 | `trial-291` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 60 | 59 | `trial-297` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 0 | 11 |
| vLLM | 61 | 60 | `trial-304` | `cache_eval:B39:B41:B40` | `single-branch-prefix` | 1 | 0 |
| vLLM | 62 | 61 | `trial-306` | `cache_eval:B37:B38:B39` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 63 | 62 | `trial-307` | `cache_eval:B35:B37:B36` | `single-branch-segment-dp-2` | 0 | 16 |
| vLLM | 64 | 63 | `trial-309` | `cache_eval:B37:B36:B38` | `single-branch-prefix` | 1 | 0 |
| vLLM | 65 | 64 | `trial-317` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 66 | 65 | `trial-324` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 67 | 66 | `trial-330` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 0 | 11 |
| vLLM | 68 | 67 | `trial-337` | `cache_eval:B39:B41:B40` | `single-branch-prefix` | 1 | 0 |
| vLLM | 69 | 68 | `trial-339` | `cache_eval:B37:B38:B39` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 70 | 69 | `trial-340` | `cache_eval:B35:B37:B36` | `single-branch-segment-dp-2` | 0 | 16 |
| vLLM | 71 | 70 | `trial-342` | `cache_eval:B37:B36:B38` | `single-branch-prefix` | 1 | 0 |
| vLLM | 72 | 71 | `trial-350` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 73 | 72 | `trial-357` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 74 | 73 | `trial-363` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 0 | 11 |
| vLLM | 75 | 74 | `trial-370` | `cache_eval:B39:B41:B40` | `single-branch-prefix` | 1 | 0 |
| vLLM | 76 | 75 | `trial-372` | `cache_eval:B37:B38:B39` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 77 | 76 | `trial-373` | `cache_eval:B35:B37:B36` | `single-branch-segment-dp-2` | 0 | 16 |
| vLLM | 78 | 77 | `trial-375` | `cache_eval:B37:B36:B38` | `single-branch-prefix` | 1 | 0 |
| vLLM | 79 | 78 | `trial-383` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 80 | 79 | `trial-390` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 81 | 80 | `trial-396` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 0 | 11 |
| vLLM | 82 | 81 | `trial-403` | `cache_eval:B39:B41:B40` | `single-branch-prefix` | 1 | 0 |
| vLLM | 83 | 82 | `trial-405` | `cache_eval:B37:B38:B39` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 84 | 83 | `trial-406` | `cache_eval:B35:B37:B36` | `single-branch-segment-dp-2` | 0 | 16 |
| vLLM | 85 | 84 | `trial-408` | `cache_eval:B37:B36:B38` | `single-branch-prefix` | 1 | 0 |
| vLLM | 86 | 85 | `trial-416` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 87 | 86 | `trial-423` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 88 | 87 | `trial-429` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 0 | 11 |
| vLLM | 89 | 88 | `trial-436` | `cache_eval:B39:B41:B40` | `single-branch-prefix` | 1 | 0 |
| vLLM | 90 | 89 | `trial-438` | `cache_eval:B37:B38:B39` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 91 | 90 | `trial-439` | `cache_eval:B35:B37:B36` | `single-branch-segment-dp-2` | 0 | 16 |
| vLLM | 92 | 91 | `trial-441` | `cache_eval:B37:B36:B38` | `single-branch-prefix` | 1 | 0 |
| vLLM | 93 | 92 | `trial-449` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 94 | 93 | `trial-456` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 95 | 94 | `trial-462` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 0 | 11 |
| vLLM | 96 | 95 | `trial-469` | `cache_eval:B39:B41:B40` | `single-branch-prefix` | 1 | 0 |
| vLLM | 97 | 96 | `trial-471` | `cache_eval:B37:B38:B39` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 98 | 97 | `trial-472` | `cache_eval:B35:B37:B36` | `single-branch-segment-dp-2` | 0 | 16 |
| vLLM | 99 | 98 | `trial-474` | `cache_eval:B37:B36:B38` | `single-branch-prefix` | 1 | 0 |
| vLLM | 100 | 99 | `trial-482` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 101 | 100 | `trial-489` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 102 | 101 | `trial-495` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 0 | 11 |
| vLLM | 103 | 102 | `trial-502` | `cache_eval:B39:B41:B40` | `single-branch-prefix` | 1 | 0 |
| vLLM | 104 | 103 | `trial-504` | `cache_eval:B37:B38:B39` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 105 | 104 | `trial-505` | `cache_eval:B35:B37:B36` | `single-branch-segment-dp-2` | 0 | 16 |
| vLLM | 106 | 105 | `trial-507` | `cache_eval:B37:B36:B38` | `single-branch-prefix` | 1 | 0 |
| vLLM | 107 | 106 | `trial-515` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 108 | 107 | `trial-522` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 109 | 108 | `trial-528` | `cache_eval:B37:B36:B38` | `single-branch-segment-dp` | 0 | 11 |
| vLLM | 110 | 109 | `trial-535` | `cache_eval:B39:B41:B40` | `single-branch-prefix` | 1 | 0 |
| vLLM | 111 | 110 | `trial-537` | `cache_eval:B37:B38:B39` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 112 | 111 | `trial-538` | `cache_eval:B35:B37:B36` | `single-branch-segment-dp-2` | 0 | 16 |
| vLLM | 113 | 0 | `trial-541` | `cache_eval:B52:B51:B53` | `single-branch-prefix` | 1 | 0 |
| vLLM | 114 | 1 | `trial-549` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 115 | 2 | `trial-556` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 116 | 3 | `trial-562` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 0 | 11 |
| vLLM | 117 | 4 | `trial-569` | `cache_eval:B54:B56:B55` | `single-branch-prefix` | 1 | 0 |
| vLLM | 118 | 5 | `trial-571` | `cache_eval:B52:B53:B54` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 119 | 6 | `trial-572` | `cache_eval:B50:B52:B51` | `single-branch-segment-dp-2` | 0 | 16 |
| vLLM | 120 | 7 | `trial-574` | `cache_eval:B52:B51:B53` | `single-branch-prefix` | 1 | 0 |
| vLLM | 121 | 8 | `trial-582` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 122 | 9 | `trial-589` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 123 | 10 | `trial-595` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 0 | 11 |
| vLLM | 124 | 11 | `trial-602` | `cache_eval:B54:B56:B55` | `single-branch-prefix` | 1 | 0 |
| vLLM | 125 | 12 | `trial-604` | `cache_eval:B52:B53:B54` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 126 | 13 | `trial-605` | `cache_eval:B50:B52:B51` | `single-branch-segment-dp-2` | 0 | 16 |
| vLLM | 127 | 14 | `trial-607` | `cache_eval:B52:B51:B53` | `single-branch-prefix` | 1 | 0 |
| vLLM | 128 | 15 | `trial-615` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 129 | 16 | `trial-622` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 130 | 17 | `trial-628` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 0 | 11 |
| vLLM | 131 | 18 | `trial-635` | `cache_eval:B54:B56:B55` | `single-branch-prefix` | 1 | 0 |
| vLLM | 132 | 19 | `trial-637` | `cache_eval:B52:B53:B54` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 133 | 20 | `trial-638` | `cache_eval:B50:B52:B51` | `single-branch-segment-dp-2` | 0 | 16 |
| vLLM | 134 | 21 | `trial-640` | `cache_eval:B52:B51:B53` | `single-branch-prefix` | 1 | 0 |
| vLLM | 135 | 22 | `trial-648` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 136 | 23 | `trial-655` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 137 | 24 | `trial-661` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 0 | 11 |
| vLLM | 138 | 25 | `trial-668` | `cache_eval:B54:B56:B55` | `single-branch-prefix` | 1 | 0 |
| vLLM | 139 | 26 | `trial-670` | `cache_eval:B52:B53:B54` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 140 | 27 | `trial-671` | `cache_eval:B50:B52:B51` | `single-branch-segment-dp-2` | 0 | 16 |
| vLLM | 141 | 28 | `trial-673` | `cache_eval:B52:B51:B53` | `single-branch-prefix` | 1 | 0 |
| vLLM | 142 | 29 | `trial-681` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 143 | 30 | `trial-688` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 144 | 31 | `trial-694` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 0 | 11 |
| vLLM | 145 | 32 | `trial-701` | `cache_eval:B54:B56:B55` | `single-branch-prefix` | 1 | 0 |
| vLLM | 146 | 33 | `trial-703` | `cache_eval:B52:B53:B54` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 147 | 34 | `trial-704` | `cache_eval:B50:B52:B51` | `single-branch-segment-dp-2` | 0 | 16 |
| vLLM | 148 | 35 | `trial-706` | `cache_eval:B52:B51:B53` | `single-branch-prefix` | 1 | 0 |
| vLLM | 149 | 36 | `trial-714` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 150 | 37 | `trial-721` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 151 | 38 | `trial-727` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 0 | 11 |
| vLLM | 152 | 39 | `trial-734` | `cache_eval:B54:B56:B55` | `single-branch-prefix` | 1 | 0 |
| vLLM | 153 | 40 | `trial-736` | `cache_eval:B52:B53:B54` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 154 | 41 | `trial-737` | `cache_eval:B50:B52:B51` | `single-branch-segment-dp-2` | 0 | 16 |
| vLLM | 155 | 42 | `trial-739` | `cache_eval:B52:B51:B53` | `single-branch-prefix` | 1 | 0 |
| vLLM | 156 | 43 | `trial-747` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 157 | 44 | `trial-754` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 158 | 45 | `trial-760` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 0 | 11 |
| vLLM | 159 | 46 | `trial-767` | `cache_eval:B54:B56:B55` | `single-branch-prefix` | 1 | 0 |
| vLLM | 160 | 47 | `trial-769` | `cache_eval:B52:B53:B54` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 161 | 48 | `trial-770` | `cache_eval:B50:B52:B51` | `single-branch-segment-dp-2` | 0 | 16 |
| vLLM | 162 | 49 | `trial-772` | `cache_eval:B52:B51:B53` | `single-branch-prefix` | 1 | 0 |
| vLLM | 163 | 50 | `trial-780` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 164 | 51 | `trial-787` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 165 | 52 | `trial-793` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 0 | 11 |
| vLLM | 166 | 53 | `trial-800` | `cache_eval:B54:B56:B55` | `single-branch-prefix` | 1 | 0 |
| vLLM | 167 | 54 | `trial-802` | `cache_eval:B52:B53:B54` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 168 | 55 | `trial-803` | `cache_eval:B50:B52:B51` | `single-branch-segment-dp-2` | 0 | 16 |
| vLLM | 169 | 56 | `trial-805` | `cache_eval:B52:B51:B53` | `single-branch-prefix` | 1 | 0 |
| vLLM | 170 | 57 | `trial-813` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 171 | 58 | `trial-820` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 172 | 59 | `trial-826` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 0 | 11 |
| vLLM | 173 | 60 | `trial-833` | `cache_eval:B54:B56:B55` | `single-branch-prefix` | 1 | 0 |
| vLLM | 174 | 61 | `trial-835` | `cache_eval:B52:B53:B54` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 175 | 62 | `trial-836` | `cache_eval:B50:B52:B51` | `single-branch-segment-dp-2` | 0 | 16 |
| vLLM | 176 | 63 | `trial-838` | `cache_eval:B52:B51:B53` | `single-branch-prefix` | 1 | 0 |
| vLLM | 177 | 64 | `trial-846` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 178 | 65 | `trial-853` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 179 | 66 | `trial-859` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 0 | 11 |
| vLLM | 180 | 67 | `trial-866` | `cache_eval:B54:B56:B55` | `single-branch-prefix` | 1 | 0 |
| vLLM | 181 | 68 | `trial-868` | `cache_eval:B52:B53:B54` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 182 | 69 | `trial-869` | `cache_eval:B50:B52:B51` | `single-branch-segment-dp-2` | 0 | 16 |
| vLLM | 183 | 70 | `trial-871` | `cache_eval:B52:B51:B53` | `single-branch-prefix` | 1 | 0 |
| vLLM | 184 | 71 | `trial-879` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 185 | 72 | `trial-886` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 186 | 73 | `trial-892` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 0 | 11 |
| vLLM | 187 | 74 | `trial-899` | `cache_eval:B54:B56:B55` | `single-branch-prefix` | 1 | 0 |
| vLLM | 188 | 75 | `trial-901` | `cache_eval:B52:B53:B54` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 189 | 76 | `trial-902` | `cache_eval:B50:B52:B51` | `single-branch-segment-dp-2` | 0 | 16 |
| vLLM | 190 | 77 | `trial-904` | `cache_eval:B52:B51:B53` | `single-branch-prefix` | 1 | 0 |
| vLLM | 191 | 78 | `trial-912` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 192 | 79 | `trial-919` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 193 | 80 | `trial-925` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 0 | 11 |
| vLLM | 194 | 81 | `trial-932` | `cache_eval:B54:B56:B55` | `single-branch-prefix` | 1 | 0 |
| vLLM | 195 | 82 | `trial-934` | `cache_eval:B52:B53:B54` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 196 | 83 | `trial-935` | `cache_eval:B50:B52:B51` | `single-branch-segment-dp-2` | 0 | 16 |
| vLLM | 197 | 84 | `trial-937` | `cache_eval:B52:B51:B53` | `single-branch-prefix` | 1 | 0 |
| vLLM | 198 | 85 | `trial-945` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 199 | 86 | `trial-952` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 200 | 87 | `trial-958` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 0 | 11 |
| vLLM | 201 | 88 | `trial-965` | `cache_eval:B54:B56:B55` | `single-branch-prefix` | 1 | 0 |
| vLLM | 202 | 89 | `trial-967` | `cache_eval:B52:B53:B54` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 203 | 90 | `trial-968` | `cache_eval:B50:B52:B51` | `single-branch-segment-dp-2` | 0 | 16 |
| vLLM | 204 | 91 | `trial-970` | `cache_eval:B52:B51:B53` | `single-branch-prefix` | 1 | 0 |
| vLLM | 205 | 92 | `trial-978` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 206 | 93 | `trial-985` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 207 | 94 | `trial-991` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 0 | 11 |
| vLLM | 208 | 95 | `trial-998` | `cache_eval:B54:B56:B55` | `single-branch-prefix` | 1 | 0 |
| vLLM | 209 | 96 | `trial-1000` | `cache_eval:B52:B53:B54` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 210 | 97 | `trial-1001` | `cache_eval:B50:B52:B51` | `single-branch-segment-dp-2` | 0 | 16 |
| vLLM | 211 | 98 | `trial-1003` | `cache_eval:B52:B51:B53` | `single-branch-prefix` | 1 | 0 |
| vLLM | 212 | 99 | `trial-1011` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 213 | 100 | `trial-1018` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 214 | 101 | `trial-1024` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 0 | 11 |
| vLLM | 215 | 102 | `trial-1031` | `cache_eval:B54:B56:B55` | `single-branch-prefix` | 1 | 0 |
| vLLM | 216 | 103 | `trial-1033` | `cache_eval:B52:B53:B54` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 217 | 104 | `trial-1034` | `cache_eval:B50:B52:B51` | `single-branch-segment-dp-2` | 0 | 16 |
| vLLM | 218 | 105 | `trial-1036` | `cache_eval:B52:B51:B53` | `single-branch-prefix` | 1 | 0 |
| vLLM | 219 | 106 | `trial-1044` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 220 | 107 | `trial-1051` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 221 | 108 | `trial-1057` | `cache_eval:B52:B51:B53` | `single-branch-segment-dp` | 0 | 11 |
| vLLM | 222 | 109 | `trial-1064` | `cache_eval:B54:B56:B55` | `single-branch-prefix` | 1 | 0 |
| vLLM | 223 | 110 | `trial-1066` | `cache_eval:B52:B53:B54` | `single-branch-segment-dp` | 1 | 0 |
| vLLM | 224 | 111 | `trial-1067` | `cache_eval:B50:B52:B51` | `single-branch-segment-dp-2` | 0 | 16 |

## 采集与验证

- 采集使用 LLVM24 worker 的吞吐成本。默认运行只输出候选内胜出的 IR 和外层评分，DP1 的 `layout_profitability` 数组为空。
- 临时审计二进制从 A 构建。只在 DP1 循环向 `layout_profitability` 追加每个生成布局的标签和去重标记，已评分项也记录 `score_result`。比较、评分、清理、并列处理与 driver 保持原样。临时源码为 `build/b2b-layouts/audit-main.cpp`，运行目录为 `build/b2b-layouts/audit-complete`。
- 九个编译 case 的提交候选、布局、每步 TTI 与原运行一致。最终 IR 只因输出目录不同而有 ModuleID 行差异，去掉该行后逐字节一致。九份审计产物均通过 LLVM12 verifier。完整检查结果保存为 `build/b2b-layouts/audit-equivalence.json`。
- SRAD16 和 SRAD32 采用现有 SRAD1 冻结输入。HiPIMS 没有找到可用于审计的现成默认运行目录。本表的搜索时间来自诊断构建，裁剪加速需做无诊断开销的同配置测量。
- 版本 A 的已有测试结果为 25 项通过、6 项失败。第 1 步未改现有测试。失败项为 `single-b2b` 及 `suite` 的 V1 断言，`condition` 的缺失测试二进制，`regions` 及 `similarity` 的旧 LLVM 路径，以及 `pair-trial` 的现有目录冲突。
