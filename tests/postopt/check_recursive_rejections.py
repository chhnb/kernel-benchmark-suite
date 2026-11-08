from pathlib import Path
import json,subprocess,sys
R=Path('/home/chh/kernel-benchmark-suite');S=R/'build/llvm24-tti/fusion-search-llvm24'
source=Path(sys.argv[1]).read_text();O=R/'experiments'/sys.argv[2];O.mkdir(exist_ok=False)
needle='%v1=call float @llvm.copysign.f32(float 0.5, float %input)'
assert needle in source
variants={
 'metadata':source.replace(needle,needle+', !fpmath !0')+'\n!0 = !{float 1.0}\n',
 'memory':source.replace('declare float @llvm.fabs.f32(float)','@g = external global float\ndeclare float @llvm.fabs.f32(float)').replace(needle,'%loaded=load float, float* @g\n %v1=call float @llvm.copysign.f32(float %loaded, float %input)'),
 'division':source.replace(needle,'%den=and i32 %bits, 1\n %quot=sdiv i32 1, %den\n %mag=sitofp i32 %quot to float\n %v1=call float @llvm.copysign.f32(float %mag, float %input)'),
 'operation':source.replace(needle,'%v1=fadd float 0.5, %input'),
 'escape':source.replace(needle,'%aux=fmul float 0.5, %input\n %v1=call float @llvm.copysign.f32(float %aux, float %input)').replace('join:\n','join:\n %escape=phi float '+', '.join('[ %aux, %L1 ]' if i==1 else f'[ 0.0, %L{i} ]' for i in range(8))+'\n')}
results=[]
for name,text in variants.items():
 inp=O/(name+'.ll');inp.write_text(text);catdir=O/(name+'-catalog')
 common=[str(S),'--ir',str(inp),'--function','f','--adjacent-only','1','--local-compute','1','--local-union','1','--cleanup','none']
 p=subprocess.run(common+['--catalog-only','1','--debug-dir',str(catdir),'--out',str(O/(name+'-catalog.ll'))],capture_output=True,text=True);assert p.returncode==0,p.stderr
 cat=json.loads((catdir/'catalog.json').read_text())['candidates'];c=next(x for x in cat if x['logical_left']=='D0.L1' and x['logical_right']=='D0.L2');d=O/(name+'-trial')
 p=subprocess.run(common+['--scorer','legacy','--debug-dir',str(d),'--out',str(O/(name+'-after.ll')),'--split',c['split'],'--left',c['left'],'--right',c['right']],capture_output=True,text=True)
 assert p.returncode==4,(name,p.stderr)
 j=json.loads((d/'trial-0/trial.json').read_text());assert not j['valid']
 assert (d/'trial-0/after-raw.ll').read_text()==(catdir/'state-0.ll').read_text(),name+' rejection mutated cloned IR'
 results.append({'case':name,'reason':j['reason'],'unchanged_on_rejection':True})
(O/'summary.json').write_text(json.dumps(results,indent=2));print(json.dumps(results,indent=2))
