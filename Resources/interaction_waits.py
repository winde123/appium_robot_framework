"""Bounded, configurable waiting helper for shared interaction keywords.

This module is intended to be imported as a Robot Framework library by
``Resources/commands.robot``.  It refactors the waiting policy behind the
public ``Click on element`` and ``Type text`` keywords so that:

* readiness (presence + visibility + enabled) is polled within a single
  wall-clock deadline,
* the click/type action is performed exactly once after readiness,
* nested full-duration retries and blind replays are avoided,
* timeout/poll are optional, validated, and produce readable diagnostics,
* the active AppiumLibrary session is reused; no new WebDriver is created.

The tunable defaults can be overridden per-suite with Robot variables or via
the environment variables ``INTERACTION_WAIT_TIMEOUT`` and
``INTERACTION_WAIT_POLL``.
"""

import math
import os
import sys
import time

from robot.api import logger
from robot.api.deco import keyword, library
from robot.libraries.BuiltIn import BuiltIn
from robot.utils import timestr_to_secs
from selenium.common.exceptions import (
    NoSuchElementException,
    StaleElementReferenceException,
)

DEFAULT_TIMEOUT = os.environ.get("INTERACTION_WAIT_TIMEOUT", "60s")
DEFAULT_POLL = os.environ.get("INTERACTION_WAIT_POLL", "0.5s")


def _get_appium_library():
    """Return the already-imported AppiumLibrary instance.

    This deliberately reuses the open session managed by AppiumLibrary and
    never creates a WebDriver itself.
    """
    return BuiltIn().get_library_instance("AppiumLibrary")


def _parse_time(value, name):
    """Convert a Robot time string/number to a positive, finite number of seconds."""
    if value is None or value == "":
        raise ValueError(f"{name} is required")
    if isinstance(value, bool):
        raise ValueError(
            f"{name} must be a time string or number, got boolean {value!r}"
        )
    try:
        seconds = timestr_to_secs(value)
    except Exception as exc:  # noqa: BLE001
        raise ValueError(
            f"{name} must be a valid Robot time string (e.g. '10s', '1min'), "
            f"got {value!r}: {exc}"
        ) from exc
    if math.isnan(seconds) or math.isinf(seconds):
        raise ValueError(
            f"{name} must be finite, got {value!r} ({seconds})"
        )
    if seconds <= 0:
        raise ValueError(
            f"{name} must be positive, got {value!r} ({seconds}s)"
        )
    return seconds


def _read_implicit_wait(driver):
    """Read the driver's implicit wait, failing loudly if it cannot be read.

    Returning a guessed default (e.g. 0) and mutating the driver could destroy
    the session's configured implicit wait and falsely claim that the deadline
    is enforced, so any read/convert failure is surfaced as a RuntimeError.
    """
    try:
        raw = driver.timeouts.implicit_wait
    except Exception as exc:  # noqa: BLE001
        raise RuntimeError(
            "Cannot read the current Appium/Selenium implicit wait; the "
            "bounded polling deadline cannot be safely enforced without "
            f"knowing the prior state: {exc}"
        ) from exc
    try:
        seconds = float(raw)
    except Exception as exc:  # noqa: BLE001
        raise RuntimeError(
            f"Current implicit wait value {raw!r} is not numeric: {exc}"
        ) from exc
    if math.isnan(seconds) or math.isinf(seconds) or seconds < 0:
        raise RuntimeError(
            f"Current implicit wait value {seconds}s is not a valid "
            "non-negative finite value"
        )
    return seconds


def _write_implicit_wait(driver, seconds):
    """Set the driver's implicit wait, failing loudly if the driver rejects it."""
    try:
        driver.implicitly_wait(float(seconds))
    except Exception as exc:  # noqa: BLE001
        raise RuntimeError(
            f"Cannot set Appium/Selenium implicit wait to {seconds}s: {exc}"
        ) from exc


def _find_ready_element(appium_lib, locator):
    """Locate the element and return it only when it is visible and enabled.

    Returns ``(element, 'ready')`` when the element is usable, otherwise
    ``(None, state)`` where ``state`` describes why it is not ready.  Only
    genuinely transient lookup failures (not-found, stale reference) are
    retried; invalid-session and other WebDriver errors propagate promptly.
    """
    try:
        element = appium_lib.get_webelement(locator)
    except (ValueError, AssertionError, StaleElementReferenceException, NoSuchElementException):
        return None, "absent"

    try:
        if not element.is_displayed():
            return None, "not visible"
        if not element.is_enabled():
            return None, "disabled"
    except StaleElementReferenceException:
        return None, "stale"

    return element, "ready"


def _wait_for_ready(
    appium_lib,
    locator,
    timeout,
    poll_interval,
    time_func=time.monotonic,
    sleep_func=time.sleep,
):
    """Poll until ``locator`` resolves to a visible/enabled element.

    The driver's implicit wait is temporarily set to 0 while polling so that
    the wall-clock deadline is respected regardless of the previous implicit
    wait value.  The original value is restored in the ``finally`` block; a
    best-effort restore is also attempted if the initial zeroing fails.

    Important: this helper can only bound its own polling loop.  Remote HTTP
    command latency and the subsequent click/type action are not hard-cancelled
    by the deadline.
    """
    timeout_secs = _parse_time(timeout, "timeout")
    poll_secs = _parse_time(poll_interval, "poll_interval")
    if poll_secs > timeout_secs:
        raise ValueError(
            f"poll_interval ({poll_secs}s) must not exceed timeout "
            f"({timeout_secs}s)"
        )

    driver = appium_lib._current_application()
    original_implicit = _read_implicit_wait(driver)

    logger.debug(
        f"Waiting up to {timeout_secs}s (poll {poll_secs}s) for "
        f"element '{locator}' to be ready."
    )

    active_exc = None
    try:
        _write_implicit_wait(driver, 0)
        deadline = time_func() + timeout_secs
        last_state = "absent"
        while True:
            element, state = _find_ready_element(appium_lib, locator)
            if element is not None:
                if time_func() > deadline:
                    raise AssertionError(
                        f"Element '{locator}' became ready after the "
                        f"{timeout_secs}s deadline had already expired."
                    )
                logger.info(f"Element '{locator}' is ready.")
                return element

            last_state = state
            now = time_func()
            remaining = deadline - now
            if remaining <= 0:
                break
            sleep_func(min(poll_secs, remaining))
            if time_func() >= deadline:
                # Do not start another poll once the deadline has been reached.
                break

        raise AssertionError(
            f"Element '{locator}' was not ready within {timeout_secs}s "
            f"(last state: {last_state}). Readiness requires the element to be "
            f"present, visible and enabled."
        )
    except Exception as exc:  # noqa: BLE001
        active_exc = exc
        raise
    finally:
        try:
            _write_implicit_wait(driver, original_implicit)
        except Exception as restore_exc:  # noqa: BLE001
            msg = (
                f"Failed to restore implicit wait to {original_implicit}s: "
                f"{restore_exc}"
            )
            if active_exc is not None:
                raise RuntimeError(msg) from active_exc
            raise


def _perform_click(element, locator):
    try:
        element.click()
    except Exception as exc:  # noqa: BLE001
        raise RuntimeError(
            f"Clicking element '{locator}' failed after it became ready: {exc}"
        ) from exc


def _perform_type(element, text, locator):
    try:
        element.send_keys(text)
    except Exception as exc:  # noqa: BLE001
        raise RuntimeError(
            f"Typing into element '{locator}' failed after it became ready: {exc}"
        ) from exc


@library(scope="GLOBAL", version="1.0.0", doc_format="ROBOT")
class InteractionWaits:
    """Robot library exposing bounded wait-and-interact keywords."""

    def __init__(
        self,
        default_timeout=DEFAULT_TIMEOUT,
        default_poll=DEFAULT_POLL,
    ):
        self.default_timeout = default_timeout
        self.default_poll = default_poll

    @keyword("Interaction Wait And Click")
    def interaction_wait_and_click(
        self, locator, timeout=None, poll_interval=None
    ):
        """Wait for ``locator`` to be ready, then click it once.

        ``timeout`` and ``poll_interval`` accept Robot time strings such as
        ``10s``, ``1min``, or ``500ms``.  When omitted, the library defaults
        are used.  Only ``None`` falls back to the default; ``0``, ``False``,
        empty strings, NaN/Inf and non-positive values are rejected.
        """
        timeout = self.default_timeout if timeout is None else timeout
        poll_interval = self.default_poll if poll_interval is None else poll_interval
        element = _wait_for_ready(
            _get_appium_library(), locator, timeout, poll_interval
        )
        _perform_click(element, locator)

    @keyword("Interaction Wait And Type")
    def interaction_wait_and_type(
        self, locator, text, timeout=None, poll_interval=None
    ):
        """Wait for ``locator`` to be ready, then type ``text`` into it once.

        See ``Interaction Wait And Click`` for timeout/poll semantics.
        """
        timeout = self.default_timeout if timeout is None else timeout
        poll_interval = self.default_poll if poll_interval is None else poll_interval
        element = _wait_for_ready(
            _get_appium_library(), locator, timeout, poll_interval
        )
        _perform_type(element, text, locator)
