# M04 — Consistent bounded interaction waits

- Status: Done (implemented, reviewed, integrated)
- Integration status: Integrated into `main` as `f653a02` and pushed (2026-09-06); device smoke test of the new wait semantics still REQUIRED before trusting green device runs
- Owner: OpenCode (moonshotai/kimi-k2.7-code), coordinated by Codex
- Priority: Medium
- Created: 2026-09-06
- Updated: 2026-09-06
- Worktree: /private/tmp/sgac-maintenance.BUsYX8/waits
- Base: 738fcda61f63ee2d8bcefaa59ddf826e35dd46f2
- Implementation model: OpenCode moonshotai/kimi-k2.7-code
- Reviewer: Codex

## Goal and scope

Refactor only shared Click on element and Type text waiting policies in commands.robot into a consistent configurable, bounded helper. Preserve existing public names/positional arguments and valid callers; allow optional timeout/poll controls with validation and readable diagnostics. Wait for readiness once within one deadline; avoid nested full-duration retries and blind replay of click/type actions (perform action once after readiness). Consider presence/visibility/enabled semantics and locator compatibility with AppiumLibrary; a Python bridge is allowed only if it uses the already-open AppiumLibrary session, never creates a driver, and is small/testable. Respect implicit waits when claiming a wall-clock bound (either implement/test safe handling or accurately document limit rather than overpromise). Do not alter app-open keywords, capabilities, iOS cleanup, NRIC typing chunk sizes/sleeps, screen recording, Chrome close helpers, or any suites. Add focused fake-clock/fake-driver or stub Robot-library unit tests that exercise the actual integration: success, absence/disabled, timeout, invalid arguments, action exceptions, no duplicate clicks/typing, and preserved locator handling. Document tunables and device validation limitations.

## Files owned

- `Resources/commands.robot`
- `Resources/interaction_waits.py`
- `tests/unit/test_interaction_waits.py`
- `docs/testing/interaction-waits.md`

## Acceptance criteria

- [x] Requested refactor implemented without unrelated changes.
- [x] Targeted device-free unit tests pass.
- [x] Both forks retain the 66-test dry-run baseline.
- [x] Codex static review completed and blocking findings addressed.
- [x] Repository parity gate passes on the combined integration baseline (see final results below).
- [x] Reviewed patch and handoff prepared for the dev lead; no worker commits or pushes.

## Execution rules

- User approved these maintenance refactors on 2026-09-06 and requested OpenCode implementation followed by Codex static analysis.
- Before task work call Mnemosyne recall, then read CLAUDE.md and AGENTS.md completely. If recall fails, report it and continue with repository evidence.
- Work ONLY in the assigned worktree, based on 738fcda61f63ee2d8bcefaa59ddf826e35dd46f2. Do not edit the main checkout, other worktrees, git metadata, settings, credentials, or files outside your ownership.
- No commits, staging, merging, pushing, dependency installation, device access, Appium sessions, remote portals, or additional agent delegation.
- Use apply_patch for edits. Keep existing public Robot keyword compatibility unless the explicit scope migrates every caller. Preserve assertions, test names/tags, fork contracts and no iOS installs. Do not implement T33, change locators/config, fix parity baseline, or edit ios_appium_commands.py / testspec*.yml.
- At dispatch, the main checkout contained a user-owned ios_appium_commands.py edit; workers were instructed not to copy or alter it. Its subsequent integration was handled independently by the dev lead.
- Interpreter: /Users/edwinwan/Documents/Projects/appium_robot_framework/venv/bin/python. Use -B; tests are device-free only. Use this interpreter directly, no venv creation/symlink/copy.
- Verification: run your new targeted unit tests with -B -m pytest -q -p no:cacheprovider; both APP_FORK=sgac1 and APP_FORK=sgac2 Robot dryruns with --output NONE --log NONE --report NONE; and -B tools/check_fork_parity.py --strict.
- Baseline at dispatch (historical): both fork dryruns passed 66 tests. Worker base 738fcda had 7 locator parity findings due to ongoing Wave 3; the then-dirty main tree had an eighth iOS literal. Workers were instructed not to suppress or fix these out of scope. The final combined check uses a newer dev-lead baseline, recorded below.
- Tests under tests/unit/ must not introduce .robot suites collected by robot --dryrun tests. No test import may contact devices, write real images, or use the network.
- The coordinator owns canonical todo task status, docs index, and final review. Do not edit those. Write only your assigned documentation file and implementation/tests. At completion list exact changes, tests and output counts, limitations, and any outstanding concerns. Leave your worktree diff uncommitted.

## Progress and decisions

- 2026-09-06: User approved deployment of OpenCode workers for the six maintenance suggestions; overlapping items grouped into four exclusive file sets.
- Canonical task status lives in the main checkout. Implementation stays isolated pending review.
- 2026-09-06: Implemented configurable readiness polling with one click/type action. Codex requested and verified input validation, environment wiring, monotonic deadline handling, error propagation, and implicit-wait restoration including partially applied setter failures. Focused tests: 57 passed.
- Codex combined review: 164 unit tests passed; 164 also passed in reverse file order with real AppiumLibrary pre-imported and no pre-existing AppiumLibrary module replacements. SGAC1 and SGAC2 dryruns each passed 66/66; inventory comparison found no name/tag/setup/teardown changes. Helper doctests and git diff --check passed.
- Combined worktree: /private/tmp/sgac-maintenance.BUsYX8/integrated, based on e7a15f1c1d339af7b1d06efa5a3cd2c8fcc1bba1. Strict parity: 0 errors, 0 warnings, with 230 pre-existing intentional divergences suppressed by the dev lead's allowlist; maintenance changes do not modify the checker, allowlist, or locator trees.
- [Static review and repeatable validation commands](../../docs/refactor/maintenance-static-review.md). [Reviewed patch](../artifacts/maintenance-refactors-2026-09-06.patch); git apply --check passed against main ab2cefe2465e8f301a11570eef99e55eb08b6378.
- Handoff: implementation remains uncommitted in the isolated review worktree and durable patch. The dev lead owns integration, rerunning checks against the latest checkout, and Android/iOS smoke testing. No live-device, remote-portal, image-generation, or Device Farm validation was performed; no commits, merges, or pushes were made by these workers or the coordinator.
- 2026-09-06: Dev lead reviewed and integrated the combined patch into `main` as `f653a02` and pushed to origin/main; full device-free battery green on the integrated checkout (164 unit tests, doctests, 66/66 dryruns both forks, strict parity 0/0). Worker worktrees/branches removed. OPEN: Android + iOS smoke test of the new semantics — `Click on element`/`Type text` now wait for visible+enabled and act ONCE (the old code retried the click itself for up to 1min; iOS XCUITest `visible` flakiness is the known risk; tune with `INTERACTION_WAIT_TIMEOUT`/`INTERACTION_WAIT_POLL`).
