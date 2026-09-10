# Commit plan — 10 September 2026 (dev-lead approved)

- Status: Ready for execution by the `git-committer` OpenCode agent
- Author/reviewer: Claude (dev lead); regression review completed 2026-09-10
- Scope: commit and push ALL currently pending work on `main` (base `c20cc14`)

## Review already performed (do not repeat, do not re-modify files)

- MailinatorDE helper, Robot resource and 251 unit tests reviewed; no regressions.
- `Data/test_data/sgac_foreigner_acknowledgement.json` had its `x-smtpapi`
  mail-provider auth header REDACTED by the dev lead — verify the string
  `REDACTED` appears in that file's `x-smtpapi` value before committing.
- `.gitignore` extended (`.env` family, `__pycache__/`, `.robotmcp_artifacts/`).
- Battery at review time: pytest 251/251, parity strict 0 errors/0 warnings,
  dual-fork dryrun 68/68 + 68/68, `robot.libdoc` parses `sgac_email.robot`.

## Preconditions (hard stop on mismatch)

`git status --short` must list EXACTLY these paths (order irrelevant):
modified: `.gitignore`, `Data/sgac2/android/STATUS.md`,
`Data/sgac2/android/sgac/foreigner/for_profile_form.yaml`, `README.md`,
`docs/README.md`, `docs/testing/test-data.md`, `requirements.txt`;
untracked: `.env.example`, `.opencode/` (5 agent files),
`Data/test_data/sgac_foreigner_acknowledgement.json`,
`Data/test_data/submission_email.yaml`, `Resources/MailinatorDE.py`,
`Resources/sgac_email.robot`, `docs/testing/ios-build15-regression-2026-09-09.md`,
`docs/testing/mailinator-de-number.md`,
`docs/testing/sgac2-build15-e2e-2026-09-08.md`, `tests/unit/test_mailinator_de.py`,
`todo/commit-plan-2026-09-10.md`, `todo/done/mailinator-sgac-de-helper.md`,
`todo/done/sgac2-build15-e2e-continuation.md`,
`todo/in-progress/ios-module-regression-2026-09-09.md`,
`todo/visitor-de-roundtrip-2026-09-10.md`.

Extra entries appearing ONLY under `Output/visitor-de-roundtrip-2026-09-10/` or
other gitignored paths are fine (they must stay unstaged). `.env` must NEVER be
staged; confirm `git check-ignore .env` succeeds.

**Amendment (2026-09-10, after the first run's correct hard stop):** two
concurrent sessions are writing to this repo while their own work is in
progress — a Codex iOS 1.19.1 regression (iPad) and the visitor-DE round-trip
agents (Android). Their outputs are TOLERATED as extra untracked/changed paths
and must NEVER be staged by this plan:
- `docs/testing/ios-1-19-1-regression-2026-09-10.md` (and any further new
  `docs/testing/ios-1-19-1-*` files)
- `docs/testing/visitor-de-roundtrip-2026-09-10.md` (if it appears)
- any new files under `todo/` not listed in this plan
Any OTHER unexpected path remains a hard stop. If a file listed in a commit
below is modified again by a concurrent session after you stage it, commit the
staged snapshot — do not re-add.

## Verification battery (run BEFORE commit 1 and AFTER commit 4)

```sh
venv/bin/python -m pytest tests/unit -q            # expect: 251 passed
venv/bin/python tools/check_fork_parity.py --strict # expect: 0 errors, 0 warnings
venv/bin/robot --dryrun --output NONE --report NONE --log NONE tests/            # expect 68/68
APP_FORK=sgac2 venv/bin/robot --dryrun --output NONE --report NONE --log NONE tests/  # expect 68/68
git diff --check                                    # expect: no output
```

## Commits (stage with explicit paths; exact messages including trailers)

**Commit 1**
Paths: `Data/sgac2/android/STATUS.md`,
`Data/sgac2/android/sgac/foreigner/for_profile_form.yaml`,
`docs/testing/sgac2-build15-e2e-2026-09-08.md`,
`todo/done/sgac2-build15-e2e-continuation.md`
Message:
```
test: record Android SGAC2 build 15 E2E continuation (status, foreigner contact locators)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_016obNgjYtf4dAiy64t5ZFaT
```

**Commit 2**
Paths: `Resources/MailinatorDE.py`, `Resources/sgac_email.robot`,
`tests/unit/test_mailinator_de.py`, `Data/test_data/submission_email.yaml`,
`Data/test_data/sgac_foreigner_acknowledgement.json`, `.env.example`,
`.gitignore`, `requirements.txt`, `README.md`,
`docs/testing/mailinator-de-number.md`, `todo/done/mailinator-sgac-de-helper.md`
Message:
```
feat: Mailinator DE-number capture helper for foreigner SGAC updates

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_016obNgjYtf4dAiy64t5ZFaT
```

**Commit 3**
Paths: `docs/testing/ios-build15-regression-2026-09-09.md`,
`todo/in-progress/ios-module-regression-2026-09-09.md`,
`docs/testing/test-data.md`, `docs/README.md`
Message:
```
docs: record iOS build 15 iPad regression, UAT permit provenance and doc index

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_016obNgjYtf4dAiy64t5ZFaT
```

**Commit 4**
Paths: `.opencode/agent/git-committer.md`, `.opencode/agent/sgac-de-roundtrip.md`,
`.opencode/agent/de-submission-driver.md`, `.opencode/agent/de-email-capturer.md`,
`.opencode/agent/de-update-verifier.md`, `todo/commit-plan-2026-09-10.md`,
`todo/visitor-de-roundtrip-2026-09-10.md`
Message:
```
chore: add OpenCode commit and visitor-DE round-trip agents with task briefs

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_016obNgjYtf4dAiy64t5ZFaT
```

## Push

After commit 4 and a green final battery: `git push origin main`.
Then report: SHAs, per-commit file counts, battery outputs (tail lines), push result.
