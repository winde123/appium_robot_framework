# Offline locator verification and device-free fork slices

**Last reviewed:** 2026-09-19

`tools/xpath_evidence_check.py` evaluates the XPath locators in a fork locator YAML
(`Data/{sgac1,sgac2}/{android,ios}/**/*.yaml`) against captured Appium page sources
(UiAutomator2 `<hierarchy>` dumps or XCUITest `<AppiumAUT>` dumps) without a device. It was
introduced on 2026-09-19 to let the T33 fork-dispatch slices be implemented and reviewed while
the emulator was offline and the iPad was held by another regression session. This page
records how to use it, the acceptance bar it enforces, the pattern for sgac2-only locator
trees it exposed, and the headless-agent workflow built around it.

## Usage

```sh
venv/bin/python tools/xpath_evidence_check.py \
    --yaml Data/sgac2/android/sgac/resident/resident_profile_creation_form_page.yaml \
    --evidence Output/sgac2-build15-regression-2026-09-10 --match res- \
    [--keys RES-PROFILE-NAME-INPUT ...] [--verbose] [--json out.json]
```

- `--yaml` and `--evidence` are repeatable; an evidence argument is an XML file or a directory
  searched recursively for `*.xml`. `--match` keeps only files whose name contains the substring
  (use the capture prefixes, e.g. `res-`, `foreigner`, `visitor`).
- `--keys` restricts the run to named keys (the flow keys a keyword taps, types into or waits
  for). `--verbose` lists the matching files per key; `--json` writes the full result mapping.
- Exit status is `0` when every checked key resolves to exactly one node in at least one file,
  otherwise `1`. Nothing here touches a device, and no file is modified.

Per-key statuses:

| Status | Meaning |
| --- | --- |
| `verified` | exactly one node in at least one evidence file (the `e.g.` column names one) |
| `ambiguous` | never exactly one, but more than one node in some file |
| `unresolved` | zero nodes in every file |
| `template (skipped)` | the value contains `{}` (a `Format String` template) — verify the filled value separately |
| `not-xpath (skipped)` / `empty (skipped)` | the value is not an XPath (comment-only keys, page markers) |
| `invalid-xpath` | lxml could not compile or evaluate the expression |

Evidence sources: the gitignored `Output/<run>/` capture sets written by the device regressions
(each report under `docs/testing/` names its directory) and the tracked walkthrough sources
under `docs/project-documentation/android-sgac2-2026-09-07/*/sources/`. Prefer the newest
build's captures; older sets are cross-checks only.

## Acceptance bar used for the T33 slices

- Every key the flow **taps, types into or waits for** must be `verified` in a capture of the
  right screen. Header and label keys may be `ambiguous` on iOS (React Native exposes some
  StaticText nodes twice) because they are only asserted, never tapped.
- Template keys are verified by a one-off lxml evaluation of the filled value, e.g. the
  `searchable dropdown accessible label SINGAPOREAN` option, and the matching capture is
  recorded in the task file.
- Evidence must come from the latest captured build. The iOS sgac2 resident and foreigner
  contact pages were annotated "email only" from build 13, but the build-15/17 captures show
  country code and mobile fields again; the verifier made that drift visible and the keys were
  restored.
- What the verifier cannot prove: keyboard state and timing (Done taps, option taps under an
  open keyboard), `Type text` behaviour on masked date inputs, and elements that only appear
  after an action (for example the SAVE button after the terms checkbox). Those stay listed as
  runtime risks for the device run (T42).

Worked examples and the resulting tables live in the task records
`todo/done/t33-android-resident-profile-crud.md`, `todo/done/t33-ios-resident-profile-crud.md`,
`todo/done/t33-android-foreigner-profile-crud.md` and `todo/done/t33-ios-foreigner-profile-crud.md`,
with per-platform summaries in `Data/sgac2/android/STATUS.md` and `Data/sgac2/ios/STATUS.md`.

## sgac2-only locator trees

`Data/sgac2/android/sgac/foreigner/` has no SGAC1.0 counterpart (SGAC1.0 Android drove the
foreigner form through the shared manual profile YAML). A static
`Variables    ${FORK_DATA_DIR}/android/sgac/foreigner/for_profile_form.yaml` in a shared keyword
file would error on every `APP_FORK=sgac1` run, including dry runs, because the file does not
exist in that tree. The accepted pattern (fork-conventions §6) is to load such files at runtime
inside the `… for sgac2` keywords:

```robot
Import foreigner locator files
    Import Variables    ${FORK_DATA_DIR}/android/sgac/foreigner/for_profile_form.yaml
    Import Variables    ${FORK_DATA_DIR}/android/sgac/foreigner/for_profile_summary.yaml
    ...

Fill foreigner profile form for sgac2
    [Arguments]    ${profile}
    Import foreigner locator files
    Click on element    ${PROFILE-CREATION-FILL-MANUALLY-BUTTON}
    ...
```

The `… for sgac1` implementations fail fast with an explicit message, and the suite carries
`Force Tags    fork:sgac1-only` or `fork:sgac2-only` as appropriate. Keep `${FORK_DATA_DIR}` in
the runtime path (no literal fork directories) and register the whole file as `files.sgac2_only`
in `tools/fork_parity_allowlist.yaml`.

## Device-free slices with headless OpenCode agents

The two T33 slices were implemented by OpenCode agents (`moonshotai/kimi-k2.7-code` for
Android, `deepseek/deepseek-v4-pro` for iOS) and reviewed and merged by the dev-lead session:

1. `git worktree add <scratch>/wt-<task> -b refactor/<task> main`; symlink the repository `venv`
   into the worktree; copy the needed `Output/<run>/` capture sets into `<worktree>/Output/evidence/`
   (headless `opencode run` cannot read outside its directory; `Output/` is gitignored).
2. In the worktree's `opencode.json` set the `appium` and `robotmcp` MCP servers to
   `enabled: false` so the agent cannot open a device session; keep `mnemosyne` for the
   mandatory recall. Restore the file before diffing.
3. Write the brief as `todo/in-progress/<task>.md` inside the worktree: capture-derived facts
   per screen, exact file ownership, the keyword design, the validation battery and acceptance
   criteria. Launch `opencode run --auto -m <provider/model> --title … "<pointer to the brief +
   hard rules>"` in the background. Hard rules: no device work, owned files only, no git
   commit/checkout/stash/push, no Mnemosyne writes.
4. Review in the worktree: `git diff`; re-run `pytest tests/unit`, `tools/check_fork_parity.py --strict`,
   `robot --dryrun tests` for both forks (also with `--exclude fork:<other>-only`), a per-fork
   `${VARIABLE}` resolution check, and the verifier over every sgac2 flow key.
5. Merge with `git diff -- . ':!opencode.json' | git apply --3way` into `main`. When another
   agent has uncommitted hunks in a shared file, stage only your hunk: apply the same edit to
   `git show HEAD:<file>`, `git diff --no-index` the two copies, then `git apply --cached`.

Adjustments the dev lead expected to make at merge: `Wait Until Element Is Visible` calls
without `${INTERACTION_WAIT_TIMEOUT}`, per-test fork tags where a suite-level `Force Tags`
was meant, and duplicated keyword bodies where a composition was asked for.
