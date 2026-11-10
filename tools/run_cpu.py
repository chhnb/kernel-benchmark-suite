# Canonical CPU admission wrapper. Preserve the historical slot identity
# so old and new callers share one quota, not two independent pools.
from pathlib import Path
import sys,subprocess,importlib.util,os,json,time
P=Path('/home/chh/region-fusion-lab');R=Path('/home/chh/divergence-strategy-search');label=sys.argv[1];cmd=sys.argv[2:];assert cmd
O=P/'work'/label;O.mkdir(exist_ok=False);spec=importlib.util.spec_from_file_location('cs',R/'explorations/case-search-20261020/tools/compile_support.py');cs=importlib.util.module_from_spec(spec);spec.loader.exec_module(cs);cs.SLOT='saspoint5-cuda-cpu';cs.W=P;cs.R=O
os.environ['LD_LIBRARY_PATH']=(P/'work/rocm-library-path.txt').read_text().strip();os.environ['PATH']=str(P/'.venv/bin')+':'+os.environ['PATH'];(O/'command.json').write_text(json.dumps(cmd));cs.quota(True)
try:
 t=time.time()
 with (O/'output.log').open('w') as f:rc=subprocess.run(cmd,cwd=P,stdout=f,stderr=subprocess.STDOUT,timeout=1800,preexec_fn=cs.limits).returncode
 (O/'result.json').write_text(json.dumps({'exit':rc,'seconds':time.time()-t},indent=2));print(label,'exit',rc,flush=True)
 if rc:print((O/'output.log').read_text()[-5000:]);raise SystemExit(rc)
finally:cs.quota(False)
