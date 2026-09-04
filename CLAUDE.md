# CLAUDE.md

This project context is shared by Codex, Claude Code, OpenCode, and any other repository agents.

## Mandatory startup order

Before planning, inspecting files, running repository commands, or making changes for each new task:

1. Call the Mnemosyne MCP `mnemosyne_recall` tool with a query describing this repository and the current task.
2. Read this file in full and use it together with the recalled project context.
3. Reconcile recalled information with the current repository state; current code, tests, and configuration take precedence over stale context.

Do not silently skip either startup step. If one is unavailable, tell the user before continuing with the best available context.

Robot Framework + Appium test suite for the MyICA mobile app (`sg.gov.ica.mobile.app`, Singapore ICA), covering Android and iOS. Tests run three ways: locally against an Android emulator/physical device, locally against a real iOS device via XCUITest, and remotely on AWS Device Farm.

## Planned refactor: SGAC1.0 / SGAC2.0 forks (planned 2026-09, NOT yet implemented)

The MyICA app has two major forks, SGAC1.0 and SGAC2.0; everything in this repo today is SGAC1.0-only. A refactor to make one codebase drive both forks is planned — the concurrent-agent task board and target architecture (an `APP_FORK` selector resolved by a new `Resources/fork_config.py`, per-fork `icaApp/` and `Data/{sgac1,sgac2}/` trees, one parameterized `tests/` tree, `fork:*` tags) live in `docs/refactor/sgac-fork-refactor-tasks.md`. Read that board before making structural changes; task file ownership and merge order there are binding. Until Wave 2 lands, the layout described below is still current.

## Running tests

Start Appium first (`appium`), then:

```sh
robot tests/android/sgac/crud_profile.robot        # single suite
robot tests/android                                # whole platform
ANDROID_PLATFORM_VERSION=16 robot tests/android/...  # override Android version
```

- Outputs go to `Output/` by default (`-d` to override).
- Android secure fields (NRIC input) require Appium started with `--allow-insecure UiAutomator2:adb_shell` — `subprocess_call.py` does this (currently Windows/PowerShell specific).
- Device/Appium config lives in `robotconfig.yaml` (Appium URL, device names, UDIDs, platform versions). `ANDROID_PLATFORM_VERSION` defaults to 16, overridable via env var.
- App binaries resolved by `Resources/getabspath.py`: Android `icaApp/1.15.0_(3)_368.apk`, iOS `icaApp/sgac_test.ipa`. (README mentions `app-staging-release.apk` — `getabspath.py` is the source of truth.)

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
  android/SGACcommads.robot     Android SGAC flow keywords (note the filename typo)
  ios/SGACcommands.robot        iOS SGAC flow keywords
  helper_func.py                String/date formatting helpers (used as a Robot library)
  ios_appium_commands.py        Python Appium bridge; provides Terminate App for iOS teardowns
  getabspath.py                 Resolves app binary absolute paths (Variables file)
Data/
  {android,ios}/**/*.yaml       Page-object locator files, one YAML per screen, mirrored per
                                platform; keys are UPPER-KEBAB names holding XPath strings
  test_data/manual_field_random.py  Faker-based generators with valid checksums: NRIC, SG passport
                                numbers, car plates, DOB, phone, email. Imported BOTH as a Library
                                (keyword calls) and as a Variables file (module-level ${NRIC},
                                ${NAME}, etc. are generated once at import time)
  test_data/input_fields_test_data.yaml  Static input test data
icaApp/                         App binaries (.apk / .ipa)
robotconfig.yaml                Device/Appium configuration (loaded by commands.robot)
```

## Conventions

- Page-object pattern via YAML Variables files: each screen has a YAML of locators; suites and keyword files import the screens they touch.
- Locator keys are UPPER-KEBAB-CASE (e.g. `RES-PROFILE-NAME-INPUT`); values are raw XPath.
- Suites use `Test Setup` to open the app (platform-specific keyword) and `Test Teardown` to close/terminate it.
- Dynamic assertion locators are built inline with `Format String` against generated test data, then checked with `Expect Element ... visible`.
- Android and iOS mirror each other: same flows, separate locator YAMLs and keyword files per platform.

## Known quirks / gotchas

- **Relative import depths are inconsistent** in `Resource`/`Variables` paths — some lines use one `../` too many (pointing above the repo root), e.g. `Resources/android/SGACcommads.robot:14-15` and several test suites mixing `../../../` with `../../../../`. Check path depth when copying import blocks.
- `manual_field_random.py` has a hardcoded Windows path in the unused `readfromfile()`; `subprocess_call.py` invokes Windows PowerShell. Both are leftovers from a Windows setup.
- Module-level variables in `manual_field_random.py` (`${NRIC}`, `${NAME}`, `${DOB}`, ...) are fixed per run at import; call the generator keywords for fresh values within a test.
- iOS keyword file prefixes some locators with `xpath=` at the call site; Android relies on AppiumLibrary's default XPath detection. Both work, just inconsistent.
