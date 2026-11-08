#!/usr/bin/env python3
"""Read validated, provenance-bound profile counters. No timing or scoring model."""
import argparse,hashlib,json,struct,math
from pathlib import Path
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def counters(raw):
 if len(raw)!=32:raise ValueError('expected four u64 counters')
 n,t,f,d=struct.unpack('<4Q',raw)
 if not (t<=n and f<=n and d<=min(t,f) and t-d==n-f):raise ValueError('inconsistent counters')
 return dict(visits=n,true_present=t,false_present=f,both_present=d,qT=t/n if n else None,qF=f/n if n else None,d=d/n if n else None,coverage='observed' if n else 'not_executed')
def report(root):
 root=root.resolve();m=json.loads((root/'manifest.json').read_text());binary=root/'profile.hsaco'
 if m['status']!='compiled_not_validated' or sha(binary)!=m['binary_sha256']:raise ValueError('binary mismatch')
 if sha(root/'parent.ll')!=m['source_sha256']:raise ValueError('snapshot mismatch')
 rows=[]
 for i,item in enumerate(m['inputs']):
  spec=Path(item['derived']);capture=root/f'capture-{i}'
  if sha(spec)!=item['derived_sha256']:raise ValueError('derived input changed')
  for path,h in item['original_sha256'].items():
   if sha(Path(path))!=h:raise ValueError('original input changed')
  accepted=json.loads((capture/'accepted.json').read_text());terminal=json.loads((capture/'terminal.json').read_text());admission=json.loads((capture/'admission.json').read_text());result=json.loads((capture/'output/0/result.json').read_text())
  if not (accepted['passed'] and accepted['phase']=='validate' and accepted['timing_mode']=='event' and terminal['exit']==0 and admission and all(p['admitted'] for p in admission) and result['passed'] and result['launches']==1):raise ValueError('validation/admission missing')
  if str(binary) not in accepted['binary_snapshot']:raise ValueError('wrong validated binary')
  expected_inputs={str(spec.resolve())}
  for line in spec.read_text().splitlines():
   parts=line.split()
   if not parts or parts[0].startswith('#'):continue
   refs=([parts[2]]+([parts[4]] if parts[4]!='-' else [])) if parts[0]=='buffer' else [parts[2]] if parts[0]=='exactref' or parts[:2]==['arg','file'] else []
   expected_inputs.update(str((spec.parent/name).resolve()) for name in refs)
  if set(accepted['input_snapshot'])!=expected_inputs:raise ValueError('wrong validated input')
  for path,stamp in {**accepted['binary_snapshot'],**accepted['input_snapshot']}.items():
   stat=Path(path).stat()
   if [stat.st_size,stat.st_mtime_ns]!=stamp:raise ValueError('validated artifact changed')
  lines=[line.split() for line in spec.read_text().splitlines()];grid=next(x[1:] for x in lines if x[:1]==['grid']);block=next(x[1:] for x in lines if x[:1]==['block']);waves=math.prod(map(int,grid))*((math.prod(map(int,block))+63)//64)
  raw=capture/'output/0/wave-profile.bin';row=counters(raw.read_bytes());row.update(input=item['original'],launched_waves=waves,visits_per_launched_wave=row['visits']/waves,counter_sha256=sha(raw),validation_receipt_sha256=sha(capture/'accepted.json'));rows.append(row)
 return dict(schema='postopt-wave-report-v0',event_kind=m.get('event_kind','split_branch'),selected_blocks=m.get('selected_blocks'),candidate=m['candidate'],parent_hash=m['parent_hash'],manifest_sha256=sha(root/'manifest.json'),performance_use=False,scope='diagnostic profile only; no learned threshold or deployment decision',inputs=rows)
def main():
 p=argparse.ArgumentParser();p.add_argument('--profile',required=True,type=Path);p.add_argument('--out',required=True,type=Path);a=p.parse_args();r=report(a.profile)
 with a.out.open('x') as f:json.dump(r,f,indent=2);f.write('\n')
if __name__=='__main__':main()
