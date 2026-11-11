from pathlib import Path
import numpy as np,json
P=Path('/home/chh/region-fusion-lab');D=P/'runs/ir-net-boost-inputs-v1';D.mkdir(exist_ok=False)
thresholds=[.5,.375,.25,.125]+[np.ldexp(1.,e) for e in (-4,-8,-16,-32,-64,-128,-256,-512,-1024)]
values=[]
for x in thresholds+[np.finfo('f8').tiny,np.nextafter(0.,1.)]:
 for y in [np.nextafter(x,0.),x,np.nextafter(x,np.inf)]:
  values.extend([y,1-y])
values.extend([0.,-0.,1.,np.nextafter(1.,0.),np.nextafter(1.,np.inf),-.01,1.01,np.nan,np.inf,-np.inf])
# Exercise the subnormal exponent dispatch and fallback over its full exponent range.
for e in range(-1074,-1021):values.extend([np.ldexp(1.,e),np.nextafter(np.ldexp(1.,e),0.),np.nextafter(np.ldexp(1.,e),np.inf)])
np.asarray(values,dtype='f8').tofile(D/'boundaries-special.bin')
# Fixed performance distributions, no timing-dependent selection.
rng=np.random.default_rng(2026110301);n=65539
anchors=np.array([.4375,.3125,.1875]+[np.ldexp(1.,e) for e in (-4,-6,-12,-24,-48,-96,-192,-384,-768)],dtype='f8')
for name,x in [('interval-mixture',np.resize(anchors,n)),('coherent-blocks',np.repeat(anchors,(n+11)//12)[:n])]:
 if name=='interval-mixture':rng.shuffle(x)
 x.tofile(D/(name+'.bin'))
(D/'manifest.json').write_text(json.dumps(dict(seed=2026110301,boundary_count=len(values),performance_count=n,anchors=anchors.tolist(),performance_distributions=['interval-mixture','coherent-blocks'],finite_tolerance={'atol':1e-14,'rtol':5e-13},transformation_contract='exact original GPU output bits for finite outputs and signed zero; classify NaN/Inf separately; no tolerance relaxation',oracle_status='references not generated yet; these inputs alone are not correctness evidence',cases=['landau','mapairy']),indent=2))
print('prepared',len(values),'boundary/special inputs')
