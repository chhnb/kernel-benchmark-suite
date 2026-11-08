#!/usr/bin/env python3
import argparse,json,os,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();s=p.add_subparsers(dest='action',required=True);s.add_parser('list')
b=s.add_parser('build');b.add_argument('case');b.add_argument('--profile',required=True);b.add_argument('--out',required=True);b.add_argument('--admitted',action='store_true',help=argparse.SUPPRESS)
a=p.parse_args()
if a.action=='list':
 for f in sorted((ROOT/'cases').glob('*/case.json')):
  j=json.loads(f.read_text());print(j['name'],','.join(j['profiles']) or 'pending',j['status'], 'ACTIVE' if j.get('enabled',True) else 'INACTIVE')
 sys.exit(0)
case=ROOT/'cases'/a.case; m=json.loads((case/'case.json').read_text());profile=m['profiles'][a.profile]
out=Path(a.out).resolve()
if out.exists():raise SystemExit('Output must be new')
if not a.admitted:
 label='benchmark-suite-'+a.case+'-'+a.profile+'-'+str(time.time_ns())
 cmd=[sys.executable,'/home/chh/region-fusion-lab/work/run-cpu.py',label,sys.executable,str(Path(__file__).resolve()),'build',a.case,'--profile',a.profile,'--out',str(out),'--admitted']
 raise SystemExit(subprocess.call(cmd))
out.mkdir(parents=True)
cmd=[x.replace('{case}',str(case)).replace('{out}',str(out)) for x in profile['argv']]
(out/'command.json').write_text(json.dumps(cmd,indent=2));t=time.time()
with (out/'build.stdout').open('w') as o,(out/'build.stderr').open('w') as e:
 rc=subprocess.run(cmd,cwd=case,stdout=o,stderr=e,timeout=1200).returncode
artifact=out/profile['artifact']; receipt={'case':a.case,'profile':a.profile,'exit_code':rc,'seconds':time.time()-t,'artifact_exists':artifact.is_file(),'gpu_validated':False,'timing_performed':False}
if rc==0 and profile['kind']=='llvm-ir':
 verify=[x.replace('{artifact}',str(artifact)) for x in profile.get('verify_argv',['/home/chh/region-fusion-lab/toolchains/llvm12/amd-bootstrap/bin/opt','-verify','-disable-output','{artifact}'])]
 v=subprocess.run(verify,capture_output=True,text=True);receipt['llvm_verifier_exit']=v.returncode
 (out/'verify.stderr').write_text(v.stderr);rc=v.returncode
receipt['build_passed']=rc==0 and artifact.is_file();(out/'receipt.json').write_text(json.dumps(receipt,indent=2));print(json.dumps(receipt))
raise SystemExit(0 if receipt['build_passed'] else 1)
