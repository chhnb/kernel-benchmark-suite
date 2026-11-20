from pathlib import Path
import json,subprocess,tempfile
S=Path(__file__).resolve().parents[2];D=S/'tests/similarity';inv=S/'build/region-inventory/region-inventory';score=S/'build/region-similarity/region-similarity';opt=Path('/home/chh/darm-artifacts-repro/build/bin/opt')
evidence = S / "analysis/suite-regions-llvm12-v4/boost-landau"
receipt = evidence / "receipt.json"
inputs = [inv, score, opt, receipt, evidence / "inventory.json"]
if receipt.is_file():
 inputs.append(Path(json.loads(receipt.read_text())["ir"]))
missing = [str(path) for path in inputs if not path.is_file()]
if missing:
 print("SKIP similarity: missing " + ", ".join(missing)
       + "; provision the historical LLVM12 tools, build region inventory and similarity, and restore the Landau analysis.")
 raise SystemExit(77)
subprocess.run([opt,str(D/'shapes.ll'),'-verify','-disable-output'],check=True)
with tempfile.TemporaryDirectory(prefix="similarity-check-") as scratch:
 inventory = Path(scratch) / "inventory.json"
 inventory.write_text(subprocess.check_output([inv, D/'shapes.ll'],text=True))
 y = json.loads(subprocess.check_output([score, D/'shapes.ll', inventory],text=True))
statuses=set();values=[]
for f in y['functions']:
 for pair in f['pairs']:
  statuses.add(pair['status'])
  if pair['similarity'] is not None:assert 0<=pair['similarity']<=0.5;values.append(pair['similarity'])
assert 'nonexclusive_sides' in statuses,statuses
assert 'region_structure_mismatch' in statuses,statuses
assert 'cyclic_context_not_scored' in statuses,statuses
assert any(v==0.5 for v in values)
z = json.loads(subprocess.check_output([score, inputs[-1], evidence/'inventory.json'],text=True));f=z['functions'][0]
row=[p for p in f['pairs'] if p['relation']=='adjacent_cascade_arms' and p['context']=='G2:0/1'];assert len(row)==1 and abs(row[0]['similarity']-0.489899)<1e-6
assert any(p['context']=='G2:11/12' for p in f['skipped_contexts'])
print(json.dumps({'passed':True,'fixture_statuses':sorted(statuses),'landau':f['summary']},indent=2))
