# Dataflow B2B 输入区域语料库

清单包含 936 条来源记录，扫描得到 112393 处条件分支区域、4378 个唯一区域。376 个 B2B 区域已单独保存并经过 LLVM 12 verifier。

## 按来源和 case 计数

每格依次为出现次数和结构去重后的数量。同一区域可以出现在不同来源或 case，所以各行的去重数可有重叠。每个来源的同一模块扫描其全部已定义函数。

| 来源 | case | b2b-diamond | b2b-triangle | b2r | r2r | other |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| darm | 全部 | 436 / 35 | 303 / 94 | 147 / 46 | 8 / 8 | 211 / 73 |
| darm | BIT | 0 / 0 | 200 / 1 | 100 / 2 | 0 / 0 | 100 / 2 |
| darm | DCT | 3 / 1 | 0 / 0 | 0 / 0 | 0 / 0 | 0 / 0 |
| darm | LUD | 11 / 11 | 44 / 44 | 21 / 21 | 3 / 3 | 39 / 26 |
| darm | MS | 12 / 3 | 4 / 1 | 4 / 1 | 0 / 0 | 12 / 3 |
| darm | NQU | 4 / 4 | 31 / 31 | 8 / 8 | 0 / 0 | 8 / 8 |
| darm | PCM | 402 / 12 | 4 / 3 | 8 / 8 | 4 / 4 | 32 / 15 |
| darm | SRAD | 4 / 4 | 18 / 12 | 6 / 6 | 0 / 0 | 18 / 18 |
| darm | gpu_example | 0 / 0 | 2 / 2 | 0 / 0 | 1 / 1 | 2 / 2 |
| project | 全部 | 322 / 39 | 409 / 120 | 435 / 89 | 23 / 14 | 1893 / 364 |
| project | CED | 0 / 0 | 7 / 7 | 1 / 1 | 1 / 1 | 3 / 3 |
| project | HLLD | 0 / 0 | 4 / 3 | 2 / 2 | 0 / 0 | 5 / 5 |
| project | LUD8 | 3 / 3 | 14 / 14 | 0 / 0 | 0 / 0 | 0 / 0 |
| project | Landau | 1 / 1 | 1 / 1 | 2 / 2 | 1 / 1 | 19 / 19 |
| project | MS32 | 3 / 3 | 1 / 1 | 1 / 1 | 0 / 0 | 3 / 3 |
| project | MapAiry | 7 / 1 | 1 / 1 | 15 / 5 | 1 / 1 | 46 / 24 |
| project | NQU64 | 1 / 1 | 7 / 7 | 2 / 2 | 0 / 0 | 2 / 2 |
| project | PCM32 | 16 / 3 | 0 / 0 | 4 / 4 | 0 / 0 | 12 / 6 |
| project | SRAD-stage2 | 2 / 2 | 9 / 6 | 3 / 3 | 0 / 0 | 9 / 9 |
| project | SRAD16 | 2 / 2 | 9 / 6 | 3 / 3 | 0 / 0 | 9 / 9 |
| project | SRAD32 | 2 / 2 | 9 / 6 | 3 / 3 | 0 / 0 | 9 / 9 |
| project | SW2D | 1 / 1 | 7 / 4 | 3 / 3 | 0 / 0 | 17 / 17 |
| project | TPACF | 0 / 0 | 3 / 2 | 3 / 3 | 1 / 1 | 96 / 67 |
| project | boost-landau | 1 / 1 | 1 / 1 | 2 / 2 | 1 / 1 | 19 / 19 |
| project | boost-mapairy | 7 / 1 | 1 / 1 | 15 / 5 | 1 / 1 | 46 / 24 |
| project | boost-saspoint5 | 1 / 1 | 0 / 0 | 2 / 2 | 0 / 0 | 9 / 9 |
| project | ced | 0 / 0 | 7 / 7 | 1 / 1 | 1 / 1 | 3 / 3 |
| project | cholla-hlld | 0 / 0 | 4 / 3 | 2 / 2 | 0 / 0 | 5 / 5 |
| project | cudaflow-particles | 1 / 1 | 6 / 6 | 8 / 8 | 0 / 0 | 21 / 21 |
| project | hipims | 14 / 13 | 136 / 48 | 57 / 29 | 5 / 5 | 91 / 59 |
| project | hypersonic | 9 / 4 | 2 / 1 | 3 / 3 | 0 / 0 | 17 / 17 |
| project | lud8 | 3 / 3 | 14 / 14 | 0 / 0 | 0 / 0 | 0 / 0 |
| project | ms32 | 3 / 3 | 1 / 1 | 1 / 1 | 0 / 0 | 3 / 3 |
| project | nqu64 | 1 / 1 | 7 / 7 | 2 / 2 | 0 / 0 | 2 / 2 |
| project | pcm32 | 16 / 3 | 0 / 0 | 4 / 4 | 0 / 0 | 12 / 6 |
| project | srad | 4 / 4 | 18 / 12 | 6 / 6 | 0 / 0 | 18 / 18 |
| project | srad-stage2 | 2 / 2 | 9 / 6 | 3 / 3 | 0 / 0 | 9 / 9 |
| project | sw2d | 1 / 1 | 7 / 4 | 3 / 3 | 0 / 0 | 17 / 17 |
| project | tigre | 0 / 0 | 11 / 6 | 6 / 4 | 3 / 2 | 8 / 6 |
| project | tigre-siddon | 0 / 0 | 11 / 6 | 6 / 4 | 3 / 2 | 8 / 6 |
| project | tpacf | 0 / 0 | 3 / 2 | 3 / 3 | 1 / 1 | 96 / 67 |
| project | vllm | 44 / 2 | 19 / 3 | 52 / 6 | 0 / 0 | 236 / 20 |
| project | vllm-quant | 45 / 3 | 23 / 7 | 61 / 14 | 4 / 3 | 335 / 88 |
| project | vllm-quant-kv-dump | 44 / 2 | 19 / 3 | 52 / 6 | 0 / 0 | 236 / 20 |
| project | vllm-quant-large | 44 / 2 | 19 / 3 | 52 / 6 | 0 / 0 | 236 / 20 |
| project | vllm-quant-qwen64k | 44 / 2 | 19 / 3 | 52 / 6 | 0 / 0 | 236 / 20 |
| snapshot | 全部 | 42649 / 92 | 10241 / 147 | 11749 / 764 | 797 / 444 | 42770 / 2351 |
| snapshot | BIT128 | 0 / 0 | 1162 / 1 | 784 / 6 | 0 / 0 | 378 / 2 |
| snapshot | BIT256 | 0 / 0 | 1926 / 1 | 1296 / 6 | 0 / 0 | 630 / 2 |
| snapshot | BIT32 | 0 / 0 | 330 / 1 | 225 / 6 | 0 / 0 | 105 / 2 |
| snapshot | BIT64 | 0 / 0 | 651 / 1 | 441 / 6 | 0 / 0 | 210 / 2 |
| snapshot | CED | 0 / 0 | 18 / 8 | 5 / 3 | 0 / 0 | 1 / 1 |
| snapshot | HLLD | 0 / 0 | 14 / 6 | 4 / 4 | 2 / 1 | 12 / 12 |
| snapshot | HiPIMS-George | 2 / 1 | 288 / 22 | 114 / 19 | 9 / 3 | 181 / 38 |
| snapshot | LUD8-lud_perimeter | 6 / 4 | 28 / 14 | 0 / 0 | 0 / 0 | 0 / 0 |
| snapshot | MS128 | 0 / 0 | 1 / 1 | 1 / 1 | 0 / 0 | 3 / 3 |
| snapshot | MS256 | 0 / 0 | 1 / 1 | 1 / 1 | 0 / 0 | 3 / 3 |
| snapshot | MS32 | 0 / 0 | 1 / 1 | 1 / 1 | 0 / 0 | 3 / 3 |
| snapshot | MS64 | 0 / 0 | 1 / 1 | 1 / 1 | 0 / 0 | 3 / 3 |
| snapshot | MapAiry | 354 / 18 | 24 / 4 | 375 / 77 | 31 / 31 | 1207 / 191 |
| snapshot | NQU128 | 1 / 1 | 8 / 8 | 2 / 2 | 0 / 0 | 1 / 1 |
| snapshot | NQU256 | 1 / 1 | 8 / 8 | 2 / 2 | 0 / 0 | 1 / 1 |
| snapshot | NQU64 | 1 / 1 | 7 / 7 | 2 / 2 | 0 / 0 | 1 / 1 |
| snapshot | NQU96 | 1 / 1 | 8 / 8 | 2 / 2 | 0 / 0 | 1 / 1 |
| snapshot | PCM128 | 30907 / 11 | 593 / 5 | 33 / 5 | 466 / 246 | 1469 / 315 |
| snapshot | PCM256 | 7291 / 11 | 581 / 6 | 33 / 5 | 210 / 118 | 213 / 152 |
| snapshot | PCM32 | 128 / 3 | 0 / 0 | 41 / 19 | 0 / 0 | 231 / 41 |
| snapshot | PCM64 | 128 / 3 | 0 / 0 | 41 / 19 | 0 / 0 | 231 / 41 |
| snapshot | SRAD-stage2 | 3 / 2 | 19 / 7 | 5 / 3 | 0 / 0 | 16 / 8 |
| snapshot | SRAD16 | 6 / 4 | 27 / 6 | 9 / 5 | 0 / 0 | 21 / 15 |
| snapshot | SRAD32 | 6 / 4 | 27 / 6 | 9 / 5 | 0 / 0 | 21 / 15 |
| snapshot | SW2D | 0 / 0 | 8 / 5 | 3 / 3 | 0 / 0 | 17 / 17 |
| snapshot | SasPoint5 | 20 / 9 | 18 / 2 | 26 / 26 | 0 / 0 | 55 / 45 |
| snapshot | TPACF | 0 / 0 | 103 / 5 | 77 / 19 | 43 / 14 | 2633 / 340 |
| snapshot | hypersonic | 28 / 3 | 15 / 8 | 12 / 10 | 0 / 0 | 68 / 44 |
| snapshot | landau | 101 / 25 | 83 / 8 | 56 / 56 | 33 / 29 | 306 / 134 |
| snapshot | tigre | 1 / 1 | 35 / 7 | 36 / 15 | 3 / 2 | 45 / 24 |
| snapshot | vllm | 3664 / 3 | 4256 / 3 | 8112 / 457 | 0 / 0 | 34704 / 913 |
| 全部 | 全部 | 43407 / 134 | 10953 / 242 | 12331 / 871 | 828 / 465 | 44874 / 2666 |

## B2B 交叉统计

按每次出现的条件来源计数。同一个结构在不同条件来源分组中可分别出现。

| 规模 | condition_source | load 或 store | 出现次数 | 唯一区域 |
| --- | --- | --- | ---: | ---: |
| small | data | 无 | 9092 | 97 |
| small | data | 有 | 43265 | 42 |
| small | thread-pattern | 无 | 16 | 4 |
| small | thread-pattern | 有 | 308 | 45 |
| small | workgroup-uniform | 无 | 0 | 0 |
| small | workgroup-uniform | 有 | 0 | 0 |
| medium | data | 无 | 275 | 41 |
| medium | data | 有 | 73 | 34 |
| medium | thread-pattern | 无 | 16 | 6 |
| medium | thread-pattern | 有 | 139 | 43 |
| medium | workgroup-uniform | 无 | 1 | 1 |
| medium | workgroup-uniform | 有 | 0 | 0 |
| large | data | 无 | 128 | 16 |
| large | data | 有 | 762 | 13 |
| large | thread-pattern | 无 | 0 | 0 |
| large | thread-pattern | 有 | 284 | 33 |
| large | workgroup-uniform | 无 | 1 | 1 |
| large | workgroup-uniform | 有 | 0 | 0 |

## 未收录或无法扫描的输入

- darm / SB1。upstream synthetic benchmark source is not public
- darm / SB2。upstream synthetic benchmark source is not public
- darm / SB3。upstream synthetic benchmark source is not public
- darm / SB4。upstream synthetic benchmark source is not public
- project / reentry。no verifiable historical input IR found on epyc; historical LLVM12 HIP build failed, and ROCm 6 input used opaque pointers

## 抽取情况

所有 B2B 结构均有 IR 文件。b2r、r2r 和 other 的位置和结构见 `inventory.json`。
