from pathlib import Path
import json,shutil
S=Path('/home/chh/kernel-benchmark-suite');L=S/'cases/boost-landau';C=S/'cases/boost-mapairy';C.mkdir();(C/'source').mkdir();(C/'provenance').mkdir()
for n in ['kernel.hip','oracle.cpp']:(C/'source'/n).write_text((L/'source'/n).read_text().replace('landau','mapairy'))
(C/'source/boost-math').symlink_to('../../boost-landau/source/boost-math',target_is_directory=True)
for n in ['compile_llvm12.sh','build_llvm12.sh']:shutil.copy2(L/n,C/n)
for f in ['interval-mixture','coherent-blocks']:
 d=C/'fixtures-cpp'/f;d.mkdir(parents=True)
 for n in ['input.bin','output-init.bin','input.txt']:shutil.copy2(L/'fixtures-cpp'/f/n,d/n)
m=json.loads((L/'case.json').read_text());m={k:m[k] for k in ['profiles','runtime','upstream','upstream_commit','baseline_profile']};m.update(name='boost-mapairy',enabled=True,status='pending_validation',scope='Complete original Boost.Math Map-Airy quantile<double>; LLVM12 gfx906; no extracted helpers',helper_extraction=False)
m['runtime']['default_kernel']=str(S/'results/mapairy-llvm12-baseline-v1/kernel.hsaco');m['runtime']['scope']='Complete Map-Airy quantile public API; 65539 finite FP64 inputs, interval-mixture and coherent-blocks; block256; long-double CPU oracle atol1e-14+rtol5e-13'
m['validation']={'status':'pending'};m['benchmark']={'status':'pending'}
(C/'case.json').write_text(json.dumps(m,indent=2))
(C/'provenance/source.json').write_text(json.dumps({'boost_commit':m['upstream_commit'],'headers':'shared pinned source via ../../boost-landau/source/boost-math','kernel':'unmodified Boost public API mapairy_distribution<double>','inputs':'byte-identical retained 2026110301 Landau/Map-Airy synthetic probability inputs; regenerated Map-Airy references; no application-captured data'},indent=2))
E=S/'experiments/mapairy-integration-v1';E.mkdir();(E/'trial').mkdir()
