from pathlib import Path
import json,csv,statistics,hashlib,collections
S=Path('/home/chh/kernel-benchmark-suite');p=S/'experiments/tigre-scoped-cfg-20261109-v2';out=p/'measure';plan=json.loads((out/'terminal.json').read_text());assert plan['status']=='completed';roles=['unmerged','original_darm','previous_greedy','hybrid'];times={r:[] for r in roles};snap=None
for r in roles:
 assert json.loads((out/(r+'-validation')/'accepted.json').read_text())['passed'];assert hashlib.sha256(Path(plan['binaries'][r]['path']).read_bytes()).hexdigest()==plan['binaries'][r]['sha256']
 for b in range(4):
  d=out/(r+'-batch-'+str(b));receipt=json.loads((d/'accepted.json').read_text());assert receipt['passed']
  if snap is None:snap=receipt['input_snapshot']
  assert snap==receipt['input_snapshot'];rows=list(csv.DictReader((d/'output/0/timing.csv').open()));assert len(rows)==108;v=[]
  for i in range(6):
   a=[float(x['ms']) for x in rows if x['warmup']=='0' and int(x['batch'])==i];assert len(a)==15 and min(a)>0;v.append(statistics.median(a))
  times[r].append(v)
med={r:[statistics.median(times[r][b][i] for b in range(4)) for i in range(6)] for r in roles};sums={r:sum(med[r]) for r in roles};bs={r:[sum(a) for a in times[r]] for r in roles}
s={'sum_medians_ms':sums,'speedup':{r:sums['unmerged']/sums[r] for r in roles},'decrease_pct':{r:100*(1-sums[r]/sums['unmerged']) for r in roles},'hybrid_vs_darm_increase_pct':100*(sums['hybrid']/sums['original_darm']-1),'batch_hybrid_vs_darm_increase_pct':[100*(bs['hybrid'][b]/bs['original_darm'][b]-1) for b in range(4)],'batch_sums_ms':bs,'projection_median_ms':med,'search':json.loads((p/'hybrid-cfg/result.json').read_text())};(p/'summary.json').write_text(json.dumps(s,indent=2));print(json.dumps(s,indent=2))
