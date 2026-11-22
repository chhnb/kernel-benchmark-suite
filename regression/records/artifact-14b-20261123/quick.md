# KBS gfx906 performance results

**快速模式，区间仅供参考**

## 1. Speedup relative to base, with paired 95% intervals

| Frozen input | base/bf | base/darm | base/darm-best | base/anchor |
|---|---:|---:|---:|---:|
| CED/110 | Unreliable [^aa] | Unreliable [^aa] | Unreliable [^aa] | Unreliable [^aa] |
| HLLD/65536 | 1.00000 [1.00000, 1.00000] | 0.65781 [0.65449, 0.65833] | 0.65943 [0.65557, 0.66000] | 0.91435 [0.91204, 0.91879] |
| LUD8/16384 | 1.14086 [1.13873, 1.15019] | 1.14086 [1.13873, 1.15019] | 1.14086 [1.13873, 1.15019] | 1.15426 [1.15130, 1.15961] |
| Landau/coherent | 1.00000 [1.00000, 1.00000] | 0.75419 [0.75141, 0.76136] | 0.90541 [0.90476, 0.91837] | 0.95035 [0.94326, 0.95745] |
| Landau/mixed | 1.00000 [1.00000, 1.00000] | 1.81695 [1.81419, 1.82034] | 2.20082 [2.19672, 2.20988] | 2.29487 [2.29487, 2.30043] |
| MS32 | 1.10915 [1.10670, 1.11063] | 1.10915 [1.10670, 1.11063] | 1.10915 [1.10670, 1.11063] | 1.11843 [1.11768, 1.12045] |
| MapAiry/65539 | 1.00188 [0.99812, 1.00375] | 1.83849 [1.82192, 1.84138] | 2.24370 [2.23529, 2.24790] | 2.66169 [2.66000, 2.67000] |
| NQU64 | 1.00000 [1.00000, 1.00000] | 1.16213 [1.16131, 1.16500] | 1.16213 [1.16131, 1.16500] | 1.18621 [1.18508, 1.18959] |
| PCM32 | 1.23749 [1.23632, 1.23770] | 1.32812 [1.32686, 1.32812] | 1.32769 [1.32662, 1.32813] | 1.32812 [1.32686, 1.32812] |
| SRAD-stage2/256 | 1.00857 [0.97436, 1.00870] | 1.00000 [0.96610, 1.00857] | 1.00000 [0.96610, 1.00857] | 0.98305 [0.98276, 0.99995] |
| SRAD16/256 | 1.00000 [0.99291, 1.00000] | 0.97222 [0.97222, 0.97241] | 0.97902 [0.97222, 0.99296] | 1.00000 [0.99291, 1.00714] |
| SRAD32/256 | 0.99353 [0.97685, 0.99945] | 0.91823 [0.89745, 0.92347] | 0.94541 [0.93020, 0.95145] | 0.99179 [0.97707, 0.99736] |
| SW2D/258x259 | 1.00000 [1.00000, 1.00000] | 1.00000 [1.00000, 1.00000] | 1.00000 [1.00000, 1.00000] | 1.00000 [1.00000, 1.00000] |
| TPACF/16384 | 1.00000 [1.00000, 1.00000] | 0.33635 [0.33547, 0.33654] | 0.33624 [0.33566, 0.33678] | 0.95423 [0.94831, 0.95458] |
| tigre/head64 | 1.00000 [1.00000, 1.00000] | 1.64429 [1.64074, 1.64766] | 1.64293 [1.63974, 1.64612] | 2.19746 [2.19541, 2.20162] |
| vllm/128K | Unavailable [^bf] | 1.13940 [1.12787, 1.14042] [^darm] | 1.13940 [1.12787, 1.14042] [^darm] | 1.35614 [1.35078, 1.38313] |
| vllm/64K | Unavailable [^bf] | 1.13386 [1.12820, 1.14477] [^darm] | 1.13386 [1.12820, 1.14477] [^darm] | 1.38016 [1.37151, 1.38794] |
| Geometric mean (measured inputs) | 1.03284 (n=14) | 1.04635 (n=16) | 1.08706 (n=16) | 1.26183 (n=16) |

## 2. Anchor execution-time ratios, with paired 95% intervals

| Frozen input | anchor/darm | anchor/darm-best |
|---|---:|---:|
| CED/110 | Unreliable [^aa] | Unreliable [^aa] |
| HLLD/65536 | 0.71761 [0.71595, 0.72000] | 0.71880 [0.71833, 0.72120] |
| LUD8/16384 | 0.98908 [0.98839, 0.99188] | 0.98908 [0.98839, 0.99188] |
| Landau/coherent | 0.79661 [0.78771, 0.80114] | 0.95918 [0.95270, 0.95918] |
| Landau/mixed | 0.79054 [0.78983, 0.79322] | 0.95902 [0.95492, 0.96296] |
| MS32 | 0.99124 [0.98952, 0.99237] | 0.99124 [0.98952, 0.99237] |
| MapAiry/65539 | 0.68966 [0.68493, 0.69072] | 0.84034 [0.84034, 0.84454] |
| NQU64 | 0.97970 [0.97933, 0.97994] | 0.97970 [0.97933, 0.97994] |
| PCM32 | 1.00000 [1.00000, 1.00000] | 0.99982 [0.99967, 1.00001] |
| SRAD-stage2/256 | 1.00862 [0.98305, 1.01724] | 1.00862 [0.98305, 1.01724] |
| SRAD16/256 | 0.97222 [0.96552, 0.97917] | 0.97917 [0.97902, 0.98592] |
| SRAD32/256 | 0.92066 [0.91851, 0.93111] | 0.95396 [0.93790, 0.96760] |
| SW2D/258x259 | 1.00000 [1.00000, 1.00000] | 1.00000 [1.00000, 1.00000] |
| TPACF/16384 | 0.35268 [0.35235, 0.35376] | 0.35294 [0.35224, 0.35395] |
| tigre/head64 | 0.74685 [0.74665, 0.75050] | 0.74624 [0.74620, 0.74980] |
| vllm/128K | 0.83168 [0.82378, 0.84427] [^darm] | 0.83168 [0.82378, 0.84427] [^darm] |
| vllm/64K | 0.82260 [0.82154, 0.82480] [^darm] | 0.82260 [0.82154, 0.82480] [^darm] |

The external comparison uses the fastest measured pristine DARM object. Where 14a did not establish reliable pristine timing, its registered pristine object is identified below.

## 3. Build time in seconds

| Case | base | bf | darm | anchor |
|---|---:|---:|---:|---:|
| CED | 0.088 | 0.105 | 0.108 | 0.550 |
| HLLD | 0.124 | 0.153 | 0.163 | 1.493 |
| LUD8 | 0.150 | 0.218 | 0.225 | 2.188 |
| Landau | 0.178 | 0.206 | 0.511 | 33.536 |
| MS32 | 0.122 | 0.115 | 0.115 | 0.476 |
| MapAiry | 0.230 | 0.265 | 0.554 | 50.445 |
| NQU64 | 0.081 | 0.100 | 0.115 | 1.243 |
| PCM32 | 0.190 | 0.206 | 0.249 | 5.755 |
| SRAD-stage2 | 0.116 | 0.161 | 0.147 | 0.465 |
| SRAD16 | 0.106 | 0.149 | 0.140 | 1.131 |
| SRAD32 | 0.645 | 0.131 | 0.138 | 1.057 |
| SW2D | 0.193 | 0.221 | 0.218 | 2.096 |
| TPACF | 0.198 | 0.199 | 0.769 | 33.275 |
| tigre | 0.153 | 0.185 | 0.180 | 1.693 |
| vllm | 0.400 | Unavailable [^bf] | 1.433 | 211.346 |

DARM-best is an archived object and has no artifact build time.

## Inputs and receipts

Elapsed work for completed inputs: 355.87 s. 17/17 inputs completed. Longest cases: LUD8 140.84 s, vllm 75.06 s, PCM32 29.95 s.

Missing: none.

<details><summary>CED/110 (unreliable)</summary>

- Runner SHA-256 7df0793a0a5defb665f1e3b1c482850a4701467cad6993cde625870c451a199a
- darm 745f9bc3a1e522c678d5638bb31872b677244b66193f9918ff5247c8b74bb8dd
- bf fa33576a65fe7848cc5de57b15b0a778ba90dde6e11d674e9ee322e49018592d
- darm-best 745f9bc3a1e522c678d5638bb31872b677244b66193f9918ff5247c8b74bb8dd
- base fa33576a65fe7848cc5de57b15b0a778ba90dde6e11d674e9ee322e49018592d
- anchor c9f5da8a8caab4cc492af650f8663fae867cb65356aaa16a8c49ce48223dae38
- A/A, 11 samples/window: 1.01237 [0.97463, 1.02874], spread 5.552%

GPU: AMD Radeon VII (gfx906:sramecc+:xnack-)
HIP driver: 50731921
HIP runtime: 50731921
ROCm: 6.3.3-74
Linux: Linux 6.12.116+deb13-amd64
Driver module: amdgpu in the running Linux kernel
KBS SHA-256: fdf69e55b07f467c5e48afbee633d3c438c99bee03c503a35b038a0160d51fc8

</details>

<details><summary>HLLD/65536 (measured)</summary>

- Runner SHA-256 f7fafbfff11968c6cdc721a1a36a469fe08ea5f52b16b521203c0d24b9ca9406
- darm f90ba3e120468be85068c4c14cf71ef3cb84f64983c5de910f065399b459f237
- bf b5166eae0e745352fb6fd0241b7772b019e58c81d778918fd7c9175727393e42
- darm-best e04262e0e27c5cb75984d84de7307ea9b6be957bab729f7ecfd6b85b60f0b244
- base b5166eae0e745352fb6fd0241b7772b019e58c81d778918fd7c9175727393e42
- anchor 3aa2cad420017f246aa3f3f148eb23baa0d834dd92611c3bf68196393ceaf9a3
- A/A, 11 samples/window: 1.00000 [0.99497, 1.00252], spread 0.758%

</details>

<details><summary>LUD8/16384 (measured)</summary>

- Runner SHA-256 b2607344f26879df28b58bcdb0e35c2d2e2e9d810cd0af18f650affff51d74bf
- darm e6a9cba0e0fa4296abfc21a6d0071826115e5016be78d66cc8f9a738973fb939
- bf e6a9cba0e0fa4296abfc21a6d0071826115e5016be78d66cc8f9a738973fb939
- darm-best e6a9cba0e0fa4296abfc21a6d0071826115e5016be78d66cc8f9a738973fb939
- base 31832b93fb5c38fdb65702a1a2f57692cb88d17c0757ee9ecb49b438e1d7766a
- anchor 15266ece5e8344423077a145cbf41eb24635ee6591884241f1e26e339d77edd8
- A/A, 11 samples/window: 0.99690 [0.99288, 1.01068], spread 1.793%

</details>

<details><summary>Landau/coherent (measured)</summary>

- Runner SHA-256 f7fafbfff11968c6cdc721a1a36a469fe08ea5f52b16b521203c0d24b9ca9406
- darm 03ba2158d28e8f6e993e16489bab683cfbd0244cab753577c70f3cfd87533382
- bf 357a67183749741fe7f469061f22bc0afd7395881d32f916c184bc70f5d71a9c
- darm-best 2e61ab46836b99724e8c5019f91f2eed61a3d42a3ef81ab808270412c0804b3a
- base 357a67183749741fe7f469061f22bc0afd7395881d32f916c184bc70f5d71a9c
- anchor a74f636a78aa5c595ba9ea2675494d942064fe7f5cd499d7a7323c501cb1019f
- A/A, 11 samples/window: 1.00752 [1.00000, 1.00752], spread 0.752%

</details>

<details><summary>Landau/mixed (measured)</summary>

- Runner SHA-256 f7fafbfff11968c6cdc721a1a36a469fe08ea5f52b16b521203c0d24b9ca9406
- darm 03ba2158d28e8f6e993e16489bab683cfbd0244cab753577c70f3cfd87533382
- bf 357a67183749741fe7f469061f22bc0afd7395881d32f916c184bc70f5d71a9c
- darm-best 08fbf4e7c7df1b5a4da6abcbdd61415c0d394c70c162819d18c7f0fa62edd17a
- base 357a67183749741fe7f469061f22bc0afd7395881d32f916c184bc70f5d71a9c
- anchor a74f636a78aa5c595ba9ea2675494d942064fe7f5cd499d7a7323c501cb1019f
- A/A, 11 samples/window: 0.99814 [0.99814, 1.00187], spread 0.373%

</details>

<details><summary>MS32 (measured)</summary>

- Runner SHA-256 363f27c27301539b39e5a927e84d841001760cb629861c26dba929a1c8f8651f
- darm 611f3f734d147f74f10221b81d290ad215a04ade9cc2b4b32370abfc76974621
- bf 611f3f734d147f74f10221b81d290ad215a04ade9cc2b4b32370abfc76974621
- darm-best 611f3f734d147f74f10221b81d290ad215a04ade9cc2b4b32370abfc76974621
- base f9fe5210e10f2b35263161a13bc2e399f858de7fefd054443f14b8ca25dbef8f
- anchor 1be889a67dbd43dd8d63e0b6d5cee7fe26584fa22bb23da67878cd30b6722054
- A/A, 1 samples/window: 0.99978 [0.99936, 1.00046], spread 0.111%

</details>

<details><summary>MapAiry/65539 (measured)</summary>

- Runner SHA-256 f7fafbfff11968c6cdc721a1a36a469fe08ea5f52b16b521203c0d24b9ca9406
- darm 2f7423e6051d9ba32d0ecaa527f7ec1871f96e97b1f18e06fe59a666a2cbe2d5
- bf b1f1acaa568b95ccbd3747793c65dca58a8d3feb56e64a56f47b93c21ad93838
- darm-best f2d6bd4da539daf1aaec979ffd88b798ade18c0704e3c7b2dab5373735f1ca46
- base be310a890bc62b7a5a37621540725627e5ddcae23edf3067835842d2976b13c0
- anchor 030b9488c8bb5b7cf98479f218adaa85aeaec30e404f7efd4fc2ba4ad0167afc
- A/A, 11 samples/window: 1.00186 [1.00000, 1.00372], spread 0.372%

</details>

<details><summary>NQU64 (measured)</summary>

- Runner SHA-256 59490d0199dace933e7314c7b0bc6d17d747ed3139f8f10908867b84050a403b
- darm 801ca7e3996f2cc93d34ee8f3d560448697a661503bafd7745eb65670bc44476
- bf 67425024b9efbed16bf390fa4493eead6a807acbbd6cb08567b09cbd20057fd2
- darm-best 801ca7e3996f2cc93d34ee8f3d560448697a661503bafd7745eb65670bc44476
- base 67425024b9efbed16bf390fa4493eead6a807acbbd6cb08567b09cbd20057fd2
- anchor 83bec1d3bb5b164770921cd52763d70670efa5ea12ab5f04082391abbf74e97b
- A/A, 11 samples/window: 1.00076 [0.98927, 1.00202], spread 1.289%

</details>

<details><summary>PCM32 (measured)</summary>

- Runner SHA-256 363f27c27301539b39e5a927e84d841001760cb629861c26dba929a1c8f8651f
- darm 5ba36c22102cb607d1db54684102c836b639e0acbd7ee03b76a109d5447c5816
- bf 455137749f41d6444a2cd7ed7654dbcfa6d3613d5d1f20561e4eb6244e0ca9f6
- darm-best 4705c6f829cebfa98e5d312ca47cc1d0f1022cf07a7b097e4b9d39d813111832
- base e08cfd73b8aeddd2ea9069e4a240a5bf299e27fa4ec3c428985a9e2733d60f8a
- anchor 5ba36c22102cb607d1db54684102c836b639e0acbd7ee03b76a109d5447c5816
- A/A, 1 samples/window: 1.00001 [0.99985, 1.00057], spread 0.072%

</details>

<details><summary>SRAD-stage2/256 (measured)</summary>

- Runner SHA-256 f7fafbfff11968c6cdc721a1a36a469fe08ea5f52b16b521203c0d24b9ca9406
- darm 3461ef1da730e086489022091e227e6bc400e4f269aa4838875ac1a9975c11f0
- bf 3d0fb7c17f645a1da20cea9281c8ed0afad0f470f52902fd60f184abc733f69a
- darm-best 3461ef1da730e086489022091e227e6bc400e4f269aa4838875ac1a9975c11f0
- base 97a7470931dc4fae9d54b95ce5f0c8e7b3b7f66a22eb410c01563e9634d660e1
- anchor 37ed260bde0e42fc816853f9ea712685dbda735b563bbddd3a5026044c7befc5
- A/A, 11 samples/window: 0.99130 [0.97436, 0.99138], spread 1.747%

</details>

<details><summary>SRAD16/256 (measured)</summary>

- Runner SHA-256 f7fafbfff11968c6cdc721a1a36a469fe08ea5f52b16b521203c0d24b9ca9406
- darm 3461ef1da730e086489022091e227e6bc400e4f269aa4838875ac1a9975c11f0
- bf 3d0fb7c17f645a1da20cea9281c8ed0afad0f470f52902fd60f184abc733f69a
- darm-best 23c4ad4ea7b8346aa96999b24f2e11d464ae963c2e2938184620a89b86f75804
- base 97a7470931dc4fae9d54b95ce5f0c8e7b3b7f66a22eb410c01563e9634d660e1
- anchor 89191ed8c58d26ef8af05dee8c5ca06a1a17c026204fec6ffdecc9e0d948d2db
- A/A, 11 samples/window: 1.00000 [0.99291, 1.00000], spread 0.714%

</details>

<details><summary>SRAD32/256 (measured)</summary>

- Runner SHA-256 396cf4e58ba17ba3c9725888bc78ffdd1a418909341cb3b1eee29d7297be6f21
- darm 341c9d0b59caba42dc50d188980235e1cba35df6c46ee664b0027f966e69d812
- bf 45594494f2182b061c16e1c2a8b7fb5d40694be3824910e2d3737843f8a95477
- darm-best 995e641eb866fc00f1ac8a034fa14c3e9bf907f3e935d234d540d25e1c127a66
- base 080421a67869991ffac44f1aa9f4084e8f94fdbb77b4da32ec60c31792ab2a91
- anchor be6cdbe3591098a69885adfabfa421f6a79c94cae37cece59f0f89648a74271a
- A/A, 11 samples/window: 0.99839 [0.99607, 1.00907], spread 1.305%

</details>

<details><summary>SW2D/258x259 (measured)</summary>

- Runner SHA-256 f7fafbfff11968c6cdc721a1a36a469fe08ea5f52b16b521203c0d24b9ca9406
- darm cd0e00d276836e765fe1dba400bfab62312a79121226fcc8ef4e4d7fa95b3518
- bf cd0e00d276836e765fe1dba400bfab62312a79121226fcc8ef4e4d7fa95b3518
- darm-best cd0e00d276836e765fe1dba400bfab62312a79121226fcc8ef4e4d7fa95b3518
- base cd0e00d276836e765fe1dba400bfab62312a79121226fcc8ef4e4d7fa95b3518
- anchor cd0e00d276836e765fe1dba400bfab62312a79121226fcc8ef4e4d7fa95b3518
- A/A, 11 samples/window: 0.99878 [0.99754, 1.00370], spread 0.618%

</details>

<details><summary>TPACF/16384 (measured)</summary>

- Runner SHA-256 f9db09af3e35777a783cf3005e5ea27b824201ce96abca34579d435d7215c976
- darm e97f299528debdef76e7f9f1787180b7bcbf9d2e43732fc83f1016d02d702603
- bf 17f78e587734ac2f0747dfe7c2a3a1eea2e99da429577fab7b3caa084794af99
- darm-best 6ec4a8def01e72dc5e2ffc62b175995fa1ea0896aee98fe3fd0e00020da775c3
- base 17f78e587734ac2f0747dfe7c2a3a1eea2e99da429577fab7b3caa084794af99
- anchor 3853cc72321f0c31102fbfe7b9b80a3258275103448e1437e0db0837dce6d65f
- A/A, 11 samples/window: 0.99946 [0.99921, 0.99980], spread 0.059%

</details>

<details><summary>tigre/head64 (measured)</summary>

- Runner SHA-256 b59bdd8a41f08a1f536460833140c6d3eaacf4460e2fa46bb9087d60fd4d799b
- darm d7fc1f4fb070c013ea1247d9ad0a0b759ea4c9ecfc72477667948f399ec7c1e0
- bf 2ace230a3a86141775179de92a0fae8277218b01ddbff1162d10dd2f326933b2
- darm-best 2c18de766742fa812fc3076ebf26ef0cdea7ac52357d4f96ceff61567b6ecbdb
- base 2ace230a3a86141775179de92a0fae8277218b01ddbff1162d10dd2f326933b2
- anchor ffa327ddc018b3b910d11d56c9d9cca022509c39d5e099363465a44a574bc721
- A/A, 11 samples/window: 1.00165 [0.99663, 1.00232], spread 0.570%

</details>

<details><summary>vllm/128K (measured)</summary>

- Runner SHA-256 f7fafbfff11968c6cdc721a1a36a469fe08ea5f52b16b521203c0d24b9ca9406
- darm 1f435ef36fb7e3f4076fa17a56c74d2a35023043c693c9168a2931e8873fba1a
- darm-best 1f435ef36fb7e3f4076fa17a56c74d2a35023043c693c9168a2931e8873fba1a
- base 6b293afa14832b73ab0738a7231ddf842f3e06d2c9aac372e019247726ff5324
- anchor 9aa97bca3906c0d31452e4594b5fc17c535bce25ba5e7e4df92e5ff6841c5fa6
- A/A, 1 samples/window: 0.99181 [0.98877, 1.00566], spread 1.708%

</details>

<details><summary>vllm/64K (measured)</summary>

- Runner SHA-256 f7fafbfff11968c6cdc721a1a36a469fe08ea5f52b16b521203c0d24b9ca9406
- darm 1f435ef36fb7e3f4076fa17a56c74d2a35023043c693c9168a2931e8873fba1a
- darm-best 1f435ef36fb7e3f4076fa17a56c74d2a35023043c693c9168a2931e8873fba1a
- base 6b293afa14832b73ab0738a7231ddf842f3e06d2c9aac372e019247726ff5324
- anchor 9aa97bca3906c0d31452e4594b5fc17c535bce25ba5e7e4df92e5ff6841c5fa6
- A/A, 1 samples/window: 0.99907 [0.99243, 1.00877], spread 1.646%

</details>

[^bf]: Upstream branch fusion on vLLM emits IR rejected by the verifier in the original opt, pristine plugin, and patched plugin.
[^aa]: The input exceeded its registered A/A tolerance. Its results are excluded from the geometric mean.
[^darm]: vLLM darm uses -disable-region-replication. The original exceeded 360 seconds.

SRAD-stage2/1024 is included in compilation verification only. CED/110 and SW2D/258x259 use the registered pristine object; 14a did not establish reliable fastest-object timings for these inputs.
