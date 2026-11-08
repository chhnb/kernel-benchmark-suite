import unittest,sys,copy,struct,hashlib
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[2]/'tools'))
from postopt_weighted_bounds import BDD,evaluate
class Bounds(unittest.TestCase):
 def setUp(self):
  self.c=dict(before_ir_sha1='before',after_ir_sha1='after',parent_ir_sha1='parent',target_cpu='gfx906',bdd_nodes=[[2**32-1,0,0],[2**32-1,1,1],[0,0,1],[0,1,0],[1,0,1],[0,0,4]],before={'left':2,'right':3},after={'merged':1},parent_blocks={'B1':2,'B2':3},parent_splits={})
  self.w=dict(candidate='k:B0:B1:B2',snapshots={'before':'before','after':'after'})
  def features(blocks):return dict(target_available=True,unknown=0,work=sum(w for _,w in blocks),blocks=[dict(block=n,work=w) for n,w in blocks])
  self.f={'before':features([('left',10),('right',10)]),'after':features([('merged',12)])}
  self.p=dict(schema='postopt-profile-v1',event_kind='selected_block_union',selected_blocks=['B1','B2'],candidate=self.w['candidate'],parent_hash='parent',target='gfx906',wave_size=64,records=[dict(workload_id='input',counts=[100,80,70,50],launched_waves=100,counter_sha256=hashlib.sha256(struct.pack('<4Q',100,80,70,50)).hexdigest())])
 def run_case(self,profiles=None):return evaluate(self.c,self.w,self.f,[self.p] if profiles is None else profiles,'input',1)
 def test_boolean_algebra(self):
  b=BDD(self.c['bdd_nodes'])
  def value(root,bits):
   while root>1:
    v,l,h=b.nodes[root];root=h if bits[v] else l
   return root
  for a in range(6):
   for c in range(6):
    for op in range(3):
     result=b.op(op,a,c)
     for bits in [(0,0),(0,1),(1,0),(1,1)]:
      x,y=value(a,bits),value(c,bits);self.assertEqual(value(result,bits),[x&y,x|y,x^y][op])
    self.assertEqual(b.subset(a,c),all(not value(a,v) or value(c,v) for v in [(0,0),(0,1),(1,0),(1,1)]))
 def test_exact(self):
  r=self.run_case();self.assertEqual((r['gain_lower'],r['gain_upper']),(300,300));self.assertEqual(r['proxy_direction'],'positive');self.assertIsNone(r['decision'])
 def test_unknown_subset(self):
  self.c['after']['extra']=5;self.f['after']['blocks'].append(dict(block='extra',work=4));self.f['after']['work']+=4
  r=self.run_case();self.assertEqual((r['gain_lower'],r['gain_upper']),(-20,300));self.assertEqual(r['proxy_direction'],'unresolved')
  term=next(x for x in r['terms'] if x['root']==5);self.assertEqual((term['visits_lower'],term['visits_upper']),(0,80))
 def test_both_is_not_lane_intersection(self):
  b=BDD(self.c['bdd_nodes']);self.assertEqual(b.op(0,2,3),0);self.assertEqual(self.p['records'][0]['counts'][3],50);self.assertEqual(self.run_case()['status'],'bounded_work_proxy')
 def test_missing(self):self.assertEqual(self.run_case([])['reason'],'profile_missing')
 def test_unknown_cost(self):
  self.f['after']['unknown']=1;self.assertEqual(self.run_case()['reason'],'unknown_static_cost')
 def test_wrong_identity(self):
  self.c['after_ir_sha1']='wrong'
  with self.assertRaises(ValueError):self.run_case()
 def test_stale_profile(self):
  self.p['parent_hash']='old';self.assertEqual(self.run_case()['reason'],'stale_parent_hash')
 def test_bad_partition(self):
  self.f['after']['work']+=1
  with self.assertRaises(ValueError):self.run_case()
 def test_multiple_visits(self):
  self.p['records'][0]['launched_waves']=50;self.assertEqual(self.run_case()['reason'],'multiple_wave_visits_not_modeled')
 def test_nonfinite_work(self):
  self.f['after']['blocks'][0]['work']=float('nan')
  with self.assertRaises(ValueError):self.run_case()
if __name__=='__main__':unittest.main()
