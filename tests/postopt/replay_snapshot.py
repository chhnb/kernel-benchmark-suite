#!/usr/bin/env python3
"""Relocate a frozen explicit trial and verify identity-checked replay."""
import argparse,hashlib,json,shutil,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
def main():
 p=argparse.ArgumentParser();p.add_argument('--trial',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--cleanup',default='darm-cfg-earlycse');a=p.parse_args()
 trial=a.trial.resolve();old=json.loads((trial/'trial.json').read_text());source=(trial/old['parent_ir']).resolve();before=hashlib.sha256(source.read_bytes()).hexdigest()
 out=a.out.resolve();out.mkdir(parents=True,exist_ok=False);function,split,left,right=old['candidate'].split(':');metrics=old['score_result']['metrics']
 cases=[];parsed_parents=[]
 for name,mutation in [('relocated-a',None),('relocated-b',None),('changed-body','body'),('missing-header','header'),('wrong-hash','hash')]:
  directory=out/name;directory.mkdir();snapshot=directory/'input.ll';content=source.read_text()
  if mutation=='body':content+='\n@replay_corruption = private global i8 0\n'
  if mutation=='header':content='\n'.join(content.splitlines()[1:])+'\n'
  snapshot.write_text(content);expected='0'*40 if mutation=='hash' else old['parent_hash']
  argv=[str(ROOT/'build/fusion-search/fusion-search'),'--ir',str(snapshot),'--function',function,'--split',split,'--left',left,'--right',right,'--cleanup',a.cleanup,'--scorer','v2','--pressure-weight',str(metrics['pressure_weight']),'--dependency-features','1','--replay-parent-hash',expected,'--out',str(directory/'result.ll'),'--debug-dir',str(directory/'debug')]
  if metrics.get('static_alloca_cost',-1)>0:argv+=['--static-alloca-cost',str(int(metrics['static_alloca_cost']))]
  result=subprocess.run(argv,capture_output=True,text=True);(directory/'run.log').write_text(result.stdout+result.stderr)
  if mutation:
   assert result.returncode!=0 and not (directory/'result.ll').exists() and not (directory/'debug').exists(),name
   assert 'snapshot parent hash mismatch' in result.stderr or 'ModuleID header' in result.stderr,result.stderr
  else:
   assert result.returncode==0,result.stderr
   new=json.loads((directory/'debug/trial-0/trial.json').read_text())
   for key in ['candidate','control_hash','cleaned_hash','eligible']:assert old[key]==new[key],(name,key)
   parsed_parents.append(new['parent_hash'])
   assert (trial/'after.ll').read_bytes()==(directory/'debug/trial-0/after.ll').read_bytes()
  cases.append({'case':name,'exit_code':result.returncode,'expected_rejection':mutation is not None})
 assert len(set(parsed_parents))==1
 assert hashlib.sha256(source.read_bytes()).hexdigest()==before
 (out/'verification.json').write_text(json.dumps({'candidate':old['candidate'],'original_parent_sha256':before,'source_unchanged':True,'serialized_origin_hash':old['parent_hash'],'relocated_parsed_parent_hash':parsed_parents[0],'relocated_control_candidate_hashes_exact':True,'cases':cases},indent=2))
 print('PASS authenticated snapshot origin, stable relocated parsed identity and exact control/candidate identities, changed-body/header/hash rejection, source immutability')
if __name__=='__main__':main()
