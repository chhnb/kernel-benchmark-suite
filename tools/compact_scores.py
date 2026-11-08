"""Losslessly factor repeated units and pair scores; no compression codec."""
from pathlib import Path
import json,hashlib,sys
def compact(data):
 result={k:v for k,v in data.items() if k!='functions'};result['schema']='llvm12-darm-neighbor-similarity-factored-v1';result['occurrence_fields']=['original_id','pair_id','left_postdominates_side_start','right_postdominates_side_start','exclusive_between_sides','note_index'];result['functions']=[]
 excluded={'id','relation','context','split','left_entry_postdominates_side_start','right_entry_postdominates_side_start','structural_note','exclusive_between_sides'}
 for f in data['functions']:
  units={};pairs={};cache={};contexts={};notes=[];restored=[]
  for p in f['pairs']:
   for side in ['left','right']:
    u=p[side];assert u['id'] not in units or units[u['id']]==u;units[u['id']]=u
   core={k:v for k,v in p.items() if k not in excluded};core['left']=p['left']['id'];core['right']=p['right']['id'];key=json.dumps(core,sort_keys=True,separators=(',',':'))
   if key not in cache:cache[key]='Q'+str(len(pairs));pairs[cache[key]]=core
   qid=cache[key];ct=(p['relation'],p['context'],p['split'])
   if ct not in contexts:contexts[ct]={'relation':ct[0],'context':ct[1],'split':ct[2],'occurrences':[]}
   note=p['structural_note']
   if note not in notes:notes.append(note)
   contexts[ct]['occurrences'].append([p['id'],qid,p['left_entry_postdominates_side_start'],p['right_entry_postdominates_side_start'],p['exclusive_between_sides'],notes.index(note)])
  for c in contexts.values():
   for oid,qid,lpd,rpd,exclusive,note in c['occurrences']:
    rec={**pairs[qid],'left':units[pairs[qid]['left']],'right':units[pairs[qid]['right']],'id':oid,'relation':c['relation'],'context':c['context'],'split':c['split'],'left_entry_postdominates_side_start':lpd,'right_entry_postdominates_side_start':rpd,'exclusive_between_sides':exclusive,'structural_note':notes[note]};restored.append(rec)
  assert sorted(restored,key=lambda p:int(p['id'][1:]))==f['pairs'],'factorization changed data'
  result['functions'].append({'name':f['name'],'summary':{**f['summary'],'distinct_pair_status_records':len(pairs),'distinct_scored_pairs':sum(p['similarity'] is not None for p in pairs.values())},'units':units,'pairs':pairs,'contexts':list(contexts.values()),'notes':notes,'skipped_contexts':f['skipped_contexts']})
 return result
def process(directory):
 D=Path(directory);p=D/'scores.json';data=json.loads(p.read_text());out=compact(data);target=D/'scores-factored.json';target.write_text(json.dumps(out,separators=(',',':'))+'\n')
 receipt={'raw_sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'raw_bytes':p.stat().st_size,'factored_bytes':target.stat().st_size,'lossless_record_reconstruction_checked':True}
 (D/'factorization.json').write_text(json.dumps(receipt,indent=2));return out
if __name__=='__main__':
 out=process(sys.argv[1]);print([(f['name'],f['summary']) for f in out['functions']])
