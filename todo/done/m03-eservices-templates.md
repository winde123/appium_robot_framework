# M03 — Reusable e-services test templates

- Status: Done (implementation and static review)
- Integration status: Pending dev-lead integration and live-device acceptance
- Owner: OpenCode (moonshotai/kimi-k2.7-code), coordinated by Codex
- Priority: Medium
- Created: 2026-09-06
- Updated: 2026-09-06
- Worktree: /private/tmp/sgac-maintenance.BUsYX8/templates
- Base: 738fcda61f63ee2d8bcefaa59ddf826e35dd46f2
- Implementation model: OpenCode moonshotai/kimi-k2.7-code
- Reviewer: Codex

## Goal and scope

Remove repeated iOS e-services navigation/assertion bodies with Robot's built-in Test Template / reusable keywords. Start with check_validity_verify_services.robot and apply to other genuinely identical repeated cases in the owned directory where safe. Retain EVERY original test name, count, fork tag, setup/teardown, locator import, portal-specific expected header, menu-count assertion and interaction order. Keep portal differences as explicit case arguments; don't force dissimilar workflows into one opaque mega-keyword or change locators/SGAC behaviour. Maintain the existing ios_appium_commands teardown call untouched; fixing it is out of scope. Add device-free tests using Robot parsing/model or fake keywords to verify original case-to-locator/assertion mappings, expanded behaviour, count/tag preservation and no missing arguments. No third-party DataDriver dependency. Document the template and how to add a service case.

## Files owned

- `tests/ios/other_e_services/*`
- `Resources/ios/eservices_commands.robot`
- `tests/unit/test_eservices_templates.py`
- `docs/testing/eservices-templates.md`

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
- 2026-09-06: Implemented the shared e-services template while preserving every original case mapping and action/assertion order. Codex found and verified fixes for the apostrophe-locator runtime regression and a combined-suite test-harness coupling/module-isolation failure. Focused tests: 16 passed.
- Codex combined review: 164 unit tests passed; 164 also passed in reverse file order with real AppiumLibrary pre-imported and no pre-existing AppiumLibrary module replacements. SGAC1 and SGAC2 dryruns each passed 66/66; inventory comparison found no name/tag/setup/teardown changes. Helper doctests and git diff --check passed.
- Combined worktree: /private/tmp/sgac-maintenance.BUsYX8/integrated, based on e7a15f1c1d339af7b1d06efa5a3cd2c8fcc1bba1. Strict parity: 0 errors, 0 warnings, with 230 pre-existing intentional divergences suppressed by the dev lead's allowlist; maintenance changes do not modify the checker, allowlist, or locator trees.
- [Static review and repeatable validation commands](../../docs/refactor/maintenance-static-review.md). [Reviewed patch](../artifacts/maintenance-refactors-2026-09-06.patch); git apply --check passed against main ab2cefe2465e8f301a11570eef99e55eb08b6378.
- Handoff: implementation remains uncommitted in the isolated review worktree and durable patch. The dev lead owns integration, rerunning checks against the latest checkout, and Android/iOS smoke testing. No live-device, remote-portal, image-generation, or Device Farm validation was performed; no commits, merges, or pushes were made by these workers or the coordinator.
