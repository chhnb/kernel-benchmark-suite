from pathlib import Path
import subprocess,shlex,json
S=Path(__file__).resolve().parents[1];D=S/'build/region-inventory';D.mkdir(parents=True,exist_ok=True)
cfg='/home/chh/darm-artifacts-repro/build/bin/llvm-config'
flags=shlex.split(subprocess.check_output([cfg,'--cxxflags','--ldflags','--libs','core','irreader','analysis','support','--system-libs'],text=True))
cmd=['g++',str(S/'tools/region_inventory.cpp'),*flags,'-std=c++17','-O2','-o',str(D/'region-inventory')]
(D/'command.json').write_text(json.dumps(cmd,indent=2))
r=subprocess.run(cmd,capture_output=True,text=True);(D/'build.stdout').write_text(r.stdout);(D/'build.stderr').write_text(r.stderr);print(r.stderr[-6000:]);raise SystemExit(r.returncode)
