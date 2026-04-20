import runpy
from pathlib import Path
# циклогексан (н-гексан) – метанол

BASE_DIR = Path(__file__).resolve().parent
LAB_UNIFAC_PATH = BASE_DIR / "lab_5_PR_UNIFAC.py"
LAB_PR_PATH = BASE_DIR / "lab_5_peng_robinson.py"


def run_script(script_path: Path) -> None:
	print(f"\nRunning {script_path.name}")
	runpy.run_path(str(script_path), run_name="__main__")


def main() -> None:
	run_script(LAB_UNIFAC_PATH)
	run_script(LAB_PR_PATH)


if __name__ == "__main__":
	main()
