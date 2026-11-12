import json
from pathlib import Path
import sys


def audit_round(row, parent, cost, blacklist):
    assert row['parent'] == parent and row['parent_cost'] == cost
    by_pair = {}
    for attempt in row['attempts']:
        if 'anchor_plan' in attempt:
            by_pair.setdefault((attempt['left'], attempt['right']), []).append(attempt)
    for attempt in row['attempts']:
        assert tuple(attempt.get('pair_key', ())) not in blacklist
        trial = Path(attempt['directory']) / 'trial.json'
        if trial.exists():
            actual = json.loads(trial.read_text())
            if 'left' in actual:
                assert (actual['decision'], actual['left'], actual['right']) == (
                    row['decision'], attempt['left'], attempt['right'])
        if 'cost' in attempt:
            assert trial.exists() and actual['status'] == 'verified'
        if 'anchor_plan' in attempt:
            assert trial.exists() and actual['anchor_plan'] == attempt['anchor_plan']
            alternatives = by_pair[attempt['left'], attempt['right']]
            scores = actual['pair_plan_scores']
            assert {a['anchor_plan'] for a in alternatives} == {'single-anchor', 'multi-anchor'}
            assert len(scores) == len(alternatives) == 2
            for score, other in zip(scores, alternatives):
                assert score['plan'] == other['anchor_plan']
                assert score['directory'] == other['directory']
                for key in ('exit_code', 'cost', 'gain', 'eligible'):
                    assert score.get(key) == other.get(key)

    scored = [a for a in row['attempts'] if 'cost' in a and a.get('eligible', True)]
    if not row['selected']:
        assert all(a['cost'] >= cost for a in scored)
        return None
    selected = min(scored, key=lambda a: a['cost'])
    best = selected['cost']
    assert best < cost and best == row['selected_cost']
    assert selected['directory'] == row['selected']
    assert abs(row['score'] - (cost - best) / max(cost, 1)) < 1e-12
    return str(Path(row['selected']) / 'fused.ll'), best, selected.get('pair_key')


def passes(metrics, baseline):
    return (metrics['active_blocks_per_cu'] >= baseline['active_blocks_per_cu']
            and all(metrics[key] <= baseline[key]
                    for key in ('vgpr_spill_count', 'sgpr_spill_count')))


def audit_transactions(summary):
    rounds = summary['rounds']
    parent, cost = None, summary['initial_cost']
    offset = commits = 0
    previous_metrics = None
    for transaction in summary['transactions']:
        assert transaction['first_round'] == offset
        assert parent is None or parent == transaction['initial_ir']
        if previous_metrics is not None:
            assert transaction['baseline'] == previous_metrics
        prefixes = [(transaction['initial_ir'], cost, None)]
        blacklist = set()
        failed_prefixes = []
        terminal = None
        rollbacks = 0
        original_costs = None
        for check in transaction['checks']:
            end = check['round_end']
            assert offset <= end <= transaction['round_end']
            for row in rounds[offset:end]:
                assert row['decision'] == transaction['decision']
                result = audit_round(row, *prefixes[-1][:2], blacklist)
                if result:
                    prefixes.append(result)
            offset = end
            prefix = check['prefix']
            assert check['ir'] == prefixes[prefix][0]
            assert check['passes'] == passes(check['metrics'], transaction['baseline'])
            arms = check.get('uniform_decision')
            if arms is not None:
                costs = [(arm['arm'], arm['before']) for arm in arms]
                assert original_costs is None or costs == original_costs
                original_costs = costs
                for arm in arms:
                    assert arm['delta'] == arm['after'] - arm['before']
                    assert arm['unexplained'] == (arm['delta'] - arm['approved_speculation']
                                                  - arm['condition_hoist'])
                    if prefix == 0:
                        assert arm['delta'] == arm['unexplained'] == 0
            if not check['passes']:
                expected = failed_prefixes[-1] - 1 if failed_prefixes else len(prefixes) - 1
                assert prefix == expected
                failed_prefixes.append(prefix)
            elif 'rollback_from' in check:
                assert summary['checkpoint_mode'] == 'enforce'
                assert failed_prefixes and prefix == failed_prefixes[-1] - 1
                assert check['rollback_from'] == failed_prefixes[0] == len(prefixes) - 1
                pair = tuple(check['blacklisted_pair'])
                assert pair == tuple(prefixes[prefix + 1][2]) and pair not in blacklist
                blacklist.add(pair)
                del prefixes[prefix + 1:]
                failed_prefixes.clear()
                rollbacks += 1
            else:
                assert not failed_prefixes and prefix == len(prefixes) - 1
            terminal = check

        assert terminal is not None
        assert offset == transaction['round_end']
        assert transaction['retained_commits'] == len(prefixes) - 1
        assert rollbacks <= summary['checkpoint_retries'] + 1
        if summary['checkpoint_mode'] == 'enforce':
            assert terminal['passes'] and not failed_prefixes
        expected_status = ('rolled_back' if rollbacks else
                           'passed' if terminal['passes'] else 'reported_failure')
        assert transaction['status'] == expected_status
        previous_metrics = terminal['metrics']
        parent, cost, _ = prefixes[-1]
        assert parent == transaction['final_ir']
        commits += len(prefixes) - 1

    assert offset == len(rounds)
    if parent is not None:
        assert Path(parent).read_bytes() == Path(summary['final_ir']).read_bytes()
    return cost, commits


def main():
    path = Path(sys.argv[1])
    summary = json.loads(path.read_text())
    assert summary['status'] == 'completed'
    assert Path(summary['final_ir']).is_file()
    if summary.get('checkpoint_mode', 'off') != 'off':
        cost, commits = audit_transactions(summary)
    else:
        cost, commits = summary['initial_cost'], 0
        rounds = summary['rounds']
        parent = rounds[0]['parent'] if rounds else None
        for row in rounds:
            result = audit_round(row, parent, cost, set())
            if result:
                parent, cost, _ = result
                commits += 1
    assert cost == summary['final_cost'] and commits == summary['commits']
    assert sum(len(row['attempts']) for row in summary['rounds']) == summary['trials']
    print(path.parent.name, 'selection, checkpoints and retained commits verified')


if __name__ == '__main__':
    main()
