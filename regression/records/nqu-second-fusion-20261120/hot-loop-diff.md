# gfx906 回溯循环逐条对照

包括回环块及热循环中全部指令。对齐按 opcode，等号表示助记符和操作数字面相同（PC 可移动），波浪线表示配对行的操作数或标签变了，−／+ 是对齐上移除／新增。寄存器重新分配和基本块标签变化也会触发波浪线标记。

| 标注 | P | C |
| --- | --- | --- |
| = | `0x1acc s_or_b64 exec, exec, s[0:1]` | `0x1acc s_or_b64 exec, exec, s[0:1]` |
| = | `0x1ad0 s_and_b64 s[0:1], exec, s[2:3]` | `0x1ad0 s_and_b64 s[0:1], exec, s[2:3]` |
| = | `0x1ad4 s_or_b64 s[10:11], s[0:1], s[10:11]` | `0x1ad4 s_or_b64 s[10:11], s[0:1], s[10:11]` |
| = | `0x1ad8 v_cndmask_b32_e32 v1, v4, v1, vcc` | `0x1ad8 v_cndmask_b32_e32 v1, v4, v1, vcc` |
| = | `0x1adc s_andn2_b64 exec, exec, s[10:11]` | `0x1adc s_andn2_b64 exec, exec, s[10:11]` |
| ~ | `0x1ae0 s_cbranch_execz BB0_13` | `0x1ae0 s_cbranch_execz BB0_9` |
| = | `0x1ae4 s_waitcnt lgkmcnt(0)` | `0x1ae4 s_waitcnt lgkmcnt(0)` |
| ~ | `0x1ae8 v_and_b32_e32 v4, s6, v3` | `0x1ae8 v_and_b32_e32 v6, s6, v3` |
| = | `0x1aec v_add_u32_e32 v7, 1, v3` | `0x1aec v_add_u32_e32 v7, 1, v3` |
| − | `0x1af0 v_cmp_eq_u32_e32 vcc, s6, v4` | — |
| + | — | `0x1af0 v_cmp_eq_u32_e64 s[0:1], s6, v6` |
| ~ | `0x1af4 v_lshlrev_b32_e32 v5, 2, v2` | `0x1af8 v_lshlrev_b32_e32 v4, 2, v2` |
| ~ | `0x1af8 v_not_b32_e32 v6, v3` | `0x1afc v_not_b32_e32 v5, v3` |
| − | `0x1afc v_cmp_ne_u32_e64 s[0:1], s6, v4` | — |
| ~ | `0x1b04 v_cndmask_b32_e64 v4, v7, 0, vcc` | `0x1b00 v_cndmask_b32_e64 v6, v7, 0, s[0:1]` |
| + | — | `0x1b08 v_mad_u32_u24 v4, v0, 40, v4` |
| ~ | `0x1b0c v_or_b32_e32 v3, v3, v4` | `0x1b10 v_or_b32_e32 v3, v3, v6` |
| − | `0x1b10 v_mad_u32_u24 v5, v0, 40, v5` | — |
| ~ | `0x1b18 v_and_b32_e32 v6, v7, v6` | `0x1b14 v_and_b32_e32 v5, v7, v5` |
| ~ | `0x1b1c ds_write_b32 v5, v3` | `0x1b18 ds_write_b32 v4, v3` |
| ~ | `0x1b24 v_and_b32_e32 v3, s6, v6` | `0x1b20 v_and_b32_e32 v3, s6, v5` |
| + | — | `0x1b24 v_cmp_eq_u32_e32 vcc, 0, v3` |
| + | — | `0x1b28 s_or_b64 vcc, s[0:1], vcc` |
| + | — | `0x1b2c v_add_u32_e32 v3, 1, v2` |
| + | — | `0x1b30 s_xor_b64 s[12:13], vcc, -1` |
| ~ | `0x1b28 v_cmp_ne_u32_e64 s[2:3], 0, v3` | `0x1b34 v_cmp_ne_u32_e64 s[2:3], s7, v3` |
| ~ | `0x1b30 s_and_b64 s[0:1], s[0:1], s[2:3]` | `0x1b3c s_and_b64 s[2:3], s[2:3], s[12:13]` |
| − | `0x1b34 s_and_saveexec_b64 s[2:3], s[0:1]` | — |
| − | `0x1b38 s_xor_b64 s[2:3], exec, s[2:3]` | — |
| − | `0x1b3c s_cbranch_execz BB0_9` | — |
| − | `0x1b40 v_add_u32_e32 v3, 1, v2` | — |
| − | `0x1b44 v_cmp_ne_u32_e64 s[0:1], s7, v3` | — |
| ~ | `0x1b4c s_and_saveexec_b64 s[12:13], s[0:1]` | `0x1b40 s_and_saveexec_b64 s[12:13], s[2:3]` |
| ~ | `0x1b50 s_xor_b64 s[0:1], exec, s[12:13]` | `0x1b44 s_xor_b64 s[2:3], exec, s[12:13]` |
| ~ | `0x1b54 s_cbranch_execz BB0_6` | `0x1b48 s_cbranch_execz BB0_5` |
| ~ | `0x1b58 v_lshlrev_b32_e32 v4, 2, v2` | `0x1b4c v_lshlrev_b32_e32 v6, 2, v2` |
| ~ | `0x1b5c v_mad_u32_u24 v4, v0, 40, v4` | `0x1b50 v_mad_u32_u24 v8, v0, 40, v6` |
| ~ | `0x1b64 ds_read_b32 v9, v4 offset:7680` | `0x1b58 ds_read_b32 v9, v8 offset:7680` |
| ~ | `0x1b6c ds_read2st64_b32 v[7:8], v4 offset0:10 offset1:20` | `0x1b60 ds_read2st64_b32 v[6:7], v8 offset0:10 offset1:20` |
| = | `0x1b74 s_waitcnt lgkmcnt(1)` | `0x1b68 s_waitcnt lgkmcnt(1)` |
| ~ | `0x1b78 v_or_b32_e32 v9, v9, v6` | `0x1b6c v_or_b32_e32 v9, v9, v5` |
| = | `0x1b7c s_waitcnt lgkmcnt(0)` | `0x1b70 s_waitcnt lgkmcnt(0)` |
| ~ | `0x1b80 v_or_b32_e32 v8, v8, v6` | `0x1b74 v_or_b32_e32 v7, v7, v5` |
| ~ | `0x1b84 v_or_b32_e32 v6, v7, v6` | `0x1b78 v_or_b32_e32 v5, v6, v5` |
| − | `0x1b88 ds_write_b32 v4, v9 offset:7684` | — |
| ~ | `0x1b90 v_lshlrev_b32_e32 v7, 1, v8` | `0x1b7c v_lshlrev_b32_e32 v6, 1, v7` |
| ~ | `0x1b94 v_lshrrev_b32_e32 v6, 1, v6` | `0x1b80 v_lshrrev_b32_e32 v5, 1, v5` |
| ~ | `0x1b98 v_add_u32_e32 v4, 0xa04, v4` | `0x1b84 v_add_u32_e32 v7, 0xa04, v8` |
| ~ | `0x1ba0 ds_write2st64_b32 v4, v6, v7 offset1:10` | `0x1b8c ds_write2st64_b32 v7, v5, v6 offset1:10` |
| ~ | `0x1ba8 v_or3_b32 v4, v7, v9, v6` | `0x1b94 v_or3_b32 v5, v6, v9, v5` |
| + | — | `0x1b9c ds_write_b32 v8, v9 offset:7684` |
| ~ | `0x1bb0 ds_write_b32 v5, v4 offset:4` | `0x1ba4 ds_write_b32 v4, v5 offset:4` |
| ~ | `0x1bb8 s_or_saveexec_b64 s[0:1], s[0:1]` | `0x1bac s_or_saveexec_b64 s[2:3], s[2:3]` |
| = | `0x1bbc v_mov_b32_e32 v4, v1` | `0x1bb0 v_mov_b32_e32 v4, v1` |
| ~ | `0x1bc0 s_xor_b64 exec, exec, s[0:1]` | `0x1bb4 s_xor_b64 exec, exec, s[2:3]` |
| = | `0x1bc4 v_add_u32_e32 v4, 1, v1` | `0x1bb8 v_add_u32_e32 v4, 1, v1` |
| = | `0x1bc8 v_add_u32_e32 v3, -1, v2` | `0x1bbc v_add_u32_e32 v3, -1, v2` |
| ~ | `0x1bcc s_or_b64 exec, exec, s[0:1]` | `0x1bc0 s_or_b64 exec, exec, s[2:3]` |
| − | `0x1bd0 s_or_saveexec_b64 s[0:1], s[2:3]` | — |
| − | `0x1bd4 s_xor_b64 exec, exec, s[0:1]` | — |
| − | `0x1bd8 v_add_u32_e32 v3, -1, v2` | — |
| − | `0x1bdc v_mov_b32_e32 v4, v1` | — |
| ~ | `0x1be0 s_or_b64 exec, exec, s[0:1]` | `0x1bc4 s_or_b64 s[0:1], s[0:1], vcc` |
| − | `0x1be4 v_cndmask_b32_e32 v2, v3, v3, vcc` | — |
| + | — | `0x1bc8 v_cndmask_b32_e64 v2, v3, v3, s[0:1]` |
| = | `0x1be8 v_cmp_lt_i32_e64 s[0:1], -1, v2` | `0x1bd0 v_cmp_lt_i32_e64 s[0:1], -1, v2` |
| = | `0x1bf0 s_mov_b64 s[2:3], -1` | `0x1bd8 s_mov_b64 s[2:3], -1` |
| = | `0x1bf4 s_and_saveexec_b64 s[12:13], s[0:1]` | `0x1bdc s_and_saveexec_b64 s[12:13], s[0:1]` |
| = | `0x1bf8 s_xor_b64 s[0:1], exec, s[12:13]` | `0x1be0 s_xor_b64 s[0:1], exec, s[12:13]` |
| = | `0x1bfc s_cbranch_execz BB0_2` | `0x1be4 s_cbranch_execz BB0_2` |
| = | `0x1c00 v_lshlrev_b32_e32 v3, 2, v2` | `0x1be8 v_lshlrev_b32_e32 v3, 2, v2` |
| = | `0x1c04 v_mad_u32_u24 v3, v0, 40, v3` | `0x1bec v_mad_u32_u24 v3, v0, 40, v3` |
| = | `0x1c0c ds_read_b32 v3, v3` | `0x1bf4 ds_read_b32 v3, v3` |
| = | `0x1c14 s_xor_b64 s[2:3], exec, -1` | `0x1bfc s_xor_b64 s[2:3], exec, -1` |
| = | `0x1c18 s_branch BB0_2` | `0x1c00 s_branch BB0_2` |
