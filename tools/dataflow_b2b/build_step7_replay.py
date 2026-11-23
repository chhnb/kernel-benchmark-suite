#!/usr/bin/env python3
"""Build a research-only greedy executable with one selected-trial substitution."""
import argparse
from pathlib import Path

START = ' std::string current=argv[1],fn=argv[2],out=argv[argc-1];'
SELECT = '  mark("read_scores_and_select");'
END = ' if(auto e=sys::fs::copy_file(current,out+"/final.ll"))'


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("output", type=Path)
    args = p.parse_args()
    text = Path("tools/decision_greedy_main.cpp").read_text()
    assert all(text.count(mark) == 1 for mark in (START, SELECT, END))
    text = text.replace(START, START + """
 const char *path = std::getenv("STEP7_OVERRIDE");
 if (!path) throw std::runtime_error("STEP7_OVERRIDE required");
 auto config = read(path);
 auto &override = *config.getAsObject();
 auto chosenRound = *override.getInteger("round");
 auto chosenTrial = *override.getString("trial");
 auto chosenCandidate = *override.getString("candidate");
 auto chosenCost = *override.getInteger("cost");
 auto chosenParent = *override.getInteger("parent_cost");
 auto chosenIR = *override.getString("ir");
 bool overridden = false;""")
    text = text.replace(SELECT, """
  if (rounds.size() == static_cast<size_t>(chosenRound)) {
    if (parentCost != chosenParent)
      throw std::runtime_error("override parent cost differs");
    bool found = false;
    for (auto &trial : structuralTrials) {
      if (sys::path::filename(trial.directory) != chosenTrial)
        continue;
      auto actual = read(trial.directory + "/structural/trial-0/trial.json");
      if (actual.getAsObject()->getString("candidate") != Optional<StringRef>(chosenCandidate))
        throw std::runtime_error("override candidate differs");
      auto replacement = parseIRFile(chosenIR, error, ctx);
      if (!replacement || verifyModule(*replacement, &errs()))
        throw std::runtime_error("invalid override IR");
      best = trial.directory;
      bestCost = chosenCost;
      bestPreparedOrdinal = trial.preparedOrdinal;
      bestIsNormalizeOnly = false;
      writeModule(*replacement, best + "/fused.ll");
      found = overridden = true;
      break;
    }
    if (!found) throw std::runtime_error("override requested trial missing");
  }
""" + SELECT)
    text = text.replace(END, ' if(!overridden)throw std::runtime_error("override never applied");\n' + END)
    # structuralTrials is owned by the structural dispatch block; substitute
    # inside it after all ordinary trials have been evaluated.
    marker = '\n    }\n  }\n\n  if (rounds.size()'
    assert text.count(marker) == 1
    text = text.replace(marker, '\n    }\n\n  if (rounds.size()')
    text = text.replace(SELECT, '  }\n' + SELECT)
    args.output.write_text(text)


if __name__ == "__main__":
    main()
