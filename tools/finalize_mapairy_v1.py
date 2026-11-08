from pathlib import Path
import json,hashlib
S=Path('/home/chh/kernel-benchmark-suite');C=S/'cases/boost-mapairy';B=S/'results/mapairy-llvm12-baseline-v1';E=S/'experiments/mapairy-integration-v1'
for phase in ['validate','benchmark']:
 assert json.loads((S/f'results/mapairy-integration-{phase}-v1/accepted.json').read_text())['passed']
m=json.loads((C/'case.json').read_text());m['status']='accepted_llvm12_baseline_and_manual_darm_screen';m['validation']={'status':'passed','result':'results/mapairy-integration-validate-v1','scope':'two retained synthetic finite lower-tail input fixtures; CPU long-double tolerance plus exact baseline bytes for transformed kernels'};m['benchmark']={'status':'completed','result':'results/mapairy-integration-benchmark-v1','warmup':3,'repeat':30,'timing':'HIP Event'};m['acceptance']={'source_build':True,'gpu_correctness':True,'timing':True,'complete_benchmark':True}
m['limitations']=['Two synthetic input fixtures only; all probabilities <= 0.5, upper-tail runtime paths not exercised.','No historical Map-Airy input timing or application-captured distribution claimed.','Manual lower-tree scope; generic Share/Bloat greedy integration not validated for this case.','Pinned Boost headers shared via symlink to boost-landau/source/boost-math.']
m['verified_builds']=[{'profile':'hip-llvm12-o3','receipt':'results/mapairy-llvm12-baseline-v1/receipt.json'}]
m['optimization_experiments']=[{'path':'experiments/mapairy-integration-v1','roles':['baseline','auto_DARM','manual_FP','manual_CFG'],'manual_tree':'(L0,L1)|L2|L3|(((L4,L5),(L6,L7)),((L8,L9),(L10,L11)))|L12','scope':'same baseline, manual upper tail unchanged; uniform final O3'}]
s=json.loads((S/'analysis/mapairy-regions-llvm12-v1/summary.json').read_text())['boost-mapairy'];m['region_analysis']={'llvm_version':12,'ir':str(B/'post.ll'),'ir_sha256':s['input_sha256'],'report':str(S/'analysis/mapairy-regions-llvm12-v1/boost-mapairy/inventory.json'),'summary':s};(C/'case.json').write_text(json.dumps(m,indent=2))
(B/'receipt.json').write_text(json.dumps({'case':'boost-mapairy','profile':'hip-llvm12-o3','build_passed':True,'artifact':str(B/'kernel.hsaco'),'build_log':'/home/chh/region-fusion-lab/work/mapairy-suite-build-v1/output.log','build_script':str(E/'build.sh'),'artifact_sha256':hashlib.sha256((B/'kernel.hsaco').read_bytes()).hexdigest()},indent=2))
(C/'README.md').write_text('''# Boost.Math Map-Airy

Complete unmodified public API `quantile(mapairy_distribution<double>(), p)` kernel. LLVM12 / gfx906, FP64, no extracted helpers. C++ HIP runner and HIP Event timing.

Build from the suite root:

```sh
python3 tools/suite.py build boost-mapairy --profile hip-llvm12-o3 --out results/mapairy-new-build
./bench boost-mapairy validate --build results/mapairy-new-build --out results/mapairy-new-check
./bench boost-mapairy benchmark --build results/mapairy-new-build --validated results/mapairy-new-check --out results/mapairy-new-time --warmup 3 --repeat 30
```

Accepted default kernel is `results/mapairy-llvm12-baseline-v1/kernel.hsaco`. Two retained synthetic 65539-element fixtures: interval-mixture and coherent-blocks. References regenerated with the pinned Boost long-double Map-Airy CPU oracle. Both fixtures use p <= 0.5; upper-tail execution is outside this validation scope. No application-captured data or historical-input replication claimed.

Pinned Boost headers are shared through `source/boost-math` with the existing Landau case. Kernel and oracle sources, build recipes, fixture buffers, references, and provenance are maintained in this case directory.

`experiments/mapairy-integration-v1` compares baseline, automatic DARM, and the same manual lower-tail balanced tree with original CFG or fixed-point scalar intermediate cleanup. All receive final O3. See `docs/mapairy-integration.md` for results. This does not port the Landau-only Share/Bloat boundary heuristic to Map-Airy.
''')
p=S/'README.md';txt=p.read_text();txt=txt.replace('Current selection: 9 active cases, including Boost.Math Landau.','Current selection: 10 active cases, including Boost.Math Landau and Map-Airy.');p.write_text(txt)
