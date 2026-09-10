# Commit plan — 11 September 2026 (dev-lead approved)

- Status: Ready for execution by the `git-committer` OpenCode agent
- Author/reviewer: Claude (dev lead); build 15 Android regression pass reviewed 2026-09-11
- Scope: commit and push the FOUR Android build-15 regression slice reports, the
  Android walk-status update, and this plan (base `4b297b8`). Docs-only — no code,
  YAML, or suite changes.

## Review already performed (do not repeat, do not re-modify files)

- All four regression slices were driven and reviewed by the dev lead on the
  Pixel_7_Pro emulator against MyICA 2.0.0/vc422 (in-app build 15); reports
  cross-checked against their evidence dirs (all PNG/XML pairs validated).
- `Data/sgac2/android/STATUS.md` gained four sections (resident+foreigner
  regression 2026-09-10; QR, cargo+convoy, 12-language sweep 2026-09-11); the
  locator table is unchanged.
- Battery at review time: pytest 251/251, parity strict 0/0, dual-fork dryrun
  68/68 + 68/68, `git diff --check` clean.

## Preconditions (hard stop on mismatch)

`git status --short` must list EXACTLY these paths (order irrelevant).

IN SCOPE (to be staged per the commits below):
- modified: `Data/sgac2/android/STATUS.md`
- untracked: `docs/testing/sgac2-build15-regression-2026-09-10.md`,
  `docs/testing/sgac2-build15-qr-regression-2026-09-11.md`,
  `docs/testing/sgac2-build15-cargo-regression-2026-09-11.md`,
  `docs/testing/sgac2-build15-language-sweep-2026-09-11.md`,
  `todo/commit-plan-2026-09-11.md` (this file)

TOLERATED — parallel iOS/doc workstream, must NEVER be staged by this plan:
- modified: `CLAUDE.md`, `Data/sgac2/ios/STATUS.md`, `docs/README.md`
- deleted: `todo/in-progress/ios-module-regression-2026-09-09.md`
- untracked: `docs/exported/`,
  `docs/testing/ios-1-19-1-regression-2026-09-10.md`,
  `docs/testing/ios-sgac2-build15-regression-2026-09-10.md`,
  `todo/blocked/ios-module-regression-2026-09-09.md`,
  and any further new `docs/testing/ios-*` or `docs/exported/*` files

Entries under `Output/` or other gitignored paths are fine and must stay
unstaged. `.env` must NEVER be staged; confirm `git check-ignore .env` succeeds.
Any OTHER unexpected path is a hard stop. If a tolerated file changes again
mid-run, ignore it; if an in-scope file changes after you stage it, commit the
staged snapshot — do not re-add.

## Verification battery (run BEFORE commit 1 and AFTER commit 4)

```sh
venv/bin/python -m pytest tests/unit -q             # expect: 251 passed
venv/bin/python tools/check_fork_parity.py --strict # expect: 0 errors, 0 warnings
venv/bin/robot --dryrun --output NONE --report NONE --log NONE tests/            # expect 68/68
APP_FORK=sgac2 venv/bin/robot --dryrun --output NONE --report NONE --log NONE tests/  # expect 68/68
git diff --check                                    # expect: no output
```

## Commits (stage with explicit paths; exact messages including trailers)

**Commit 1**
Paths: `docs/testing/sgac2-build15-regression-2026-09-10.md`
Message:
```
test: record Android SGAC2 build 15 resident+foreigner regression pass

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_019UAi2Wq2LZUmkJv5pWNAWQ
```

**Commit 2**
Paths: `docs/testing/sgac2-build15-qr-regression-2026-09-11.md`
Message:
```
test: record Android SGAC2 build 15 QR module regression pass

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_019UAi2Wq2LZUmkJv5pWNAWQ
```

**Commit 3**
Paths: `docs/testing/sgac2-build15-cargo-regression-2026-09-11.md`
Message:
```
test: record Android SGAC2 build 15 cargo and convoy regression pass

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_019UAi2Wq2LZUmkJv5pWNAWQ
```

**Commit 4**
Paths: `docs/testing/sgac2-build15-language-sweep-2026-09-11.md`,
`Data/sgac2/android/STATUS.md`, `todo/commit-plan-2026-09-11.md`
Message:
```
test: record build 15 12-language sweep; update Android walk status for all four slices

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_019UAi2Wq2LZUmkJv5pWNAWQ
```

## Push

After commit 4 and a green final battery: `git push origin main`.
Then report: SHAs, per-commit file counts, battery outputs (tail lines), push result.
