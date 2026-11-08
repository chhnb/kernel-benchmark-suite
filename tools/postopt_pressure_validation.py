#!/usr/bin/env python3
"""Offline IR-pressure/resource associations; never used by candidate scoring."""
import argparse
import collections
import hashlib
import json
import math
from pathlib import Path
from postopt_resources import collect

def ranks(values):
    ordered=sorted(range(len(values)),key=values.__getitem__)
    result=[0.0]*len(values);start=0
    while start<len(ordered):
        end=start+1
        while end<len(ordered) and values[ordered[end]]==values[ordered[start]]:end+=1
        for i in ordered[start:end]:result[i]=(start+end-1)/2
        start=end
    return result

def correlation(x,y):
    if len(x)<2:return None
    x=ranks(x);y=ranks(y)
    mx=sum(x)/len(x);my=sum(y)/len(y)
    denominator=math.sqrt(sum((v-mx)**2 for v in x)*sum((v-my)**2 for v in y))
    return sum((a-mx)*(b-my) for a,b in zip(x,y))/denominator if denominator else None

def association(rows,pressure,resource):
    pairs=[(r['pressure_delta'][pressure],r['resource_delta'][resource]) for r in rows
           if r['pressure_delta'][pressure] is not None and r['resource_delta'][resource] is not None]
    sign=lambda v:(v>0)-(v<0)
    nonzero=[(x,y) for x,y in pairs if x or y]
    return {'n':len(pairs),'spearman':correlation([x for x,y in pairs],[y for x,y in pairs]),
            'nonzero_change_pairs':len(nonzero),'same_sign_excluding_both_zero':sum(sign(x)==sign(y) for x,y in nonzero)/len(nonzero) if nonzero else None,
            'both_zero':len(pairs)-len(nonzero),'positive_ir_but_nonpositive_resource':sum(x>0 and y<=0 for x,y in pairs),
            'nonpositive_ir_but_positive_resource':sum(x<=0 and y>0 for x,y in pairs)}

def main():
    p=argparse.ArgumentParser();p.add_argument('--pair',type=Path,action='append',required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
    rows=[];seen=set();duplicates=[]
    for pair in a.pair:
        pair=pair.resolve();m=json.loads((pair/'manifest.json').read_text());t=m.get('trial')
        if not t:raise ValueError('single candidate trial required: '+str(pair))
        identity=(t['parent_hash'],t['candidate'],t['cleaned_hash'])
        if identity in seen:duplicates.append(str(pair));continue
        seen.add(identity)
        r=collect(pair);metrics=r['ir'];d={}
        for name,prefix in [('total','pressure'),('uniform','pressure_uniform'),('unproven','pressure_unproven')]:
            before=metrics.get(prefix+'_before_slots32');after=metrics.get(prefix+'_after_slots32')
            d[name]=after-before if before is not None and after is not None else None
        spills={}
        for kind in ('sgpr','vgpr'):
            key=kind+'_spill_count';before=r['backend']['baseline'][key];after=r['backend']['variant'][key]
            spills[kind]=None if before is None or after is None else before==0 and after>0
        rows.append({'case':m['case'],'candidate':t['candidate'],'pair':str(pair),'manifest_sha256':hashlib.sha256((pair/'manifest.json').read_bytes()).hexdigest(),
                     'identity':identity,'pressure_delta':d,'resource_delta':r['delta'],'backend':r['backend'],'new_spill':spills})
    groups={}
    for case in sorted({r['case'] for r in rows}):
        subset=[r for r in rows if r['case']==case]
        groups[case]={name:association(subset,pressure,resource) for name,pressure,resource in
                      [('total_vs_vgpr','total','vgpr_count'),('unproven_vs_vgpr','unproven','vgpr_count'),('uniform_vs_sgpr','uniform','sgpr_count')]}
    result={'schema':'postopt-pressure-offline-validation-v1','scope':'Exploratory within-case association; IR uniform/unproven values are not physical SGPR/VGPR allocations. Backend follows additional O3. No occupancy or runtime inference.',
            'rows':rows,'within_case':groups,'duplicates_excluded':duplicates,
            'spill_coverage':{kind:{'known':sum(r['new_spill'][kind] is not None for r in rows),'new_spill_candidates':sum(r['new_spill'][kind] is True for r in rows),
                 'ir_total_increase_detected':sum(r['new_spill'][kind] is True and (r['pressure_delta']['total'] or 0)>0 for r in rows)} for kind in ('sgpr','vgpr')}}
    with a.out.open('x') as f:json.dump(result,f,indent=2)
    print(json.dumps({'pairs':len(rows),'within_case':groups,'spill_coverage':result['spill_coverage']},indent=2))
if __name__=='__main__':main()
