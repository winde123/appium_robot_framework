# M01 — Portable cargo loading and reproducible per-test data

- Status: Done (implementation and static review)
- Integration status: Pending dev-lead integration and live-device acceptance
- Owner: OpenCode (moonshotai/kimi-k2.7-code), coordinated by Codex
- Priority: High
- Created: 2026-09-06
- Updated: 2026-09-06
- Worktree: /private/tmp/sgac-maintenance.BUsYX8/data
- Base: 738fcda61f63ee2d8bcefaa59ddf826e35dd46f2
- Implementation model: OpenCode moonshotai/kimi-k2.7-code
- Reviewer: Codex

## Goal and scope

Refactor shared test-data plumbing, not application flows. (1) Extract cargo file loading from manual_field_random.py into cargo_data.py with a repository-anchored default Cargo_Test_Data.txt, optional explicit path, UTF-8 BOM support, deterministic blank-line handling, useful invalid/missing-file errors, and proper file closing. Preserve readfromfile as a compatibility wrapper. The live Android cargo caller at line 234 uses it: retain intended 100-permit coverage, validate sufficient entries before indexing rather than silently changing test size. (2) Replace random module-level profile constants with explicit per-test profile records. Provide a seeded factory returning all required fields plus reproducibility metadata (seed and reference date for relative expiry dates). Seed both Faker and Python randomness independently without altering global RNGs, preserving the existing output formats/checksum algorithms. Allow replay by seed+reference date; log only seed/reference date at Robot level. Migrate all active Variables imports of manual_field_random.py and dependent legacy globals to per-test records, including Android QR and iOS cargo/SGAC. Helpers should accept/return explicit profile data as appropriate, with compatible no-argument entry points when existing callers need them. Leave random keyword/list APIs callable and compatible; no accidental Robot keywords from new imported helpers. Do not change existing assertions/flow/secure field timing or add fork-dispatch. Add focused unit tests for cargo files/CWD/BOM/error handling, seed/date replay, non-shared instances/global RNG isolation, valid field shapes/checksums, Robot import/keyword use and no import-time generation. Document API, replay, migration and compatibility.

## Files owned

- `Data/test_data/manual_field_random.py`
- `Data/test_data/cargo_data.py`
- `tests/unit/test_manual_field_random.py`
- `tests/unit/test_cargo_data.py`
- `Resources/android/SGACcommands.robot`
- `Resources/ios/SGACcommands.robot`
- `Resources/android/QRcommands.robot`
- `tests/android/sgac/*`
- `tests/ios/sgac/*`
- `tests/android/QR_code/QR_code_individual_profile_creation.robot`
- `tests/android/Add_Vehicle_Profile.robot`
- `tests/ios/cargo/convoy.robot`
- `docs/testing/test-data.md`

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
- 2026-09-06: Implemented portable cargo loading and explicit profile records. Codex requested and verified both resident helpers' supplied-record/return behavior, replay metadata validation, original CLI car-registration output, and removal of import-search-path side effects. Focused tests: 46 passed.
- Codex combined review: 164 unit tests passed; 164 also passed in reverse file order with real AppiumLibrary pre-imported and no pre-existing AppiumLibrary module replacements. SGAC1 and SGAC2 dryruns each passed 66/66; inventory comparison found no name/tag/setup/teardown changes. Helper doctests and git diff --check passed.
- Combined worktree: /private/tmp/sgac-maintenance.BUsYX8/integrated, based on e7a15f1c1d339af7b1d06efa5a3cd2c8fcc1bba1. Strict parity: 0 errors, 0 warnings, with 230 pre-existing intentional divergences suppressed by the dev lead's allowlist; maintenance changes do not modify the checker, allowlist, or locator trees.
- [Static review and repeatable validation commands](../../docs/refactor/maintenance-static-review.md). [Reviewed patch](../artifacts/maintenance-refactors-2026-09-06.patch); git apply --check passed against main ab2cefe2465e8f301a11570eef99e55eb08b6378.
- Handoff: implementation remains uncommitted in the isolated review worktree and durable patch. The dev lead owns integration, rerunning checks against the latest checkout, and Android/iOS smoke testing. No live-device, remote-portal, image-generation, or Device Farm validation was performed; no commits, merges, or pushes were made by these workers or the coordinator.
