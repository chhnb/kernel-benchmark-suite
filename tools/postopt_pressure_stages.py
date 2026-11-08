import argparse,json,subprocess,sys,hashlib
from pathlib import Path
root=Path(__file__).resolve().parents[1];sys.path.insert(0,str(root/'tools'))
from postopt_pressure_validation import association
parser=argparse.ArgumentParser(description='Compare scoring and final-O3 SSA pressure offline')
parser.add_argument('--resources',type=Path,required=True)
parser.add_argument('--out',type=Path,required=True)
args=parser.parse_args()
source=args.resources
data=json.loads(source.read_text());rows=[]
for item in data['rows']:
 pair=Path(item['pair']);manifest=json.loads((pair/'manifest.json').read_text());function=manifest['context']['function'];stages={}
 for stage,suffix in [('scoring',''),('final_o3','-final')]:
  values={}
  for side in ('baseline','variant'):
   ir=pair/(side+suffix+'.ll')
   result=subprocess.run([str(root/'build/fusion-search/postopt-pressure'),str(ir),function],capture_output=True,text=True,check=True)
   values[side]=json.loads(result.stdout)
   values[side]['ir_sha256']=hashlib.sha256(ir.read_bytes()).hexdigest()
  values['delta']=values['variant']['peak_slots32']-values['baseline']['peak_slots32'];stages[stage]=values
 assert stages['scoring']['delta']==item['pressure_delta']['total'],item['candidate']
 rows.append({**item,'stages':stages,'pressure_delta':{'total':stages['final_o3']['delta']}})
summary={}
for case in sorted({r['case'] for r in rows}):
 summary[case]={'scoring':data['within_case'][case]['total_vs_vgpr'],'final_o3':association([r for r in rows if r['case']==case],'total','vgpr_count')}
result={'scope':'Offline pipeline diagnostic; same SSA pressure implementation before and after final O3; no backend in scoring','scoring_reproduction':str(len(rows))+' candidate deltas exactly reproduced','within_case':summary,'rows':rows}
out=args.out
with out.open('x') as f:json.dump(result,f,indent=2)
print(json.dumps(summary,indent=2))
