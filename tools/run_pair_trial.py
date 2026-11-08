#!/usr/bin/env python3
"""One explicit LLVM12 IR pair trial; emits before/after scoring inputs."""
from pathlib import Path
import argparse,subprocess,sys,time,json,hashlib,shutil,difflib
S=Path(__file__).resolve().parents[1]
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def save(p,v):p.write_text(json.dumps(v,indent=2)+'\n')
def main():
 p=argparse.ArgumentParser();p.add_argument('--ir',required=True);p.add_argument('--function',required=True);p.add_argument('--split',required=True);p.add_argument('--left',required=True);p.add_argument('--right',required=True);p.add_argument('--expected-sha256',required=True);p.add_argument('--version',type=int,default=0);p.add_argument('--opt-level',choices=['2','3'],default='3');p.add_argument('--codegen',choices=['none','gfx906'],default='none');p.add_argument('--out',required=True);p.add_argument('--admitted',action='store_true',help=argparse.SUPPRESS);a=p.parse_args();ir=Path(a.ir).resolve();D=Path(a.out).resolve()
 if not a.admitted:
  cmd=[sys.executable,'/home/chh/region-fusion-lab/work/run-cpu.py','directed-pair-'+str(time.time_ns()),sys.executable,str(Path(__file__).resolve()),'--ir',str(ir),'--out',str(D),'--function',a.function,'--split',a.split,'--left',a.left,'--right',a.right,'--expected-sha256',a.expected_sha256,'--version',str(a.version),'--opt-level',a.opt_level,'--codegen',a.codegen,'--admitted'];return subprocess.call(cmd)
 D.mkdir(parents=True,exist_ok=False);request={'function':a.function,'split':a.split,'left':a.left,'right':a.right,'parent_state_sha256':a.expected_sha256,'parent_version':a.version,'normalization':['-O'+a.opt_level,'-verify'],'candidate_id':a.function+':'+a.left+'+'+a.right+'@'+a.split};save(D/'request.json',request)
 if sha(ir)!=a.expected_sha256:save(D/'result.json',{'status':'rejected_stale_input','transformation_applied':False});return 2
 shutil.copy2(ir,D/'before.ll');tool=S/'build/pair-trial/pair-trial';inv=S/'build/region-inventory/region-inventory';opt=Path('/home/chh/region-fusion-lab/toolchains/llvm12/amd-bootstrap/bin/opt');commands=[]
 def run(name,cmd,stdout=None):
  cmd=list(map(str,cmd));commands.append({'name':name,'argv':cmd});save(D/'commands.json',commands)
  with (stdout or D/(name+'.stdout')).open('w') as o,(D/(name+'.stderr')).open('w') as e:
   try:r=subprocess.run(cmd,stdout=o,stderr=e,timeout=300);rc=r.returncode
   except subprocess.TimeoutExpired:rc=124
  return rc
 rc=run('engine',[tool,D/'before.ll',D/'request.json',D]);checks={'engine_exit':rc,'parent_ir_unchanged':sha(ir)==a.expected_sha256};save(D/'checks.json',checks)
 if rc:save(D/'result.json',{'status':'trial_failed_or_rejected','checks':checks,'failure_preserved':True});return rc if rc>0 else 1
 snapshots={}
 for stage,file in [('before_raw','before.ll'),('after_raw','after-raw.ll'),('before_normalized','before-normalized.ll'),('after_normalized','after-normalized.ll')]:
  if 'normalized' in stage:
   inp=D/('before.ll' if stage.startswith('before') else 'after-raw.ll');assert run(stage+'-normalize',[opt,inp,'-O'+a.opt_level,'-verify','-S','-o',D/file])==0
  facts=D/(stage+'-features.json');inventory=D/(stage+'-regions.json');assert run(stage+'-features',[tool,'--facts',D/file,a.function],facts)==0;assert run(stage+'-regions',[inv,D/file,a.function],inventory)==0
  facts_data=json.loads(facts.read_text());region_data=json.loads(inventory.read_text());matches=[f for f in region_data['functions'] if f['name']==a.function];assert len(matches)==1
  snapshots[stage]={'ir':str(D/file),'ir_sha256':sha(D/file),'features':str(facts),'regions':str(inventory),'summary':{**facts_data['summary'],'loops':matches[0]['summary']['loops'],'canonical_regions':matches[0]['summary']['canonical_regions_including_root']}}
 checks['no_new_raw_loops']=snapshots['after_raw']['summary']['loops']<=snapshots['before_raw']['summary']['loops'];checks['llvm_verified']=True;checks['other_functions_unchanged']=json.loads((D/'engine-result.json').read_text())['other_functions_unchanged']
 changes={}
 for label,before,after in [('raw','before_raw','after_raw'),('normalized','before_normalized','after_normalized')]:
  b=snapshots[before]['summary'];c=snapshots[after]['summary'];changes[label]={k:c[k]-b[k] for k in b}
  x=Path(snapshots[before]['ir']).read_text();y=Path(snapshots[after]['ir']).read_text();(D/(label+'.diff')).write_text(''.join(difflib.unified_diff(x.splitlines(True),y.splitlines(True),fromfile=before,tofile=after)))
  fb=json.loads(Path(snapshots[before]['features']).read_text());fa=json.loads(Path(snapshots[after]['features']).read_text());bb={v['name']:v for v in fb['blocks']};ab={v['name']:v for v in fa['blocks']};changes[label+'_block_names']={'added':sorted(ab.keys()-bb.keys()),'removed':sorted(bb.keys()-ab.keys()),'modified':sorted(k for k in ab.keys()&bb.keys() if ab[k]!=bb[k]),'scope':'name-based footprint, not exact instruction fusion provenance'}
 checks['semantic_validation']='not_run';checks['engine_calls']=json.loads((D/'engine-result.json').read_text())['engine_calls'];checks['parent_ir_unchanged']=sha(ir)==a.expected_sha256
 if a.codegen=='gfx906' and checks['no_new_raw_loops']:
  for stage in ['before_normalized','after_normalized']:
   obj=D/(stage+'.o');binary=D/(stage+'.hsaco');assert run(stage+'-llc',[opt.parent/'llc',snapshots[stage]['ir'],'-O3','-mtriple=amdgcn-amd-amdhsa','-mcpu=gfx906','-mattr=+sram-ecc,-xnack','-filetype=obj','-o',obj])==0;assert run(stage+'-link',['/opt/rocm/llvm/bin/ld.lld','-shared',obj,'-o',binary])==0;snapshots[stage]['binary']=str(binary);snapshots[stage]['binary_sha256']=sha(binary)
 save(D/'checks.json',checks);payload={'schema':'pair-trial-score-input-v1','candidate':request,'scope':'complete selected function in unextracted module; raw and equally normalized before/after snapshots','snapshots':snapshots,'selection':json.loads((D/'selection.json').read_text()),'deltas':changes,'checks':checks,'scorer_result':None,'tool_sha256':sha(tool),'fusion_engine_source':str(S/'tools/darm_pair_engine/provenance.json')};save(D/'score-input.json',payload)
 good=all(checks[k] for k in ['parent_ir_unchanged','no_new_raw_loops','llvm_verified','other_functions_unchanged']) and checks['engine_calls']==1;save(D/'result.json',{'status':'ir_trial_ready_for_scoring' if good else 'failed_postcheck','static_checks_passed':good,'semantic_validation':'not_run','committed':False,'score_input':str(D/'score-input.json')});print(json.dumps({'status':'ready' if good else 'failed','deltas':changes['normalized'],'out':str(D)},indent=2));return 0 if good else 1
if __name__=='__main__':raise SystemExit(main())
