import sys,unittest
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[2]/'tools'))
from postopt_confirm import interval
class Confirmation(unittest.TestCase):
 def test_one_outlier_allowed_but_two_crossing_threshold_unclear(self):
  self.assertEqual(interval([-.1]+[.03]*8,.02)['label'],'beneficial')
  self.assertEqual(interval([-.1]*2+[.03]*7,.02)['label'],'unclear')
  self.assertEqual(interval([.1]+[-.03]*8,.02)['label'],'harmful')
 def test_null_and_boundary_do_not_become_effects(self):
  self.assertEqual(interval([0]*9,.02)['label'],'unclear')
  self.assertEqual(interval([.02]*9,.02)['label'],'unclear')
 def test_incomplete_nonfinite_or_invalid_threshold_rejected(self):
  for values,threshold in [([.1]*8,.02),([float('nan')]*9,.02),([.1]*9,-1)]:
   with self.assertRaises(ValueError):interval(values,threshold)
if __name__=='__main__':unittest.main()
