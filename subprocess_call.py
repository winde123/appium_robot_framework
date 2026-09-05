#!/usr/bin/env python3
"""Start the Appium server with the insecure adb_shell feature enabled.

The Android NRIC secure-field keyword types via `adb shell`, which Appium only
permits when started with `--allow-insecure UiAutomator2:adb_shell`. Run this
in its own terminal before `robot`; stop the server with Ctrl+C.

Usage:
    python3 subprocess_call.py [--dry-run] [extra appium args...]

Extra arguments are forwarded to appium verbatim (e.g. `--port 4724`).
`--dry-run` prints the command that would run, without starting the server.

The child process inherits this shell's environment untouched, so an exported
APP_FORK (sgac1 default | sgac2) passes through to Appium and anything it
launches; when APP_FORK is unset the environment is left as-is.
"""

import os
import shutil
import subprocess
import sys

APPIUM_ARGS = ["--allow-insecure", "UiAutomator2:adb_shell"]


def build_command(extra_args):
    """Return the appium argv; resolve the binary via PATH when possible."""
    appium = shutil.which("appium") or "appium"
    return [appium, *APPIUM_ARGS, *extra_args]


def main(argv):
    dry_run = "--dry-run" in argv
    extra_args = [arg for arg in argv if arg != "--dry-run"]
    command = build_command(extra_args)

    print("Starting Appium server:")
    print(f"  {' '.join(command)}")
    fork = os.environ.get("APP_FORK")
    if fork:
        print(f"  APP_FORK={fork} (inherited by the Appium process)")
    else:
        print("  APP_FORK not set (downstream tooling defaults to sgac1)")
    print("Appium logs stream to this terminal. Press Ctrl+C to stop the server.")

    if dry_run:
        print("--dry-run: server not started.")
        return 0

    try:
        return subprocess.call(command)
    except FileNotFoundError:
        print(
            "error: `appium` was not found on PATH. "
            "Install it with `npm install -g appium` or open a shell where it is available.",
            file=sys.stderr,
        )
        return 1
    except KeyboardInterrupt:
        print("\nAppium server stopped.")
        return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
