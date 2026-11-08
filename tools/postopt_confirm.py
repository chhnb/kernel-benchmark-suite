#!/usr/bin/env python3
"""Predeclared nine-batch median-effect confirmation; separate from screening."""
import argparse,hashlib,json,math,statistics
from pathlib import Path
from postopt_labels import summarize

def interval(values,threshold):
    if len(values)!=9 or any(not math.isfinite(v) for v in values):raise ValueError('nine finite independent batch log ratios required')
    if not math.isfinite(threshold) or threshold<0:raise ValueError('invalid effect threshold')
    ordered=sorted(values);lower,upper=ordered[1],ordered[7]
    label='beneficial' if lower>threshold else 'harmful' if upper<-threshold else 'unclear'
    return {'log_ratios':values,'mean_log_ratio':statistics.mean(values),'median_log_ratio':statistics.median(values),
            'median_log_interval':[lower,upper],'observed_batch_range':[min(values),max(values)],'label':label}

def main():
    p=argparse.ArgumentParser();p.add_argument('--protocol',type=Path,required=True);p.add_argument('--measure',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
    protocol=json.loads(a.protocol.read_text());plan=json.loads((a.measure/'plan.json').read_text())
    if protocol['schema']!='postopt-confirmation-protocol-v1' or protocol['batches']!=9:raise ValueError('unsupported frozen protocol')
    for key in ['batches','warmup','repeat','minimum_log_effect','binary_sha256']:
        if plan[key]!=protocol[key]:raise ValueError('measurement/protocol mismatch: '+key)
    data=summarize(a.measure,'paired',9,protocol['minimum_log_effect'])
    result={'schema':'postopt-confirmation-v1','protocol_sha256':hashlib.sha256(a.protocol.read_bytes()).hexdigest(),
            'measurement_plan_sha256':hashlib.sha256((a.measure/'plan.json').read_bytes()).hexdigest(),
            'scope':'single-candidate independent measurement confirmation; selected after exploratory screening, not a held-out program family',
            'interval_method':'order statistics 2 and 8 of 9 batch log ratios; population median effect',
            'per_input_coverage_under_independent_batches':1-2*(math.comb(9,0)+math.comb(9,1))/2**9,
            'coverage_limitations':'Requires independent identically distributed batch effects; no model-confidence interpretation, no joint multiple-input coverage claim',
            'minimum_log_effect':protocol['minimum_log_effect'],'issues':data['issues'],'inputs':{},
            'status':'complete_confirmation' if data['status']=='complete_screening' else 'incomplete_no_label'}
    if result['status']=='complete_confirmation':
        for key,value in data['inputs'].items():result['inputs'][key]=interval(value['log_ratios'],protocol['minimum_log_effect'])
    with a.out.open('x') as f:json.dump(result,f,indent=2)
    print(json.dumps({'status':result['status'],'inputs':result['inputs']},indent=2))
if __name__=='__main__':main()
