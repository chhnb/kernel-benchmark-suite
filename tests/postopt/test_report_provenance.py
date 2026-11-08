import hashlib,json
from pathlib import Path
import subprocess,sys,tempfile,unittest
TOOL=Path(__file__).resolve().parents[2]/'tools/postopt_report.py'
class ReportProvenance(unittest.TestCase):
 def invoke(self,change=None,legacy=False,replay=False,wrong_control=False,confirmation=False,bad_plan=False):
  with tempfile.TemporaryDirectory() as tmp:
   d=Path(tmp);(d/'trial-0').mkdir()
   run={'schema':'postopt-scoring-run-v1','mode':'explicit_pair','policy':'v2','initial_parent_hash':'parent','work_absolute':0,'work_relative':0,'pressure_weight':.1}
   t={'version':0,'candidate':'candidate','parent_hash':'parent','cleaned_hash':'clean','control_hash':'control','valid':True,'eligible':True,'original_darm_profitable':False,'score_result':{'status':'scored','reason':'pass','coverage':{},'metrics':{'absolute_threshold':0,'relative_threshold':0,'pressure_weight':.1},'static_gain':2,'static_score':.2},'timings_ms':{'trial_total':1,'score_with_analysis':1}}
   if replay:run['replay_parent_hash']='a'*40
   if change:change(run,t)
   if legacy:(d/'result.json').write_text(json.dumps({'policy':'v2'}))
   else:(d/'run.json').write_text(json.dumps(run))
   (d/'trial-0/trial.json').write_text(json.dumps(t))
   extra=[]
   if replay:
    pair=d/'pair';pair.mkdir();measure=d/'measure';measure.mkdir()
    (pair/'manifest.json').write_text(json.dumps({'trial':{'candidate':'candidate','parent_hash':'a'*40,'cleaned_hash':'clean','control_hash':'wrong' if wrong_control else 'control'}}))
    (measure/'plan.json').write_text(json.dumps({'pair':str(pair)}))
    (measure/'labels.json').write_text(json.dumps({'status':'complete_screening','inputs':{'0':{'label':'beneficial','mean_log_ratio':.1}}}))
    extra=['--measure',str(measure)]
    if confirmation:
     labels=json.loads((measure/'labels.json').read_text());labels.update(status='complete_confirmation',schema='postopt-confirmation-v1',measurement_plan_sha256='0'*64 if bad_plan else hashlib.sha256((measure/'plan.json').read_bytes()).hexdigest())
     derived=d/'confirmation.json';derived.write_text(json.dumps(labels));extra+=['--labels-file',str(derived)]

   result=subprocess.run([sys.executable,str(TOOL),'--debug',str(d),'--out',str(d/'report.json'),*extra],capture_output=True,text=True)
   return result,json.loads((d/'report.json').read_text()) if (d/'report.json').exists() else None
 def test_explicit_run_without_greedy_result(self):
  r,data=self.invoke();self.assertEqual(r.returncode,0,r.stderr);self.assertEqual(data['run']['mode'],'explicit_pair')
 def test_legacy_greedy_record_remains_supported(self):
  r,data=self.invoke(legacy=True);self.assertEqual(r.returncode,0,r.stderr);self.assertEqual(data['run']['mode'],'legacy_greedy_record')
 def test_wrong_parent_is_rejected(self):
  r,data=self.invoke(lambda run,t:run.update(initial_parent_hash='other'));self.assertNotEqual(r.returncode,0);self.assertIn('parent mismatch',r.stderr);self.assertIsNone(data)
 def test_wrong_parameter_is_rejected(self):
  r,data=self.invoke(lambda run,t:run.update(pressure_weight=.2));self.assertNotEqual(r.returncode,0);self.assertIn('parameter mismatch',r.stderr);self.assertIsNone(data)
 def test_v1_cannot_masquerade_as_v2(self):
  r,data=self.invoke(lambda run,t:run.update(policy='v1'));self.assertNotEqual(r.returncode,0);self.assertIn('requires v2',r.stderr);self.assertIsNone(data)
 def test_authenticated_replay_origin_binds_exact_pair(self):
  r,data=self.invoke(replay=True);self.assertEqual(r.returncode,0,r.stderr)
  self.assertEqual(data['unmatched_measurements'],[])
  self.assertEqual(data['candidates'][0]['identity_parent_hash'],'a'*40)
  self.assertIn('authenticated_snapshot',data['candidates'][0]['measurements'][0]['identity_binding'])
 def test_replay_cannot_bind_different_control(self):
  r,data=self.invoke(replay=True,wrong_control=True);self.assertEqual(r.returncode,0,r.stderr)
  self.assertEqual(len(data['unmatched_measurements']),1)
  self.assertEqual(data['candidates'][0]['measurements'],[])
 def test_confirmation_binds_plan_and_contributes_labels(self):
  r,data=self.invoke(replay=True,confirmation=True);self.assertEqual(r.returncode,0,r.stderr)
  self.assertEqual(data['summary']['v2']['definite_candidate_inputs'],1)
  self.assertEqual(data['candidates'][0]['measurements'][0]['label_schema'],'postopt-confirmation-v1')
 def test_confirmation_wrong_plan_rejected(self):
  r,data=self.invoke(replay=True,confirmation=True,bad_plan=True);self.assertNotEqual(r.returncode,0)
  self.assertIn('do not bind',r.stderr);self.assertIsNone(data)
if __name__=='__main__':unittest.main()
