from pathlib import Path
import subprocess,json,hashlib
s=Path('/home/chh/kernel-benchmark-suite');p=Path(__file__).resolve().parent
src=p/'start.ll';fn='srad_cuda_2'
plan={'source':str(src),'commands':[]}
def run(name,cmd):
 plan['commands'].append(list(map(str,cmd)));(p/'build-plan.json').write_text(json.dumps(plan,indent=2))
 with (p/(name+'.stdout')).open('w') as a,(p/(name+'.stderr')).open('w') as b:subprocess.run(cmd,stdout=a,stderr=b,check=True,timeout=900)
case=s/'cases/srad-stage2'
run('build-oracle',['g++','-std=c++17','-O2','-ffp-contract=off',case/'make_fixtures.cpp','-o',p/'make-fixtures'])
run('fixtures',[p/'make-fixtures',s/'cases/srad/fixtures-cpp',case/'fixtures-cpp'])
cfg=json.loads((case/'case.json').read_text())
run('build-baseline',[x.replace('{case}',str(case)).replace('{out}',str(p)) for x in cfg['profiles']['hip-o3']['argv']])
run('common-preparation',[s/'../region-fusion-lab/toolchains/llvm12/amd-bootstrap/bin/opt',src,'-always-inline','-O3','-internalize','-internalize-public-api-list=srad_cuda_2','-globaldce','-verify','-S','-o',p/'post.ll'])
src=p/'post.ll'
plan['source']=str(src)
plan['sha256']=hashlib.sha256(src.read_bytes()).hexdigest()
for mode in ['scoped-local','scoped-cfg']:
 run(mode,[s/'build/llvm24-tti/fusion-search-llvm24','--ir',src,'--function',fn,'--structural','1','--adjacent-only','0','--cleanup',mode,'--scorer','llvm24','--rounds','256','--trials','100000','--debug-dir',p/mode,'--out',p/(mode+'.ll')])
run('original-darm',['/home/chh/darm-artifacts-repro/build/bin/opt',src,'-cfmelder','-run-cfmelding-on-function='+fn,'-verify','-S','-o',p/'original-darm.ll'])
for role in ['scoped-local','scoped-cfg','original-darm']:
 run(role+'-compile',['python3',s/'tools/postopt_compile_pair.py','--baseline',src,'--variant',p/(role+'.ll'),'--case','srad-stage2','--function',fn,'--scope','full-srad-stage2-current-greedy-vs-original-artifacts','--out',p/(role+'-pair'),'--admitted'])
print({mode:json.loads((p/mode/'result.json').read_text()) for mode in ['scoped-local','scoped-cfg']})
