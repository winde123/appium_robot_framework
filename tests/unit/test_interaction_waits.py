"""Unit tests for Resources/interaction_waits.py.

These tests use fake AppiumLibrary/WebDriver objects and a controllable
clock so they never contact a device, Appium server, or the network.
"""

import importlib.util
import json
import math
import os
import subprocess
import sys

import pytest


def _load_interaction_waits():
    """Load the library via importlib so the test file never mutates sys.path."""
    repo_root = os.path.dirname(
        os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    )
    path = os.path.join(repo_root, "Resources", "interaction_waits.py")
    spec = importlib.util.spec_from_file_location("Resources.interaction_waits", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


iw = _load_interaction_waits()


class FakeElement:
    """Minimal WebElement stand-in for unit tests."""

    def __init__(
        self,
        displayed=True,
        enabled=True,
        click_exc=None,
        send_exc=None,
    ):
        self._displayed = displayed
        self._enabled = enabled
        self.click_exc = click_exc
        self.send_exc = send_exc
        self.click_count = 0
        self.send_count = 0
        self.sent_text = None

    def is_displayed(self):
        return self._displayed

    def is_enabled(self):
        return self._enabled

    def click(self):
        self.click_count += 1
        if self.click_exc is not None:
            raise self.click_exc

    def send_keys(self, text):
        self.send_count += 1
        self.sent_text = text
        if self.send_exc is not None:
            raise self.send_exc


class FakeTimeouts:
    def __init__(self, value=5.0, exc=None):
        self._value = value
        self._exc = exc

    @property
    def implicit_wait(self):
        if self._exc is not None:
            raise self._exc
        return self._value


class FakeDriver:
    """Minimal WebDriver stand-in that records implicit-wait changes."""

    def __init__(self, implicit_wait=5.0, read_exc=None, set_exc=None):
        self.timeouts = FakeTimeouts(implicit_wait, read_exc)
        self._set_exc = set_exc
        self.implicit_wait_log = []

    def implicitly_wait(self, seconds):
        if self._set_exc is not None:
            raise self._set_exc
        self.implicit_wait_log.append(seconds)
        self.timeouts._value = seconds


class RestoreFailDriver(FakeDriver):
    """Allows the first set (to 0) but fails the restore."""

    def __init__(self, implicit_wait=5.0):
        super().__init__(implicit_wait)
        self._call_count = 0

    def implicitly_wait(self, seconds):
        self._call_count += 1
        if self._call_count == 2:
            raise RuntimeError("restore failed")
        self.implicit_wait_log.append(seconds)
        self.timeouts._value = seconds


class PartialSetDriver(FakeDriver):
    """Applies the requested value, then raises on the first call only."""

    def __init__(self, implicit_wait=5.0):
        super().__init__(implicit_wait)
        self._call_count = 0

    def implicitly_wait(self, seconds):
        self._call_count += 1
        self.implicit_wait_log.append(seconds)
        self.timeouts._value = seconds
        if self._call_count == 1:
            raise RuntimeError("set to 0 lost response")


class InitialAndRestoreFailDriver(FakeDriver):
    """Fails on every call after applying the value."""

    def __init__(self, implicit_wait=5.0):
        super().__init__(implicit_wait)
        self._call_count = 0

    def implicitly_wait(self, seconds):
        self._call_count += 1
        self.implicit_wait_log.append(seconds)
        self.timeouts._value = seconds
        raise RuntimeError(f"fail call {self._call_count}")


class FakeAppiumLib:
    """Stand-in for AppiumLibrary that returns scripted element responses."""

    def __init__(self, responses=None, driver=None):
        self.responses = list(responses) if responses is not None else []
        self.driver = driver if driver is not None else FakeDriver()
        self.calls = []
        self._index = 0
        self.on_get_webelement = None

    def get_webelement(self, locator):
        self.calls.append(locator)
        if self.on_get_webelement is not None:
            self.on_get_webelement()
        if self._index >= len(self.responses):
            raise ValueError("element not found")
        response = self.responses[self._index]
        self._index += 1
        if isinstance(response, Exception):
            raise response
        if response is None:
            raise ValueError("element not found")
        return response

    def _current_application(self):
        return self.driver


class Clock:
    """Deterministic clock for wait-policy tests."""

    def __init__(self, start=0.0):
        self.now = start

    def time(self):
        return self.now

    def sleep(self, seconds):
        self.now += seconds

    def advance(self, seconds):
        self.now += seconds


def make_clock(start=0.0):
    """Return a deterministic ``time_func``/``sleep_func`` pair."""
    clock = Clock(start)
    return clock.time, clock.sleep


# ---------------------------------------------------------------------------
# Argument validation
# ---------------------------------------------------------------------------

@pytest.mark.parametrize(
    "value,expected",
    [
        ("10s", 10.0),
        ("1min", 60.0),
        ("500ms", 0.5),
        ("30", 30.0),
        (15, 15.0),
        (0.25, 0.25),
    ],
)
def test_parse_time_accepts_valid_strings_and_numbers(value, expected):
    assert iw._parse_time(value, "timeout") == expected


@pytest.mark.parametrize(
    "value",
    ["", None, "not-a-time", -5, 0, "0s", True, False, float("nan"), float("inf")],
)
def test_parse_time_rejects_invalid_or_non_positive_values(value):
    with pytest.raises(ValueError):
        iw._parse_time(value, "timeout")


def test_poll_interval_must_not_exceed_timeout():
    fake = FakeAppiumLib()
    with pytest.raises(ValueError, match="poll_interval .* must not exceed"):
        iw._wait_for_ready(fake, "//foo", "1s", "5s", *make_clock())


# ---------------------------------------------------------------------------
# Public keyword wrappers
# ---------------------------------------------------------------------------

@pytest.mark.parametrize("bad_timeout", [0, -1, "", False, float("nan")])
def test_click_wrapper_rejects_invalid_timeouts(monkeypatch, bad_timeout):
    fake = FakeAppiumLib([FakeElement()])
    monkeypatch.setattr(iw, "_get_appium_library", lambda: fake)
    lib = iw.InteractionWaits(default_timeout="0.2s", default_poll="0.01s")

    with pytest.raises(ValueError):
        lib.interaction_wait_and_click("//x", timeout=bad_timeout)

    assert fake.calls == []  # validation fails before touching the driver


@pytest.mark.parametrize("bad_poll", [0, -1, "", False, float("inf")])
def test_type_wrapper_rejects_invalid_poll_intervals(monkeypatch, bad_poll):
    fake = FakeAppiumLib([FakeElement()])
    monkeypatch.setattr(iw, "_get_appium_library", lambda: fake)
    lib = iw.InteractionWaits()

    with pytest.raises(ValueError):
        lib.interaction_wait_and_type("//x", "hi", poll_interval=bad_poll)

    assert fake.calls == []


def test_wrapper_uses_default_only_for_none(monkeypatch):
    element = FakeElement()
    fake = FakeAppiumLib([element])
    monkeypatch.setattr(iw, "_get_appium_library", lambda: fake)

    lib = iw.InteractionWaits(default_timeout="0.1s", default_poll="0.01s")
    lib.interaction_wait_and_click("//x", timeout=None, poll_interval=None)

    assert element.click_count == 1


# ---------------------------------------------------------------------------
# Successful readiness and single action
# ---------------------------------------------------------------------------

def test_wait_for_ready_returns_ready_element():
    element = FakeElement()
    fake = FakeAppiumLib([element])
    result = iw._wait_for_ready(fake, "//foo", "2s", "0.5s", *make_clock())
    assert result is element
    assert fake.calls == ["//foo"]


def test_action_click_performed_exactly_once():
    element = FakeElement()
    iw._perform_click(element, "//foo")
    assert element.click_count == 1


def test_action_type_performed_exactly_once_with_text():
    element = FakeElement()
    iw._perform_type(element, "hello", "//input")
    assert element.send_count == 1
    assert element.sent_text == "hello"


# ---------------------------------------------------------------------------
# Polling behaviour
# ---------------------------------------------------------------------------

def test_wait_for_ready_polls_until_element_appears():
    ready_element = FakeElement()
    fake = FakeAppiumLib([None, None, ready_element])
    clock = Clock()

    result = iw._wait_for_ready(fake, "//foo", "2s", "0.5s", clock.time, clock.sleep)

    assert result is ready_element
    assert fake.calls == ["//foo", "//foo", "//foo"]
    assert clock.now == 1.0  # two sleeps of 0.5s


def test_wait_for_ready_polls_until_element_becomes_enabled():
    disabled = FakeElement(enabled=False)
    ready = FakeElement()
    fake = FakeAppiumLib([disabled, ready])
    clock = Clock()

    result = iw._wait_for_ready(fake, "//foo", "2s", "0.5s", clock.time, clock.sleep)

    assert result is ready
    assert clock.now == 0.5


def test_wait_for_ready_treats_stale_element_as_absent_and_retries():
    from selenium.common.exceptions import StaleElementReferenceException

    stale = FakeElement()
    stale.is_displayed = lambda: (_ for _ in ()).throw(
        StaleElementReferenceException("stale")
    )
    ready = FakeElement()
    fake = FakeAppiumLib([stale, ready])

    result = iw._wait_for_ready(fake, "//foo", "2s", "0.5s", *make_clock())

    assert result is ready


# ---------------------------------------------------------------------------
# Timeout diagnostics
# ---------------------------------------------------------------------------

def test_wait_for_ready_absent_times_out():
    fake = FakeAppiumLib([None, None, None])
    clock = Clock()

    with pytest.raises(AssertionError, match="last state: absent") as exc_info:
        iw._wait_for_ready(fake, "//missing", "1s", "0.5s", clock.time, clock.sleep)

    assert "//missing" in str(exc_info.value)
    assert clock.now == 1.0  # deadline reached without overshooting
    # The final poll exactly at the deadline is avoided.
    assert len(fake.calls) == 2


def test_wait_for_ready_disabled_times_out():
    fake = FakeAppiumLib([FakeElement(enabled=False)] * 5)
    clock = Clock()

    with pytest.raises(AssertionError, match="last state: disabled"):
        iw._wait_for_ready(fake, "//locked", "0.4s", "0.2s", clock.time, clock.sleep)

    assert len(fake.calls) == 2


def test_wait_for_ready_not_visible_times_out():
    fake = FakeAppiumLib([FakeElement(displayed=False)] * 5)
    clock = Clock()

    with pytest.raises(AssertionError, match="last state: not visible"):
        iw._wait_for_ready(fake, "//hidden", "0.4s", "0.2s", clock.time, clock.sleep)

    assert len(fake.calls) == 2


def test_wait_for_ready_rejects_result_that_arrives_after_deadline():
    clock = Clock()
    element = FakeElement()
    fake = FakeAppiumLib([element])
    fake.on_get_webelement = lambda: clock.advance(1.0)

    with pytest.raises(AssertionError, match=r"became ready after the .+ deadline"):
        iw._wait_for_ready(fake, "//slow", "0.5s", "0.1s", clock.time, clock.sleep)


def test_wait_for_ready_accepts_result_before_deadline():
    clock = Clock()
    element = FakeElement()
    fake = FakeAppiumLib([element])
    fake.on_get_webelement = lambda: clock.advance(0.4)

    result = iw._wait_for_ready(fake, "//ok", "0.5s", "0.1s", clock.time, clock.sleep)

    assert result is element


# ---------------------------------------------------------------------------
# Exception filtering
# ---------------------------------------------------------------------------

def test_invalid_session_error_propagates_promptly():
    from selenium.common.exceptions import WebDriverException

    fake = FakeAppiumLib([WebDriverException("invalid session")])
    with pytest.raises(WebDriverException, match="invalid session"):
        iw._wait_for_ready(fake, "//x", "0.2s", "0.1s", *make_clock())


# ---------------------------------------------------------------------------
# Action exceptions
# ---------------------------------------------------------------------------

def test_perform_click_wraps_exception():
    exc = RuntimeError("intercepted")
    element = FakeElement(click_exc=exc)
    with pytest.raises(RuntimeError, match="Clicking element '//foo' failed"):
        iw._perform_click(element, "//foo")
    assert element.click_count == 1


def test_perform_type_wraps_exception():
    exc = RuntimeError("keyboard hidden")
    element = FakeElement(send_exc=exc)
    with pytest.raises(RuntimeError, match="Typing into element '//input' failed"):
        iw._perform_type(element, "text", "//input")
    assert element.send_count == 1


# ---------------------------------------------------------------------------
# Implicit-wait safety
# ---------------------------------------------------------------------------

def test_implicit_wait_zeroed_during_polling_and_restored_on_success():
    driver = FakeDriver(implicit_wait=7.0)
    fake = FakeAppiumLib([FakeElement()], driver=driver)

    iw._wait_for_ready(fake, "//foo", "1s", "0.2s", *make_clock())

    assert driver.implicit_wait_log == [0.0, 7.0]
    assert driver.timeouts.implicit_wait == 7.0


def test_implicit_wait_restored_on_timeout():
    driver = FakeDriver(implicit_wait=3.0)
    fake = FakeAppiumLib([None], driver=driver)

    with pytest.raises(AssertionError):
        iw._wait_for_ready(fake, "//foo", "0.2s", "0.1s", *make_clock())

    assert driver.implicit_wait_log == [0.0, 3.0]
    assert driver.timeouts.implicit_wait == 3.0


def test_implicit_wait_read_failure_is_surfaced():
    driver = FakeDriver(read_exc=RuntimeError("timeouts unavailable"))
    fake = FakeAppiumLib(driver=driver)

    with pytest.raises(RuntimeError, match="Cannot read the current Appium/Selenium implicit wait"):
        iw._wait_for_ready(fake, "//foo", "1s", "0.2s", *make_clock())

    assert driver.implicit_wait_log == []


def test_implicit_wait_set_failure_is_surfaced():
    driver = FakeDriver(set_exc=RuntimeError("cannot mutate"))
    fake = FakeAppiumLib(driver=driver)

    with pytest.raises(RuntimeError, match="Cannot set Appium/Selenium implicit wait"):
        iw._wait_for_ready(fake, "//foo", "1s", "0.2s", *make_clock())

    assert driver.implicit_wait_log == []


def test_initial_set_failure_still_attempts_restore():
    driver = PartialSetDriver(implicit_wait=4.0)
    fake = FakeAppiumLib(driver=driver)

    with pytest.raises(RuntimeError, match="set to 0 lost response"):
        iw._wait_for_ready(fake, "//foo", "0.2s", "0.1s", *make_clock())

    # The zero was applied but the response was lost; restore was still tried.
    assert driver.implicit_wait_log == [0.0, 4.0]
    assert driver.timeouts.implicit_wait == 4.0


def test_initial_and_restore_failure_preserves_initial_exception():
    driver = InitialAndRestoreFailDriver(implicit_wait=4.0)
    fake = FakeAppiumLib(driver=driver)

    with pytest.raises(RuntimeError, match="Failed to restore implicit wait") as exc_info:
        iw._wait_for_ready(fake, "//foo", "0.2s", "0.1s", *make_clock())

    assert exc_info.value.__cause__ is not None
    assert "fail call 1" in str(exc_info.value.__cause__)
    assert driver.implicit_wait_log == [0.0, 4.0]


def test_implicit_wait_restore_failure_chains_timeout_exception():
    driver = RestoreFailDriver(implicit_wait=3.0)
    fake = FakeAppiumLib([None], driver=driver)

    with pytest.raises(RuntimeError, match="Failed to restore implicit wait") as exc_info:
        iw._wait_for_ready(fake, "//foo", "0.2s", "0.1s", *make_clock())

    assert exc_info.value.__cause__ is not None
    assert "was not ready within" in str(exc_info.value.__cause__)
    assert driver.implicit_wait_log == [0.0]


def test_implicit_wait_restore_failure_chains_lookup_exception():
    from selenium.common.exceptions import WebDriverException

    driver = RestoreFailDriver(implicit_wait=3.0)
    fake = FakeAppiumLib([WebDriverException("invalid session")], driver=driver)

    with pytest.raises(RuntimeError, match="Failed to restore implicit wait") as exc_info:
        iw._wait_for_ready(fake, "//foo", "0.2s", "0.1s", *make_clock())

    assert exc_info.value.__cause__ is not None
    assert "invalid session" in str(exc_info.value.__cause__)


# ---------------------------------------------------------------------------
# Locator preservation
# ---------------------------------------------------------------------------

@pytest.mark.parametrize(
    "locator",
    [
        "//android.widget.Button[@text='Save']",
        "xpath=//android.widget.Button[@text='Save']",
        "id=sg.gov.ica.mobile.app:id/button",
        "accessibility_id=SaveButton",
    ],
)
def test_wait_for_ready_passes_locator_through_unmodified(locator):
    fake = FakeAppiumLib([FakeElement()])
    iw._wait_for_ready(fake, locator, "1s", "0.2s", *make_clock())
    assert fake.calls == [locator]


# ---------------------------------------------------------------------------
# Robot keyword wrappers (integration with AppiumLibrary lookup)
# ---------------------------------------------------------------------------

def test_interaction_wait_and_click_uses_current_appium_session(monkeypatch):
    element = FakeElement()
    fake = FakeAppiumLib([element])
    monkeypatch.setattr(iw, "_get_appium_library", lambda: fake)

    lib = iw.InteractionWaits()
    lib.interaction_wait_and_click("xpath=//btn", timeout="0.2s", poll_interval="0.05s")

    assert element.click_count == 1
    assert fake.calls == ["xpath=//btn"]


def test_interaction_wait_and_type_uses_current_appium_session(monkeypatch):
    element = FakeElement()
    fake = FakeAppiumLib([element])
    monkeypatch.setattr(iw, "_get_appium_library", lambda: fake)

    lib = iw.InteractionWaits()
    lib.interaction_wait_and_type(
        "xpath=//input", "hello", timeout="0.2s", poll_interval="0.05s"
    )

    assert element.send_count == 1
    assert element.sent_text == "hello"
    assert fake.calls == ["xpath=//input"]


# ---------------------------------------------------------------------------
# ACTUAL commands.robot delegation/config with a stub AppiumLibrary
# ---------------------------------------------------------------------------

def test_commands_robot_delegation_and_env_config(tmp_path, monkeypatch):
    """Run Robot against the real commands.robot with a fake AppiumLibrary."""
    repo_root = os.path.dirname(
        os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    )

    fake_lib_dir = tmp_path / "fake_appium_library"
    fake_lib_dir.mkdir()
    fake_module = fake_lib_dir / "AppiumLibrary.py"
    results_file = tmp_path / "results.json"

    fake_module.write_text(
        """
import json
import os

RESULTS_FILE = os.environ.get('FAKE_APPIUM_RESULTS')

class _FakeElement:
    def __init__(self, recorder):
        self._recorder = recorder

    def is_displayed(self):
        self._recorder('is_displayed')
        return True

    def is_enabled(self):
        self._recorder('is_enabled')
        return True

    def click(self):
        self._recorder('click')

    def send_keys(self, text):
        self._recorder('send_keys:' + text)


class _FakeDriver:
    def __init__(self, recorder):
        self._recorder = recorder
        self.timeouts = type('T', (), {'implicit_wait': 5.0})()

    def implicitly_wait(self, seconds):
        self._recorder('implicit_wait:' + str(seconds))
        self.timeouts.implicit_wait = seconds


class AppiumLibrary:
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def __init__(self):
        self._calls = []
        self._driver = _FakeDriver(self._record)
        self._element = _FakeElement(self._record)

    def _record(self, item):
        self._calls.append(item)
        if RESULTS_FILE:
            with open(RESULTS_FILE, 'w') as f:
                json.dump(self._calls, f)

    def open_application(self, **kwargs):
        pass

    def click_element(self, locator):
        pass

    def input_text(self, locator, text):
        pass

    def swipe_by_percent(self, *args, **kwargs):
        pass

    def terminate_application(self, app_id):
        pass

    def get_webelement(self, locator):
        self._record('get_webelement:' + locator)
        return self._element

    def _current_application(self):
        return self._driver
"""
    )

    robot_file = tmp_path / "delegation.robot"
    robot_file.write_text(
        f"""*** Settings ***
Resource    {os.path.join(repo_root, 'Resources', 'commands.robot')}

*** Variables ***
${{LOC}}    xpath=//button

*** Test Cases ***
Env Defaults And Delegation
    Should Be Equal    ${{INTERACTION_WAIT_TIMEOUT}}    0.3s
    Should Be Equal    ${{INTERACTION_WAIT_POLL}}    0.05s
    Click on element    ${{LOC}}
    Type text    ${{LOC}}    hello
"""
    )

    env = os.environ.copy()
    env["APP_FORK"] = "sgac1"
    env["INTERACTION_WAIT_TIMEOUT"] = "0.3s"
    env["INTERACTION_WAIT_POLL"] = "0.05s"
    env["FAKE_APPIUM_RESULTS"] = str(results_file)
    existing_pythonpath = env.get("PYTHONPATH", "")
    env["PYTHONPATH"] = str(fake_lib_dir) + (
        os.pathsep + existing_pythonpath if existing_pythonpath else ""
    )

    result = subprocess.run(
        [
            sys.executable,
            "-B",
            "-m",
            "robot",
            "--output",
            "NONE",
            "--log",
            "NONE",
            "--report",
            "NONE",
            "-d",
            str(tmp_path),
            str(robot_file),
        ],
        env=env,
        capture_output=True,
        text=True,
    )

    if result.returncode != 0:
        pytest.fail(
            f"Robot run failed ({result.returncode}):\nSTDOUT:\n{result.stdout}\nSTDERR:\n{result.stderr}"
        )

    recorded = json.loads(results_file.read_text())

    # Each interaction: set implicit wait to 0, find element, check visible,
    # check enabled, restore implicit wait, then act.  Restoring before the
    # action is intentional: the bounded helper owns only the readiness poll.
    assert recorded == [
        "implicit_wait:0.0",
        "get_webelement:xpath=//button",
        "is_displayed",
        "is_enabled",
        "implicit_wait:5.0",
        "click",
        "implicit_wait:0.0",
        "get_webelement:xpath=//button",
        "is_displayed",
        "is_enabled",
        "implicit_wait:5.0",
        "send_keys:hello",
    ]
