# Mailinator SGAC DE-number helper

- Status: Done — helper and user-supplied Mailinator email fixture verified
- Owner: Codex
- Priority: High
- Created: 2026-09-09
- Updated: 2026-09-10

## Goal

Read the successful foreigner SGAC submission email through Mailinator's API,
extract the DE number and retain it for the subsequent update flow.

## Scope

- Shared Python/Robot helper, environment or gitignored .env token, read-only API polling.
- Submission correlation, stale/ambiguous email protection, in-memory and optional
  local JSON storage, mocked API and Robot integration tests, setup documentation.
- No changes to native UI locators, no email deletion, no new SGAC submissions.

## Acceptance criteria

- [x] Documented Mailinator API inbox/message reads use header authentication.
- [x] Plain-text/HTML DE extraction rejects missing or ambiguous values.
- [x] Capture before Submit excludes old mail and requires submission correlation.
- [x] DE numbers can be saved/reloaded by submission key for update flows.
- [x] Offline tests and fork parity pass; live-test prerequisites are explicit.
- [x] Configure Edwin's resident, foreigner and cargo inboxes as shared Robot variables.
- [x] Create ignored private .env/template and load its token without overriding the environment.
- [x] Fetch the user's dummy SGAC foreigner email and preserve it as a JSON fixture in Data/test_data.

## Validation plan

- Pytest mocked polling, parsing, errors, persistence and Robot execution.
- Full unit suite, fork parity and diff whitespace checks.

## Progress and decisions

- Mandatory recall and full CLAUDE.md read completed.
- No automated foreigner submission/update suite exists; provide composable keywords
  and a runnable device-free integration test instead of inventing an on-device pass.
- API contract checked against Mailinator's official documentation.
- Account domain/inboxes, token and dummy confirmation were subsequently supplied;
  live API and template validation are recorded in the follow-ups below.

## Handoff or blocker

Implementation, offline checks, authenticated API reads and dummy template parsing
are complete. A fresh app submission-to-email-to-native-update round trip remains
outside this completed helper/fixture task; WDA stays stopped at Edwin's request.

## Outcome

- Added `Resources/MailinatorDE.py` and `Resources/sgac_email.robot`: read-only
  paginated API capture/polling, subject/recipient/identity correlation, MIME DE
  extraction, explicit ambiguity failure, sanitized HTTP errors, retry/deadline
  handling and per-submission in-memory/optional owner-only JSON storage.
- Initially the token came only from the process environment; the persistent .env
  follow-up below extends this. No HTTP redirects or mailbox writes.
- Added indexed [setup and integration guide](../../docs/testing/mailinator-de-number.md).
  Prior regression task remains blocked; no fresh SGAC submission or live API read
  was made, and no native locator migration/device pass is claimed.
- `venv/bin/python -B -m pytest tests/unit -q -p no:cacheprovider`: **232 passed**,
  including **67 Mailinator tests**. The Robot integration test executes three real
  keyword cases against mocked HTTP: capture/store, later load, failed-load reset.
- `venv/bin/python -B tools/check_fork_parity.py`: **0 errors, 0 warnings**,
  238 documented divergences suppressed. `git diff --check`: pass.
- Existing unrelated worktree edits preserved. Initial helper added no dependency,
  account configuration or token changes; the follow-up supplies non-secret routing.

## User-provided inbox follow-up

- Added `Data/test_data/submission_email.yaml`, imported by the shared Robot resource:
  resident `sgac-res@team380551.testinator.email`, foreigner
  `sgac-fore@team380551.testinator.email`, cargo `cargo@team380551.testinator.email`.
- Kept email inputs explicit; no blanket overrides of generated profiles, no native
  profile/server record changes, no new submissions or live Mailinator requests.
- Shared module inboxes still require per-submission identity/time/ID correlation.
- Token presence check returned false; no credential value was printed or stored.
- Final full unit suite: **236 passed**, including **71 Mailinator tests**. New tests
  validate all three API inbox routes and actual Robot variable imports without a token.
- Fork parity: **0 errors, 0 warnings**. Whitespace checks pass.

## Persistent .env follow-up

- Edwin explicitly requested persistent local token storage instead of shell-only
  exports. Created root `.env` with a blank `MAILINATOR_API_TOKEN=` and mode `0600`;
  created a blank trackable `.env.example` for other checkouts.
- `.gitignore` excludes `.env` and `.env.*`, except `.env.example`. Verified the local
  file is ignored and absent from normal Git status. No existing .env was overwritten.
- `MailinatorDE` reads the exact repository-root file with `dotenv_values`, interpolation
  disabled, on each API request. No CWD search, no global environment mutation, no
  credential logging. An explicit environment value (even empty) takes precedence.
- Declared installed `python-dotenv==1.2.3` in requirements. Added tests for quoted
  values, CWD independence, precedence, blank/invalid tokens, literal values, reloads,
  sanitized errors and no environment mutation. Offline tests isolate the real .env.
- Full suite **249 passed**, including **84 Mailinator tests**; fork parity **0 errors,
  0 warnings**; whitespace checks pass. Token authenticity/API delivery not tested.
- Updated root README, indexed setup guide, test-data comment and regression handoff.
  User should fill the token locally; no live mail reads or new submissions were made.

## Live API and dummy email fixture follow-up

- Edwin populated the persistent local token. Authenticated inbox reads succeeded;
  subsequent read-only retrieval found his dummy SGAC foreigner acknowledgement in
  `sgac-fore@team380551.testinator.email`, ID `sgac-fore-1788946522-096396023`.
- Saved the entire parsed API response to
  [Data/test_data/sgac_foreigner_acknowledgement.json](../../Data/test_data/sgac_foreigner_acknowledgement.json),
  including headers, metadata and original HTML. Verified saved content exactly matches
  the fetched response after JSON pretty-printing. No token included, no mail deleted
  or modified, and no email links/images opened.
- Existing parsing extracts the repeated dummy DE `X8276T7137` correctly. Added offline
  fixture tests for HTML extraction and mocked identity-correlated capture/storage.
  The latter changes only the timestamp in memory to simulate new delivery.
- The actual subject uses `Singapore Arrival Card`, not the helper's default
  `SG Arrival Card`. Documented the explicit `subject_contains=Singapore Arrival Card`
  override and updated integration examples; no helper defaults changed in this task.
- This raw email fixture is not a helper-generated DE storage record and is not for
  the previous regression visitor's identity. No live update, new submission, WDA
  restart or full-regression completion is claimed.
- Validation: **251 unit tests passed**, including **86 Mailinator tests**; fork parity
  **0 errors, 0 warnings** (238 documented divergences suppressed). Tracked diff and
  new fixture whitespace checks pass. Existing unrelated worktree changes preserved.
