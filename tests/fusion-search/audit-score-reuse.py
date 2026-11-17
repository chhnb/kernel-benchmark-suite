#!/usr/bin/env python3
"""Offline test of candidate fingerprints against full-rescore PCM traces.
These fingerprints are hypotheses, not certificates authorizing score reuse.
"""
import argparse,collections,hashlib,json,re
from pathlib import Path
TOKEN=re.compile(r'%(?:"(?:[^"\\]|\\.)*"|[-a-zA-Z$._0-9]+)')
LABEL=re.compile(r'^((?:"[^"\\]*"|[-a-zA-Z$._0-9]+)):\s*(?:;.*)?$')
def parse(path,fn):
 text=path.read_text();lines=text.splitlines();inside=False;blocks=[];defs={};args=[];current=[]
 for line in lines:
  if not inside:
   if line.startswith('define ') and '@'+fn+'(' in line:
    inside=True;args=TOKEN.findall(line.split('(',1)[1]);current=[]
   continue
  if line=='}':
   if current:blocks.append(current)
   break
  m=LABEL.match(line)
  if m:
   if current:blocks.append(current)
   current=[('%'+m[1], '')]
  elif line.strip() and not line.lstrip().startswith(';'):
   if not current:current=[('%implicit-entry','')]
   body=line.strip();lhs=body.split(' = ',1)[0] if ' = ' in body else ''
   current.append((lhs,body))
   if lhs:defs[lhs]=body
 mapping={b[0][0]:i for i,b in enumerate(blocks)}
 uses=collections.defaultdict(set)
 for i,b in enumerate(blocks):
  for lhs,line in b[1:]:
   rhs=line.split(' = ',1)[-1]
   for name in TOKEN.findall(rhs):uses[name].add(i)
 return blocks,defs,mapping,uses,args

def memory_ancestors(parsed):
 blocks,defs,mapping,uses,args=parsed
 successors=[];predecessors=[set() for _ in blocks]
 for i,b in enumerate(blocks):
  targets={mapping[x] for x in TOKEN.findall(b[-1][1]) if x in mapping}
  successors.append(targets)
  for target in targets:predecessors[target].add(i)
 reachable={0};pending=[0]
 while pending:
  for target in successors[pending.pop()]:
   if target not in reachable:reachable.add(target);pending.append(target)
 dom=[({0} if i==0 else set(reachable)) for i in range(len(blocks))]
 changed=True
 while changed:
  changed=False
  for i in sorted(reachable-{0}):
   incoming=[dom[p] for p in predecessors[i] if p in reachable]
   value={i}|(set.intersection(*incoming) if incoming else set())
   if value!=dom[i]:dom[i]=value;changed=True
 return dom

def fingerprint(parsed,indices,radius,memory_context=None,data_context=False):
 blocks,defs,mapping,uses,args=parsed
 scope=set(indices)
 for _ in range(radius):
  more=set()
  for i in scope:
   b=blocks[i]
   for token in TOKEN.findall(b[-1][1]):
    if token in mapping:more.add(mapping[token])
   for lhs,_ in b[1:]:more.update(uses[lhs])
  scope.update(more)
 # Role labels preserve orientation; other blocks retain deterministic traversal order.
 order=list(dict.fromkeys(indices))+sorted(scope-set(indices))
 names={};serial=[]
 def replace(m):
  x=m[0]
  if x not in names:names[x]='%v'+str(len(names))
  return names[x]
 for i in order:
  for lhs,line in blocks[i]:
   serial.append(TOKEN.sub(replace,line or lhs+':'))
 if memory_context is not None:
  # This is a deliberately conservative hypothesis: record all dominating
  # memory operations, including their immediate operand definitions. Do not
  # confuse a zero-mismatch trace audit with a complete LLVM read-set proof.
  for i in sorted(memory_context[indices[0]]-{indices[0]}):
   for lhs,line in blocks[i][1:]:
    rhs=line.split(' = ',1)[-1]
    if re.search(r'\b(load|store|call|invoke|atomicrmw|cmpxchg|fence)\b',rhs):
     serial.append('INCOMING '+TOKEN.sub(replace,line))
 # Immediate external definitions and types/constants influence operand costs.
 local={lhs for i in scope for lhs,_ in blocks[i]}
 extern=[x for x in names if x not in local]
 seen=set();cursor=0
 while cursor<len(extern):
  x=extern[cursor];cursor+=1
  if x in seen:continue
  seen.add(x)
  definition=defs.get(x,'argument:'+str(args.index(x)) if x in args else 'other')
  serial.append('EXTERNAL '+names[x]+' '+TOKEN.sub(replace,definition))
  if data_context:
   extern.extend(y for y in TOKEN.findall(definition) if y not in local and y not in seen)
 key='\n'.join(serial)
 return hashlib.sha256(key.encode()).hexdigest(),len(scope)
def main():
 ap=argparse.ArgumentParser();ap.add_argument('trace',type=Path);ap.add_argument('--rounds',type=int,default=8);ap.add_argument('--memory-context',action='store_true');ap.add_argument('--data-context',action='store_true');args=ap.parse_args()
 summary=json.loads((args.trace/'summary.json').read_text());results=[]
 for radius in [0,1,2]:
  cache={};hits=0;mismatches=[];scores=0;scopes=[]
  for rnd in summary['rounds'][:args.rounds]:
   if not rnd['attempts']:continue
   fn=rnd['attempts'][0]['candidate'].rsplit(':',3)[0]
   parsed=parse(Path(rnd['parent']),fn)
   memory_context=memory_ancestors(parsed) if args.memory_context else None
   for a in rnd['attempts']:
    candidate=a['candidate'].split(':');left,right=candidate[-2:]
    if not left.startswith('B') or not right.startswith('B') or a.get('stage')!='scored':continue
    req=json.loads((Path(a['directory'])/'request.json').read_text());av=req['argv']
    if av[av.index('--ir')+1]!=rnd['parent']:continue
    ids=[int(x[1:]) for x in candidate[-3:]];key,size=fingerprint(parsed,ids,radius,memory_context,args.data_context);scores+=1;scopes.append(size)
    value=(a['gain'],a.get('reason',''),a.get('eligible',False))
    if key in cache:
     hits+=1
     if cache[key][0]!=value:mismatches.append(dict(previous=cache[key],current=[value,a['directory']]))
    cache[key]=(value,a['directory'])
  results.append(dict(radius=radius,scored=scores,hits=hits,mismatches=mismatches,mean_scope=sum(scopes)/max(1,len(scopes))))
 print(json.dumps(results,indent=2))
if __name__=='__main__':main()
