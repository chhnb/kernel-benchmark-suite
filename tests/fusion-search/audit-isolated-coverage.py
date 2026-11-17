#!/usr/bin/env python3
"""Read-only frozen-input coverage audit; never authorizes cached score reuse."""
import argparse,collections,gzip,hashlib,json,os,subprocess,tempfile
from pathlib import Path
root=Path(__file__).resolve().parents[2]
ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--tool',type=Path,required=True);ap.add_argument('--out',type=Path,required=True);args=ap.parse_args()
env=dict(os.environ);env['LD_LIBRARY_PATH']=str(root/'build/llvm12-jammy/usr/lib/x86_64-linux-gnu')+':'+env.get('LD_LIBRARY_PATH','')
base=root/'regression/greedy-v1';manifest=json.loads((base/'manifest.json').read_text());rows=[]
with tempfile.TemporaryDirectory(prefix='isolated-coverage-') as temp:
 path=Path(temp)/'input.ll'
 for case in manifest['cases']:
  data=gzip.decompress((base/case['input']).read_bytes())
  assert hashlib.sha256(data).hexdigest()==case['input_sha256'],case['case']
  path.write_bytes(data)
  result=json.loads(subprocess.check_output([str(args.tool.resolve()),str(path),case['function']],env=env,text=True));result['case']=case['case'];rows.append(result)
args.out.parent.mkdir(parents=True,exist_ok=True);args.out.write_text(json.dumps(rows,indent=2)+'\n')
reasons=collections.Counter()
for row in rows:reasons.update(row['rejections'])
print(json.dumps(dict(cases=len(rows),roots=sum(r['conditional_roots'] for r in rows),units=sum(r['isolatable_units'] for r in rows),tti_domain=sum(r['whole_function_tti_domain'] for r in rows),rejections=dict(reasons),admitted=[(r['case'],r['isolatable_units']) for r in rows if r['isolatable_units']]),indent=2))
