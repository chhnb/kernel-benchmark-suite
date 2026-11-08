import sys
from pathlib import Path
import unittest
sys.path.insert(0,str(Path(__file__).resolve().parents[2]/'tools'))
from postopt_pressure_validation import ranks,correlation,association

class PressureStatistics(unittest.TestCase):
    def test_tied_ranks_and_correlation(self):
        self.assertEqual(ranks([3,1,1,5]),[2,0.5,0.5,3])
        self.assertAlmostEqual(correlation([1,2,3],[3,2,1]),-1)
        self.assertAlmostEqual(correlation([1,1,3],[2,2,4]),1)
        self.assertIsNone(correlation([0,0],[1,2]))
        self.assertIsNone(correlation([1],[1]))
    def test_zero_and_missing_values_do_not_inflate_agreement(self):
        rows=[{'pressure_delta':{'total':a},'resource_delta':{'vgpr_count':b}}
              for a,b in [(0,0),(0,0),(1,-1),(None,4)]]
        result=association(rows,'total','vgpr_count')
        self.assertEqual(result['n'],3)
        self.assertEqual(result['both_zero'],2)
        self.assertEqual(result['nonzero_change_pairs'],1)
        self.assertEqual(result['same_sign_excluding_both_zero'],0)
        self.assertEqual(result['positive_ir_but_nonpositive_resource'],1)
if __name__=='__main__':unittest.main()
