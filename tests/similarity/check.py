from pathlib import Path
import json,subprocess
S=Path(__file__).resolve().parents[2];D=S/'tests/similarity';inv=S/'build/region-inventory/region-inventory';score=S/'build/region-similarity/region-similarity';opt='/home/chh/darm-artifacts-repro/build/bin/opt'
subprocess.run([opt,str(D/'shapes.ll'),'-verify','-disable-output'],check=True)
x=subprocess.check_output([str(inv),str(D/'shapes.ll')],text=True);(D/'inventory.json').write_text(x)
y=json.loads(subprocess.check_output([str(score),str(D/'shapes.ll'),str(D/'inventory.json')],text=True));(D/'scores.json').write_text(json.dumps(y,indent=2))
statuses=set();values=[]
for f in y['functions']:
 for pair in f['pairs']:
  statuses.add(pair['status'])
  if pair['similarity'] is not None:assert 0<=pair['similarity']<=0.5;values.append(pair['similarity'])
assert 'nonexclusive_sides' in statuses,statuses
assert 'region_structure_mismatch' in statuses,statuses
assert 'cyclic_context_not_scored' in statuses,statuses
assert any(v==0.5 for v in values)
E=S/'analysis/suite-regions-llvm12-v4/boost-landau';receipt=json.loads((E/'receipt.json').read_text());z=json.loads(subprocess.check_output([str(score),receipt['ir'],str(E/'inventory.json')],text=True));(D/'landau-scores.json').write_text(json.dumps(z,indent=2));f=z['functions'][0]
row=[p for p in f['pairs'] if p['relation']=='adjacent_cascade_arms' and p['context']=='G2:0/1'];assert len(row)==1 and abs(row[0]['similarity']-0.489899)<1e-6
assert any(p['context']=='G2:11/12' for p in f['skipped_contexts'])
print(json.dumps({'passed':True,'fixture_statuses':sorted(statuses),'landau':f['summary']},indent=2))
