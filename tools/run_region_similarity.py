#!/usr/bin/env python3
"""CPU-only scoring orchestration. Native LLVM12/DARM C++ does all scoring."""
from pathlib import Path
import argparse,subprocess,sys,time,json,hashlib
from compact_scores import process as factor_scores
S=Path(__file__).resolve().parents[1]
def digest(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--inventory',default=str(S/'analysis/suite-regions-llvm12-v4'));p.add_argument('--out',required=True);p.add_argument('--case');p.add_argument('--admitted',action='store_true',help=argparse.SUPPRESS);a=p.parse_args();E=Path(a.inventory).resolve();O=Path(a.out).resolve()
 if not a.admitted:
  cmd=[sys.executable,'/home/chh/region-fusion-lab/work/run-cpu.py','suite-neighbor-score-'+str(time.time_ns()),sys.executable,str(Path(__file__).resolve()),'--inventory',str(E),'--out',str(O),'--admitted']
  if a.case:cmd+=['--case',a.case]
  return subprocess.call(cmd)
 summary=json.loads((E/'summary.json').read_text());assert not a.case or a.case in summary
 O.mkdir(parents=True,exist_ok=False);tool=S/'build/region-similarity/region-similarity';lib=Path('/home/chh/darm-artifacts-repro/build/lib/libLLVMCFMelder.a');records={}
 protocol={'analysis_only':True,'llvm':12,'enumeration':['cross-product of maximal canonical regions plus uncovered blocks on opposite split sides','frontiers of consecutive arms in conservative first-match cascades'],'not_enumerated':'all possible arbitrary region unions; sequential same-path adjacency','score':'unmodified DARM Utils::computeBBSimilarty / computeRegionSimilarity after RegionComparator','score_maximum':0.5,'threshold_annotation':'>=0.2; not measured performance or fusion legality','storage':'lossless JSON factorization of repeated units/scores; occurrence contexts retained', 'skips':['nonexclusive sides','overlap','cyclic context','mixed block/region granularity','nonmatching region CFG','empty/PHI-only arm'],'tool_sha256':digest(tool),'darm_library_sha256':digest(lib),'source_sha256':digest(S/'tools/region_similarity.cpp')}
 (O/'protocol.json').write_text(json.dumps(protocol,indent=2))
 for case in summary:
  if a.case and a.case!=case:continue
  d=O/case;d.mkdir();old=json.loads((E/case/'receipt.json').read_text());ir=Path(old['ir']);assert digest(ir)==old['ir_sha256'];inv=E/case/'inventory.json';cmd=[str(tool),str(ir),str(inv)];receipt={'command':cmd,'ir_sha256':digest(ir),'inventory_sha256':digest(inv),'inventory':str(inv)}
  start=time.time()
  with (d/'scores.json').open('w') as out,(d/'stderr.txt').open('w') as err:
   try:r=subprocess.run(cmd,stdout=out,stderr=err,timeout=300);rc=r.returncode
   except subprocess.TimeoutExpired:rc=124
  receipt.update(exit=rc,seconds=time.time()-start,input_unchanged=digest(ir)==old['ir_sha256']);(d/'receipt.json').write_text(json.dumps(receipt,indent=2));assert receipt['input_unchanged']
  if rc:records[case]={'status':'failed','exit':rc};continue
  data=json.loads((d/'scores.json').read_text());counts={'candidate_records':0,'scored':0,'score_at_least_0_2':0,'empty_arm_contexts':0};statuses={};adjacent=[]
  for f in data['functions']:
   for k in counts:counts[k]+=f['summary'][k]
   for k,v in f['summary']['statuses'].items():statuses[k]=statuses.get(k,0)+v
   for pair in f['pairs']:
    score=pair['similarity'];assert score is None or 0<=score<=0.5
    if pair['relation']=='adjacent_cascade_arms':adjacent.append({'function':f['name'],**pair})
  factored=factor_scores(d)
  records[case]={'status':'completed','functions':len(data['functions']),**counts,'statuses':statuses,'adjacent_records':len(adjacent),'adjacent_scored':sum(p['similarity'] is not None for p in adjacent)}
  records[case]['distinct_pair_status_records']=sum(f['summary']['distinct_pair_status_records'] for f in factored['functions'])
  records[case]['distinct_scored_pairs']=sum(f['summary']['distinct_scored_pairs'] for f in factored['functions'])
  (d/'scores.json').unlink()  # All original records reconstruct exactly; receipt retains raw digest.
  print(case,json.dumps(records[case]),flush=True)
 (O/'summary.json').write_text(json.dumps(records,indent=2));return int(any(v['status']!='completed' for v in records.values()))
if __name__=='__main__':raise SystemExit(main())
