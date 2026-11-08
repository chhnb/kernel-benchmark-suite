"""Selection must be stable and must not recycle retired requests."""
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
from types import SimpleNamespace

spec = importlib.util.spec_from_file_location('sampling', Path(__file__).resolve().parents[2]/'tools/postopt_sample.py')
sampling = importlib.util.module_from_spec(spec)
spec.loader.exec_module(sampling)

class Sampling(unittest.TestCase):
    def test_fixed_selection_excludes_all_prior_candidates(self):
        with tempfile.TemporaryDirectory() as tmp:
            root=Path(tmp);debug=root/'debug';debug.mkdir();old=root/'old';old.mkdir()
            for i in range(5):
                d=debug/('trial-'+str(i));d.mkdir()
                row={'valid':True,'candidate':'candidate-'+str(i),'parent_hash':'p','cleaned_hash':str(i),
                     'eligible':True,'original_darm_profitable':True,
                     'score_result':{'status':'scored','static_score':1,'total':1},'after':{'instructions':10}}
                (d/'trial.json').write_text(json.dumps(row))
                if i==0:(old/'manifest.json').write_text(json.dumps({'status':'failed_preserved','trial':row}))
            plans=[]
            for run in range(2):
                out=root/('out'+str(run))
                argv=['sample','--debug',str(debug),'--case','dummy','--out',str(out),'--selection','hash','--exclude-root',str(old)]
                with patch('sys.argv',argv),patch.object(sampling.subprocess,'run',return_value=SimpleNamespace(returncode=0)):
                    self.assertEqual(sampling.main(),0)
                plans.append(json.loads((out/'plan.json').read_text()))
            self.assertEqual(plans[0]['samples'],plans[1]['samples'])
            self.assertEqual(plans[0]['excluded_candidate_count'],1)
            self.assertEqual(plans[0]['remaining_legal_population'],4)
            self.assertEqual(len(plans[0]['samples']),1)
            self.assertNotEqual(plans[0]['samples'][0]['candidate'],'candidate-0')

if __name__=='__main__':unittest.main()
