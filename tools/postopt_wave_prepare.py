#!/usr/bin/env python3
"""Prepare a separate wave64 profile binary; original data/oracles stay immutable."""
import argparse,hashlib,json,subprocess,sys,time,shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
BIN=Path('/home/chh/region-fusion-lab/toolchains/llvm12/amd-bootstrap/bin')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--trial',type=Path,required=True);p.add_argument('--case',required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--selected-blocks',action='store_true');p.add_argument('--admitted',action='store_true');a=p.parse_args()
 if not a.admitted:
  return subprocess.call([sys.executable,'/home/chh/region-fusion-lab/work/run-cpu.py','wave-profile-'+str(time.time_ns()),sys.executable,str(Path(__file__).resolve()),'--trial',str(a.trial.resolve()),'--case',a.case,'--out',str(a.out.resolve()),'--admitted']+(['--selected-blocks'] if a.selected_blocks else []))
 t=a.trial.resolve();r=json.loads((t/'trial.json').read_text());source=(t/r['parent_ir']).resolve()
 assert r['valid'] and hashlib.sha1(source.read_bytes()).hexdigest()==r['parent_hash']
 candidate=r['candidate'];fn,split,left,right=candidate.split(':');assert split.startswith('B')
 if a.selected_blocks:
  assert left.startswith('B') and right.startswith('B'), 'selected-block profile requires block candidates'
  if r['orientation_swapped']:left,right=right,left
 case=ROOT/'cases'/a.case;rt=json.loads((case/'case.json').read_text())['runtime'];assert rt['backend']=='amd'
 d=a.out.resolve();d.mkdir(parents=True,exist_ok=False);shutil.copyfile(source,d/'parent.ll')
 m=dict(schema='postopt-wave-profile-v0',status='preparing',candidate=candidate,parent_hash=r['parent_hash'],source_sha256=sha(source),wave_size=64,target='gfx906',function=fn,split=split,counters=['visits','true_present','false_present','both_present'],commands=[],inputs=[],performance_use=False)
 m['event_kind']='selected_block_union' if a.selected_blocks else 'split_branch'
 if a.selected_blocks:m['selected_blocks']=[left,right]
 def save(): (d/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
 def run(cmd):
  cmd=list(map(str,cmd));m['commands'].append(cmd);save();subprocess.run(cmd,check=True,timeout=600)
 save()
 try:
  instrumenter=ROOT/'build/fusion-search'/('postopt-pair-profile' if a.selected_blocks else 'postopt-wave-profile')
  run([instrumenter,d/'parent.ll',fn,split[1:],d/'instrumented.ll']+([left[1:],right[1:]] if a.selected_blocks else []))
  run([BIN/'opt',d/'instrumented.ll','-O3','-verify-each','-S','-o',d/'final.ll'])
  run([BIN/'llc',d/'final.ll','-O3','-mtriple=amdgcn-amd-amdhsa','-mcpu=gfx906','-mattr=+sram-ecc,-xnack','-filetype=obj','-o',d/'profile.o'])
  run(['/opt/rocm/llvm/bin/ld.lld','-shared',d/'profile.o','-o',d/'profile.hsaco'])
  for i,name in enumerate(rt['inputs']):
   original=(case/name).resolve();assert original.name=='input.txt';out=d/'inputs'/str(i);out.mkdir(parents=True);lines=[];files={str(original):sha(original)}
   for line in original.read_text().splitlines():
    parts=line.split()
    if parts and parts[0]=='buffer':
     assert parts[1]!='wave_profile'
     for j in [2,4]:
      if parts[j]!='-':
       q=(original.parent/parts[j]).resolve();parts[j]=str(q);files[str(q)]=sha(q)
    elif parts and (parts[0]=='exactref' or parts[:2]==['arg','file']):
     q=(original.parent/parts[2]).resolve();parts[2]=str(q);files[str(q)]=sha(q)
    lines.append(' '.join(parts))
   (out/'zeros.bin').write_bytes(bytes(32));lines+=['buffer wave_profile zeros.bin profile_u64 - 0 0','arg ptr wave_profile']
   (out/'input.txt').write_text('\n'.join(lines)+'\n');m['inputs'].append(dict(original=str(original),derived=str(out/'input.txt'),original_sha256=files,derived_sha256=sha(out/'input.txt')))
  assert sha(source)==m['source_sha256'];m['binary_sha256']=sha(d/'profile.hsaco');m['tool_sha256']=sha(instrumenter);m['instrumenter_source_sha256']=sha(ROOT/'tools'/('postopt_pair_profile.cpp' if a.selected_blocks else 'postopt_wave_profile.cpp'));m['status']='compiled_not_validated';save()
 except Exception:
  m['status']='failed_preserved';save();raise
 print(d);return 0
if __name__=='__main__':raise SystemExit(main())
