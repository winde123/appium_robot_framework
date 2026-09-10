# appium_robot_framework

Last reviewed: 2026-09-07

Robot Framework + Appium test suite for the MyICA Mobile app on Android and iOS.

**Project layout**
- `tests/` Robot Framework test suites for Android and iOS.
- `Resources/` Shared Robot keywords and Python helper utilities.
- `Data/` Page object YAML locators and test data.
- `icaApp/` App binaries used by tests.
- `docs/` Durable project documentation for humans and agents.
- `todo/` Shared, file-based task queue and handoff history.
- `robotconfig.yaml` Device/Appium configuration values.
- `Output/` Default Robot Framework output directory.

Repository-wide contributor guidance lives in [`AGENTS.md`](AGENTS.md). Start at
[`docs/README.md`](docs/README.md) for project knowledge and [`todo/README.md`](todo/README.md)
to create or pick up work.

**Screen walkthrough documentation**

The [Android walkthrough package](docs/project-documentation/android-sgac2-2026-09-07/README.md)
contains 200 documented screenshots, six category Word documents and a local gallery from
the 7 September 2026 SGAC2 sessions. The continuation added 36 captures, completing the
32 e-Service entry links, search and remaining support/About destinations. The
[task record](todo/done/emulator-flow-documentation.md) and
[flow inventory](docs/project-documentation/android-sgac2-2026-09-07/flow-inventory.md)
record observed issues, authentication/fixture boundaries and unexercised variants.
Browse all capture runs from the
[project documentation index](docs/project-documentation/README.md).

**Prerequisites**
- Python 3.x with `robotframework`, `AppiumLibrary`, `appium-python-client`, and `PyYAML`.
- Appium server running locally.
- Android SDK (for emulator/device) and/or Xcode + iOS device tooling.

**App binaries**
The MyICA app has two forks (SGAC1.0 / SGAC2.0); one codebase drives both, selected by the
`APP_FORK` env var (`sgac1` default | `sgac2`). See
[`docs/refactor/fork-conventions.md`](docs/refactor/fork-conventions.md) for the contract and
[`docs/refactor/sgac-fork-refactor-tasks.md`](docs/refactor/sgac-fork-refactor-tasks.md) for
the rollout plan.

Android binaries live per fork with stable names — `icaApp/{sgac1,sgac2}/app.apk` (gitignored,
local files) — resolved by `Resources/fork_config.py` (the single resolver). iOS installs
nothing: app versions ship via TestFlight and sessions launch the installed build by bundle ID
(`icaApp/sgac_test.ipa` is kept only as a bundle-ID reference). When switching Android forks on
a device, run once with `ENFORCE_APP_INSTALL=True` (shared package ID + skipped downgrades
otherwise leave the old fork running).

**Configuration**
Edit `robotconfig.yaml` for device and platform details. It is loaded by the shared keywords in `Resources/commands.robot`.
- `APPIUM_SERVER_URL` is used by all test runs.
- `ANDROID_PLATFORM_VERSION` can be overridden with the `ANDROID_PLATFORM_VERSION` env var (defaults to `16`).
- iOS device name/UDID/version/Xcode org ID are required for real-device runs.
- Mailinator email capture reads `MAILINATOR_API_TOKEN` from the root gitignored `.env`
  (copy the blank `.env.example` for a new checkout), with process environment taking
  precedence. See [Mailinator setup](docs/testing/mailinator-de-number.md).

**Running tests**
Start Appium, then run Robot Framework with a suite or a directory:

```sh
robot tests/android/other_e_services.robot
robot tests/ios/other_e_services.robot
APP_FORK=sgac2 robot tests/android/sgac/crud_profile.robot   # select the SGAC2.0 fork
```

**Android emulator runs**
The Android emulator keyword uses values from `robotconfig.yaml`:
- `ANDROID_EMULATOR_NAME` (e.g. `emulator-5554`)
- `ANDROID_PLATFORM_VERSION` (defaults to `16`, can be overridden via env)
- `ANDROID_APP_PACKAGE` and optional `appActivity` passed in tests

Example:

```sh
ANDROID_PLATFORM_VERSION=16 robot tests/android/other_e_services.robot
```

Make sure your emulator is running and visible via `adb devices` before starting the test.

If you want to start the emulator from the CLI (AVD: `Pixel_7_Pro`):

```sh
emulator -avd Pixel_7_Pro
adb devices
```

To run an entire platform folder:

```sh
robot tests/android
robot tests/ios
```

Outputs are written to `Output/` by default (use `-d` to override).
