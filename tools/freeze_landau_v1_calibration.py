from pathlib import Path
import json,hashlib,shutil,subprocess,re
S=Path('/home/chh/kernel-benchmark-suite');P=S/'experiments/landau-incremental-score-v1';E=S/'experiments/landau-score-v1-calibration-20261106';E.mkdir(exist_ok=False)
def sha(p,algo='sha256'):return hashlib.new(algo,p.read_bytes()).hexdigest()
def save(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
review=json.loads((P/'review.json').read_text())
for name in ['tools/fusion_search.h','tools/fusion_search.cpp','tools/fusion_search_main.cpp','build/fusion-search/fusion-search']:
 assert sha(S/name)==review['source_and_binary_sha256'][name],name
 (E/'frozen'/Path(name).parent).mkdir(parents=True,exist_ok=True);shutil.copy2(S/name,E/'frozen'/name)
shutil.copytree(S/'tools/darm_pair_engine',E/'frozen/tools/darm_pair_engine')
for name in ['compare','compare.cpp','run_gpu.py']:shutil.copy2(P/name,E/name)
shutil.copy2(P/'review.json',E/'v1-search-review.json')
D=P/'debug';round0=json.loads((D/'round-0.json').read_text());assert sha(D/'round-0-control.ll','sha1')==round0['control_hash'];shutil.copy2(D/'round-0.json',E/'round-0.json')
selection={'evaluate:B12:B13:B15':('gain665',665),'evaluate:B16:B17:B19':('gain658',658),'evaluate:B21:B22:B24':('gain107',107),'evaluate:B25:B26:B28':('gain_neg40',-40)}
records=[{'role':'baseline','candidate':'control','gain':0,'ir':str(E/'baseline/input.ll')}];(E/'baseline').mkdir();shutil.copy2(D/'round-0-control.ll',E/'baseline/input.ll')
for f in sorted(D.glob('trial-*/trial.json')):
 t=json.loads(f.read_text())
 if t['version']!=0 or t['candidate'] not in selection:continue
 role,gain=selection[t['candidate']];assert t['valid'] and t['score_result']['static_gain']==gain and t['parent_hash']==round0['parent_hash']
 assert sha(f.parent/'after.ll','sha1')==t['cleaned_hash']
 target=E/role;target.mkdir();shutil.copy2(f,target/'trial.json');shutil.copy2(f.parent/'after.ll',target/'input.ll');shutil.copy2(f.parent/'after-raw.ll',target/'raw.ll')
 records.append({'role':role,'candidate':t['candidate'],'gain':gain,'static_score':t['score_result']['static_score'],'ir':str(target/'input.ll')})
assert len(records)==5
records.sort(key=lambda r:['baseline','gain665','gain658','gain107','gain_neg40'].index(r['role']))
llvm=Path('/home/chh/region-fusion-lab/toolchains/llvm12/amd-bootstrap/bin');llc=llvm/'llc';ld=Path('/opt/rocm/llvm/bin/ld.lld');readobj=Path('/opt/rocm/llvm/bin/llvm-readobj');objdump=Path('/opt/rocm/llvm/bin/llvm-objdump')
commands=[]
def run(cmd,output):
 commands.append(list(map(str,cmd)));save(E/'commands.json',commands)
 with output.open('w') as f,(output.with_suffix(output.suffix+'.stderr')).open('w') as err:subprocess.run(list(map(str,cmd)),stdout=f,stderr=err,check=True)
for r in records:
 d=E/r['role'];obj=d/'kernel.o';binary=d/'kernel.hsaco'
 run([llc,r['ir'],'-O3','-mtriple=amdgcn-amd-amdhsa','-mcpu=gfx906','-mattr=+sram-ecc,-xnack','-filetype=obj','-o',obj],d/'llc.stdout')
 run([ld,'-shared',obj,'-o',binary],d/'link.stdout')
 run([readobj,'--notes',binary],d/'metadata.txt');run([readobj,'--sections','--symbols',binary],d/'sections-symbols.txt');run([objdump,'-d',binary],d/'disassembly.txt')
 meta=(d/'metadata.txt').read_text();resources={}
 for key in ['sgpr_count','vgpr_count','sgpr_spill_count','vgpr_spill_count','private_segment_fixed_size','group_segment_fixed_size','wavefront_size','max_flat_workgroup_size']:
  m=re.search(r'^\s*\.'+key+r':\s*(\d+)',meta,re.M);resources[key]=int(m.group(1)) if m else None
 sections=(d/'sections-symbols.txt').read_text();m=re.search(r'Name: \.text\b.*?Size: (\d+)',sections,re.S);resources['text_section_bytes']=int(m.group(1)) if m else None
 r.update(binary=str(binary),binary_sha256=sha(binary),ir_sha256=sha(Path(r['ir'])),resources=resources)
(E/'variants.txt').write_text(''.join(r['role']+' '+r['binary']+'\n' for r in records if r['role']!='baseline'))
# Preserve the canonical admission runner, adapting only this experiment's roles.
p=(E/'run_gpu.py').read_text().replace("E/'trial/before_normalized.hsaco'","E/'baseline/kernel.hsaco'")
p=p.replace("snap={str(x):[x.stat().st_size,x.stat().st_mtime_ns] for x in [kernel,runner,E/'variants.txt',E/'trial/after_normalized.hsaco']}","artifact_files=[kernel,runner,E/'variants.txt']+[Path(line.split()[1]) for line in (E/'variants.txt').read_text().splitlines() if line.strip()]\nsnap={str(x):[x.stat().st_size,x.stat().st_mtime_ns] for x in artifact_files}\nimport hashlib\ndef digest(x):return hashlib.sha256(x.read_bytes()).hexdigest()\nfrozen=json.loads((E/'freeze.json').read_text())\nfor item in frozen['roles']:assert digest(Path(item['binary']))==item['binary_sha256'],'binary changed since freeze'\nassert digest(runner)==frozen['runner_sha256'],'runner changed since freeze'\nbinary_sha256={str(x):digest(x) for x in artifact_files}")
p=p.replace("input_snapshot=input_snapshot,timing_mode", "input_snapshot=input_snapshot,timing_mode")
p=p.replace("'binary_snapshot':snap,", "'binary_snapshot':snap,'binary_sha256':binary_sha256,")
p=p.replace("binary_snapshot=snap,budget=", "binary_snapshot=snap,binary_sha256=binary_sha256,budget=")
p=p.replace("prev['passed'] and prev['binary_snapshot']==snap", "prev['passed'] and prev['binary_snapshot']==snap and prev['binary_sha256']==binary_sha256")
p=p.replace("two-round incremental-control legacy-score C++ greedy full-kernel result versus identically normalized baseline", "frozen V1 parent version 0: control and four individual trials gain665/gain658/gain107/gain_neg40; no greedy combination")
p=p.replace("'scope':rt['scope']", "'scope':req['scope']")
p=p.replace("'one full-output validation per final benchmark fixture'", "'one full-output check per each of five roles on each of three fixtures; 15 launches total'")
(E/'run_gpu.py').write_text(p)
manifest={'schema':'scorer-v1-frozen-calibration-v1','v1_search_budget':{'maxRounds':2,'maxTrials':512,'actual_trials':39,'actual_commits':2,'stop':'round_budget','not_a_convergence_claim':True},'experiment_parent_version':0,'parent_hash':round0['parent_hash'],'control_hash':round0['control_hash'],'cleanup':round0['cleanup'],'weights':round0['weight_version'],'feature_schema':round0['feature_schema'],'roles':records,'measurement':{'timing':'HIP Event','warmup':2,'repeat':5,'fixtures':['interval-mixture','coherent-blocks','historical-2026102507'],'role_order':'existing mirrored cyclic order; baseline name means no-fusion control','stage':'screening; no tuned weights or penalty changes'},'runner_sha256':sha(E/'compare'),'toolchain_sha256':{str(p):sha(p) for p in [llc,ld,readobj,objdump]},'frozen_sources':{str(p.relative_to(E)):sha(p) for p in (E/'frozen').rglob('*') if p.is_file()}}
save(E/'freeze.json',manifest);print(json.dumps({'out':str(E),'roles':records},indent=2))
