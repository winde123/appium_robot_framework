# CLAUDE.md

Last reviewed: 2026-09-07

This project context is shared by Codex, Claude Code, OpenCode, and any other repository agents.

## Mandatory startup order

Before planning, inspecting files, running repository commands, or making changes for each new task:

1. Call the Mnemosyne MCP `mnemosyne_recall` tool with a query describing this repository and the current task.
2. Read this file in full and use it together with the recalled project context.
3. Reconcile recalled information with the current repository state; current code, tests, and configuration take precedence over stale context.

Do not silently skip either startup step. If one is unavailable, tell the user before continuing with the best available context.

Robot Framework + Appium test suite for the MyICA mobile app (`sg.gov.ica.mobile.app`, Singapore ICA), covering Android and iOS. Tests run three ways: locally against an Android emulator/physical device, locally against a real iOS device via XCUITest, and remotely on AWS Device Farm.

## Fork model: SGAC1.0 / SGAC2.0

The MyICA app has two forks; one codebase drives both, selected by the `APP_FORK` env var
(`sgac1` default | `sgac2`). The contract — variable names, per-fork layout, tag scheme,
dispatch pattern — is [`docs/refactor/fork-conventions.md`](docs/refactor/fork-conventions.md);
the work queue and merge order are [`docs/refactor/sgac-fork-refactor-tasks.md`](docs/refactor/sgac-fork-refactor-tasks.md).

- Run: `APP_FORK=sgac2 robot tests/android/sgac/crud_profile.robot` (unset ⇒ sgac1, today's behavior).
- `Resources/fork_config.py` is the single resolver exporting `${APP_FORK}`, `${ANDROID_APP}`,
  `${ANDROID_APP_PACKAGE}`, `${ANDROID_APP_ACTIVITY}`, `${IOS_BUNDLE_ID}`, `${FORK_DATA_DIR}`.
  Import it first in every file; nothing else hardcodes fork-specific values. There is no
  `${IOS_APP}`: iOS app versions are driven by TestFlight, so no per-fork `.ipa` lives in the
  repo — iOS sessions launch the TestFlight-installed build via `appium:bundleId=${IOS_BUNDLE_ID}`
  (nothing is installed; `icaApp/sgac_test.ipa` is kept purely as a bundle-ID reference).
- `${ENFORCE_APP_INSTALL}` (env var, default False): set True for the first run after switching
  Android forks — the forks share one package ID and UiAutomator2 skips downgrades otherwise.
- Locators live in per-fork trees `Data/{sgac1,sgac2}/{android,ios}/`; suites import via
  `Variables    ${FORK_DATA_DIR}/android/….yaml`. `Data/test_data/` stays shared.
- Tags: `fork:both` (default), `fork:sgac1-only`, `fork:sgac2-only`; runs exclude the other
  fork's tags (`--exclude fork:sgac2-only`).
- Divergent flows dispatch inside `Resources/**` behind stable keyword names
  (`Run Keyword … for ${APP_FORK}`), never inline in suites.

**Status:** Waves 1–2 are DONE (fork resolver, fork-aware keywords, full sgac1 tree migration,
parity linter). Both `Data/sgac2/android/` and `Data/sgac2/ios/` now exist, with a mixture of
verified, diverged and unverified locator files. Consult each tree's `STATUS.md`; the
presence of the trees and a passing dry run do not establish complete SGAC2 flow coverage.
Run `python3 tools/check_fork_parity.py` before finishing any change — it must stay at 0 errors.

## Latest Android walkthrough and coverage boundaries

The [7 September 2026 screen package](docs/project-documentation/android-sgac2-2026-09-07/README.md)
contains 207 original captures, 200 documented screens, six illustrated Word documents and
a local HTML gallery for SGAC2 build 2.0.0/420 on the Pixel_7_Pro Android 16 emulator.
The user resumed the walkthrough from Citizenship and Permanent Residence. The continuation
added 36 captures, completed all 32 e-Service entry links, exercised service search, and
opened the remaining Help/About, privacy/terms and home advisory destinations. The emulator
was returned to **MyICA Home**. The [documentation task](todo/done/emulator-flow-documentation.md)
and [flow inventory](docs/project-documentation/android-sgac2-2026-09-07/flow-inventory.md)
record the completed evidence and remaining flow/variant boundaries.

Manual resident and visitor profiles saved and updated, but selecting either for an arrival
card repeated **Profile update required** even after a successful update/save. Individual
and all four vehicle-type group QRs were generated; cargo and convoy reached review without
submission. The Trusted Traveller Programme link reached ICA's 404 page. Search for `Report`
returned two services and `test` returned none, but names/time estimates displayed raw
translation keys. Appointment links use `eservices-stg.ica.gov.sg`; other destinations
include public ICA, FormSG, Customs, AskGov, GovTech and ScamShield pages.
Singpass retrieval, scan extraction, existing-record retrieval and physical clearance need
the corresponding credentials, fixtures or equipment. This was a manual screen walkthrough;
it did not update YAML locators or establish automated suite passes. See
[Android walk status](Data/sgac2/android/STATUS.md) for the locator/evidence distinction.

## Running tests

Start Appium first (`appium`), then:

```sh
robot tests/android/sgac/crud_profile.robot        # single suite
robot tests/android                                # whole platform
ANDROID_PLATFORM_VERSION=16 robot tests/android/...  # override Android version
APP_FORK=sgac2 robot tests/android/sgac/crud_profile.robot  # SGAC2.0 fork (default sgac1)
```

- Outputs go to `Output/` by default (`-d` to override).
- **iOS is real-device only**: simulator testing is blocked for the iOS platform. The iPad is connected via Xcode (WDA signed with `IOS_XCODE_ORGID` from `robotconfig.yaml`) and driven over XCUITest; don't attempt simulator-based runs. The app under test is whatever TestFlight build is installed on the device — sessions launch it by bundle ID and never install anything on iOS.
- Android secure fields (NRIC input) require Appium started with `--allow-insecure UiAutomator2:adb_shell` — `subprocess_call.py` does this (macOS-native; supports `--dry-run` and forwards extra args like `--port`).
- Device/Appium config lives in `robotconfig.yaml` (Appium URL, device names, UDIDs, platform versions). `ANDROID_PLATFORM_VERSION` defaults to 16, overridable via env var.
- App binaries resolved by `Resources/fork_config.py` from `robotconfig.yaml`'s `FORKS:` block: Android `icaApp/{sgac1,sgac2}/app.apk` (gitignored, local files); iOS installs nothing — sessions launch the TestFlight-installed build by bundle ID (`icaApp/sgac_test.ipa` remains only as a bundle-ID reference).
- When switching Android forks on a device, run once with `ENFORCE_APP_INSTALL=True` — both forks share one package ID and UiAutomator2 skips downgrades, so without it the previously installed fork keeps running silently.

### AWS Device Farm

- `testspec.yml` — iOS runs (hardcodes `TEST_SUITE_PATH` in the test phase; edit to change target suite).
- `testspec-android.yml` — Android runs (same pattern).
- `docs/examples/aws-device-farm-appium-python.yml` — stock AWS pytest sample template retained for reference; not used by the Robot suites.
- Device Farm passes device/app via `DEVICEFARM_*` env vars, consumed by `${REMOTE_*}` variables in `Resources/commands.robot` and `--variable` overrides in the testspecs.
- `wheelhouse/` holds pre-downloaded wheels for `requirements.txt`, but several are macOS arm64 binaries (numpy, pillow, opencv) — usable locally, not on the Amazon Linux 2 test host.

## Layout

```
tests/{android,ios}/            Robot suites, split by platform then feature area
  sgac/                         SG Arrival Card: profile CRUD, individual submission flows
  other_e_services/             Navigation/smoke tests opening e-service portals (iOS has 9 suites)
  (landing, QR_code, cargo, ...)
Resources/
  commands.robot                Shared keywords: app-open per target (emulator / Android phone /
                                Device Farm remote / iOS device), retry-wrapped "Click on element"
                                and "Type text", adb-based NRIC input, iOS screen recording
                                (idevicescreenrecord), Chrome teardown helpers
  android/SGACcommands.robot    Android SGAC flow keywords (typo-fix renamed in Wave 2)
  android/QRcommands.robot      Android QR flow keywords
  ios/SGACcommands.robot        iOS SGAC flow keywords
  helper_func.py                String/date formatting helpers (used as a Robot library)
  interaction_waits.py          Shared readiness polling and single-action click/type helpers;
                                preserve the current session's implicit wait (see docs/testing/interaction-waits.md)
  ios_appium_commands.py        Python Appium bridge; provides Terminate App for iOS teardowns
  fork_config.py                Single fork resolver (Variables file): APP_FORK → app paths,
                                package/activity, bundle ID, FORK_DATA_DIR, ENFORCE_APP_INSTALL
Data/
  sgac1/{android,ios}/**/*.yaml Page-object locator files, one YAML per screen, mirrored per
                                platform; keys are UPPER-KEBAB names holding XPath strings.
                                Suites import them via ${FORK_DATA_DIR}, never by literal path.
  sgac2/{android,ios}/**/*.yaml  Present; seeded from sgac1, then selectively corrected.
                                Each platform's STATUS.md records remaining unverified files
  test_data/manual_field_random.py  Faker-based generators with valid checksums: NRIC, SG passport
                                numbers, car plates, DOB, phone, email. Imported as a Library only;
                                Generate Profile Record returns per-test data plus seed/reference-date/country
                                metadata for replay. Legacy generator keywords remain available. SHARED — never forked
  test_data/cargo_data.py         CWD-independent cargo permit file loader; readfromfile() remains a
                                compatibility wrapper enforcing the Android test's 100-permit minimum
  test_data/input_fields_test_data.yaml  Static input test data
tools/check_fork_parity.py      Parity linter: locator key parity between fork trees, import
                                hygiene (no repo-root escapes, no literal fork paths), hardcoded
                                fork values. Must stay at 0 errors
icaApp/{sgac1,sgac2}/app.apk    Android binaries per fork (gitignored, local); sgac_test.ipa is
                                an iOS bundle-ID reference only
robotconfig.yaml                Device/Appium config + per-fork FORKS: block (read by fork_config.py)
```

## Conventions

- Page-object pattern via YAML Variables files: each screen has a YAML of locators; suites and keyword files import the screens they touch.
- Locator keys are UPPER-KEBAB-CASE (e.g. `RES-PROFILE-NAME-INPUT`); values are raw XPath.
- Suites use `Test Setup` with the zero-argument fork-aware open keywords (`Open MyICA App on Android Emulator` / `... on Android Phone` / `... Remotely` / `... on iOS Device`) and `Test Teardown` to close/terminate. Every suite imports `fork_config.py` FIRST in Settings and carries `Force Tags    fork:both`.
- Dynamic assertion locators are built inline with `Format String` against generated test data, then checked with `Expect Element ... visible`.
- Android and iOS mirror each other: same flows, separate locator YAMLs and keyword files per platform.

## Known quirks / gotchas

- Relative import depths were historically inconsistent (some escaped the repo root); Wave 2 fixed them all and `tools/check_fork_parity.py` now flags any regression as an error — run it before finishing a change.
- `manual_field_random.py` no longer exports import-time profile constants. Use `Generate Profile Record` per test and pass/retain the returned record; see `docs/testing/test-data.md` for replay and compatibility details.
- `readfromfile()` is used by the Android cargo suite and now delegates to the portable cargo loader. It requires at least 100 nonblank permit entries before the caller indexes them.
- Shared `Click on element` and `Type text` wait for visible/enabled elements and act once; configure `INTERACTION_WAIT_TIMEOUT` / `INTERACTION_WAIT_POLL` or per-call `timeout` / `poll`. Remote HTTP/action duration is not hard-cancelled by the polling deadline.
- iOS keyword file prefixes some locators with `xpath=` at the call site; Android relies on AppiumLibrary's default XPath detection. Both work, just inconsistent.
