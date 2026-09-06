# Interaction wait helpers

**Last reviewed:** 2026-09-06

`Resources/interaction_waits.py` is a small Robot Framework library that
centralises the waiting policy for the two most common shared interactions:

- `Click on element`
- `Type text`

Both are defined in `Resources/commands.robot` and delegate to the helpers in
this module.

## What changed and why

Previously the keywords nested `Wait Until Keyword Succeeds` retries around
`Wait Until Page Contains Element`, which could retry the full wait duration
and did not bound the total wall-clock time cleanly.  The new implementation:

- polls **once** within a single deadline for the element to be present,
  visible **and** enabled;
- performs the click or type action **exactly once** after readiness;
- avoids blind replays and overlapping timeouts;
- reuses the already-open AppiumLibrary session — it never creates a new
  WebDriver.

## Public keywords

`Click on element` and `Type text` keep their existing positional signatures
so all current callers continue to work unchanged.  Two optional named
arguments are now available on each:

| Argument | Default | Description |
|----------|---------|-------------|
| `timeout`  | `${INTERACTION_WAIT_TIMEOUT}` (`60s`) | Maximum time to wait for readiness. |
| `poll`     | `${INTERACTION_WAIT_POLL}` (`0.5s`)   | Polling interval while waiting. |

Both accept Robot Framework time strings such as `10s`, `1min`, `500ms`, or a
plain number of seconds.  `0`, empty strings, booleans, NaN/Inf and non-positive
values are rejected with a clear error.

### Examples

```robot
Click on element    ${SAVE-BUTTON}
Click on element    ${SAVE-BUTTON}    timeout=10s    poll=0.2s

Type text    ${NAME-INPUT}    ${NAME}
Type text    ${NAME-INPUT}    ${NAME}    timeout=30s
```

## Configuration

`commands.robot` reads the defaults from the environment first, so env vars are
now wired through to the public keywords:

```bash
export INTERACTION_WAIT_TIMEOUT=30s
export INTERACTION_WAIT_POLL=0.2s
robot tests/android
```

Defaults can also be overridden per run with Robot variables (which take
precedence over the environment):

```bash
robot --variable INTERACTION_WAIT_TIMEOUT:30s --variable INTERACTION_WAIT_POLL:0.2s tests/android
```

## Readiness semantics

An element is considered ready only when **all** of the following are true:

1. AppiumLibrary can find it (`get_webelement` returns a match).
2. `is_displayed()` returns `True`.
3. `is_enabled()` returns `True`.

If the timeout expires, the failure message reports the last observed state
(`absent`, `not visible`, `disabled`, or `stale`) so failures are easier to
diagnose.  Only genuinely transient lookup failures are retried; invalid
session and other WebDriver errors propagate immediately.

## Implicit-wait handling

AppiumLibrary/Selenium implicit waits can silently extend a `find_element`
call beyond the requested deadline.  While polling, the helper temporarily
sets the driver's implicit wait to `0` and restores the original value
afterwards (even on failure).  If the current implicit wait cannot be read or
mutated, the error is surfaced instead of guessed, and the original exception
is preserved when a restore failure occurs.

## Deadline limits

The polling deadline bounds only the readiness-polling loop.  It does **not**
hard-cancel remote HTTP command latency inside the Appium driver or the
subsequent click/type action.  A result that becomes ready after the deadline
has already passed is rejected.

## Portable verification commands

```bash
# Unit tests
/Users/edwinwan/Documents/Projects/appium_robot_framework/venv/bin/python -B -m pytest -q -p no:cacheprovider tests/unit/test_interaction_waits.py

# Fork dryruns
APP_FORK=sgac1 /Users/edwinwan/Documents/Projects/appium_robot_framework/venv/bin/python -B -m robot --dryrun --output NONE --log NONE --report NONE tests
APP_FORK=sgac2 /Users/edwinwan/Documents/Projects/appium_robot_framework/venv/bin/python -B -m robot --dryrun --output NONE --log NONE --report NONE tests

# Parity linter
APP_FORK=sgac1 /Users/edwinwan/Documents/Projects/appium_robot_framework/venv/bin/python -B tools/check_fork_parity.py --strict
```

## Device validation limitations

The unit tests in `tests/unit/test_interaction_waits.py` exercise the helper
with fake AppiumLibrary/WebDriver objects and a controllable clock.  They do
**not** validate:

- real device or emulator timing;
- actual Appium server/session behaviour;
- platform-specific locator resolution beyond what AppiumLibrary's
  `get_webelement` provides;
- whether an element is truly clickable/typeable in the UI (only visibility
  and enabled state are checked).

These behaviours are still owned by AppiumLibrary and the underlying drivers.

## Files

- `Resources/interaction_waits.py` — implementation.
- `Resources/commands.robot` — public `Click on element` / `Type text` wrappers.
- `tests/unit/test_interaction_waits.py` — device-free unit tests.
