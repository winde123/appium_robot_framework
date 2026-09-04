# SGAC 1.0 / SGAC 2.0 fork refactor — task board

**Goal:** the MyICA app has two major forks, SGAC1.0 and SGAC2.0. Everything in this repo today
(binaries, package IDs, locators, keywords, suites, Device Farm specs) is SGAC1.0-only. After this
refactor, one codebase drives both forks, selected at run time, with SGAC1.0 remaining the default
so existing runs keep working.

**Status:** PLANNING ONLY — no refactoring has been implemented yet. This board is the work queue
for concurrent agents.

---

## Target architecture (the contract all tasks build against)

- **Fork selector:** a single variable `APP_FORK`, values `sgac1` (default) | `sgac2`.
  Local: `APP_FORK=sgac2 robot tests/android/...`. Device Farm: exported in the testspec.
- **Single resolver:** a new Variables file `Resources/fork_config.py` reads `APP_FORK` and emits
  every fork-dependent value: `${ANDROID_APP}`, `${IOS_APP}`, `${ANDROID_APP_PACKAGE}`,
  `${ANDROID_APP_ACTIVITY}`, `${IOS_BUNDLE_ID}`, `${FORK_DATA_DIR}` (e.g. `Data/sgac2`), and
  `${APP_FORK}` itself. Nothing else in the repo hardcodes a fork-specific value.
- **Per-fork trees where content diverges, one tree where it doesn't:**
  - `icaApp/{sgac1,sgac2}/app.apk|app.ipa` — binaries, stable filenames (no version in the name).
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

T01 finalizes this contract; raise objections there, not in downstream tasks.

---

## Wave 0 — inputs & contract (BLOCKING, serial)

### T00 — Collect SGAC2.0 inputs  `[owner: Edwin — cannot be done by an agent]`
Needed before Wave 3 (Waves 1–2 do NOT block on this):
- [ ] SGAC2.0 `.apk` and `.ipa` binaries dropped into the repo.
- [ ] SGAC2.0 Android `appPackage` + main `appActivity`, and iOS bundle ID. Note whether they
      differ from SGAC1.0 (`sg.gov.ica.mobile.app` / `...MainActivity`) and whether both forks
      can be installed side by side on one device.
- [ ] List of flows/screens known to differ between the forks (drives Wave 3 scoping).
- [ ] Whether Device Farm gets separate projects per fork or one project with two app uploads.

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
  `icaApp/` (restructure into `icaApp/sgac1/`, move `1.15.0_(3)_368.apk` → `sgac1/app.apk`,
  `sgac_test.ipa` → `sgac1/app.ipa`; create empty `icaApp/sgac2/` with a README placeholder).
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
- iOS teardown in `ios_appium_commands.py`: terminate by `${IOS_BUNDLE_ID}` variable, not literal.
- Acceptance: suites can call the new setup keywords with zero arguments; old keywords kept as
  deprecated aliases until Wave 2 rewires the suites.

### T12 — AWS Device Farm testspecs
- Files owned: `testspec.yml`, `testspec-android.yml`, plus a short
  `docs/refactor/device-farm-forks.md` explaining per-fork run setup.
- Add `APP_FORK` (default `sgac1`) exported in the test phase and passed through to robot; the
  binary itself still comes from `$DEVICEFARM_APP_PATH` (whichever fork's app was uploaded), so
  the spec's `APP_FORK` must match the uploaded app — document that clearly. Keep hardcoded
  `TEST_SUITE_PATH` behavior but hoist it next to `APP_FORK` so both edits are in one place.
- Acceptance: specs lint (`yamllint`-clean or at least valid YAML), fork exclude-tag flag
  (`--exclude fork:sgac2-only` etc.) included in the robot invocation.

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
- Files owned: `robotconfig.yaml` (sgac2 section values), `icaApp/sgac2/` (binaries from T00).
- Fill real package/activity/bundle-id/binary values; verify `APP_FORK=sgac2` resolves end to end.

### T31 — SGAC2.0 Android locator tree
- Files owned: `Data/sgac2/android/**` (new).
- Seed by copying `Data/sgac1/android/**`, then walk each screen against the real SGAC2.0 build
  (Appium MCP `appium_get_page_source` / `generate_locators` makes this fast) and correct the
  XPaths that changed. Track per-screen status in a checklist at the top of the tree
  (`Data/sgac2/android/STATUS.md`): `copied` → `verified` → `diverged`.

### T32 — SGAC2.0 iOS locator tree
- Files owned: `Data/sgac2/ios/**` (new). Same procedure and STATUS.md as T31.

### T33 — Divergent flows
- Files owned: `Resources/android/**`, `Resources/ios/**` (fork-dispatch additions),
  fork-exclusive test cases in `tests/**` tagged `fork:sgac1-only` / `fork:sgac2-only`.
- Only for flows T00 lists as genuinely different; identical flows must stay single-sourced.
- NOTE: overlaps T20/T21 file sets — run strictly after Wave 2 merges.

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
- No file ownership. `APP_FORK=sgac1` and `APP_FORK=sgac2` × {Android emulator, iOS device}:
  run one SGAC suite each (`tests/android/sgac/crud_profile.robot`,
  `tests/ios/sgac/crud_res_profile.robot`) plus one Device Farm run per platform.
- Acceptance: green sgac1 runs prove no regression; sgac2 runs prove the fork switch works.

---

## Concurrency & merge rules

1. **Ownership is exclusive.** A task writes only the files it owns above. If you need a change
   in another task's file, leave a `TODO(T-id)` note in your task's PR description — don't edit it.
2. **Merge order:** T01 → (T10, T11, T12, T13 in any order) → (T20 ∥ T21) → (T30, T31 ∥ T32,
   then T33) → T40/T41/T42. T40 can start any time after T01 (it lints against the contract).
3. **One branch (or worktree) per task**, named `refactor/<task-id>-<slug>`.
4. **Definition of done for every task:** `robot --dryrun tests/` still resolves, the parity
   linter (once it exists) passes, and the T01 contract doc was followed verbatim.
5. **Uncommitted work warning:** the working tree currently holds a large uncommitted SGAC batch
   (see `git status`). **Commit or stash it before any Wave 2 task starts** — tree moves on top
   of uncommitted modifications will make a mess.

## Open questions for Edwin (answers slot into T00/T01)

1. Does SGAC2.0 use a different Android package / iOS bundle ID, or the same
   `sg.gov.ica.mobile.app`? (Same ID ⇒ forks can't coexist on one device; affects T42 logistics.)
2. Separate Device Farm projects per fork, or one project + two app uploads?
3. Any flows that exist in only one fork (not just changed, but absent)? Those become
   `fork:*-only` suites in T33 rather than dispatch branches.
