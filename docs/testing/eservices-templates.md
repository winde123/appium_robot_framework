# Reusable iOS e-services test templates

The iOS e-services suites under `tests/ios/other_e_services/` share a single,
highly repetitive navigation pattern:

1. Tap **Other e-Services** from the favourites bar.
2. Tap a service portal category.
3. Assert the portal shows the expected number of option cards.
4. Tap the target service tab.
5. Optionally assert the portal-specific header is visible.
6. Close the iOS Chrome browser.

To remove this repetition while keeping each test readable, the suites use
**Robot Framework Test Templates** together with a shared keyword in
`Resources/ios/eservices_commands.robot`.

## Shared keyword

```robot
Open E-Service Portal And Verify
    [Arguments]    ${portal_locator}    ${card_count}    ${tab_locator}    ${header_locator}=${EMPTY}
    Click on element              ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element              ${portal_locator}
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    ${card_count}
    Click on element              ${tab_locator}
    Run Keyword If                $header_locator != ''
    ...                           Expect Element    ${header_locator}    visible
    Close iOS Chrome Browser
```

The keyword is part of `Resources/ios/eservices_commands.robot`, which imports
`commands.robot` and the common `other_e_services_page.yaml` locator file.
Portal-specific locators remain in the individual suites and are passed as
arguments.

## When to use the template

Use the template for any test case that follows the exact six-step flow above.
Do **not** force dissimilar workflows into it.  For example,
`tests/ios/other_e_services/appt_services.robot` has a third test that enters
the appointment portal via the Citizen & Resident card and asserts that two tabs
are visible, so it keeps its original body and only the first two cases use the
template.

## Adding a new service case

1. Add the portal/tab/header locators to the appropriate per-fork YAML under
   `Data/{sgac1,sgac2}/ios/other_e_services/`.
2. Open the relevant suite in `tests/ios/other_e_services/`.
3. Add a new test case line using the same template.  For suites that declare
   `Test Template` in `*** Settings ***`, this is a single line:

   ```robot
   Navigating to my new service page
       [Documentation]    my service category
       ${E-SERVICES-MY-CATEGORY}    4    ${MY-SERVICE-TAB}    ${MY-SERVICE-HEADER-ELEM}
   ```

   For suites with a mixed workflow (e.g. `appt_services.robot`), use the
   `[Template]` setting on the individual test case:

   ```robot
   Navigating to my new service page
       [Documentation]    my service category
       [Template]         Open E-Service Portal And Verify
       ${E-SERVICES-MY-CATEGORY}    4    ${MY-SERVICE-TAB}    ${MY-SERVICE-HEADER-ELEM}
   ```

4. If the portal does **not** assert a portal-specific header, pass `${EMPTY}`
   as the fourth argument.
5. Update `tests/unit/test_eservices_templates.py` with the expected case
   mapping.
6. Run the verification commands (use the project Python interpreter; the
   maintenance worktree uses `/Users/edwinwan/Documents/Projects/appium_robot_framework/venv/bin/python`):

   ```sh
   ${PYTHON:-python3} -B -m pytest -q -p no:cacheprovider tests/unit/test_eservices_templates.py
   APP_FORK=sgac1 ${PYTHON:-python3} -B -m robot --dryrun --output NONE --log NONE --report NONE tests/ios/other_e_services
   APP_FORK=sgac2 ${PYTHON:-python3} -B -m robot --dryrun --output NONE --log NONE --report NONE tests/ios/other_e_services
   ${PYTHON:-python3} -B tools/check_fork_parity.py --strict
   ```

## What is preserved

The refactor intentionally keeps every original:

- test name,
- test count per suite,
- `fork:both` force tag,
- `Test Setup` / `Test Teardown`,
- locator variable import,
- portal-specific expected header,
- menu card-count assertion, and
- interaction order.

Portal differences are explicit case arguments; they are not hidden inside a
single opaque keyword.

## Device-free test coverage

`tests/unit/test_eservices_templates.py` verifies the refactor without touching
Appium, a device, the network or real image I/O:

- `robot.api.parsing` checks that each owned suite declares the expected template
  (settings-level or per-case), that test names and counts are unchanged, that
  every case maps to the original portal/tab/header/assertion arguments, and
  that tags, setup, teardown and imports are retained.
- An in-memory `robot.running.TestSuite` exercises the actual shared resource
  with suite-level override keywords that delegate to a temporary spy library.
  This confirms the exact high-level action/assertion order and proves that
  locators containing apostrophes, double quotes and backslashes do not break
  the header condition, without shadowing or mutating the real `AppiumLibrary`.

## Last reviewed

2026-09-06
