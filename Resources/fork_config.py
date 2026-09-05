"""Single fork resolver for the SGAC1.0 / SGAC2.0 dual-fork setup.

Robot Framework Variables file (contract: docs/refactor/fork-conventions.md §2).
Import it FIRST in any file that needs fork values:

    *** Settings ***
    Variables    ../Resources/fork_config.py

Resolution:

1. Read ``APP_FORK`` from the environment (default ``sgac1``).
2. Validate against the known fork set; raise loudly on anything else.
3. Read the fork's block from the ``FORKS:`` mapping in ``robotconfig.yaml``
   (contract §4) — this module is the only consumer of that mapping.
4. Return exactly the contract-pinned variables:

   APP_FORK, ANDROID_APP, ANDROID_APP_PACKAGE, ANDROID_APP_ACTIVITY,
   IOS_BUNDLE_ID, FORK_DATA_DIR

There is deliberately NO ``IOS_APP`` variable: iOS builds ship via TestFlight,
so sessions launch the installed app by ``IOS_BUNDLE_ID`` — no ipa is ever
installed by the framework. Binary paths are resolved to absolute paths but
NOT checked for existence (other machines may not hold the binaries, and
``sgac2`` must resolve before its apk exists).
"""

import os

import yaml

VALID_FORKS = ("sgac1", "sgac2")
DEFAULT_FORK = "sgac1"

_REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
_ROBOTCONFIG_PATH = os.path.join(_REPO_ROOT, "robotconfig.yaml")
_REQUIRED_FORK_KEYS = ("android_package", "android_activity", "ios_bundle_id",
                       "android_binary")


def _resolve_fork():
    fork = os.environ.get("APP_FORK", DEFAULT_FORK)
    if fork not in VALID_FORKS:
        raise ValueError(
            "Invalid APP_FORK %r: valid values are %s (unset defaults to %r)."
            % (fork, ", ".join(repr(f) for f in VALID_FORKS), DEFAULT_FORK))
    return fork


def _load_fork_block(fork):
    with open(_ROBOTCONFIG_PATH, "r", encoding="utf-8") as config_file:
        config = yaml.safe_load(config_file)
    forks = (config or {}).get("FORKS")
    if not isinstance(forks, dict):
        raise ValueError(
            "No FORKS mapping found in %s — expected the per-fork blocks "
            "defined by docs/refactor/fork-conventions.md §4."
            % _ROBOTCONFIG_PATH)
    if fork not in forks:
        raise ValueError(
            "robotconfig.yaml FORKS mapping has no %r block (found: %s)."
            % (fork, ", ".join(repr(f) for f in sorted(forks))))
    block = forks[fork]
    missing = [key for key in _REQUIRED_FORK_KEYS if key not in (block or {})]
    if missing:
        raise ValueError(
            "robotconfig.yaml FORKS[%r] is missing required keys: %s."
            % (fork, ", ".join(missing)))
    return block


def get_variables():
    fork = _resolve_fork()
    block = _load_fork_block(fork)
    return {
        "APP_FORK": fork,
        "ANDROID_APP": os.path.normpath(
            os.path.join(_REPO_ROOT, str(block["android_binary"]))),
        "ANDROID_APP_PACKAGE": str(block["android_package"]),
        "ANDROID_APP_ACTIVITY": str(block["android_activity"]),
        "IOS_BUNDLE_ID": str(block["ios_bundle_id"]),
        "FORK_DATA_DIR": os.path.join(_REPO_ROOT, "Data", fork),
    }
