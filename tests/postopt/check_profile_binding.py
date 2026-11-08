#!/usr/bin/env python3
"""Integration check against a preserved two-input capture; never modifies it."""
import argparse,sys
from pathlib import Path
from unittest.mock import patch
sys.path.insert(0,str(Path(__file__).resolve().parents[2]/'tools'))
from postopt_wave_report import report
p=argparse.ArgumentParser();p.add_argument('capture',type=Path);a=p.parse_args();root=a.capture.resolve()
r=report(root);assert len(r['inputs'])>=2
original=Path.read_text;wrong=(root/'capture-0/accepted.json').read_text()
def read(path,*args,**kwargs):
 return wrong if path==root/'capture-1/accepted.json' else original(path,*args,**kwargs)
with patch.object(Path,'read_text',read):
 try:report(root)
 except ValueError as e:assert str(e)=='wrong validated input'
 else:raise AssertionError('accepted swapped input receipt')
print('PASS: valid capture accepted; swapped input receipt rejected; originals unchanged')
