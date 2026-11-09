from pathlib import Path
import subprocess,json,hashlib
s=Path('/home/chh/kernel-benchmark-suite');p=Path(__file__).resolve().parent
src=s/'experiments/hypersonic-complete-leaf-20261109-v1/input.ll'
rows=[]
for pair,split,left,right in [('L0-L1','B5','E6_23','E8_23'),('L1-L2','B7','E8_23','E15_23')]:
 for enabled in [0,1]:
  tag=pair+('-on' if enabled else '-off')
  cmd=[str(s/'build/llvm24-tti/fusion-search-llvm24'),'--ir',str(src),'--function','face_kernel','--structural','1','--cleanup','scoped-cfg','--scorer','llvm24','--coalesce-gaps',str(enabled),'--split',split,'--left',left,'--right',right,'--debug-dir',str(p/tag),'--out',str(p/(tag+'.ll'))]
  with (p/(tag+'.stdout')).open('w') as a,(p/(tag+'.stderr')).open('w') as b:
   r=subprocess.run(cmd,stdout=a,stderr=b)
  assert r.returncode==0,tag
  t=json.loads((p/tag/'trial-0/trial.json').read_text());assert t['valid'] and t['score_result']['status']=='scored'
  rows.append({'tag':tag,'command':cmd,'trial':t})
  (p/'trials.json').write_text(json.dumps(rows,indent=2))
for i in [0,2]:
 a,b=rows[i]['trial'],rows[i+1]['trial']
 assert a['parent_hash']==b['parent_hash'] and a['fusion_plan']==b['fusion_plan']
 assert a['original_darm_similarity']==b['original_darm_similarity']
 old=s/'experiments/hypersonic-complete-leaf-20261109-v1'/(rows[i]['tag'].replace('-off','-v2'))/'trial-0/after-raw.ll'
 new=p/rows[i]['tag']/'trial-0/after-raw.ll'
 assert old.read_bytes()==new.read_bytes(),'off regression'
assert rows[1]['trial']['coalesced_gap_groups']>0
print([(r['tag'],r['trial']['coalesced_gap_groups'],r['trial']['after_raw']['blocks'],r['trial']['score_result']['static_gain']) for r in rows])
