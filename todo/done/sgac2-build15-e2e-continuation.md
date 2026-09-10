# SGAC2 build 15 E2E continuation

- Status: Done
- Owner: Codex
- Priority: High
- Created: 2026-09-08
- Updated: 2026-09-08

## Goal

Resume Claude's Android SGAC2 testing on the installed staging build, validate
Singpass/Myinfo with the supplied test account, and exercise the remaining reachable
SGAC, QR and cargo flows with reproducible evidence.

## Context

Claude's commit `78be5e1` fixes shared interaction and scroll blockers. Its saved
24-case run in `Output/sgac2-build15-2026-09-08/` has 1 pass and 23 failures; most
failures are obsolete SGAC1 flow references, and four are Device Farm setup failures.
The landing-only rerun still stops on a removed banner text locator. Mnemosyne
records a Singpass return to the profile-method screen, with no populated Myinfo
profile, and an unexecuted language sweep. The referenced scratchpad scripts are
absent from the current checkout.

## Scope

- Android emulator, current installed SGAC2 staging build.
- Singpass login, callback and profile retrieval; manual resident/visitor submission.
- Remaining reachable QR/cargo variants and module language checks.
- Evidence, precise blockers, and targeted automation fixes needed for these checks.
- No SGAC1 device switching, iOS simulator runs, or Device Farm changes.

## Acceptance criteria

- [x] Verify installed build and capture live evidence for the Singpass outcome.
- [x] Attempt resident and visitor native SGAC E2E flows; record the exact last
  successful step and any blocker without claiming blocked steps pass.
- [x] Exercise reachable remaining QR/cargo and language variants, recording inputs
  or equipment needed for anything inaccessible.
- [x] Save an indexed test report, reproduction steps and artifact locations.
- [x] Run repository checks appropriate to any changes, including fork parity.

## Validation plan

Use Appium against the existing Android emulator with preserved app data. Save
screenshots, UI XML and case outcomes in a separate dated output directory. Keep
the supplied authentication secrets out of committed code, reports and artifacts.
Reconcile live results against the earlier Robot output and screen inventory.

## Progress and decisions

- Startup recall and full `CLAUDE.md` read completed. Current code confirms the
  SGAC1 tutorial/contact steps remain in the Android SGAC keywords.
- Emulator `emulator-5554` and local Appium 3.1.2 server are available. Appium MCP
  device discovery lacks Android SDK environment variables; use the configured
  local Appium server through the repository's Python environment.

## Handoff or blocker

No work remains for this testing task. Application and automation defects, required
fixtures and untested submission boundaries are itemised in the report. Future runs
should start a new no-reset Appium session and check the installed build and retained
synthetic records before relying on them.

## Outcome

The [indexed build 15 report](../../docs/testing/sgac2-build15-e2e-2026-09-08.md)
records the Singpass callback failure, resident and visitor review boundaries,
individual and group QR generation, cargo and convoy review, language checks,
automation limitations and precise remaining scope. Evidence is stored in
`Output/sgac2-continuation-2026-09-08/` as 174 validated PNG/XML pairs and three
valid JSON files.

Singpass authentication visibly succeeded, but MyInfo returned to the profile-method
screen without a populated profile. Resident, visitor, cargo and convoy drafts reached
review without submitting declarations. Individual and two-person Motorcycle QR codes
rendered locally. All three module language pickers exposed 12 options; Bengali SGAC,
Hindi QR and Simplified Chinese cargo rendered and English was restored.

### Live findings — first continuation segment

- Installed versionName 2.0.0 / versionCode 422, matching build 15. New Appium
  session preserves app data; original suite runs had left no resident profiles.
- Singpass showed `Taking you to MYICAMOBILE` at 2.40 seconds after password
  submission and returned to `Choose profile creation method` at 4.54 seconds.
  No Myinfo consent or populated profile followed. Evidence:
  `Output/sgac2-continuation-2026-09-08/singpass-return-trace.json` and `006-*`.
  This establishes the visible login/return behavior, not the backend root cause.
- Manual resident fixture (seed 908422, reference date 2026-09-08) saved as
  `TEST RESIDENT SEPT`. Build 15 contact fields include country code and mobile;
  the build 13 email-only description is stale for this build.
- Resident selection + Continue now opens a web-based Residents Submission form.
  Profile-update loop did not reproduce for this new complete profile. Prefilled
  name, identity, birth date and email were checked; arrival 8 September 2026 and
  synthetic NO health answers reached review.
- The web form repeats two health questions, includes `X country**`, and repeats
  resource IDs `#traveller-0-input-9` and `#traveller-0-input-10`.
- Resident Submit was blocked before execution by automatic approval review,
  which requested explicit authorization for the specific staging declaration.
  User approval requested asynchronously. No declaration submitted in this segment.
- Shared Appium server does not enable `adb_shell`; direct ADB was used for the
  synthetic protected NRIC/passport fields. The supplied password was not saved
  in code or report files. Raw screenshots with test identity remain in ignored
  local Output; do not publish them without redaction.

### Live findings — second continuation segment

- Synthetic Australian visitor `TEST VISITOR SEPT` saved successfully and reached
  the foreign-visitor review screen. Passport, nationality, residence, contact,
  embarkation, travel purpose, departure date, Singapore Airlines SQ318 and
  TRANSIT accommodation values carried through. No visitor declaration submitted.
- Staging visitor content includes `Dummy Question 1`. Resident content includes
  `X country**` and duplicated health questions; retain the XML/screenshots for
  defect evidence.
- QR tutorial completed all seven screens on build 15. QR profile storage includes
  both saved SGAC profiles. The individual personal-profile setup was interrupted
  after opening `TEST RESIDENT SEPT` for editing; resume there or restart from the
  QR landing screen.
- The automation interruption was environmental: the original Appium process and
  UiAutomator2 instrumentation stopped. A fresh no-reset session was created on
  system port 8216, then closed cleanly when the user paused the walkthrough.
- `venv/bin/python tools/check_fork_parity.py`: 0 errors, 0 warnings (238 expected
  divergences suppressed).

### Live findings — final continuation segment

- The apparent QR form blocker was resolved: build 15 adds required country/region
  code and mobile fields below the initially visible identity fields. Completing them
  advanced to review. The individual resident QR rendered and persisted.
- Group QR exposed Car (maximum 10), Bus (4), Lorry (4) and Motorcycle (2), all with
  a minimum of two people. One-member validation fired, then a resident plus synthetic
  visitor generated a Motorcycle group QR and foreign-visitor SGAC reminder.
- Vehicle `SBA1234G` saved. Cargo low-value goods = NO, full permit `IG2BB990011`
  and partial permit `IG2BB990012` with quantity 10 reached review. Convoy low-value
  goods = YES, two vehicles and full permit `IG2BB990013` also reached review.
- SGAC, QR and cargo each listed 12 explicit languages. Bengali, Hindi and Simplified
  Chinese smoke checks rendered module content. Hindi QR dates retained English month
  names. The prior 19-language device-locale sweep was not rerun on build 15.
- Further staging data/content findings include `Dummy Question 1`, a literal
  `ALBANIA<h1>test</h1>` residence value, four repeated cargo test announcements and
  the `vechicle` typo.
- The QR and cargo records persisted across UiAutomator2 recovery and a locale-triggered
  activity restart. This did not reproduce the earlier loss of the first two SGAC
  profiles, so that persistence observation remains non-deterministic.
- The app was returned to MyICA Home. The Android per-app locale override was cleared,
  English restored, and the Appium session closed without clearing app data.

## Validation

- Installed package: versionName 2.0.0, versionCode 422, Play installer.
- 174/174 PNG files decoded; 174/174 UI XML files parsed; 3/3 JSON files parsed.
- Four new build 15 foreigner contact locators each resolve exactly once against live
  captured XML.
- `venv/bin/python -B tools/check_fork_parity.py`: 0 errors, 0 warnings; 238 intended
  divergences suppressed.
- `APP_FORK=sgac2 venv/bin/python -B -m robot --dryrun --output NONE --log NONE
  --report NONE tests`: 68 passed, 0 failed.
- `git diff --check`: passed.
