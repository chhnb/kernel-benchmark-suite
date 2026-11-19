#!/usr/bin/env python3
"""Compare legacy and unified TTI on five minimal B2B shapes."""
import argparse
import json
from pathlib import Path
import subprocess
import tempfile


parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('search', type=Path)
parser.add_argument('worker', type=Path)
args = parser.parse_args()
fixtures = Path(__file__).with_name('b2b-unified')


def candidate(source, planner, out, extra=()):
    command = [args.search, '--ir', source, '--function', 'choose',
               '--split', 'B0', '--left', 'B1', '--right', 'B2',
               '--b2b-planner', planner, '--tti-worker', args.worker,
               '--debug-dir', out, '--out', out.with_suffix('.ll'), *extra]
    completed = subprocess.run(command, capture_output=True, text=True)
    assert completed.returncode == 0, completed.stderr
    return json.loads((out / 'trial-0/trial.json').read_text())


def cost(trial):
    assert trial['valid'] and trial['score_result']['status'] == 'scored', trial
    return trial['score_result']['metrics']['work_after']


def expected_layout(shape, row):
    if shape == 'segment':
        return bool(row['segments']) and not row['after']
    if shape == 'prefix':
        return bool(row['before']) and not row['after'] and not row['merge_exit']
    if shape == 'prefix-merged-exit':
        return row['merge_exit']
    if shape == 'prefix-suffix':
        return bool(row['before'] and row['after'])
    return bool(row['after']) and not (row['before'] or row['segments'])


with tempfile.TemporaryDirectory() as temp:
    out = Path(temp)
    for source in sorted(fixtures.glob('*.ll')):
        shape = source.stem
        legacy = candidate(source, 'legacy', out / f'{shape}-legacy')
        unified_path = out / f'{shape}-unified'
        unified = candidate(source, 'unified', unified_path)
        assert unified['merge_path'].startswith('b2b-unified-'), unified['merge_path']
        assert cost(unified) <= cost(legacy), (shape, cost(unified), cost(legacy))
        recipe = json.loads((unified_path / 'b2b-recipe.json').read_text())
        assert recipe['schema'] == 'b2b-recipe-v4' and recipe['planner'] == 'unified'
        expected = [row for row in recipe['layouts'] if expected_layout(shape, row)]
        assert expected, (shape, recipe['layouts'])
        full_recipe = unified_path / 'b2b-recipe.json'
        replay_path = out / f'{shape}-replay'
        replay = candidate(source, 'unified', replay_path, ('--b2b-recipe-in', full_recipe))
        assert replay['b2b_plan'] == unified['b2b_plan']
        assert replay_path.with_suffix('.ll').read_bytes() == unified_path.with_suffix('.ll').read_bytes()
        for rank, row in enumerate(expected):
            # Isolate the structure even if another layout normalizes to the same IR.
            recipe_path = out / f'{shape}-layout-{rank}.json'
            recipe_path.write_text(json.dumps({**recipe, 'layouts': [row]}))
            trial = candidate(source, 'unified', out / f'{shape}-layout-{rank}',
                              ('--b2b-recipe-in', recipe_path))
            if cost(trial) <= cost(legacy):
                assert trial['b2b_plan']['segments'] > 0
                assert trial['b2b_plan']['sunk_pairs'] == len(row['after'])
                if shape == 'prefix-merged-exit':
                    assert trial['b2b_plan']['removes_branch']
                break
        else:
            raise AssertionError(f'{shape}: no scored equivalent for the expected shape')
        print(f'{shape}: {cost(legacy)} → {cost(unified)}')
