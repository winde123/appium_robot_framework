"""Device-free unit tests for the reusable iOS e-services templates.

These tests parse the refactored Robot suites and verify that:
- the expected Test Template is declared (settings-level or per-case),
- every original test case is preserved with its original name,
- the case-to-locator/assertion mapping is unchanged,
- fork tags, setup/teardown and variable imports are retained, and
- the shared template keyword in Resources/ios/eservices_commands.robot has the
  expected signature and body.

No Appium session, device access, network call or real image I/O is used.
"""

__all__ = ["EXPECTED_CASES", "NON_TEMPLATE_CASES", "TEMPLATE_KEYWORD"]

import importlib
import os
import sys
import tempfile
import textwrap
import uuid
from pathlib import Path

import pytest
import yaml

from robot.api.parsing import (
    Arguments,
    Documentation,
    Keyword,
    KeywordCall,
    ResourceImport,
    Tags,
    Template,
    TemplateArguments,
    TestCase as RobotTestCase,
    TestCaseSection as RobotTestCaseSection,
    TestSetup as RobotTestSetup,
    TestTags as RobotTestTags,
    TestTeardown as RobotTestTeardown,
    TestTemplate as RobotTestTemplate,
    VariablesImport,
    get_model,
)
from robot.running import TestSuite as RobotTestSuite

REPO_ROOT = Path(__file__).resolve().parents[2]
OWNED_DIR = REPO_ROOT / "tests" / "ios" / "other_e_services"
RESOURCE_FILE = REPO_ROOT / "Resources" / "ios" / "eservices_commands.robot"
TEMPLATE_KEYWORD = "Open E-Service Portal And Verify"


def _fav_button_locator(fork="sgac1"):
    path = REPO_ROOT / "Data" / fork / "ios" / "landing_page.yaml"
    with path.open() as f:
        data = yaml.safe_load(f)
    return data["OTHER-E-SERVICES-FAV-BUTTON"].strip()

# Canonical expectations derived from the original pre-template test bodies.
# Each entry maps a suite file stem to a list of (test_name, portal_locator,
# card_count, tab_locator, header_locator) tuples.  ${EMPTY} means the original
# test did not assert a portal-specific header.
EXPECTED_CASES = {
    "check_validity_verify_services": [
        (
            "Navigating to verify validity of IC page",
            "${E-SERVICES-CHECK-VALIDITY-VERIFY}",
            "8",
            "${VERIFY-VALIDITY-IC-TAB}",
            "${VERIFY-VALIDITY-IC-HEADER-ELEM}",
        ),
        (
            "Navigating to verify validity of immigration pass page",
            "${E-SERVICES-CHECK-VALIDITY-VERIFY}",
            "8",
            "${IMMIGRATION-PASS-LTVP-STUDENT-PASS-TAB}",
            "${IMMIGRATION-PASS-LTVP-STUDENT-PASS-HEADER-ELEM}",
        ),
        (
            "Navigating to verify validity of digital birth page",
            "${E-SERVICES-CHECK-VALIDITY-VERIFY}",
            "8",
            "${DIGITAL-BIRTH-CERTIFICATE-TAB}",
            "${DIGITAL-BIRTH-CERTIFICATE-HEADER-ELEM}",
        ),
        (
            "Navigating to verify validity of digital birth extract page",
            "${E-SERVICES-CHECK-VALIDITY-VERIFY}",
            "8",
            "${DIGITAL-BIRTH-EXTRACT-TAB}",
            "${DIGITAL-BIRTH-EXTRACT-HEADER-ELEM}",
        ),
        (
            "Navigating to verify validity of digital death cert page",
            "${E-SERVICES-CHECK-VALIDITY-VERIFY}",
            "8",
            "${DIGITAL-DEATH-CERTIFICATE-TAB}",
            "${DIGITAL-DEATH-CERTIFICATE-HEADER-ELEM}",
        ),
        (
            "Navigating to verify validity of digital death extract page",
            "${E-SERVICES-CHECK-VALIDITY-VERIFY}",
            "8",
            "${DIGITAL-DEATH-EXTRACT-TAB}",
            "${DIGITAL-DEATH-EXTRACT-HEADER-ELEM}",
        ),
        (
            "Navigating to verify validity of digital stillbirth cert page",
            "${E-SERVICES-CHECK-VALIDITY-VERIFY}",
            "8",
            "${DIGITAL-STILLBIRTH-CERTIFICATE-TAB}",
            "${DIGITAL-STILLBIRTH-CERTIFICATE-HEADER-ELEM}",
        ),
        (
            "Navigating to verify validity of digital stillbirth extract cert page",
            "${E-SERVICES-CHECK-VALIDITY-VERIFY}",
            "8",
            "${DIGITAL-STILLBIRTH-EXTRACT-TAB}",
            "${DIGITAL-STILLBIRTH-EXTRACT-HEADER-ELEM}",
        ),
    ],
    "other_services": [
        (
            "Navigating to apply for apec business travel card page",
            "${E-SERVICES-OTHERS}",
            "3",
            "${OTHERS-APEC-BUSINESS-TRAVEL-CARD-TAB}",
            "${OTHERS-APEC-BUSINESS-TRAVEL-HEADER-ELEM}",
        ),
        (
            "Navigating to apply for usa trusted traveller program page",
            "${E-SERVICES-OTHERS}",
            "3",
            "${OTHERS-US-TRUSTED-TRAVELLER-PROGRAMME-TAB}",
            "${EMPTY}",
        ),
        (
            "Navigating to apply for change race / dialect page",
            "${E-SERVICES-OTHERS}",
            "3",
            "${OTHERS-CHANGE-RACE-DIALECT-TAB}",
            "${OTHERS-CHANGE-RACE-DIALECT-HEADER-ELEM}",
        ),
    ],
    "birth_death_services": [
        (
            "Navigating to apply for birth/death extract page",
            "${E-SERVICES-BIRTH-DEATH}",
            "1",
            "${BIRTH-DEATH-APPLY-EXTRACT-TAB}",
            "${BIRTH-DEATH-APPLY-EXTRACT-HEADER-ELEM}",
        ),
    ],
    "sgac_epass_services": [
        (
            "Navigating to SGAC and epass enquiry page",
            "${E-SERVICES-SGAC-ENTRY-VISA-EPASS-ENQUIRY-PORTAL}",
            "4",
            "${SUBMIT-SG-ARRIVAL-CARD-TAB}",
            "${SUBMIT-SG-ARRIVAL-CARD-HEADER-ELEM}",
        ),
        (
            "Navigating to apply to entry visa page",
            "${E-SERVICES-SGAC-ENTRY-VISA-EPASS-ENQUIRY-PORTAL}",
            "4",
            "${APPLY-ENTRY-VISA-TAB}",
            "${APPLY-ENTRY-VISA-CARD-HEADER-ELEM}",
        ),
        (
            "Navigating to epass enquiry portal page",
            "${E-SERVICES-SGAC-ENTRY-VISA-EPASS-ENQUIRY-PORTAL}",
            "4",
            "${RETRIEVE-E-PASS-RECORD-TAB}",
            "${RETRIEVE-E-PASS-RECORD-HEADER-ELEM}",
        ),
        (
            "Navigating to extension of visit pass portal page",
            "${E-SERVICES-SGAC-ENTRY-VISA-EPASS-ENQUIRY-PORTAL}",
            "4",
            "${APPLY-EXTENSION-OF-VISIT-PASS-TAB}",
            "${APPLY-EXTENSION-OF-VISIT-PASS-HEADER-ELEM}",
        ),
    ],
    "report_change_res_address": [
        (
            "Navigating to change of address for ic holder page",
            "${E-SERVICES-REPORT-CHANGE-RESIDENTIAL-ADDRESS}",
            "2",
            "${REPORT-CHANGE-RES-ADDRESS-IC-HOLDER-TAB}",
            "${REPORT-CHANGE-RES-ADDRESS-HEADER-ELEM}",
        ),
        (
            "Navigating to change of address for ltvp/stp holder page",
            "${E-SERVICES-REPORT-CHANGE-RESIDENTIAL-ADDRESS}",
            "2",
            "${REPORT-CHANGE-RES-ADDRESS-LTVP-STP-HOLDER-TAB}",
            "${REPORT-CHANGE-RES-ADDRESS-HEADER-ELEM}",
        ),
    ],
    "sc_pr_services": [
        (
            "Navigating to apply for sc page",
            "${E-SERVICES-SC-PR}",
            "3",
            "${SC-PR-APPLY-SINGAPORE-CITIZENSHIP-TAB}",
            "${SC-PR-APPLY-SINGAPORE-CITIZENSHIP-HEADER-ELEM}",
        ),
        (
            "Navigating to apply for pr page",
            "${E-SERVICES-SC-PR}",
            "3",
            "${SC-PR-APPLY-PR-TAB}",
            "${SC-PR-APPLY-PR-HEADER-ELEM}",
        ),
        (
            "Navigating to apply for renewal/transfer re-entry permit page",
            "${E-SERVICES-SC-PR}",
            "3",
            "${SC-PR-REENTRY-PERMIT-RENEWAL-TRANSFER-TAB}",
            "${SC-PR-REENTRY-PERMIT-RENEWAL-TRANSFER-HEADER-ELEM}",
        ),
    ],
    "ltvp_stu_pass_services": [
        (
            "Navigating to apply/renew ltvp page",
            "${E-SERVICES-LTVP-STUDENTS-PASS}",
            "4",
            "${LTVP-APPLY-RENEW-LTVP-TAB}",
            "${LTVP-APPLY-RENEW-LTVP-HEADER-ELEM}",
        ),
        (
            "Navigating to apply for PMLA page",
            "${E-SERVICES-LTVP-STUDENTS-PASS}",
            "4",
            "${LTVP-APPLY-PMLA-TAB}",
            "${LTVP-APPLY-PMLA-HEADER-ELEM}",
        ),
        (
            "Navigating to apply/renew student pass page",
            "${E-SERVICES-LTVP-STUDENTS-PASS}",
            "4",
            "${LTVP-APPLY-RENEW-STUDENT-PASS-IHL-TAB}",
            "${LTVP-APPLY-RENEW-STUDENT-PASS-IHL-HEADER-ELEM}",
        ),
        (
            "Navigating to apply/renew student pass for other schools page",
            "${E-SERVICES-LTVP-STUDENTS-PASS}",
            "4",
            "${LTVP-APPLY-RENEW-STUDENT-PASS-OTHER-SCHOOLS-TAB}",
            "${LTVP-APPLY-RENEW-STUDENT-PASS-IHL-HEADER-ELEM}",
        ),
    ],
    "passport_IC_services": [
        (
            "Navigating to the passport and ic page",
            "${E-SERVICES-PASSPORT-IDENTITY-CARD}",
            "4",
            "${APPLY-TRAVEL-DOC-TAB}",
            "${APPLY-TRAVEL-WEBPAGE-HEADER-ELEM}",
        ),
        (
            "Navigating to report lost passport page",
            "${E-SERVICES-PASSPORT-IDENTITY-CARD}",
            "4",
            "${REPORT-LOST-PASSPORT-TAB}",
            "${LOST-PASSPORT-WEBPAGE-HEADER-ELEM}",
        ),
        (
            "Navigating to register IC page",
            "${E-SERVICES-PASSPORT-IDENTITY-CARD}",
            "4",
            "${REGISTER-REPLACE-IDENTITY-CARD-TAB}",
            "${REGISTER-REPLACE-IDENTITY-WEBPAGE-HEADER-ELEM}",
        ),
        (
            "Navigating to report lost IC page",
            "${E-SERVICES-PASSPORT-IDENTITY-CARD}",
            "4",
            "${REPORT-LOST-IDENTITY-CARD-TAB}",
            "${REGISTER-REPLACE-IDENTITY-WEBPAGE-HEADER-ELEM}",
        ),
    ],
    "appt_services": [
        (
            "Navigating to book change cancel appt page",
            "${E-SERVICES-APPOINTMENT}",
            "2",
            "${APPT-BOOK-CHANGE-CANCEL-TAB}",
            "${APPT-BOOK-CHANGE-CANCEL-TAB-HEADER-ELEM}",
        ),
        (
            "Navigating to check in page",
            "${E-SERVICES-APPOINTMENT}",
            "2",
            "${APPT-ONLINE-CHECK-IN-TAB}",
            "${APPT-ONLINE-CHECK-IN-TAB-HEADER-ELEM}",
        ),
    ],
}

# Suites where every test case uses the settings-level Test Template.
SETTINGS_TEMPLATE_SUITES = set(EXPECTED_CASES.keys()) - {"appt_services"}

# Test cases that are preserved but intentionally not driven by the shared
# template because they follow a different workflow.
NON_TEMPLATE_CASES = {
    "appt_services": [
        "Navigate to the appointment page via the citizen and residents card"
    ],
}


def _settings_dict(model):
    """Extract reusable settings from a parsed model as simple Python values."""
    settings = {
        "variables": [],
        "resources": [],
        "test_tags": None,
        "test_setup": None,
        "test_teardown": None,
        "test_template": None,
    }
    for section in model.sections:
        if not hasattr(section, "body"):
            continue
        for node in section.body:
            if isinstance(node, VariablesImport):
                settings["variables"].append(node.name)
            elif isinstance(node, ResourceImport):
                settings["resources"].append(node.name)
            elif isinstance(node, RobotTestTags):
                settings["test_tags"] = list(node.values)
            elif isinstance(node, RobotTestSetup):
                settings["test_setup"] = node.name
            elif isinstance(node, RobotTestTeardown):
                settings["test_teardown"] = node.name
            elif isinstance(node, RobotTestTemplate):
                settings["test_template"] = node.value
    return settings


def _test_cases(model):
    """Yield TestCase nodes from a parsed model."""
    for section in model.sections:
        if isinstance(section, RobotTestCaseSection):
            for node in section.body:
                if isinstance(node, RobotTestCase):
                    yield node


def _case_info(case):
    """Return (documentation, template_keyword, arguments) for a parsed test case."""
    doc = None
    template = None
    args = ()
    for node in case.body:
        if isinstance(node, Documentation):
            doc = node.value
        elif isinstance(node, Template):
            template = node.value
        elif isinstance(node, TemplateArguments):
            args = node.args
    return doc, template, args


_SPY_LIBRARY_SOURCE = textwrap.dedent(
    '''
    """Small spy library used only by the device-free execution tests."""

    RECORDS = []

    def record_click(elementid):
        RECORDS.append(("Click on element", elementid))

    def record_xpath(xpath, count):
        RECORDS.append(("Xpath Should Match X Times", xpath, int(count)))

    def record_expect(locator, state):
        RECORDS.append(("Expect Element", locator, state))

    def record_close():
        RECORDS.append(("Close iOS Chrome Browser",))

    def reset():
        RECORDS.clear()
    '''
).strip()


def _execute_template(portal, count, tab, header, fork="sgac1"):
    """Run the actual shared template keyword with stubbed UI keywords.

    Builds a temporary Robot suite that imports the real
    ``Resources/ios/eservices_commands.robot`` and then defines the four UI
    primitives (``Click on element``, ``Xpath Should Match X Times``,
    ``Expect Element``, ``Close iOS Chrome Browser``) at the suite level.
    Suite-level user keywords have the highest precedence, so they override
    the keywords imported from ``commands.robot``/AppiumLibrary without
    shadowing or mutating ``AppiumLibrary`` itself.

    The suite-level keywords delegate to a uniquely named temporary spy
    library that records every call.  Returns ``(return_code, recorded_calls)``.
    """
    old_fork = os.environ.get("APP_FORK")
    os.environ["APP_FORK"] = fork
    spy_name = f"eservices_template_spy_{uuid.uuid4().hex}"
    try:
        with tempfile.TemporaryDirectory() as tmpdir:
            spy_path = Path(tmpdir) / f"{spy_name}.py"
            spy_path.write_text(_SPY_LIBRARY_SOURCE)
            sys.path.insert(0, tmpdir)
            try:
                suite_source = f"""
*** Settings ***
Resource    {RESOURCE_FILE.resolve()}
Library    {spy_name}

*** Keywords ***
Click on element
    [Arguments]    ${{elementid}}
    Record Click    ${{elementid}}

Xpath Should Match X Times
    [Arguments]    ${{xpath}}    ${{count}}
    Record Xpath    ${{xpath}}    ${{count}}

Expect Element
    [Arguments]    ${{locator}}    ${{state}}
    Record Expect    ${{locator}}    ${{state}}

Close iOS Chrome Browser
    Record Close

*** Test Cases ***
Execute template
    Open E-Service Portal And Verify    {portal}    {count}    {tab}    {header}
"""
                suite = RobotTestSuite.from_string(suite_source)
                result = suite.run(output=None, log=None, report=None, consolewidth=120)

                spy_module = importlib.import_module(spy_name)
                calls = list(spy_module.RECORDS)
                return result.return_code, calls
            finally:
                sys.path.remove(tmpdir)
                if spy_name in sys.modules:
                    del sys.modules[spy_name]
    finally:
        if old_fork is None:
            os.environ.pop("APP_FORK", None)
        else:
            os.environ["APP_FORK"] = old_fork


@pytest.fixture(scope="module")
def resource_model():
    return get_model(str(RESOURCE_FILE))


@pytest.mark.parametrize("suite_stem,expected", EXPECTED_CASES.items())
def test_suite_uses_template_and_preserves_cases(suite_stem, expected):
    path = OWNED_DIR / f"{suite_stem}.robot"
    assert path.exists(), f"Owned suite missing: {path}"
    model = get_model(str(path))
    settings = _settings_dict(model)

    # Common contract: fork_config imported first, commands.robot, and the new
    # eservices_commands.robot resource.
    assert any("fork_config.py" in v for v in settings["variables"])
    assert "../../../Resources/commands.robot" in settings["resources"]
    assert "../../../Resources/ios/eservices_commands.robot" in settings["resources"]

    # Tags / setup / teardown retained.
    assert settings["test_tags"] == ["fork:both"]
    assert settings["test_setup"] == "Open MyICA App on iOS Device"
    assert settings["test_teardown"] == "ios_appium_commands.Terminate App"

    # Determine whether the suite uses a settings-level template.
    if suite_stem in SETTINGS_TEMPLATE_SUITES:
        assert settings["test_template"] == TEMPLATE_KEYWORD
    else:
        assert settings["test_template"] is None

    # Collect parsed test cases.
    cases = list(_test_cases(model))
    case_by_name = {c.name: c for c in cases}

    # Every expected case exists and maps to the same arguments.
    non_templated = NON_TEMPLATE_CASES.get(suite_stem, [])
    assert len(cases) == len(expected) + len(non_templated), (
        f"{suite_stem}: expected {len(expected) + len(non_templated)} cases, found {len(cases)}"
    )
    for name in non_templated:
        assert name in case_by_name, f"{suite_stem}: missing non-templated case {name}"
        _, case_template, args = _case_info(case_by_name[name])
        assert case_template != TEMPLATE_KEYWORD, (
            f"{suite_stem}/{name}: non-templated case should not use [Template]"
        )

    for name, portal, count, tab, header in expected:
        assert name in case_by_name, f"{suite_stem}: missing test case {name}"
        case = case_by_name[name]

        doc, case_template, args = _case_info(case)
        if suite_stem in SETTINGS_TEMPLATE_SUITES:
            assert case_template in (None, TEMPLATE_KEYWORD)
        else:
            assert case_template == TEMPLATE_KEYWORD, (
                f"{suite_stem}/{name}: expected per-case [Template] {TEMPLATE_KEYWORD}, got {case_template}"
            )

        assert args == (portal, count, tab, header), (
            f"{suite_stem}/{name}: args mismatch: {args!r} != "
            f"{(portal, count, tab, header)!r}"
        )

        assert doc is not None, f"{suite_stem}/{name}: documentation removed"


def test_resource_template_keyword_signature(resource_model):
    """The shared keyword accepts portal, card count, tab, and optional header."""
    keyword = None
    for section in resource_model.sections:
        if section.__class__.__name__ == "KeywordSection":
            for node in section.body:
                if isinstance(node, Keyword) and node.name == TEMPLATE_KEYWORD:
                    keyword = node
                    break
        if keyword:
            break

    assert keyword is not None, f"{TEMPLATE_KEYWORD} not found in resource file"

    args_node = next((n for n in keyword.body if isinstance(n, Arguments)), None)
    assert args_node is not None, "Keyword has no [Arguments]"
    assert list(args_node.values) == [
        "${portal_locator}",
        "${card_count}",
        "${tab_locator}",
        "${header_locator}=${EMPTY}",
    ], f"Unexpected keyword arguments: {args_node.values}"


def test_resource_template_keyword_body(resource_model):
    """The shared keyword preserves the original interaction order and assertions."""
    keyword = None
    for section in resource_model.sections:
        if section.__class__.__name__ == "KeywordSection":
            for node in section.body:
                if isinstance(node, Keyword) and node.name == TEMPLATE_KEYWORD:
                    keyword = node
                    break
        if keyword:
            break

    calls = []
    for node in keyword.body:
        if isinstance(node, KeywordCall):
            calls.append((node.keyword, list(node.args)))

    expected_calls = [
        ("Click on element", ["${OTHER-E-SERVICES-FAV-BUTTON}"]),
        ("Click on element", ["${portal_locator}"]),
        ("Xpath Should Match X Times", ['//XCUIElementTypeOther[@name="card"]', "${card_count}"]),
        ("Click on element", ["${tab_locator}"]),
        (
            "Run Keyword If",
            ["$header_locator != ''", "Expect Element", "${header_locator}", "visible"],
        ),
        ("Close iOS Chrome Browser", []),
    ]
    assert calls == expected_calls, f"Keyword body mismatch:\n{calls}\nvs\n{expected_calls}"


def test_resource_imports_commands_and_common_locators(resource_model):
    """The resource imports the shared commands and the common e-services locators."""
    settings = _settings_dict(resource_model)

    assert "../../Resources/commands.robot" in settings["resources"]
    assert any("fork_config.py" in v for v in settings["variables"])
    assert any("other_e_services_page.yaml" in v for v in settings["variables"])


# ---------------------------------------------------------------------------
# Execution tests: run the actual shared resource keyword with stubbed UI
# keywords to verify runtime behaviour without Appium or a real device.
# ---------------------------------------------------------------------------


def _expected_calls(portal, count, tab, header, expect_assertion=True, fork="sgac1"):
    """Return the high-level runtime calls recorded by the spy library.

    Because the suite-level override keywords capture the primitive UI actions
    directly, the recorded calls are exactly the high-level steps performed by
    the template keyword, independent of ``commands.robot`` internals.
    """
    fav = _fav_button_locator(fork)
    calls = [
        ("Click on element", fav),
        ("Click on element", portal),
        ("Xpath Should Match X Times", '//XCUIElementTypeOther[@name="card"]', count),
        ("Click on element", tab),
    ]
    if expect_assertion:
        calls.append(("Expect Element", header, "visible"))
    calls.append(("Close iOS Chrome Browser",))
    return calls


def test_template_executes_with_apostrophe_header():
    """The existing Student's Pass locator does not break the header condition."""
    header = '//XCUIElementTypeStaticText[@name="Apply for Student\'s Pass"]'
    return_code, calls = _execute_template(
        portal="portal-locator",
        count=4,
        tab="tab-locator",
        header=header,
    )
    assert return_code == 0
    assert calls == _expected_calls("portal-locator", 4, "tab-locator", header)


def test_template_executes_with_double_quote_and_backslash_header():
    """Double quotes and backslashes in the header locator are handled safely."""
    header = '//*[@class="foo\\\\bar" and @name="baz"]/text()'
    return_code, calls = _execute_template(
        portal="portal-locator",
        count=2,
        tab="tab-locator",
        header=header,
    )
    assert return_code == 0
    expected_header = '//*[@class="foo\\bar" and @name="baz"]/text()'
    assert calls == _expected_calls("portal-locator", 2, "tab-locator", expected_header)


def test_template_executes_with_empty_header():
    """When header is ${EMPTY}, Expect Element is skipped and only the fixed steps run."""
    return_code, calls = _execute_template(
        portal="portal-locator",
        count=3,
        tab="tab-locator",
        header="${EMPTY}",
    )
    assert return_code == 0
    assert calls == _expected_calls(
        "portal-locator", 3, "tab-locator", "${EMPTY}", expect_assertion=False
    )


def test_template_single_execution_order():
    """The keyword performs exactly one favourites click, portal click, count check,
    tab click, optional header assertion and browser close in that order."""
    return_code, calls = _execute_template(
        portal="portal-locator",
        count=8,
        tab="tab-locator",
        header="header-locator",
    )
    assert return_code == 0
    assert calls == _expected_calls("portal-locator", 8, "tab-locator", "header-locator")
    # Each high-level action appears exactly once.
    assert sum(1 for c in calls if c[0] == "Click on element") == 3
    assert sum(1 for c in calls if c[0] == "Xpath Should Match X Times") == 1
    assert sum(1 for c in calls if c[0] == "Expect Element") == 1
    assert sum(1 for c in calls if c[0] == "Close iOS Chrome Browser") == 1
