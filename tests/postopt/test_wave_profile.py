import sys,unittest,struct
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[2]/'tools'))
from postopt_wave_report import counters
class Counters(unittest.TestCase):
 def test_mixed(self):
  r=counters(struct.pack('<4Q',4,3,3,2));self.assertEqual((r['qT'],r['qF'],r['d']),(.75,.75,.5))
 def test_absent(self):
  r=counters(bytes(32));self.assertIsNone(r['d']);self.assertEqual(r['coverage'],'not_executed')
 def test_invalid(self):
  for v in [(1,2,0,0),(2,1,1,1),(1,0,0,0)]:
   with self.assertRaises(ValueError):counters(struct.pack('<4Q',*v))
  with self.assertRaises(ValueError):counters(bytes(24))
if __name__=='__main__':unittest.main()
