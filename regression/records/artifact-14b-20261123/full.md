# KBS gfx906 performance results

**完整协议**

## 1. Speedup relative to base, with paired 95% intervals

| Frozen input | base/bf | base/darm | base/darm-best | base/anchor |
|---|---:|---:|---:|---:|
| CED/110 | Unreliable [^aa] | Unreliable [^aa] | Unreliable [^aa] | Unreliable [^aa] |
| HLLD/65536 | 1.00000 [1.00000, 1.00000] | 0.66164 [0.66107, 0.66330] | 0.65970 [0.65886, 0.66191] | 0.91445 [0.91312, 0.91639] |
| LUD8/16384 | 1.14474 [1.14308, 1.14667] | 1.14474 [1.14308, 1.14667] | 1.14474 [1.14308, 1.14667] | 1.15678 [1.15379, 1.15849] |
| Landau/coherent | 1.00000 [1.00000, 1.00000] | 0.73731 [0.73653, 0.74174] | 0.88530 [0.87902, 0.89130] | 0.93893 [0.93563, 0.93916] |
| Landau/mixed | 1.00000 [1.00000, 1.00000] | 1.82818 [1.82818, 1.82961] | 2.21667 [2.21667, 2.22176] | 2.32314 [2.31878, 2.32314] |
| MS32 | 1.11385 [1.10888, 1.11576] | 1.11385 [1.10888, 1.11576] | 1.11385 [1.10888, 1.11576] | 1.11879 [1.11425, 1.12401] |
| MapAiry/65539 | 1.00000 [0.99906, 1.00000] | 1.83505 [1.83162, 1.83505] | 2.23431 [2.23220, 2.23900] | 2.65672 [2.65421, 2.65672] |
| NQU64 | 1.00000 [1.00000, 1.00000] | 1.16224 [1.16120, 1.16271] | 1.16224 [1.16120, 1.16271] | 1.18701 [1.18653, 1.18722] |
| PCM32 | 1.23721 [1.23715, 1.23754] | 1.32788 [1.32780, 1.32798] | 1.32795 [1.32769, 1.32804] | 1.32788 [1.32780, 1.32798] |
| SRAD-stage2/256 | 1.00000 [0.99569, 1.00000] | 1.00000 [0.99138, 1.00000] | 1.00000 [0.99138, 1.00000] | 1.00000 [0.99138, 1.00435] |
| SRAD16/256 | 1.00000 [1.00000, 1.00791] | 0.96958 [0.96241, 0.97692] | 0.97710 [0.97674, 0.98450] | 1.00000 [0.99219, 1.00397] |
| SRAD32/256 | 0.99560 [0.99278, 0.99978] | 0.91928 [0.91446, 0.92179] | 0.94938 [0.94514, 0.95310] | 0.99669 [0.99245, 1.00211] |
| SW2D/258x259 | 1.00000 [1.00000, 1.00000] | 1.00000 [1.00000, 1.00000] | 1.00000 [1.00000, 1.00000] | 1.00000 [1.00000, 1.00000] |
| TPACF/16384 | 1.00000 [1.00000, 1.00000] | 0.33583 [0.33405, 0.33628] | 0.33585 [0.33431, 0.33619] | 0.95242 [0.95205, 0.95287] |
| tigre/head64 | 1.00000 [1.00000, 1.00000] | 1.64213 [1.63585, 1.67194] | 1.64152 [1.63644, 1.64681] | 2.19229 [2.17601, 2.19808] |
| vllm/128K | Unavailable [^bf] | 1.13311 [1.12749, 1.13568] [^darm] | 1.13311 [1.12749, 1.13568] [^darm] | 1.36671 [1.35731, 1.37179] |
| vllm/64K | Unavailable [^bf] | 1.13200 [1.12113, 1.13737] [^darm] | 1.13200 [1.12113, 1.13737] [^darm] | 1.35253 [1.34627, 1.36508] |
| Geometric mean (measured inputs) | 1.03277 (n=14) | 1.04526 (n=16) | 1.08583 (n=16) | 1.26236 (n=16) |

## 2. Anchor execution-time ratios, with paired 95% intervals

| Frozen input | anchor/darm | anchor/darm-best |
|---|---:|---:|
| CED/110 | Unreliable [^aa] | Unreliable [^aa] |
| HLLD/65536 | 0.72362 [0.72291, 0.72519] | 0.72120 [0.72049, 0.72279] |
| LUD8/16384 | 0.99019 [0.98974, 0.99124] | 0.99019 [0.98974, 0.99124] |
| Landau/coherent | 0.78807 [0.78443, 0.79042] | 0.94265 [0.93910, 0.94627] |
| Landau/mixed | 0.78694 [0.78694, 0.78966] | 0.95417 [0.95417, 0.95816] |
| MS32 | 0.99581 [0.99045, 0.99734] | 0.99581 [0.99045, 0.99734] |
| MapAiry/65539 | 0.69072 [0.69071, 0.69072] | 0.84100 [0.84100, 0.84452] |
| NQU64 | 0.97934 [0.97861, 0.97969] | 0.97934 [0.97861, 0.97969] |
| PCM32 | 1.00000 [1.00000, 1.00000] | 1.00002 [0.99994, 1.00010] |
| SRAD-stage2/256 | 0.99573 [0.99138, 1.00435] | 0.99573 [0.99138, 1.00435] |
| SRAD16/256 | 0.96958 [0.96582, 0.97719] | 0.97710 [0.97674, 0.98467] |
| SRAD32/256 | 0.92018 [0.91861, 0.92428] | 0.95183 [0.94988, 0.95496] |
| SW2D/258x259 | 1.00000 [1.00000, 1.00000] | 1.00000 [1.00000, 1.00000] |
| TPACF/16384 | 0.35286 [0.35111, 0.35300] | 0.35277 [0.35112, 0.35299] |
| tigre/head64 | 0.74954 [0.74713, 0.76154] | 0.74971 [0.74695, 0.75771] |
| vllm/128K | 0.82794 [0.82696, 0.83080] [^darm] | 0.82794 [0.82696, 0.83080] [^darm] |
| vllm/64K | 0.83564 [0.82955, 0.83900] [^darm] | 0.83564 [0.82955, 0.83900] [^darm] |

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

Elapsed work for completed inputs: 2435.83 s. 17/17 inputs completed. Longest cases: LUD8 1492.49 s, vllm 240.72 s, TPACF 224.85 s.

Missing: none.

<details><summary>CED/110 (unreliable)</summary>

- Runner SHA-256 7df0793a0a5defb665f1e3b1c482850a4701467cad6993cde625870c451a199a
- darm 745f9bc3a1e522c678d5638bb31872b677244b66193f9918ff5247c8b74bb8dd
- bf fa33576a65fe7848cc5de57b15b0a778ba90dde6e11d674e9ee322e49018592d
- darm-best 745f9bc3a1e522c678d5638bb31872b677244b66193f9918ff5247c8b74bb8dd
- base fa33576a65fe7848cc5de57b15b0a778ba90dde6e11d674e9ee322e49018592d
- anchor c9f5da8a8caab4cc492af650f8663fae867cb65356aaa16a8c49ce48223dae38
- A/A, 31 samples/window: 1.00045 [0.98690, 1.01840], spread 7.393%
- A/A, 61 samples/window: 1.00994 [1.00099, 1.01477], spread 3.605%

GPU: AMD Radeon VII (gfx906:sramecc+:xnack-)
HIP driver: 50731921
HIP runtime: 50731921
ROCm: 6.3.3-74
Linux: Linux 6.12.116+deb13-amd64
Driver module: amdgpu in the running Linux kernel
KBS SHA-256: 8190c4eae9e173705a77f6e8de3fe15503c4e49e760db8f0fb9e6fc54bd1333c

</details>

<details><summary>HLLD/65536 (measured)</summary>

- Runner SHA-256 c94a76cd2e6665685e58773efad25d832dec5e42558f36f8460ed7755698a691
- darm f90ba3e120468be85068c4c14cf71ef3cb84f64983c5de910f065399b459f237
- bf b5166eae0e745352fb6fd0241b7772b019e58c81d778918fd7c9175727393e42
- darm-best e04262e0e27c5cb75984d84de7307ea9b6be957bab729f7ecfd6b85b60f0b244
- base b5166eae0e745352fb6fd0241b7772b019e58c81d778918fd7c9175727393e42
- anchor 3aa2cad420017f246aa3f3f148eb23baa0d834dd92611c3bf68196393ceaf9a3
- A/A, 1 samples/window: 1.00380 [0.99375, 1.01144], spread 23.076%
- A/A, 1 samples/window: 0.98870 [0.98615, 0.99494], spread 23.142%
- A/A, 31 samples/window: 0.99493 [0.98993, 0.99495], spread 1.013%

GPU: AMD Radeon VII (gfx906:sramecc+:xnack-)
HIP driver: 50731921
HIP runtime: 50731921
ROCm: 6.3.3-74
Linux: Linux 6.12.116+deb13-amd64
Driver module: amdgpu in the running Linux kernel
KBS SHA-256: 177fd0a637249b406a0fc3db5bb950627dae39896915995cebd048b2abbb27f8

</details>

<details><summary>LUD8/16384 (measured)</summary>

- Runner SHA-256 b2607344f26879df28b58bcdb0e35c2d2e2e9d810cd0af18f650affff51d74bf
- darm e6a9cba0e0fa4296abfc21a6d0071826115e5016be78d66cc8f9a738973fb939
- bf e6a9cba0e0fa4296abfc21a6d0071826115e5016be78d66cc8f9a738973fb939
- darm-best e6a9cba0e0fa4296abfc21a6d0071826115e5016be78d66cc8f9a738973fb939
- base 31832b93fb5c38fdb65702a1a2f57692cb88d17c0757ee9ecb49b438e1d7766a
- anchor 15266ece5e8344423077a145cbf41eb24635ee6591884241f1e26e339d77edd8
- A/A, 31 samples/window: 0.99812 [0.99714, 0.99947], spread 0.571%

GPU: AMD Radeon VII (gfx906:sramecc+:xnack-)
HIP driver: 50731921
HIP runtime: 50731921
ROCm: 6.3.3-74
Linux: Linux 6.12.116+deb13-amd64
Driver module: amdgpu in the running Linux kernel
KBS SHA-256: fdf69e55b07f467c5e48afbee633d3c438c99bee03c503a35b038a0160d51fc8

</details>

<details><summary>Landau/coherent (measured)</summary>

- Runner SHA-256 f7fafbfff11968c6cdc721a1a36a469fe08ea5f52b16b521203c0d24b9ca9406
- darm 03ba2158d28e8f6e993e16489bab683cfbd0244cab753577c70f3cfd87533382
- bf 357a67183749741fe7f469061f22bc0afd7395881d32f916c184bc70f5d71a9c
- darm-best 2e61ab46836b99724e8c5019f91f2eed61a3d42a3ef81ab808270412c0804b3a
- base 357a67183749741fe7f469061f22bc0afd7395881d32f916c184bc70f5d71a9c
- anchor a74f636a78aa5c595ba9ea2675494d942064fe7f5cd499d7a7323c501cb1019f
- A/A, 1 samples/window: 1.00761 [1.00000, 1.02264], spread 48.137%
- A/A, 1 samples/window: 1.00000 [0.98180, 1.01926], spread 38.453%
- A/A, 31 samples/window: 1.00000 [0.99262, 1.00000], spread 1.504%

</details>

<details><summary>Landau/mixed (measured)</summary>

- Runner SHA-256 f7fafbfff11968c6cdc721a1a36a469fe08ea5f52b16b521203c0d24b9ca9406
- darm 03ba2158d28e8f6e993e16489bab683cfbd0244cab753577c70f3cfd87533382
- bf 357a67183749741fe7f469061f22bc0afd7395881d32f916c184bc70f5d71a9c
- darm-best 08fbf4e7c7df1b5a4da6abcbdd61415c0d394c70c162819d18c7f0fa62edd17a
- base 357a67183749741fe7f469061f22bc0afd7395881d32f916c184bc70f5d71a9c
- anchor a74f636a78aa5c595ba9ea2675494d942064fe7f5cd499d7a7323c501cb1019f
- A/A, 1 samples/window: 0.99906 [0.99625, 1.00001], spread 12.489%
- A/A, 1 samples/window: 1.00189 [0.99718, 1.00566], spread 11.119%
- A/A, 31 samples/window: 1.00000 [1.00000, 1.00000], spread 0.377%

</details>

<details><summary>MS32 (measured)</summary>

- Runner SHA-256 363f27c27301539b39e5a927e84d841001760cb629861c26dba929a1c8f8651f
- darm 611f3f734d147f74f10221b81d290ad215a04ade9cc2b4b32370abfc76974621
- bf 611f3f734d147f74f10221b81d290ad215a04ade9cc2b4b32370abfc76974621
- darm-best 611f3f734d147f74f10221b81d290ad215a04ade9cc2b4b32370abfc76974621
- base f9fe5210e10f2b35263161a13bc2e399f858de7fefd054443f14b8ca25dbef8f
- anchor 1be889a67dbd43dd8d63e0b6d5cee7fe26584fa22bb23da67878cd30b6722054
- A/A, 1 samples/window: 0.99932 [0.99571, 1.00409], spread 1.206%

</details>

<details><summary>MapAiry/65539 (measured)</summary>

- Runner SHA-256 c94a76cd2e6665685e58773efad25d832dec5e42558f36f8460ed7755698a691
- darm 2f7423e6051d9ba32d0ecaa527f7ec1871f96e97b1f18e06fe59a666a2cbe2d5
- bf b1f1acaa568b95ccbd3747793c65dca58a8d3feb56e64a56f47b93c21ad93838
- darm-best f2d6bd4da539daf1aaec979ffd88b798ade18c0704e3c7b2dab5373735f1ca46
- base be310a890bc62b7a5a37621540725627e5ddcae23edf3067835842d2976b13c0
- anchor 030b9488c8bb5b7cf98479f218adaa85aeaec30e404f7efd4fc2ba4ad0167afc
- A/A, 300 samples/window: 1.00000 [1.00000, 1.00000], spread 0.369%

</details>

<details><summary>NQU64 (measured)</summary>

- Runner SHA-256 d7fce2305ee05ba7ac6ffb82f9977e5fdf1061cd3d0d7717e8283d8e92d948e2
- darm 801ca7e3996f2cc93d34ee8f3d560448697a661503bafd7745eb65670bc44476
- bf 67425024b9efbed16bf390fa4493eead6a807acbbd6cb08567b09cbd20057fd2
- darm-best 801ca7e3996f2cc93d34ee8f3d560448697a661503bafd7745eb65670bc44476
- base 67425024b9efbed16bf390fa4493eead6a807acbbd6cb08567b09cbd20057fd2
- anchor 83bec1d3bb5b164770921cd52763d70670efa5ea12ab5f04082391abbf74e97b
- A/A, 1 samples/window: 1.00123 [0.99579, 1.01316], spread 4.963%
- A/A, 1 samples/window: 1.00174 [0.98412, 1.00478], spread 4.376%
- A/A, 31 samples/window: 1.00036 [0.99946, 1.00091], spread 0.337%

</details>

<details><summary>PCM32 (measured)</summary>

- Runner SHA-256 363f27c27301539b39e5a927e84d841001760cb629861c26dba929a1c8f8651f
- darm 5ba36c22102cb607d1db54684102c836b639e0acbd7ee03b76a109d5447c5816
- bf 455137749f41d6444a2cd7ed7654dbcfa6d3613d5d1f20561e4eb6244e0ca9f6
- darm-best 4705c6f829cebfa98e5d312ca47cc1d0f1022cf07a7b097e4b9d39d813111832
- base e08cfd73b8aeddd2ea9069e4a240a5bf299e27fa4ec3c428985a9e2733d60f8a
- anchor 5ba36c22102cb607d1db54684102c836b639e0acbd7ee03b76a109d5447c5816
- A/A, 1 samples/window: 1.00006 [0.99992, 1.00020], spread 0.086%

</details>

<details><summary>SRAD-stage2/256 (measured)</summary>

- Runner SHA-256 f7fafbfff11968c6cdc721a1a36a469fe08ea5f52b16b521203c0d24b9ca9406
- darm 3461ef1da730e086489022091e227e6bc400e4f269aa4838875ac1a9975c11f0
- bf 3d0fb7c17f645a1da20cea9281c8ed0afad0f470f52902fd60f184abc733f69a
- darm-best 3461ef1da730e086489022091e227e6bc400e4f269aa4838875ac1a9975c11f0
- base 97a7470931dc4fae9d54b95ce5f0c8e7b3b7f66a22eb410c01563e9634d660e1
- anchor 37ed260bde0e42fc816853f9ea712685dbda735b563bbddd3a5026044c7befc5
- A/A, 1 samples/window: 0.99561 [0.96596, 1.01268], spread 50.710%
- A/A, 1 samples/window: 0.98718 [0.97425, 1.00901], spread 51.133%
- A/A, 31 samples/window: 1.00000 [0.99138, 1.00003], spread 2.639%

</details>

<details><summary>SRAD16/256 (measured)</summary>

- Runner SHA-256 f7fafbfff11968c6cdc721a1a36a469fe08ea5f52b16b521203c0d24b9ca9406
- darm 3461ef1da730e086489022091e227e6bc400e4f269aa4838875ac1a9975c11f0
- bf 3d0fb7c17f645a1da20cea9281c8ed0afad0f470f52902fd60f184abc733f69a
- darm-best 23c4ad4ea7b8346aa96999b24f2e11d464ae963c2e2938184620a89b86f75804
- base 97a7470931dc4fae9d54b95ce5f0c8e7b3b7f66a22eb410c01563e9634d660e1
- anchor 89191ed8c58d26ef8af05dee8c5ca06a1a17c026204fec6ffdecc9e0d948d2db
- A/A, 1 samples/window: 0.99621 [0.98065, 1.00781], spread 45.020%
- A/A, 1 samples/window: 1.00800 [0.99603, 1.01991], spread 46.774%
- A/A, 31 samples/window: 1.00781 [1.00000, 1.00787], spread 2.375%

</details>

<details><summary>SRAD32/256 (measured)</summary>

- Runner SHA-256 396cf4e58ba17ba3c9725888bc78ffdd1a418909341cb3b1eee29d7297be6f21
- darm 341c9d0b59caba42dc50d188980235e1cba35df6c46ee664b0027f966e69d812
- bf 45594494f2182b061c16e1c2a8b7fb5d40694be3824910e2d3737843f8a95477
- darm-best 995e641eb866fc00f1ac8a034fa14c3e9bf907f3e935d234d540d25e1c127a66
- base 080421a67869991ffac44f1aa9f4084e8f94fdbb77b4da32ec60c31792ab2a91
- anchor be6cdbe3591098a69885adfabfa421f6a79c94cae37cece59f0f89648a74271a
- A/A, 31 samples/window: 1.00150 [1.00000, 1.00304], spread 0.955%

</details>

<details><summary>SW2D/258x259 (measured)</summary>

- Runner SHA-256 f7fafbfff11968c6cdc721a1a36a469fe08ea5f52b16b521203c0d24b9ca9406
- darm cd0e00d276836e765fe1dba400bfab62312a79121226fcc8ef4e4d7fa95b3518
- bf cd0e00d276836e765fe1dba400bfab62312a79121226fcc8ef4e4d7fa95b3518
- darm-best cd0e00d276836e765fe1dba400bfab62312a79121226fcc8ef4e4d7fa95b3518
- base cd0e00d276836e765fe1dba400bfab62312a79121226fcc8ef4e4d7fa95b3518
- anchor cd0e00d276836e765fe1dba400bfab62312a79121226fcc8ef4e4d7fa95b3518
- A/A, 1 samples/window: 0.99938 [0.99448, 1.00744], spread 12.778%
- A/A, 1 samples/window: 1.00000 [0.99632, 1.00495], spread 10.355%
- A/A, 31 samples/window: 1.00000 [0.99755, 1.00062], spread 0.494%

</details>

<details><summary>TPACF/16384 (measured)</summary>

- Runner SHA-256 f9db09af3e35777a783cf3005e5ea27b824201ce96abca34579d435d7215c976
- darm e97f299528debdef76e7f9f1787180b7bcbf9d2e43732fc83f1016d02d702603
- bf 17f78e587734ac2f0747dfe7c2a3a1eea2e99da429577fab7b3caa084794af99
- darm-best 6ec4a8def01e72dc5e2ffc62b175995fa1ea0896aee98fe3fd0e00020da775c3
- base 17f78e587734ac2f0747dfe7c2a3a1eea2e99da429577fab7b3caa084794af99
- anchor 3853cc72321f0c31102fbfe7b9b80a3258275103448e1437e0db0837dce6d65f
- A/A, 1 samples/window: 0.99973 [0.99549, 1.00327], spread 14.569%
- A/A, 1 samples/window: 1.00039 [0.99413, 1.00511], spread 14.665%
- A/A, 31 samples/window: 1.00012 [0.99939, 1.00133], spread 1.065%

</details>

<details><summary>tigre/head64 (measured)</summary>

- Runner SHA-256 50b27076a880a00750f5101b447d79b627257230f36f430e2748351275c63e75
- darm d7fc1f4fb070c013ea1247d9ad0a0b759ea4c9ecfc72477667948f399ec7c1e0
- bf 2ace230a3a86141775179de92a0fae8277218b01ddbff1162d10dd2f326933b2
- darm-best 2c18de766742fa812fc3076ebf26ef0cdea7ac52357d4f96ceff61567b6ecbdb
- base 2ace230a3a86141775179de92a0fae8277218b01ddbff1162d10dd2f326933b2
- anchor ffa327ddc018b3b910d11d56c9d9cca022509c39d5e099363465a44a574bc721
- A/A, 15 samples/window: 1.00023 [0.99945, 1.00268], spread 0.857%

</details>

<details><summary>vllm/128K (measured)</summary>

- Runner SHA-256 c94a76cd2e6665685e58773efad25d832dec5e42558f36f8460ed7755698a691
- darm 1f435ef36fb7e3f4076fa17a56c74d2a35023043c693c9168a2931e8873fba1a
- darm-best 1f435ef36fb7e3f4076fa17a56c74d2a35023043c693c9168a2931e8873fba1a
- base 6b293afa14832b73ab0738a7231ddf842f3e06d2c9aac372e019247726ff5324
- anchor 9aa97bca3906c0d31452e4594b5fc17c535bce25ba5e7e4df92e5ff6841c5fa6
- A/A, 1 samples/window: 0.99961 [0.99731, 1.00048], spread 1.163%

</details>

<details><summary>vllm/64K (measured)</summary>

- Runner SHA-256 c94a76cd2e6665685e58773efad25d832dec5e42558f36f8460ed7755698a691
- darm 1f435ef36fb7e3f4076fa17a56c74d2a35023043c693c9168a2931e8873fba1a
- darm-best 1f435ef36fb7e3f4076fa17a56c74d2a35023043c693c9168a2931e8873fba1a
- base 6b293afa14832b73ab0738a7231ddf842f3e06d2c9aac372e019247726ff5324
- anchor 9aa97bca3906c0d31452e4594b5fc17c535bce25ba5e7e4df92e5ff6841c5fa6
- A/A, 1 samples/window: 1.00073 [0.99968, 1.00195], spread 1.478%

</details>

[^bf]: Upstream branch fusion on vLLM emits IR rejected by the verifier in the original opt, pristine plugin, and patched plugin.
[^aa]: The input exceeded its registered A/A tolerance. Its results are excluded from the geometric mean.
[^darm]: vLLM darm uses -disable-region-replication. The original exceeded 360 seconds.

SRAD-stage2/1024 is included in compilation verification only. CED/110 and SW2D/258x259 use the registered pristine object; 14a did not establish reliable fastest-object timings for these inputs.
