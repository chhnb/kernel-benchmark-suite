from pathlib import Path
import subprocess,json
S=Path(__file__).resolve().parents[2];tool=S/'build/region-inventory/region-inventory';opt='/home/chh/darm-artifacts-repro/build/bin/opt'
fixture=S/'tests/regions/multiple.ll'
subprocess.run([opt,str(fixture),'-verify','-disable-output'],check=True)
d=json.loads(subprocess.check_output([str(tool),str(fixture)],text=True));f=d['functions'][0];s=f['summary']
assert s['multiway_cascades']==2 and s['conditional_branches']==5 and s['switches']==1 and s['selects']==1 and s['loops']==1,s
assert all(len(g['tests'])==2 and len(g['arms'])==3 for g in f['groups'])
assert sum(c['cyclic_or_backedge'] for c in f['choices'])==1
ir=S/'results/landau-llvm12-baseline-v1/post.ll';landau=json.loads(subprocess.check_output([str(tool),str(ir),'evaluate'],text=True))['functions'][0]
assert landau['summary']['blocks']==48 and landau['summary']['canonical_regions_including_root']==25
assert sorted(len(g['arms']) for g in landau['groups'])==[3,9,13],landau['groups']
print(json.dumps({'passed':True,'fixture':s,'landau':landau['summary']},indent=2))
