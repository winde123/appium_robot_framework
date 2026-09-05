"""TRANSITION shim (T10) — delete in T11.

Kept only because ``Resources/commands.robot`` still imports this file as a
Variables file; T11 replaces that import with ``fork_config.py`` and removes
this module. No app filename is hardcoded here.

- ``ANDROID_APP`` and ``ANDROID_APP_PACKAGE`` delegate to
  ``Resources/fork_config.py`` (the single fork resolver). The flat
  ``ANDROID_APP_PACKAGE`` key was removed from ``robotconfig.yaml`` by T10,
  but ``commands.robot`` still references ``${ANDROID_APP_PACKAGE}`` until
  T11 rewires it — so the shim re-exports it from the fork block.
- ``IOS_APP`` is the legacy springboard ipa (``icaApp/sgac_test.ipa``),
  passed as ``appium:app`` with ``noReset`` to launch the TestFlight-installed
  build. It carries the SGAC1.0 bundle ID. T11 switches the iOS keyword to
  ``appium:bundleId=${IOS_BUNDLE_ID}`` and drops this variable — there is no
  ``IOS_APP`` in the target contract.
"""

import os

from fork_config import get_variables as _get_fork_variables

__all__ = ["ANDROID_APP", "ANDROID_APP_PACKAGE", "IOS_APP"]

_REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
_FORK_VARIABLES = _get_fork_variables()

ANDROID_APP = _FORK_VARIABLES["ANDROID_APP"]
ANDROID_APP_PACKAGE = _FORK_VARIABLES["ANDROID_APP_PACKAGE"]
IOS_APP = os.path.join(_REPO_ROOT, "icaApp", "sgac_test.ipa")
