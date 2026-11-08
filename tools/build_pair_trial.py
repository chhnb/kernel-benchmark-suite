from pathlib import Path
import subprocess,shlex,json
S=Path(__file__).resolve().parents[1];D=S/'build/pair-trial';D.mkdir(parents=True,exist_ok=True);src=S/'tools/darm_pair_engine';cfg='/home/chh/darm-artifacts-repro/build/bin/llvm-config'
flags=shlex.split(subprocess.check_output([cfg,'--cxxflags','--ldflags','--libs','core','irreader','analysis','transformutils','support','--system-libs'],text=True))
objects=[]
for file in [S/'tools/pair_trial.cpp',*[src/x for x in ['RegionAnalyzer.cpp','RegionMelder.cpp','RegionReplicator.cpp','CFMelderUtils.cpp','InstructionMatch.cpp']]]:
 obj=D/(file.stem+'.o');cmd=['g++',str(file),'-I'+str(src),*flags,'-std=c++17','-O2','-c','-o',str(obj)];(D/(file.stem+'.command.json')).write_text(json.dumps(cmd,indent=2));r=subprocess.run(cmd,capture_output=True,text=True);(D/(file.stem+'.stderr')).write_text(r.stderr)
 if r.returncode:print(r.stderr[-6000:]);raise SystemExit(r.returncode)
 objects.append(str(obj))
cmd=['g++',*objects,*flags,'-std=c++17','-o',str(D/'pair-trial')];(D/'link-command.json').write_text(json.dumps(cmd,indent=2));r=subprocess.run(cmd,capture_output=True,text=True);(D/'link.stderr').write_text(r.stderr);print(r.stderr[-6000:]);raise SystemExit(r.returncode)
