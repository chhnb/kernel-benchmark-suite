#!/usr/bin/env python3
"""CPU-only suite orchestration; all CFG/Region analyses use LLVM12 C++ APIs."""
from pathlib import Path
import argparse,json,subprocess,hashlib,re,time,sys
S=Path(__file__).resolve().parents[1]
CASES={
 'tpacf':('tpacf-baseline-v1/post.ll','ACFKernel','O3/no-unroll','helper-free full kernel; common historical no-unroll profile, FP contraction off'),
 'boost-mapairy':('mapairy-llvm12-baseline-v1/post.ll','evaluate','O3','same LLVM IR used by default code object'),
 'boost-landau':('landau-llvm12-baseline-v1/post.ll','evaluate','O3','same LLVM IR used by default code object'),
 'cholla-hlld':('cholla-hlld-cuda-o3-v1/start.ll','Calculate_HLLD_Fluxes_CUDA','O3','Clang12 source companion; default runtime is NVCC'),
 'cudaflow-particles':('cudaflow-cuda-o3-v1/start.ll','partPushK','O3','Clang12 source companion; default runtime is NVCC'),
 'hipims':('hipims-hllc-llvm-o3-v2/start.ll','cuAdvectionMSWEsCartesianKernel','O3','Clang12 source companion with Vector constructor annotation compatibility; default runtime is NVCC'),
 'hypersonic':('hypersonic-hip-llvm12-ir-v1/start.ll','face_kernel','O2','fresh LLVM12 source build; previous default runtime is ROCm18'),
 'reentry':('reentry-hip-llvm12-ir-v1/start.ll','face_kernel','O2','fresh LLVM12 source build; previous default runtime is ROCm18'),
 'srad':('srad-baseline-binary-v1/post.ll','srad_cuda_1','O3','same LLVM IR used by default code object'),
 'tigre-siddon':('tigre-baseline-binary-v1/post.ll','kernelPixelDetector','O3','same LLVM IR used by default code object'),
 'vllm-quant':('vllm-hip-software-v1/post.ll','cache_eval','O3','software HIP quant route, same LLVM IR used by default code object'),
}
def main():
 p=argparse.ArgumentParser();p.add_argument('--out',required=True);p.add_argument('--case',choices=CASES);p.add_argument('--admitted',action='store_true',help=argparse.SUPPRESS);a=p.parse_args()
 a.out=str(Path(a.out).resolve())
 if not a.admitted:
  cmd=[sys.executable,'/home/chh/region-fusion-lab/work/run-cpu.py','suite-regions-'+str(time.time_ns()),sys.executable,str(Path(__file__).resolve()),'--out',a.out,'--admitted']
  if a.case:cmd+=['--case',a.case]
  return subprocess.call(cmd)
 O=Path(a.out).resolve();O.mkdir(parents=True,exist_ok=False)
 opt='/home/chh/darm-artifacts-repro/build/bin/opt';tool=S/'build/region-inventory/region-inventory';summary={}
 version=subprocess.check_output([opt,'--version'],text=True);assert '12.0' in version
 (O/'llvm-version.txt').write_text(version)
 for case,(path,match,level,scope) in CASES.items():
  if a.case and a.case!=case:continue
  ir=S/'results'/path;d=O/case;d.mkdir();receipt={'ir':str(ir),'ir_sha256':hashlib.sha256(ir.read_bytes()).hexdigest(),'function_match':match,'optimization':level,'scope':scope,'commands':[]}
  def run(name,cmd,timeout=180):
   cmd=list(map(str,cmd));receipt['commands'].append(cmd)
   try:r=subprocess.run(list(map(str,cmd)),capture_output=True,text=True,timeout=timeout);rc=r.returncode;stdout,stderr=r.stdout,r.stderr
   except subprocess.TimeoutExpired as e:rc=124;stdout=(e.stdout or b'').decode() if isinstance(e.stdout,bytes) else e.stdout or '';stderr='TIMEOUT'
   (d/(name+'.stdout')).write_text(stdout);(d/(name+'.stderr')).write_text(stderr);return rc,stdout,stderr
  rc,_,_=run('verify',[opt,ir,'-verify','-regions','-verify-region-info','-disable-output']);assert rc==0,case+' verifier'
  rc,out,_=run('inventory',[tool,ir,match]);assert rc==0,case+' inventory'
  data=json.loads(out);exact=[f for f in data['functions'] if f['name']==match];data['functions']=exact or data['functions'];assert len(data['functions'])==1,(case,'ambiguous function selection');f=data['functions'][0]
  data['reachable_functions']=[];data['external_callees']=[]
  if f['callees']:
   rc,allout,_=run('module-inventory',[tool,ir]);assert rc==0
   definitions={v['name']:v for v in json.loads(allout)['functions']};pending=list(f['callees']);seen={f['name']}
   while pending:
    n=pending.pop()
    if n in seen:continue
    seen.add(n)
    if n in definitions:data['reachable_functions'].append(definitions[n]);pending.extend(definitions[n]['callees'])
    else:data['external_callees'].append(n)
  (d/'inventory.json').write_text(json.dumps(data,indent=2))
  # Restrict the existing DARM analysis to the target kernel by extracting it;
  # definitions of other functions become declarations. No kernel CFG edits.
  extract='/home/chh/darm-artifacts-repro/build/bin/llvm-extract'
  rc,_,_=run('extract',[extract,'-func='+f['name'],'-S',ir,'-o',d/'target.ll']);assert rc==0
  rc,_,log=run('darm',[opt,d/'target.ll','-cfmelder','-cfmelder-analysis-only','-disable-output'])
  darm={'exit':rc,'status':'analyzed' if rc==0 else 'failed-preserved','valid_locations':len(re.findall('Valid merge location found at BB',log)) if rc==0 else None,'profitable_locations':len(re.findall(r'This merge is :  PROFITABLE!',log)) if rc==0 else None}
  receipt['darm']=darm;(d/'receipt.json').write_text(json.dumps(receipt,indent=2))
  summary[case]={'function':f['name'],'llvm':12,'optimization':level,**f['summary'],'reachable_device_definitions':len(data['reachable_functions']),'external_callees':data['external_callees'],'darm':darm,'scope':scope,'input_sha256':receipt['ir_sha256']}
  print(case,json.dumps(summary[case]),flush=True)
 (O/'summary.json').write_text(json.dumps(summary,indent=2));return 0
if __name__=='__main__':raise SystemExit(main())
