#!/usr/bin/env python3
"""Same parent, pair, cleanup and TTI mode; compare only scorer dispatch."""
import argparse,json,os,subprocess,time,hashlib
from pathlib import Path
root=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--old',type=Path,required=True);p.add_argument('--new',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
env=dict(os.environ);env['LD_LIBRARY_PATH']=str(root/'build/llvm12-jammy/usr/lib/x86_64-linux-gnu')+':'+env.get('LD_LIBRARY_PATH','');env.setdefault('LLVM24_LIBDIR',str(root/'build/llvm24-pinned/lib'))
rows=[]
for case in ['PCM32','PCM256','BIT32','MS32','vllm','tigre']:
 ref=root/'build/incremental-identity-regression'/case
 summary=json.loads((ref/'summary.json').read_text());round=next(r for r in summary['rounds'] if r['selected'])
 request=json.loads((Path(round['selected'])/'request.json').read_text())
 scores=[];irs=[];times=[];score_times=[]
 for name,tool in [('old',a.old),('new',a.new)]:
  out=(a.out/case/name).resolve();out.mkdir(parents=True)
  args=request['replay_args'].copy();args[0]=str(tool.resolve());args+=['--debug-dir',str(out/'debug'),'--out',str(out/'fused.ll')]
  start=time.monotonic();r=subprocess.run(args,env=env,capture_output=True,text=True);times.append(time.monotonic()-start)
  (out/'stdout').write_text(r.stdout);(out/'stderr').write_text(r.stderr);assert r.returncode==0,(case,name,r.returncode,r.stderr[-1000:])
  trial=json.loads((out/'debug/trial-0/trial.json').read_text());scores.append(trial['score_result']);irs.append((out/'fused.ll').read_bytes());score_times.append(trial.get('timings_ms',{}).get('score_with_analysis'))
 assert scores[0]==scores[1],(case,'score fields differ')
 assert irs[0]==irs[1],(case,'IR bytes differ')
 row=dict(case=case,candidate=request['candidate'],scores_exact=True,ir_bytes_exact=True,ir_sha256=hashlib.sha256(irs[0]).hexdigest(),old_seconds=times[0],new_seconds=times[1],score_ms=score_times)
 rows.append(row);(a.out/'results.json').write_text(json.dumps(rows,indent=2)+'\n');print(case,'PASS',flush=True)
print('PASS all six same-parent candidates; timing samples are not a full compile benchmark')
