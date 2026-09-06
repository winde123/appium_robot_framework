"""Compatibility shim for the moved QR-date validator.

The original exploratory script has been refactored into a reusable tool:

    tools/examples/qr_date_validator.py

Importing this file has no side effects.  Running it directly executes the
new script.
"""

import runpy
from pathlib import Path

_NEW_SCRIPT = Path(__file__).resolve().parents[2] / "tools" / "examples" / "qr_date_validator.py"

if __name__ == "__main__":
    runpy.run_path(str(_NEW_SCRIPT), run_name="__main__")
