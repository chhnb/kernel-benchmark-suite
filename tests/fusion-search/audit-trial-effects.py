#!/usr/bin/env python3
"""Describe observed fusion/cleanup writes; NEVER a cache-validity certificate.
Uses retained LLVM textual block names. Numeric slots or nonunique shape matches
are reported explicitly; this audit does not invent lineage across renumbering.
"""
import argparse, collections, importlib.util, json, re
from pathlib import Path
spec=importlib.util.spec_from_file_location('trace_ir',Path(__file__).with_name('audit-score-reuse.py'))
ir=importlib.util.module_from_spec(spec);spec.loader.exec_module(ir)
MEM=re.compile(r'\b(load|store|call|invoke|atomicrmw|cmpxchg|fence)\b')
def body(line):
    return line.split(';',1)[0].strip()
def phi_order_normalized(line):
    if ' = phi ' not in line:return line
    start=line.find('[')
    if start<0:return line
    tail=line[start:]
    entries=re.findall(r'\[[^\[\]]*\]',tail)
    # Only normalize simple flat incoming lists, not aggregate constants.
    if not entries or re.sub(r'\[[^\[\]]*\]', '', tail).strip(' ,'):return line
    return line[:start]+', '.join(sorted(entries))
def snapshot(path,fn):
    blocks,defs,mapping,uses,args=ir.parse(path,fn)
    return {b[0][0]:[body(line) for _,line in b[1:]] for b in blocks}
def compare(old,new,arms):
    common=old.keys() & new.keys()
    changed=sorted(k for k in common if old[k]!=new[k])
    deleted=sorted(old.keys()-new.keys());added=sorted(new.keys()-old.keys())
    details=[]
    for k in changed:
        a,b=old[k],new[k]
        removed=list((collections.Counter(a)-collections.Counter(b)).elements())
        inserted=list((collections.Counter(b)-collections.Counter(a)).elements())
        delta=removed+inserted
        details.append(dict(block=k,in_original_arms=k in arms,
            terminator_changed=bool(a and b and a[-1]!=b[-1]),
            phi_changed=any(re.search(r'\bphi\b',x) for x in delta),
            memory_changed=any(MEM.search(x) for x in delta),
            removed=removed,inserted=inserted))
    semantic_changed=[k for k in changed if
        [phi_order_normalized(x) for x in old[k]] != [phi_order_normalized(x) for x in new[k]]]
    numeric=any(k[1:].isdigit() for k in old.keys()|new.keys())
    return dict(changed=len(changed),changed_excluding_phi_order=len(semantic_changed),deleted=len(deleted),added=len(added),
        unchanged=sum(old[k]==new[k] for k in common),
        name_based_observation_only=True,numeric_slot_ambiguity=numeric,
        changed_blocks=details,deleted_blocks=deleted,added_blocks=added)
def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('trace',type=Path);ap.add_argument('--out',type=Path,required=True)
    args=ap.parse_args();summary=json.loads((args.trace/'summary.json').read_text())
    rows=[];totals=collections.Counter();previous={};transitions=[]
    for index,r in enumerate(summary['rounds']):
        current={}
        for a in r['attempts']:
            totals['enumerated']+=1;totals['stage_'+a.get('stage','unknown')]+=1
            if a.get('stage')=='scored':
                key=a['candidate'];current[key]=(a.get('gain'),a.get('eligible'),a['directory'])
                if key in previous:
                    totals['same_numbered_candidate_again']+=1
                    before=previous[key];after=current[key]
                    totals['same_numbered_candidate_gain_changed' if before[:2]!=after[:2] else 'same_numbered_candidate_gain_unchanged']+=1
                    if before[:2]!=after[:2]:transitions.append(dict(round=index,candidate=key,before=before,after=after))
        previous=current
        if not r['selected']:continue
        chosen=next(a for a in r['attempts'] if a['directory']==r['selected'])
        base=Path(r['selected'])/'structural';detail=base/'trial-0'
        trial=json.loads((detail/'trial.json').read_text());fn=chosen['candidate'].rsplit(':',3)[0]
        arms=set(trial['left']['blocks']+trial['right']['blocks'])
        paths=[base/'state-0.ll',detail/'after-raw.ll',detail/'after.ll']
        control=base/'round-0-control.ll'
        missing=[str(p) for p in [*paths,control] if not p.exists()]
        if missing:
            row=dict(round=index,missing=missing)
            if trial.get('snapshot_mode')=='compact':
                row['diagnostic']='Replay the request or rerun decision-greedy with --ir-snapshots full'
            rows.append(row)
            continue
        a,b,c=[snapshot(p,fn) for p in paths]
        rows.append(dict(round=index,candidate=chosen['candidate'],directory=r['selected'],
            fusion_kind=trial['fusion_plan']['kind'],gain=chosen['gain'],
            input=str(paths[0]),driver_parent=r['parent'],
            preparation_separate=str(paths[0])!=r['parent'],
            fusion=compare(a,b,arms),cleanup=compare(b,c,arms),
            cleaned_control_to_result=compare(snapshot(control,fn),c,arms)))
    result=dict(schema='observed-trial-effects-v1',proof_of_independence=False,
        caveats=['Numeric B indices in adjacent rounds are NOT stable candidate identity.',
                 'Retained textual names are observations, not SSA lineage certificates.',
                 'Raw IR may already include internal melder cleanup.',
                 'Write sets do not bound pass read dependencies.'],
        counters=dict(totals),changed_gain_observations=transitions,commits=rows)
    args.out.parent.mkdir(parents=True,exist_ok=True)
    args.out.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(commits=len(rows),counters=dict(totals),output=str(args.out)),indent=2))
if __name__=='__main__':main()
