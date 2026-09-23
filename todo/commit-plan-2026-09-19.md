# Commit plan — 19 September 2026 (dev-lead approved)

- Status: Ready for execution by the `git-committer` OpenCode agent
- Author/reviewer: Claude (dev lead); Codex's iPad/Android regression documentation reviewed 2026-09-19
- Scope: commit and push Codex's regression documentation backlog from 10–19 September
  (iOS 1.19.1(1) run + SGAC2 build-15 iPad continuation + Word issue export; Android build-15
  submission regression; iPad build-17 regression; iPad build-18 regression + CLAUDE.md /
  docs-index refresh) and this plan, on top of base `c008088` (the git-committer permission fix; the T33/docs commits `c423241`, `1529e7a`, `dc90c14` sit below it). Docs, task records and one
  Word export only — no code, YAML, suite or tooling changes.

## Review already performed (do not repeat, do not re-modify files)

- All reports were produced by Codex from device runs (physical iPad Air 11-inch for the iOS
  runs, Pixel_7_Pro emulator for the Android run); the dev lead read the diffs, the report
  headers and the STATUS/CLAUDE.md hunks, and scanned every file for credentials (none).
- The dev lead's own T33 hunks in `CLAUDE.md`, `docs/README.md` and both `STATUS.md` files
  were already committed separately (`c423241`, `1529e7a`, `dc90c14`); what remains in those
  files is Codex's text only.
- `docs/exported/myica-ios-sgac2-build15-possible-issues-2026-09-10.docx` (4.8 MB, a genuine
  Word file) is tracked on purpose — six Word documents are already tracked under
  `docs/project-documentation/`; `docs/exported/README.md` describes it.
- Battery at review time: parity strict 0/0; `git diff --check` clean; no trailing whitespace
  or tabs in the untracked Markdown files.

## Preconditions (hard stop on mismatch)

`git status --short` must list EXACTLY these paths (order irrelevant). Everything listed is IN
SCOPE and is staged by exactly one of the commits below.

- modified: `CLAUDE.md`, `Data/sgac2/android/STATUS.md`, `Data/sgac2/ios/STATUS.md`, `docs/README.md`
- deleted: `todo/in-progress/ios-module-regression-2026-09-09.md` (moved to `todo/blocked/`)
- untracked: `docs/exported/README.md`,
  `docs/exported/myica-ios-sgac2-build15-possible-issues-2026-09-10.docx`,
  `docs/testing/ios-1-19-1-regression-2026-09-10.md`,
  `docs/testing/ios-sgac2-build15-regression-2026-09-10.md`,
  `docs/testing/sgac2-build15-submission-regression-2026-09-11.md`,
  `docs/testing/ios-build17-regression-2026-09-16.md`,
  `docs/testing/ios-build18-regression-2026-09-19.md`,
  `todo/blocked/ios-module-regression-2026-09-09.md`,
  `todo/done/android-sgac-submission-regression-2026-09-11.md`,
  `todo/done/myica-build17-full-regression-2026-09-16.md`,
  `todo/done/myica-build18-full-regression-2026-09-19.md`,
  `todo/commit-plan-2026-09-19.md` (this file)

`git status --short` shows `docs/exported/` collapsed as a directory; use
`git status --short --untracked-files=all` to see both files inside it. Entries under
`Output/` or other gitignored paths are fine and must stay unstaged. `.env` must NEVER be
staged; confirm `git check-ignore .env` succeeds. Any OTHER unexpected path is a hard stop:
report and do not commit.

## Verification battery (run BEFORE commit 1 and AFTER commit 4)

```sh
venv/bin/python -m pytest tests/unit -q             # expect: 251 passed
venv/bin/python tools/check_fork_parity.py --strict # expect: 0 errors, 0 warnings
venv/bin/robot --dryrun --output NONE --report NONE --log NONE tests/            # expect 69/69
APP_FORK=sgac2 venv/bin/robot --dryrun --output NONE --report NONE --log NONE tests/  # expect 69/69
git diff --check                                    # expect: no output
```

Run each command on its own (no `cd`, no `&&` chains). Any failure is a hard stop: report,
do not commit further, do not push.

## Commits (stage with explicit paths; exact messages including trailers)

Stage each commit with `git add <path> [<path> …]` using exactly the listed paths (for the
deleted file, `git add todo/in-progress/ios-module-regression-2026-09-09.md` records the
removal). Never `git add -A`, `git add .` or `git add -u`. Commit with
`git commit -F <message-file>` or a quoted `-m` message reproducing the text below verbatim.

**Commit 1**
Paths: `docs/testing/ios-1-19-1-regression-2026-09-10.md`
`docs/testing/ios-sgac2-build15-regression-2026-09-10.md`
`docs/exported/README.md`
`docs/exported/myica-ios-sgac2-build15-possible-issues-2026-09-10.docx`
`todo/blocked/ios-module-regression-2026-09-09.md`
`todo/in-progress/ios-module-regression-2026-09-09.md` (deletion)
`Data/sgac2/ios/STATUS.md`

Message:
```
test: record iOS 1.19.1(1) run, SGAC2 build 15 iPad continuation and Word issue export

- docs/testing/ios-1-19-1-regression-2026-09-10.md: the 10 September iPad run on MyICA
  1.19.1(1) — SGAC1.0, the wrong target version — retained as evidence and excluded from
  SGAC2.0 coverage.
- docs/testing/ios-sgac2-build15-regression-2026-09-10.md: SGAC2.0 2.0.0(15) STAGING
  continuation on the physical iPad (117 paired captures): resident/visitor retrieval,
  one approved visitor health update, cargo/convoy retrieval and persistence, QR checks.
- docs/exported/: illustrated Word issue review (eight findings, nine screenshots) and its
  README.
- todo/blocked/ios-module-regression-2026-09-09.md replaces the in-progress record (WDA
  stopped 11 September; visitor update email/readback still unverified).
- Data/sgac2/ios/STATUS.md: build-correction and issue-review notes (no locator changes).

Co-Authored-By: Codex <noreply@openai.com>
Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
```

**Commit 2**
Paths: `docs/testing/sgac2-build15-submission-regression-2026-09-11.md`
`todo/done/android-sgac-submission-regression-2026-09-11.md`
`Data/sgac2/android/STATUS.md`

Message:
```
test: record Android SGAC2 build 15 resident and foreigner submission regression

- docs/testing/sgac2-build15-submission-regression-2026-09-11.md: Pixel_7_Pro emulator,
  MyICA 2.0.0(15)/versionCode 422 STAGING — one resident and one foreigner submission
  accepted, both acknowledgement emails delivered and both records retrieved (visitor DE
  captured with MailinatorDE.py); wrong-arrival and wrong-DE checks rejected; catalogue
  HOTEL submission and masked update form to Review; 7-day form versus 6-day email
  discrepancy; 100 paired captures.
- todo/done/android-sgac-submission-regression-2026-09-11.md: completed task with the
  next-session handover (retained fixtures, readiness checks, open findings).
- Data/sgac2/android/STATUS.md: regression section (no locator status changes).

Co-Authored-By: Codex <noreply@openai.com>
Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
```

**Commit 3**
Paths: `docs/testing/ios-build17-regression-2026-09-16.md`
`todo/done/myica-build17-full-regression-2026-09-16.md`

Message:
```
test: record iPad MyICA 2.0.0(17) full regression

- docs/testing/ios-build17-regression-2026-09-16.md: iPad-only 2.0.0(17) STAGING regression
  (519 validated paired captures): Singpass result, ten finding groups with proposed
  priorities, transaction/email evidence and cleanup.
- todo/done/myica-build17-full-regression-2026-09-16.md: completed task and handoff (WDA and
  USB forwarding stopped after the run; Appium server left running).

Co-Authored-By: Codex <noreply@openai.com>
Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
```

**Commit 4**
Paths: `docs/testing/ios-build18-regression-2026-09-19.md`
`todo/done/myica-build18-full-regression-2026-09-19.md`
`CLAUDE.md`
`docs/README.md`
`todo/commit-plan-2026-09-19.md`

Message:
```
test: record iPad MyICA 2.0.0(18) full regression; refresh CLAUDE.md and docs index

- docs/testing/ios-build18-regression-2026-09-19.md: iPad-only 2.0.0(18) STAGING regression
  (521 paired captures, nine accepted staging operations with correlated acknowledgements,
  36 language selections, 111 navigation observations): ten active finding groups
  (2 High, 7 Medium, 1 Low), build-17 comparison, new QR-generation and Customs-download
  findings, MyInfo required-field blocker, cleanup and coverage boundaries.
- todo/done/myica-build18-full-regression-2026-09-19.md: completed task and handoff (run-owned
  records removed, settings restored, session/WDA/forwarder closed, Appium 4723 ready).
- CLAUDE.md: latest iOS regression, historical build-15 notes and Android submission
  regression sections; docs/README.md: index rows for the new reports and the Word export.
- todo/commit-plan-2026-09-19.md: this commit plan.

Co-Authored-By: Codex <noreply@openai.com>
Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
```

## After the commits

1. Run the verification battery again (expect the same results).
2. `git status --short` must be empty apart from gitignored paths.
3. `git log --oneline -5` must show the four new commits on top of `c008088`.
4. Push: `git push origin main` — only if every battery result matched and all four commits
   were created.
5. Report: the four commit SHAs with their file lists, both battery results, and the push
   result.

## Execution log

- 2026-09-19 20:13 — first `git-committer` run (no `--auto`) hung with no output; killed 2026-09-23.
- 2026-09-23 — relaunch with `--auto` stopped correctly: the agent's wildcard bash deny removed
  its shell tool. Fixed in `c008088` (dev-lead chore commit); plan base retargeted to `c008088`.
