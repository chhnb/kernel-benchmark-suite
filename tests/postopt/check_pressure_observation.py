#!/usr/bin/env python3
"""Real-kernel ablation: default V2 observes pressure without changing V1 decisions."""
import argparse,hashlib,json,subprocess,sys,time
from pathlib import Path

R=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--admitted',action='store_true');a=p.parse_args()
if not a.admitted:
    sys.exit(subprocess.call([sys.executable,'/home/chh/region-fusion-lab/work/run-cpu.py','pressure-observation-'+str(time.time_ns()),sys.executable,str(Path(__file__).resolve()),'--out',str(a.out.resolve()),'--admitted']))
O=a.out.resolve();O.mkdir(parents=True,exist_ok=False)
reference=R/'work/postopt/mapairy-full-fixed-v1/v1';source=R/'work/postopt/mapairy-supported/state-0.ll';binary=R/'build/fusion-search/fusion-search'
cmd=[str(binary),'--ir',str(source),'--function','evaluate','--out',str(O/'result.ll'),'--rounds','8','--trials','2048','--scorer','v2','--debug-dir',str(O/'debug')]
(O/'plan.json').write_text(json.dumps({'argv':cmd,'binary_sha256':hashlib.sha256(binary.read_bytes()).hexdigest(),'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'reference':str(reference),'pressure_weight_flag_omitted':True},indent=2))
with (O/'run.log').open('w') as f:subprocess.run(cmd,check=True,stdout=f,stderr=subprocess.STDOUT,timeout=300)
load=lambda p:json.loads(p.read_text())
run=load(O/'debug/run.json');assert run['pressure_weight']==0 and run['policy']=='v2'
assert (O/'debug/state-0.ll').read_bytes()==(reference/'state-0.ll').read_bytes()
assert (O/'result.ll').read_bytes()==(reference.parent/'v1.ll').read_bytes()
def trials(d):return {(t['version'],t['candidate']):t for t in [load(p) for p in d.glob('trial-*/trial.json')]}
old,new=trials(reference),trials(O/'debug');assert old.keys()==new.keys()
observed=accepted_growth=0
for k,t in new.items():
    before=old[k]
    for field in ['valid','eligible','control_hash','cleaned_hash']:assert t[field]==before[field],(k,field)
    s=t['score_result'];m=s['metrics']
    if s['status']=='scored':
        assert s['liveness_penalty_applied']==0
        assert s['total']==before['score_result']['total']
        assert m['pressure_weight']==0
        assert 'pressure_after_slots32' in m
        observed+=1
        accepted_growth+=int(t['eligible'] and m['pressure_after_slots32']>m['pressure_before_slots32'])
assert observed>0 and accepted_growth>0
assert [load(p)['candidate'] for p in sorted(reference.glob('commit-*.json'))]==[load(p)['candidate'] for p in sorted((O/'debug').glob('commit-*.json'))]
summary={'status':'passed','trials':len(new),'scored_with_pressure_features':observed,'eligible_despite_pressure_growth':accepted_growth,'same_final_ir':True,'same_accept_sequence':True,'default_pressure_weight':0,'scope':'fixed Map-Airy full-search ablation; no GPU requests and no runtime superiority claim'}
(O/'summary.json').write_text(json.dumps(summary,indent=2)+'\n');print(json.dumps(summary))
