from pathlib import Path
p=Path('/home/chh/kernel-benchmark-suite/tools/run_region_inventory.py')
s=p.read_text().splitlines();s=[l for l in s if not ('boost-mapairy' in l and 'mapairy-llvm12' in l)]
i=s.index('CASES={');s.insert(i+1," 'boost-mapairy':('mapairy-llvm12-baseline-v1/post.ll','evaluate','O3','same LLVM IR used by default code object'),")
p.write_text('\n'.join(s)+'\n')
