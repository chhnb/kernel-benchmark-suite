import unittest,sys,copy,struct,hashlib,json,subprocess,tempfile
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[2]/'tools'))
from postopt_profile import select,workload_id
class Profile(unittest.TestCase):
 def setUp(self):
  self.ctx=dict(parent_hash='parent',candidate='f:B1:B2:B3',target='gfx906',wave_size=64,workload='input',min_visits=10)
  self.data=dict(schema='postopt-profile-v1',parent_hash='parent',candidate='f:B1:B2:B3',target='gfx906',wave_size=64,records=[dict(workload_id='input',counts=[100,80,70,50],launched_waves=200,counter_sha256=hashlib.sha256(struct.pack('<4Q',100,80,70,50)).hexdigest())])
 def choose(self,data=None,**ctx):return select(self.data if data is None else data,**(self.ctx|ctx))
 def test_matching(self):
  r=self.choose();self.assertEqual(r['status'],'profile_available');self.assertEqual(r['profile']['d'],.5);self.assertEqual(r['profile']['visits_per_launched_wave'],.5)
 def test_event_kind(self):
  self.data['event_kind']='selected_block_union'
  self.assertEqual(self.choose()['reason'],'wrong_event_kind')
  self.assertEqual(self.choose(event_kind='selected_block_union')['status'],'profile_available')
  with self.assertRaises(ValueError):self.choose(event_kind='unknown')
 def test_stale(self):
  for key,val in [('parent_hash','new'),('candidate','new'),('target','gfx90a'),('wave_size',32)]:
   self.assertEqual(self.choose(**{key:val})['reason'],'stale_'+key)
 def test_missing(self):
  self.assertEqual(select(None,**self.ctx)['reason'],'profile_missing')
 def test_unseen_input(self):self.assertEqual(self.choose(workload='unseen')['reason'],'workload_not_covered')
 def test_coverage(self):
  self.assertEqual(self.choose(min_visits=101)['reason'],'insufficient_visits')
  r=self.data['records'][0];r['counts']=[0]*4;r['counter_sha256']=hashlib.sha256(bytes(32)).hexdigest()
  self.assertEqual(self.choose()['reason'],'region_not_executed')
 def test_corrupt(self):
  self.data['records'][0]['counts'][0]=101
  self.assertEqual(self.choose()['reason'],'counter_hash_mismatch')
 def test_ambiguous(self):
  self.data['records']*=2;self.assertEqual(self.choose()['reason'],'ambiguous_workload')
 def test_malformed(self):
  for d in [{},[],{'schema':'postopt-profile-v1'}]:self.assertEqual(self.choose(d)['status'],'static_fallback')
 def test_bad_budget(self):
  for v in [0,-1,True,1.5]:
   with self.assertRaises(ValueError):self.choose(min_visits=v)
 def test_relocatable_workload(self):
  a=dict(original='/a/input.txt',original_sha256={'/a/input.txt':'spec','/a/input.bin':'bytes'})
  b=dict(original='/b/input.txt',original_sha256={'/b/input.bin':'bytes','/b/input.txt':'spec'})
  self.assertEqual(workload_id(a),workload_id(b));b['original_sha256']['/b/input.bin']='changed';self.assertNotEqual(workload_id(a),workload_id(b))
 def test_cli_missing(self):
  with tempfile.TemporaryDirectory() as d:
   p=Path(d);(p/'context.json').write_text(json.dumps(self.ctx))
   r=subprocess.run([sys.executable,str(Path(__file__).resolve().parents[2]/'tools/postopt_profile.py'),'select','--profile',str(p/'missing.json'),'--context',str(p/'context.json')],check=True,capture_output=True,text=True)
   self.assertEqual(json.loads(r.stdout)['reason'],'profile_missing')
if __name__=='__main__':unittest.main()
