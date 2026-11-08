#!/usr/bin/env python3
"""Extract supported AMD metadata fields from retained llvm-readobj notes."""
import argparse,hashlib,json,re
from pathlib import Path
FIELDS=("sgpr_count","vgpr_count","sgpr_spill_count","vgpr_spill_count","private_segment_fixed_size","group_segment_fixed_size")
def extract(text,function):
 records=re.split(r"(?m)^  - ",text)[1:]
 matches=[]
 for record in records:
  names=re.findall(r"(?m)^    \.name:\s*(.+)$",record)
  if names and names[0].strip().strip("'\"")==function:
   values={}
   for key in FIELDS:
    v=re.search(r"(?m)^    \."+key+r":\s*(\d+)\s*$",record)
    values[key]=int(v.group(1)) if v else None
   matches.append(values)
 if len(matches)!=1:raise ValueError("expected exactly one named kernel metadata record")
 return matches[0]
def collect(pair):
 m=json.loads((pair/"manifest.json").read_text());result={"pair":str(pair),"candidate":m["candidate"],"function":m["context"]["function"],"ir":m.get("trial",{}).get("score_result",{}).get("metrics",{}),"backend":{}}
 for side in ("baseline","variant"):
  record=m["files"][side+"_resources"];path=pair/record["path"]
  if hashlib.sha256(path.read_bytes()).hexdigest()!=record["sha256"]:raise ValueError("resource report changed")
  result["backend"][side]=extract(path.read_text(),result["function"])
 result["delta"]={k:result["backend"]["variant"][k]-result["backend"]["baseline"][k] if all(result["backend"][s][k] is not None for s in ("baseline","variant")) else None for k in FIELDS}
 return result
def main():
 p=argparse.ArgumentParser();p.add_argument("--pair",type=Path,action="append",required=True);p.add_argument("--out",type=Path,required=True);a=p.parse_args()
 result={"schema":"postopt-offline-resources-v0","scope":"backend metadata is offline validation only; counts are not occupancy or runtime predictions","pairs":[collect(p.resolve()) for p in a.pair]}
 with a.out.open("x") as f:json.dump(result,f,indent=2)
 for r in result["pairs"]:print(r["candidate"],r["delta"])
if __name__=="__main__":main()
