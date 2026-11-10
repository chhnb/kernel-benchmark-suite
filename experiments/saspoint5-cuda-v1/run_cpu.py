# Compatibility entrypoint for historical reproduction commands.
from pathlib import Path
import runpy
runpy.run_path(str(Path(__file__).resolve().parents[2]/"tools/run_cpu.py"), run_name="__main__")
