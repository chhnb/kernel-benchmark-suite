import importlib.util,json,tempfile,unittest
from pathlib import Path
spec=importlib.util.spec_from_file_location("labels",Path(__file__).resolve().parents[2]/"tools/postopt_labels.py")
labels=importlib.util.module_from_spec(spec);spec.loader.exec_module(labels)
class Labels(unittest.TestCase):
 def test_complete_incomplete_and_binary_change(self):
  with tempfile.TemporaryDirectory() as d:
   root=Path(d)
   for batch in range(3):
    for side,time in [("baseline",100),("variant",80)]:
     p=root/f"x-{side}-batch-{batch}";(p/"output/0").mkdir(parents=True)
     (p/"accepted.json").write_text(json.dumps({"passed":True,"phase":"benchmark","timing_mode":"event","input_snapshot":{"input":[1,2]},"binary_snapshot":{side:[1,2]}}))
     (p/"output/0/samples.csv").write_text("round,warmup,microseconds,timing,full_output_passed\n0,1,999,event,1\n1,0,"+str(time)+",event,1\n")
   report=labels.summarize(root,"x",3,.02)
   self.assertEqual(report["inputs"]["0"]["label"],"beneficial")
   receipt=root/"x-variant-batch-2/accepted.json"
   old=receipt.read_text();receipt.unlink()
   self.assertEqual(labels.summarize(root,"x",3,.02)["inputs"]["0"]["label"],"unlabeled_incomplete")
   data=json.loads(old);data["binary_snapshot"]={"changed":[1,2]};receipt.write_text(json.dumps(data))
   self.assertEqual(labels.summarize(root,"x",3,.02)["status"],"incomplete_no_label")
 def test_tigre_projection_batches(self):
  with tempfile.TemporaryDirectory() as d:
   p=Path(d);(p/"output/0").mkdir(parents=True)
   (p/"accepted.json").write_text(json.dumps({"passed":True,"phase":"benchmark","timing_mode":"event","binary_snapshot":{"/path/bench_tigre":[1,2]}}))
   (p/"output/0/timing.csv").write_text("round,variant,batch,warmup,ms\n"+"".join(f"0,baseline,{i},0,1.5\n" for i in range(6)))
   receipt,samples=labels.read_batch(p)
   self.assertEqual(len(samples),6)
   self.assertEqual(samples["0:projection_batch2"]["median_us"],1500)
 def test_fluid_checks_and_units(self):
  with tempfile.TemporaryDirectory() as d:
   p=Path(d);(p/"output/0/hypersonic-1").mkdir(parents=True)
   (p/"accepted.json").write_text(json.dumps({"passed":True,"phase":"benchmark","timing_mode":"event","binary_snapshot":{"/path/bench_hypersonic":[1,2]}}))
   log=p/"output/0/hypersonic-1/checks.jsonl"
   r={"round":0,"measurement":True,"milliseconds":2,"slot":0,"role":"baseline","pass":True,"guards":True,"readonly":True,"mismatches":0,"negatives":0}
   log.write_text(json.dumps(r)+"\n")
   self.assertEqual(labels.read_batch(p)[1]["0:hypersonic-1"]["median_us"],2000)
   r["guards"]=False;log.write_text(json.dumps(r)+"\n")
   with self.assertRaises(ValueError):labels.read_batch(p)
if __name__=="__main__":unittest.main()
