# SGAC 1.0 / SGAC 2.0 fork refactor — task board

Last reviewed: 2026-09-07 (walkthrough evidence and documentation synchronization)

**Goal:** the MyICA app has two major forks, SGAC1.0 and SGAC2.0. The starting repository
(2026-09-05) was SGAC1.0-only. The refactor makes one codebase drive both forks, selected at
run time, with SGAC1.0 remaining the default so existing runs keep working. Current progress
and remaining runtime verification are recorded below.

**Status:** Waves 1 AND 2 COMPLETE (2026-09-05). Wave 1 (T10/T11/T13/T40) merged; its
cross-review (Codex `gpt-6-astra` + DeepSeek `v4-pro`, both HOLD → fixed) produced the
`ENFORCE_APP_INSTALL` fork-switch fix (see fork-conventions §2). Wave 2 (T20 Kimi k2.7-code ∥
T21 Claude; Codex was quota-blocked for authoring) merged after a second two-vendor review —
both verdicts SHIP. Result on main: `robot --dryrun tests/` = 66/66 with zero error output for
sgac1; parity linter 0 errors / 0 warnings; all repo-root-escaping imports fixed.
**Historical caveat (2026-09-05, per both reviewers):** the sgac2 dryrun "pass" did not prove
runtime readiness while `Data/sgac2/**` was absent. Both platform trees now exist; their
`STATUS.md` files record the remaining unverified and divergent screens. Wave 3 and full
runtime acceptance are not declared complete by the later manual walkthrough.
This board is the work queue for concurrent agents.

**Walkthrough update (2026-09-07):** [200 documented Android screens and six Word documents](../project-documentation/android-sgac2-2026-09-07/README.md)
are available from build 2.0.0/420. The session covered manual profile saves, QR generation,
cargo/convoy review and all 32 e-Service entry links. The continuation added service search
and the remaining support/About destinations; [the documentation task](../../todo/done/emulator-flow-documentation.md)
records the result and unexercised variants. Trusted Traveller Programme reached ICA's 404
page; search matched correctly but displayed raw translation keys. The emulator was returned to Home.
Native SGAC profile selection is blocked by a repeatable update-required loop. These captures
add evidence for T31/T33; they do not change locator verification states or establish T42
automated regression passes.

**Orchestration:** the Claude Code session is dev lead / solution architect (Edwin, 2026-09-05):
it assigns tasks, reviews every agent diff, and performs all merges and pushes. See rule 6.

**Scope change (2026-09-05):** AWS Device Farm is NOT in use for now — all Device Farm
integration work is deferred. `testspec.yml` / `testspec-android.yml` stay in the repo untouched
and no task edits them; T12 is parked below for when Device Farm testing resumes.

---

## Target architecture (the contract all tasks build against)

- **Fork selector:** a single variable `APP_FORK`, values `sgac1` (default) | `sgac2`.
  Local: `APP_FORK=sgac2 robot tests/android/...`. (Device Farm would export it in the testspec —
  deferred, see T12.)
- **Single resolver:** a new Variables file `Resources/fork_config.py` reads `APP_FORK` and emits
  every fork-dependent value: `${ANDROID_APP}`, `${IOS_APP}`, `${ANDROID_APP_PACKAGE}`,
  `${ANDROID_APP_ACTIVITY}`, `${IOS_BUNDLE_ID}`, `${FORK_DATA_DIR}` (e.g. `Data/sgac2`), and
  `${APP_FORK}` itself. Nothing else in the repo hardcodes a fork-specific value.
- **Per-fork trees where content diverges, one tree where it doesn't:**
  - `icaApp/{sgac1,sgac2}/app.apk` — Android binaries only, stable filenames (no version in the
    name). **iOS has no per-fork binary in the repo:** app versions are driven by TestFlight.
    Today `icaApp/sgac_test.ipa` is passed as `appium:app` purely as a springboard that launches
    the installed app on the Xcode-connected iPad (`noReset=True`) — and it carries the
    **SGAC1.0 bundle ID**, so it cannot launch SGAC2.0. Target: launch by `${IOS_BUNDLE_ID}`
    (`appium:bundleId`) instead, keep the ipa only as a bundle-ID reference, and drop
    `${IOS_APP}` from the contract.
  - `Data/{sgac1,sgac2}/{android,ios}/**` — locator YAMLs, full tree per fork (sgac2 seeded by
    copying sgac1, then corrected screen by screen). `Data/test_data/` stays shared.
  - `tests/{android,ios}/**` — ONE suite tree, parameterized by `${APP_FORK}`; suites import
    locators via `${FORK_DATA_DIR}` in the `Variables` path. RF resolves variables in import
    paths as long as `fork_config.py` is imported first (settings are processed in order).
  - `Resources/**` — shared keywords; where a flow genuinely diverges between forks, dispatch
    inside the keyword file (`Run Keyword    Do X for ${APP_FORK}`) or split into
    `<name>_sgac1.robot` / `<name>_sgac2.robot` selected by a dispatcher keyword.
- **Tags:** every test gets `fork:both` by default; fork-exclusive tests get `fork:sgac1-only` /
  `fork:sgac2-only`. Runs for fork N use `--exclude fork:sgacM-only`.
- **Back-compat:** with `APP_FORK` unset, everything resolves exactly to today's SGAC1.0 behavior.
- **iOS is real-device only:** the `.ipa` cannot be installed in the iOS Simulator — simulator
  runs are blocked for the iOS platform. Every iOS execution (suite runs, locator capture,
  smoke tests) needs Edwin's physical device connected via XCUITest; only Android has an
  emulator option. Plan iOS tasks as Edwin-in-the-loop. Switching iOS forks means installing
  the other fork's TestFlight build on the device and setting `APP_FORK` to match.

T01 finalizes this contract; raise objections there, not in downstream tasks.

---

## Wave 0 — inputs & contract (BLOCKING, serial)

### T00 — Collect SGAC2.0 inputs  `[owner: Edwin — cannot be done by an agent]`

**Status (2026-09-05):** Partially complete — Android inputs verified; iOS inputs and the
flow/screen difference list remain open. Evidence and checksums are in
[`android-apk-analysis.md`](android-apk-analysis.md).

Needed before Wave 3 (Waves 1–2 do NOT block on this):

- [x] SGAC2.0 APK supplied in `icaApp/2.0.0_12_418.apk.zip` (manifest version `2.0.0`,
      versionCode `418`). The latest SGAC1.0 baseline is supplied in
      `icaApp/1.9.1_1_417.apk.zip` (manifest version `1.19.1`, versionCode `417`; note the
      filename/version mismatch). Both ZIPs were extracted temporarily for static analysis.
- [x] SGAC2.0 Android identifiers verified: `appPackage=sg.gov.ica.mobile.app` and
      `appActivity=sg.gov.ica.mobile.app.MainActivity`. Both match the supplied SGAC1.0 APK;
      each declares a direct exported `MAIN`/`LAUNCHER` activity with no activity alias.
- [x] Android coexistence established from the manifests: both forks use the same application
      ID, so they cannot coexist as separate apps in the same Android profile. Install the
      intended fork's APK for each run.
- [x] iOS binaries: RESOLVED AS NOT APPLICABLE — iOS app versions are driven by TestFlight, so
      no `.ipa` will be supplied for either fork. The existing `icaApp/sgac_test.ipa` serves
      only as a bundle-ID reference for the iOS app. iOS runs launch the TestFlight-installed
      build by bundle ID.
- [ ] SGAC2.0 iOS bundle ID verified (read it from the TestFlight-installed app on the iPad or
      from App Store Connect) and compared with SGAC1.0's `sg.gov.ica.mobile.app`; record
      whether the iOS forks can coexist on one device.
- [ ] SGAC2.0 TestFlight build installed on the iPad when Wave 3 iOS work (T32) is scheduled.
- [ ] List of flows/screens known to differ between the forks (drives Wave 3 scoping).

Device Farm project decisions remain deferred with T12 and are not required to close T00.

### T01 — Finalize the fork contract and conventions  `[1 agent, serial — lands first]`
- Files owned: `docs/refactor/fork-conventions.md` (new), `CLAUDE.md` (conventions + running
  sections), `README.md`.
- Pin down: `APP_FORK` variable name/values/default and the env-var mechanism
  (`%{APP_FORK=sgac1}` consumed by `fork_config.py`), the exact variable names `fork_config.py`
  exports, the directory layout above, the tag scheme, and the keyword-dispatch pattern for
  divergent flows (with one worked example).
- Acceptance: doc merged; every Wave 1–2 task references it instead of inventing names.

---

## Wave 1 — fork-aware infrastructure  `[parallel after T01; disjoint file sets]`

### T10 — Config + app resolution layer
- Files owned: `robotconfig.yaml`, `Resources/getabspath.py`, `Resources/fork_config.py` (new),
  `icaApp/` (restructure into `icaApp/sgac1/app.apk` and `icaApp/sgac2/app.apk` — Android only.
  T00 supplied newer APK zips (`1.9.1_1_417.apk.zip`, `2.0.0_12_418.apk.zip`, see
  `android-apk-analysis.md`); extract those as the fork apks rather than the old
  `1.15.0_(3)_368.apk`. Leave `icaApp/sgac_test.ipa` exactly where it is — it's a bundle-ID
  reference only; iOS ships via TestFlight and no ipa is ever installed by the framework).
- Restructure `robotconfig.yaml` with per-fork sections (app package, activity, bundle id, binary
  path per fork); device/Appium-server config stays fork-agnostic.
- `fork_config.py` (Robot Variables file with `get_variables()`): reads `APP_FORK` env var,
  validates it, returns the resolved fork variables per the T01 contract. `getabspath.py` either
  folds into it or becomes a thin fork-aware helper it calls — either way no hardcoded filename.
- Acceptance: `APP_FORK=sgac1` (and unset) resolve to today's values; `APP_FORK=sgac2` resolves
  to the sgac2 paths/IDs (placeholders until T00 delivers real values); bad value fails loudly.

### T11 — Shared keyword layer (`commands.robot`)
- Files owned: `Resources/commands.robot`, `Resources/ios_appium_commands.py`.
- Import `fork_config.py` (before anything that needs fork variables); remove the direct
  `getabspath.py` import once T10 lands (coordinate the one-line seam with T10's owner).
- All `Open ... App` keywords take package/activity/bundle-id from fork variables — callers stop
  passing `appActivity=sg.gov.ica.mobile.app.MainActivity` (today hardcoded in every suite's
  `Test Setup`). Add fork-agnostic entry points: `Open MyICA App on Android Emulator`,
  `... on Android Phone`, `... Remotely`, `Open MyICA App on iOS Device` — thin wrappers that
  inject `${ANDROID_APP_ACTIVITY}` / `${IOS_BUNDLE_ID}` for the active fork.
- iOS keyword launches the TestFlight-installed build: replace `appium:app=${IOS_APP}` with
  `appium:bundleId=${IOS_BUNDLE_ID}` (keep `noReset=${True}`). Today the ipa passed as
  `appium:app` is only a launch springboard for the installed app, and it holds the SGAC1.0
  bundle ID — this bundleId switch is what unlocks SGAC2.0 on iOS. There is no `${IOS_APP}`
  variable in the contract and the framework never installs an ipa.
- iOS teardown in `ios_appium_commands.py`: terminate by `${IOS_BUNDLE_ID}` variable, not literal.
- Acceptance: suites can call the new setup keywords with zero arguments; old keywords kept as
  deprecated aliases until Wave 2 rewires the suites.

### T12 — AWS Device Farm testspecs  `[DEFERRED — do not pick up]`
- Edwin is not testing on Device Farm for now; no agent should touch `testspec.yml` /
  `testspec-android.yml` during this refactor. They stay as-is (SGAC1.0-era) and will drift from
  the new layout — that is accepted.
- When Device Farm resumes, this task = re-verify both specs against the post-refactor repo
  (moved trees, `fork_config.py`, new setup keywords), export `APP_FORK` in the test phase,
  forward it to robot with the fork exclude-tag flag, and document that the spec's `APP_FORK`
  must match whichever fork's binary was uploaded (`$DEVICEFARM_APP_PATH`).

### T13 — Local tooling cleanup (nice-to-have, fully independent)
- Files owned: `subprocess_call.py`, `requirements.txt` (only if needed).
- Rewrite `subprocess_call.py` for macOS (it currently shells out to Windows PowerShell) so
  `appium --allow-insecure UiAutomator2:adb_shell` startup works on Edwin's machine, and accept
  `APP_FORK` pass-through for anything fork-dependent it launches.
- Acceptance: script runs on macOS; documented in CLAUDE.md by T30-era docs task (T41).

---

## Wave 2 — migrate existing content to the fork layout  `[parallel after Wave 1; split by platform so file sets never overlap]`

> These two tasks move trees AND fix every import that references them, so each owns its whole
> platform slice. They also fix the known bad relative-import depths (`../../../` vs
> `../../../../`) while touching each import block — do not leave any import pointing above repo
> root.

### T20 — Android slice
- Files owned: everything under `Data/android/**` (moves to `Data/sgac1/android/**`),
  `Data/yaml_Cargo_pages/**` (Android-consumed legacy tree — fold into `Data/sgac1/android/cargo/`),
  `tests/android/**`, `Resources/android/**` (rename `SGACcommads.robot` → `SGACcommands.robot`
  while at it).
- Suites: import `fork_config.py` first, switch locator imports to
  `Variables    ${FORK_DATA_DIR}/android/...`, replace `Test Setup` with the new fork-agnostic
  open keyword from T11, add `fork:both` default tags.
- Acceptance: `robot --dryrun tests/android` passes (dryrun catches import/keyword resolution
  without a device); no file references `Data/android/` directly.

### T21 — iOS slice
- Files owned: `Data/ios/**` (→ `Data/sgac1/ios/**`), `tests/ios/**`, `Resources/ios/**`.
- Same treatment as T20 (fork_config import, `${FORK_DATA_DIR}` paths, new setup keyword,
  tags, `xpath=` prefix left as-is unless trivially normalized).
- Acceptance: `robot --dryrun tests/ios` passes; no file references `Data/ios/` directly.

---

## Wave 3 — SGAC2.0 enablement  `[blocked on T00 + Waves 1–2; then parallel]`

### T30 — SGAC2.0 config activation
- Files owned: `robotconfig.yaml` (sgac2 section values), `icaApp/sgac2/` (Android apk from T00).
- Fill the remaining sgac2 values (Android package/activity are already verified by T00; the
  open item is the iOS bundle ID, read from the TestFlight build — no ios_binary exists);
  verify `APP_FORK=sgac2` resolves end to end.

### T31 — SGAC2.0 Android locator tree
- Files owned: `Data/sgac2/android/**` (new).
- Seed by copying `Data/sgac1/android/**`, then walk each screen against the real SGAC2.0 build
  (Appium MCP `appium_get_page_source` / `generate_locators` makes this fast) and correct the
  XPaths that changed. Track per-screen status in a checklist at the top of the tree
  (`Data/sgac2/android/STATUS.md`): `copied` → `verified` → `diverged`.
- 2026-09-07 evidence: the tree is present, and the screen-documentation session reached
  profile save/update, individual/group QR generation and cargo/convoy review. See the
  [Android status supplement](../../Data/sgac2/android/STATUS.md) and dated screenshot package.
  Unverified XPath entries still require explicit locator checks.

### T32 — SGAC2.0 iOS locator tree  `[Edwin-in-the-loop: needs the real device]`
- Files owned: `Data/sgac2/ios/**` (new). Same procedure and STATUS.md as T31.
- iOS has no simulator option (the `.ipa` won't install in the iOS Simulator), so screen
  walking requires Edwin's physical device connected with the SGAC2.0 build installed —
  schedule this task for when the device is available.

### T33 — Divergent flows
- Files owned: `Resources/android/**`, `Resources/ios/**` (fork-dispatch additions),
  fork-exclusive test cases in `tests/**` tagged `fork:sgac1-only` / `fork:sgac2-only`.
- Only for flows T00 lists as genuinely different; identical flows must stay single-sourced.
- NOTE: overlaps T20/T21 file sets — run strictly after Wave 2 merges.
- 2026-09-07 evidence: profile-centric SGAC selection repeats an update-required alert after
  saving an update; native downstream submission remains blocked. Cargo/convoy permit and
  review screens are captured in the in-app webview. No flow-dispatch implementation was
  changed during the documentation session.

---

## Wave 4 — guardrails & verification  `[after Wave 2; T40 parallel with Wave 3]`

### T40 — Parity linter
- Files owned: `tools/check_fork_parity.py` (new).
- Script that (a) diffs locator KEY sets between `Data/sgac1/**` and `Data/sgac2/**` per matching
  file and reports missing/extra keys, (b) flags any `Resource`/`Variables` path that escapes the
  repo root or bypasses `${FORK_DATA_DIR}`, (c) flags hardcoded `sg.gov.ica.mobile.app` outside
  `robotconfig.yaml`. Runnable standalone; agents run it before finishing any task.

### T41 — Docs & memory sync
- Files owned: `CLAUDE.md`, `README.md`, `docs/refactor/*` final pass.
- Update layout/conventions/quirks sections for the fork model; mirror the outcome into
  Mnemosyne (standing instruction).

### T42 — Smoke runs  `[Edwin-in-the-loop: needs devices]`
- No file ownership. `APP_FORK=sgac1` and `APP_FORK=sgac2` × {Android emulator, real iOS
  device}: run one SGAC suite each (`tests/android/sgac/crud_profile.robot`,
  `tests/ios/sgac/crud_res_profile.robot`). The iOS half is real-device only (no simulator),
  and switching iOS forks means installing that fork's TestFlight build on the iPad first —
  the framework launches by bundle ID and never installs an app on iOS. Device Farm runs:
  deferred with T12.
- Acceptance: green sgac1 runs prove no regression; sgac2 runs prove the fork switch works.

---

## Concurrency & merge rules

1. **Ownership is exclusive.** A task writes only the files it owns above. If you need a change
   in another task's file, leave a `TODO(T-id)` note in your task's PR description — don't edit it.
2. **Merge order:** T01 → (T10, T11, T13 in any order) → (T20 ∥ T21) → (T30, T31 ∥ T32,
   then T33) → T40/T41/T42. T40 can start any time after T01 (it lints against the contract).
   T12 is deferred and outside the merge order.
3. **One branch (or worktree) per task**, named `refactor/<task-id>-<slug>`.
4. **Definition of done for every task:** `robot --dryrun tests/` still resolves, the parity
   linter (once it exists) passes, and the T01 contract doc was followed verbatim.
5. **Uncommitted work warning:** RESOLVED — the SGAC batch was committed (`de12a73`…`eee80f4`).
   Keep the tree clean before Wave 2 tree moves all the same.
6. **Multi-vendor allocation (Edwin, 2026-09-05):** Wave 1 (T10/T11/T13) → Claude subagents;
   T40 → OpenCode `kimi-k2.7-code` (writes the file only; dev lead reviews and commits);
   Wave 1 cross-review → Codex `gpt-6-astra` + `deepseek/deepseek-v4-pro` review the merged
   Wave 1 diff BEFORE Wave 2 launches; Wave 2 → T20 Codex `gpt-6-astra`, T21 Claude subagent.
   External CLIs run headless in dedicated worktrees, never push, and the dev lead session
   merges everything.

## Open questions for Edwin (answers slot into T00/T01)

1. Does SGAC2.0 use a different iOS bundle ID, or the same `sg.gov.ica.mobile.app`?
   Confirm iOS coexistence for T42 logistics. Android IDs and coexistence are answered in T00
   and [`android-apk-analysis.md`](android-apk-analysis.md).
2. Any flows that exist in only one fork (not just changed, but absent)? Those become
   `fork:*-only` suites in T33 rather than dispatch branches.
