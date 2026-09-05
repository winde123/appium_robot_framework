# SGAC fork conventions (T01 contract)

**Status:** CONTRACT — final, and the naming authority for Waves 1–2. Tasks T10–T21 implement
exactly the names, paths, and patterns pinned here; any objection is raised against this doc
(T01) first, never resolved by inventing a local name in a downstream task.

**Board:** [`sgac-fork-refactor-tasks.md`](sgac-fork-refactor-tasks.md) is the work queue and
holds the wave/task assignments. This document holds the *what*; the board holds the *who/when*.

---

## 1. Fork selector: `APP_FORK`

- One environment variable, `APP_FORK`, selects the fork for the whole run.
- Values: `sgac1` (default) | `sgac2`. Lowercase, no other forms.
- Unset ⇒ `sgac1` ⇒ today's exact behavior. This is the back-compat guarantee. (One deliberate
  exception: iOS sessions launch the TestFlight-installed build by bundle ID instead of
  installing an `.ipa` — see the iOS delivery model note in §2.)
- Local run: `APP_FORK=sgac2 robot tests/android/sgac/crud_profile.robot`
- Device Farm: deferred — not in use for now (T12 is parked). When it resumes, `APP_FORK` gets
  exported in the testspec test phase and forwarded to robot; until then the testspecs stay
  untouched and no task edits them.
- Robot-side equivalent for suites that must read the env var directly:
  `%{APP_FORK=sgac1}` — but suites should NOT need it: `fork_config.py` is the single resolver
  (see §2). Suites read fork values only from the variables `fork_config.py` exports.
- Invalid value (anything not `sgac1`/`sgac2`) ⇒ `fork_config.py` raises, and the run fails
  loudly with the list of valid values. No silent fallback.

## 2. `Resources/fork_config.py` — the single resolver

A Robot Framework **Variables file** (Python module with `get_variables()`). It is the only
place in the repo that maps `APP_FORK` to fork-dependent values. **Nothing else hardcodes a
fork-specific value** (package IDs, activities, bundle IDs, binary paths, data paths).

Resolution order inside `fork_config.py`:

1. Read `APP_FORK` from `os.environ` (default `sgac1`).
2. Validate against the known fork set; raise on unknown.
3. Read the fork's value block from `robotconfig.yaml` (T10 restructures it into a `FORKS:`
   mapping — see §4).
4. Return the flat variable dict below.

Exact exported variable names (UPPER_SNAKE):

| Variable | Meaning | Example (sgac1) |
| --- | --- | --- |
| `${APP_FORK}` | the resolved fork selector | `sgac1` |
| `${ANDROID_APP}` | absolute path to the Android binary | `/…/icaApp/sgac1/app.apk` |
| `${ANDROID_APP_PACKAGE}` | Android app package | `sg.gov.ica.mobile.app` |
| `${ANDROID_APP_ACTIVITY}` | Android main activity | `sg.gov.ica.mobile.app.MainActivity` |
| `${IOS_BUNDLE_ID}` | iOS bundle ID | `sg.gov.ica.mobile.app` |
| `${FORK_DATA_DIR}` | root of the fork's locator tree | `Data/sgac1` |
| `${ENFORCE_APP_INSTALL}` | boolean from the `ENFORCE_APP_INSTALL` env var (default `False`); forces (re)install of `${ANDROID_APP}` even when the device holds a newer build | `False` |

**Android fork switching (added after Wave 1 cross-review):** both forks share one package ID
and UiAutomator2 *skips downgrades* by default, so a device holding the sgac2 build (versionCode
418) silently keeps running sgac2 when `APP_FORK=sgac1` selects the older 417 apk. The Android
open keywords pass `enforceAppInstall=${ENFORCE_APP_INSTALL}`; run once with
`ENFORCE_APP_INSTALL=True APP_FORK=<fork> robot …` after switching forks to force the selected
apk onto the device, then run normally (enforcing every run would reinstall the apk each
session).

**iOS delivery model (2026-09-05):** iOS app versions are driven by TestFlight — no per-fork
`.ipa` lives in the repo, and there is NO `${IOS_APP}` variable in the target contract. The
iPad is connected through Xcode (WDA signed via `IOS_XCODE_ORGID`). **Current mechanism:** the
keyword passes `icaApp/sgac_test.ipa` as `appium:app`, which acts purely as a *springboard* to
launch the already-installed app (`noReset=True`, no reinstall) — and that ipa carries the
**SGAC1.0 bundle ID**, so it can only ever launch SGAC1.0. **Target (T11):** launch directly by
`appium:bundleId=${IOS_BUNDLE_ID}`, removing the ipa from the launch path so both forks work;
the ipa is then retained only as a bundle-ID reference artifact. Which fork runs on iOS is
determined by which TestFlight build is installed on the device; `APP_FORK` must match it.

`fork_config.py` absorbs `Resources/getabspath.py` (T10): absolute paths are computed inside
`fork_config.py` (or in a thin helper it calls) from the `robotconfig.yaml` fork block. The
stable binary filenames `app.apk` / `app.ipa` mean no version string ever appears in code.

Known SGAC1.0 values (source of truth today — must resolve to these when `APP_FORK` is unset):

- package `sg.gov.ica.mobile.app`, activity `sg.gov.ica.mobile.app.MainActivity`
  (currently hardcoded in every Android suite's `Test Setup` — removed by T11/T20),
- iOS bundle ID `sg.gov.ica.mobile.app`,
- Android binary today at `icaApp/1.15.0_(3)_368.apk` (T10 moves it; T00 has since supplied
  newer APK zips — see the board). The iOS `icaApp/sgac_test.ipa` stays where it is as a
  bundle-ID reference only.

SGAC2.0 values are **placeholders** until T00 delivers the real package/activity/bundle-ID/binary
inputs; T30 fills them in. The placeholder block must still be valid YAML so `APP_FORK=sgac2`
resolves end to end (against a not-yet-present app is fine).

## 3. Directory layout

```
icaApp/{sgac1,sgac2}/app.apk             # Android binaries only, stable filenames
icaApp/sgac_test.ipa                     # iOS bundle-ID reference ONLY (iOS ships via TestFlight)
Data/{sgac1,sgac2}/{android,ios}/**      # locator YAMLs: FULL tree per fork
                                         # (sgac2 seeded by copying sgac1, then corrected)
Data/test_data/                          # SHARED test data — never forked
tests/{android,ios}/**                   # ONE suite tree, parameterized by ${APP_FORK}
Resources/**                             # shared keywords; fork dispatch lives here
robotconfig.yaml                         # FORKS: value blocks + fork-agnostic device/Appium config
```

Rules:

- `Data/test_data/` stays shared. `Data/yaml_Cargo_pages/**` (legacy Android cargo locators)
  folds into `Data/sgac1/android/cargo/` (T20).
- Suites import locators through the variable: `Variables    ${FORK_DATA_DIR}/android/foo.yaml`.
  No suite may contain a literal `Data/sgac1` or `Data/sgac2` path.
- Suites never branch on `APP_FORK` for flow logic (tags for exclusivity, keyword dispatch for
  divergence — §5/§6). A fork-exclusive *test* is fine; fork-specific *flow logic* lives in
  `Resources/**`, never inline in suites.

## 4. `robotconfig.yaml` split (T10)

- Fork-agnostic keys stay flat at the top: `APPIUM_SERVER_URL`, `ANDROID_AUTOMATION_NAME`,
  `ANDROID_PLATFORM_VERSION`, `ANDROID_DEVICE_NAME`, `ANDROID_EMULATOR_NAME`, `IOS_*` device
  keys — everything that describes Appium/device, not the app fork.
- New `FORKS:` mapping holds the per-fork blocks:

```yaml
FORKS:
  sgac1:
    android_package: sg.gov.ica.mobile.app
    android_activity: sg.gov.ica.mobile.app.MainActivity
    ios_bundle_id: sg.gov.ica.mobile.app
    android_binary: icaApp/sgac1/app.apk
  sgac2:
    android_package: sg.gov.ica.mobile.app        # verified by T00 (same as sgac1)
    android_activity: sg.gov.ica.mobile.app.MainActivity
    ios_bundle_id: TODO(T00/T30)
    android_binary: icaApp/sgac2/app.apk
```

`fork_config.py` reads this block; nothing else consumes `FORKS` directly.

## 5. Tag scheme

Every test carries exactly one fork-scope tag:

| Tag | Meaning |
| --- | --- |
| `fork:both` | default — the test runs on both forks |
| `fork:sgac1-only` | runs only when `APP_FORK=sgac1` |
| `fork:sgac2-only` | runs only when `APP_FORK=sgac2` |

- Suites apply the default once in Settings: `Force Tags    fork:both`; individual
  fork-exclusive test cases override with their `[Tags]`.
- Runs exclude the other fork's tags: sgac1 runs use `--exclude fork:sgac2-only`; sgac2 runs
  use `--exclude fork:sgac1-only`. `fork:both` tests always run.
- Fork-exclusive tests are only for flows T00 reports as absent in one fork; divergent-but-
  present flows stay single tests with keyword dispatch (§6).

## 6. Fork dispatch for divergent flows

Flow logic that differs between forks lives in `Resources/**` behind a **stable public keyword
name**; suites call the public name and never see the fork. Two patterns, by divergence size:

**A. In-file dispatch (preferred for step-level differences).** One public keyword plus one
`… for ${APP_FORK}` implementation keyword per fork:

```robot
*** Keywords ***
Submit Arrival Card
    [Arguments]    ${data}
    Run Keyword    Submit Arrival Card for ${APP_FORK}    ${data}

Submit Arrival Card for sgac1
    Type text    ${PROFILE-INPUT}    ${data}
    Click on element    ${SUBMIT-BUTTON}

Submit Arrival Card for sgac2
    # illustrative only — real divergence comes from T00
    Type text    ${PROFILE-INPUT}    ${data}
    Click on element    ${SUBMIT-BUTTON}
    Click on element    ${CONFIRM-SUBMIT-BUTTON}
```

Naming: public keyword = plain name (`Submit Arrival Card`); forks = `<public name> for sgac1` /
`<public name> for sgac2`. Dispatch via `Run Keyword … for ${APP_FORK}`.

**B. File split (for large screen-level divergence).** `Resources/<area>/<name>_sgac1.robot`
and `<name>_sgac2.robot`, each exporting the same keyword names, and a shared dispatcher file
that imports the right one:

```robot
*** Settings ***
Resource    ${CURDIR}/${APP_FORK}_keywords.robot   # e.g. onboarding_sgac2_keywords.robot
```

Pattern B is an exception, not the default: prefer A, and only split a file when the shared
content shrinks to almost nothing.

Either way: locators stay in the per-fork `Data/` tree (§3) and are imported by the suite via
`${FORK_DATA_DIR}` — dispatch code manipulates flow, not locators.

## 7. Import ordering (mandatory)

Settings are processed in order, so `fork_config.py` MUST be imported before anything that
references its variables:

```robot
*** Settings ***
Variables    ../Resources/fork_config.py          # first, always
Variables    ${FORK_DATA_DIR}/android/landing.yaml
Resource     ../Resources/commands.robot
```

Same rule in `Resources/commands.robot` itself (T11): `Variables    ../Resources/fork_config.py`
before any use of fork variables. When T20/T21 touch each import block, they also fix the known
bad relative depths (`../../../` vs `../../../../`) — no import may point above the repo root.

## 8. Definition of done (shared across tasks)

- `robot --dryrun tests/` resolves (imports, variables, keywords) with no device attached.
- The parity linter `tools/check_fork_parity.py` (T40) passes once it exists.
- No fork-specific value is hardcoded anywhere outside `robotconfig.yaml`'s `FORKS:` block.

---

Last reviewed: 2026-09-05
