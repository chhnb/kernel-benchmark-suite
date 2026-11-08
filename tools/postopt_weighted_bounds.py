#!/usr/bin/env python3
"""Offline V5 prototype: bounds on a profiled static-work proxy, never cycles.

All function blocks participate. Equal-condition work cancels. Unobserved
conditions use only subset/superset constraints; no independence assumption.
"""
import argparse,json,hashlib,math
from pathlib import Path
from postopt_profile import select
class BDD:
 def __init__(self,nodes):
  self.nodes=[tuple(x) for x in nodes];self.unique={tuple(n):i for i,n in enumerate(self.nodes) if i>1};self.cache={}
 def node(self,v,l,h):
  if l==h:return l
  k=(v,l,h)
  if k not in self.unique:
   if len(self.nodes)>=100000:raise ValueError("bdd_budget_exceeded")
   self.unique[k]=len(self.nodes);self.nodes.append(k)
  return self.unique[k]
 def op(self,op,a,b):
  if a>b:a,b=b,a
  k=(op,a,b)
  if k in self.cache:return self.cache[k]
  if b<2:return (a&b) if op==0 else (a|b) if op==1 else (a^b)
  av,al,ah=self.nodes[a];bv,bl,bh=self.nodes[b];v=min(av,bv)
  r=self.node(v,self.op(op,al if av==v else a,bl if bv==v else b),self.op(op,ah if av==v else a,bh if bv==v else b));self.cache[k]=r;return r
 def subset(self,a,b):return self.op(0,a,self.op(2,b,1))==0

def evaluate(conditions,work,features,profiles,workload,min_visits):
 if conditions['before_ir_sha1']!=work['snapshots']['before'] or conditions['after_ir_sha1']!=work['snapshots']['after']:raise ValueError('IR identities differ')
 if not conditions['parent_ir_sha1']:raise ValueError('original parent conditions required')
 bdd=BDD(conditions['bdd_nodes']);counts={0:0};launches=None;used=[]
 def record(root,count):
  if root in counts and counts[root]!=count:raise ValueError('inconsistent event counts')
  counts[root]=count
 for profile in profiles:
  kind=profile.get('event_kind','split_branch')
  selected=select(profile,parent_hash=conditions['parent_ir_sha1'],candidate=work['candidate'],target=conditions['target_cpu'],wave_size=64,workload=workload,min_visits=min_visits,event_kind=kind)
  if selected['status']!='profile_available':return dict(status='static_fallback',reason=selected['reason'],decision=None)
  row=next(x for x in profile['records'] if x['workload_id']==workload);waves=row['launched_waves']
  if launches is not None and launches!=waves:raise ValueError('launch mismatch')
  launches=waves
  if any(n>waves for n in row['counts']):return dict(status='static_fallback',reason='multiple_wave_visits_not_modeled',decision=None)
  n,l,r,_=row['counts']
  if kind=='split_branch':
   event=conditions['parent_splits'][work['candidate'].split(':')[1]];roots=[event['visits'],event['true_present'],event['false_present']]
  else:
   left,right=profile['selected_blocks'];lr=conditions['parent_blocks'][left];rr=conditions['parent_blocks'][right];roots=[bdd.op(1,lr,rr),lr,rr]
  for root,count in zip(roots,[n,l,r]):record(root,count)
  used.append(kind)
 if launches is None:return dict(status='static_fallback',reason='profile_missing',decision=None)
 record(1,launches)
 # Any measured subset relation must be respected by the supplied profiles.
 for a,na in counts.items():
  for b,nb in counts.items():
   if bdd.subset(a,b) and na>nb:raise ValueError('profile violates event inclusion')
 delta={};detail={}
 for stage,sign in [('before',1),('after',-1)]:
  data=features[stage]
  if not data['target_available'] or data['unknown']:return dict(status='static_fallback',reason='unknown_static_cost',decision=None)
  blocks={x['block']:x for x in data['blocks']}
  if len(blocks)!=len(data['blocks']) or any(not math.isfinite(x['work']) or x['work']<0 for x in blocks.values()):raise ValueError('invalid block work')
  if set(blocks)!=set(conditions[stage]):raise ValueError('block coverage differs')
  if sum(x['work'] for x in blocks.values())!=data['work']:raise ValueError('work partition differs')
  for name,block in blocks.items():
   root=conditions[stage][name];delta[root]=delta.get(root,0)+sign*block['work'];detail.setdefault(root,[]).append(dict(stage=stage,block=name,work=block['work']))
 lower=upper=0;terms=[]
 for root,coefficient in sorted(delta.items()):
  if coefficient==0:continue
  if root in counts:lo=hi=counts[root]
  else:
   lo=max(n for r,n in counts.items() if bdd.subset(r,root));hi=min(n for r,n in counts.items() if bdd.subset(root,r))
  if lo>hi:raise ValueError('inconsistent inferred bounds')
  lower+=coefficient*(lo if coefficient>0 else hi);upper+=coefficient*(hi if coefficient>0 else lo)
  terms.append(dict(root=root,work_delta=coefficient,visits_lower=lo,visits_upper=hi,measured=root in counts,blocks=detail[root]))
 return dict(status='bounded_work_proxy',candidate=work['candidate'],parent_hash=conditions['parent_ir_sha1'],workload_id=workload,profiles=used,launched_waves=launches,gain_lower=lower,gain_upper=upper,gain_per_wave_lower=lower/launches,gain_per_wave_upper=upper/launches,proxy_direction='positive' if lower>0 else 'negative' if upper<0 else 'unresolved',decision=None,terms=terms,coverage='whole-function static TTI work under reconverged wave-presence model; bounds are not runtime intervals or GPU scheduling proof')

def main():
 p=argparse.ArgumentParser();p.add_argument('--conditions',type=Path,required=True);p.add_argument('--work',type=Path,required=True);p.add_argument('--profile',type=Path,action='append',required=True);p.add_argument('--workload',required=True);p.add_argument('--min-visits',type=int,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
 c=json.loads(a.conditions.read_text());w=json.loads((a.work/'report.json').read_text());f={}
 for stage in ['before','after']:
  path=a.work/(stage+'.json')
  if hashlib.sha256(path.read_bytes()).hexdigest()!=w['feature_sha256'][stage]:raise ValueError('work feature digest mismatch')
  f[stage]=json.loads(path.read_text())
 result=evaluate(c,w,f,[json.loads(p.read_text()) for p in a.profile],a.workload,a.min_visits)
 result['conditions_sha256']=hashlib.sha256(a.conditions.read_bytes()).hexdigest()
 with a.out.open('x') as out:json.dump(result,out,indent=2);out.write('\n')
 print(result['status'],result.get('proxy_direction',result.get('reason')))
if __name__=='__main__':main()
