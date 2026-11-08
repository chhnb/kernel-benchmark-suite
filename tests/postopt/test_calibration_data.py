"""Exercise dataset isolation through the public export CLI."""
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

TOOL = Path(__file__).resolve().parents[2] / 'tools/postopt_calibration_data.py'

class CalibrationIsolation(unittest.TestCase):
    def run_export(self, specs):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            command = [sys.executable, str(TOOL), '--out', str(root / 'export.json')]
            for index, (family, candidate, label, status) in enumerate(specs):
                report = root / ('report%d.json' % index)
                report.write_text(json.dumps({'candidates': [{
                    'candidate': candidate, 'parent_hash': 'parent', 'cleaned_hash': candidate,
                    'features': {}, 'measurements': [{'status': status, 'path': 'measurement',
                    'inputs': {'input': {'mean_log_ratio': .1 if label == 'beneficial' else -.1,
                                         'label': label}}}]}]}))
                command += ['--report', family + '=' + str(report)]
            result = subprocess.run(command, text=True, capture_output=True)
            output = root / 'export.json'
            return result, json.loads(output.read_text()) if output.exists() else None

    def test_cross_family_leak_is_rejected(self):
        result, output = self.run_export([
            ('train', 'same', 'beneficial', 'complete_screening'),
            ('test', 'same', 'beneficial', 'complete_screening')])
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('candidate leaks across families', result.stderr)
        self.assertIsNone(output)

    def test_repeated_candidate_input_is_not_double_counted(self):
        row = ('family', 'same', 'beneficial', 'complete_screening')
        result, output = self.run_export([row, row])
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('duplicate candidate/input', result.stderr)
        self.assertIsNone(output)

    def test_incomplete_labels_excluded_and_screening_not_deployment(self):
        result, output = self.run_export([
            ('a', 'one', 'beneficial', 'complete_screening'),
            ('b', 'two', 'harmful', 'complete_screening'),
            ('c', 'three', 'beneficial', 'complete_screening'),
            ('d', 'missing', 'beneficial', 'incomplete')])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(len(output['rows']), 3)
        self.assertEqual(output['readiness']['families_with_definite_labels'], ['a', 'b', 'c'])
        self.assertFalse(output['readiness']['ready_for_deployment_calibration'])
        self.assertIn('exploratory_extreme_sampling_not_representative', output['readiness']['reasons'])
        self.assertFalse(output['model_fitted'])
        self.assertFalse(output['test_evaluated'])

if __name__ == '__main__':
    unittest.main()
