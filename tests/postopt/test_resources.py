import importlib.util,unittest
from pathlib import Path
spec=importlib.util.spec_from_file_location("resources",Path(__file__).resolve().parents[2]/"tools/postopt_resources.py")
resources=importlib.util.module_from_spec(spec);spec.loader.exec_module(resources)
class ResourceMetadata(unittest.TestCase):
 def test_selected_kernel_and_missing_fields(self):
  text="""amdhsa.kernels:
  - .args:
      - .name: second
    .name: first
    .vgpr_count: 10
  - .args:
      - .name: first
    .name: second
    .vgpr_count: 20
    .sgpr_spill_count: 0
"""
  first=resources.extract(text,"first");second=resources.extract(text,"second")
  self.assertEqual(first["vgpr_count"],10)
  self.assertIsNone(first["sgpr_count"])
  self.assertEqual(second["vgpr_count"],20)
  self.assertEqual(second["sgpr_spill_count"],0)
  with self.assertRaises(ValueError):resources.extract(text,"missing")
if __name__=="__main__":unittest.main()
