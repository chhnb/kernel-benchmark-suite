#!/usr/bin/env python3
"""Stable pair requests survive order metadata and reject absent identities."""
import json,pathlib,subprocess,tempfile
root=pathlib.Path(__file__).resolve().parents[2]
with tempfile.TemporaryDirectory() as tmp:
 d=pathlib.Path(tmp);src=d/'input.ll'
 src.write_text((root/'tests/decision-model/chain.ll').read_text())
 order=d/'order.json';order.write_text(json.dumps([{'entry':'%'+name,'family':'case:%entry','index':i} for i,name in enumerate(['c','d','a','b'])]))
 req=d/'pair.json';wanted={'decision':'case:%entry','left':'case:%a','right':'case:%b'};req.write_text(json.dumps(wanted))
 out=d/'valid'
 cmd=[str(root/'build/decision-fuse/decision-fuse'),str(src),'case','0','0',str(out),str(order),str(req)]
 p=subprocess.run(cmd,capture_output=True);assert p.returncode==0,p.stderr.decode()
 actual=json.loads((out/'trial.json').read_text());assert all(actual[k]==v for k,v in wanted.items())
 wanted['right']='case:%missing';req.write_text(json.dumps(wanted));cmd[5]=str(d/'invalid')
 p=subprocess.run(cmd,capture_output=True);assert p.returncode!=0
 assert json.loads((d/'invalid/trial.json').read_text())['reason']=='requested_pair_not_unique_or_adjacent'
 assert not (d/'invalid/fused.ll').exists()
 print('stable pair IDs survive reordered catalog; missing ID rejected without ordinal fallback')
