# appium_robot_framework

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

**Prerequisites**
- Python 3.x with `robotframework`, `AppiumLibrary`, `appium-python-client`, and `PyYAML`.
- Appium server running locally.
- Android SDK (for emulator/device) and/or Xcode + iOS device tooling.

**App binaries**
Paths are resolved in `Resources/getabspath.py`:
- Android: `icaApp/app-staging-release.apk`
- iOS: `icaApp/sgac_test.ipa`

Update those files or adjust `Resources/getabspath.py` if your app filenames differ.

**Configuration**
Edit `robotconfig.yaml` for device and platform details. It is loaded by the shared keywords in `Resources/commands.robot`.
- `APPIUM_SERVER_URL` is used by all test runs.
- `ANDROID_PLATFORM_VERSION` can be overridden with the `ANDROID_PLATFORM_VERSION` env var (defaults to `16`).
- iOS device name/UDID/version/Xcode org ID are required for real-device runs.

**Running tests**
Start Appium, then run Robot Framework with a suite or a directory:

```sh
robot tests/android/other_e_services.robot
robot tests/ios/other_e_services.robot
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
