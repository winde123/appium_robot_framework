# Project documentation

Last reviewed: 2026-09-08

This directory is the durable reference point for humans and coding agents working on this repository. It should explain why the project is structured as it is, how important workflows operate, and which constraints should be preserved.

## Documentation map

| Document | Purpose |
| --- | --- |
| [`testing/ios-1-19-1-regression-2026-09-10.md`](testing/ios-1-19-1-regression-2026-09-10.md) | Post-reinstall iOS 1.19.1 regression: authorized submissions, deletion semantics and mixed resident/foreigner group QR |
| [`testing/ios-build15-regression-2026-09-09.md`](testing/ios-build15-regression-2026-09-09.md) | Real-iPad build 15 regression results: resident/foreigner SGAC, cargo/convoy and QR; findings, evidence and remaining end-to-end prerequisites |
| [`project-documentation/README.md`](project-documentation/README.md) | Categorised Android emulator screen walkthroughs, original screenshots, and illustrated Word documents |
| [`project-documentation/android-sgac2-2026-09-07/README.md`](project-documentation/android-sgac2-2026-09-07/README.md) | SGAC2 walkthrough: 200 documented screens, six Word documents, all 32 e-Service entry links, support destinations and coverage limits |
| [`project-documentation/android-sgac2-2026-09-07/flow-inventory.md`](project-documentation/android-sgac2-2026-09-07/flow-inventory.md) | Live navigation and 24 Android test cases reconciled against manual captures, observed issues and unexercised variants |
| [`../Data/sgac2/android/STATUS.md`](../Data/sgac2/android/STATUS.md) | Android locator verification status and links to later manual walkthrough evidence |
| [`testing/sgac2-build15-e2e-2026-09-08.md`](testing/sgac2-build15-e2e-2026-09-08.md) | Build 15 Android E2E continuation: Singpass callback, resident/visitor review, QR, cargo/convoy, languages, defects and evidence boundaries |
| [`testing/test-data.md`](testing/test-data.md) | Portable cargo permit loading and replayable per-test profile records |
| [`testing/mailinator-de-number.md`](testing/mailinator-de-number.md) | Mailinator API capture, DE extraction, private local storage and Robot handoff to foreigner SGAC update flows |
| [`testing/helper-tools.md`](testing/helper-tools.md) | String/date helper contracts and import-safe QR/date utilities |
| [`testing/eservices-templates.md`](testing/eservices-templates.md) | Shared e-services templates, case mappings, and device-free execution checks |
| [`testing/interaction-waits.md`](testing/interaction-waits.md) | Configurable interaction waits, session-state preservation, and timing limits |
| [`../README.md`](../README.md) | Project overview, prerequisites, configuration, and basic test commands |
| [`../AGENTS.md`](../AGENTS.md) | Repository-wide instructions for Codex, Claude Code, OpenCode, and other agents |
| [`../CLAUDE.md`](../CLAUDE.md) | Detailed project context that every agent reads at startup |
| [`../opencode.json`](../opencode.json) | OpenCode instruction loading and MCP server configuration |
| [`DOCUMENT_TEMPLATE.md`](DOCUMENT_TEMPLATE.md) | Starting point for new durable documentation |
| [`examples/README.md`](examples/README.md) | Reference-only configurations that are not part of active project execution |
| [`../todo/README.md`](../todo/README.md) | Shared task queue and handoff workflow |
| [`refactor/fork-conventions.md`](refactor/fork-conventions.md) | SGAC1.0/SGAC2.0 fork contract: `APP_FORK`, `fork_config.py` exports, per-fork layout, tags, dispatch pattern |
| [`refactor/sgac-fork-refactor-tasks.md`](refactor/sgac-fork-refactor-tasks.md) | Fork-refactor task board: waves, file ownership, merge order |
| [`refactor/android-apk-analysis.md`](refactor/android-apk-analysis.md) | T00 Android APK evidence: package, launcher activity, versions, and SHA-256 fingerprints for both forks |
| [`refactor/maintenance-static-review.md`](refactor/maintenance-static-review.md) | Reviewed OpenCode maintenance refactors: corrected findings, verification evidence, and integration handoff |

Add new documents to this table when they are created. Prefer a small number of focused documents with descriptive, kebab-case filenames, such as `android-test-setup.md` or `device-farm-runbook.md`.

## What belongs here

- Architecture and design explanations
- Local and CI setup guides
- Test-writing conventions and examples
- Operational runbooks and troubleshooting
- Decisions that future contributors need to understand
- External-system assumptions that affect the repository

Short-lived notes, unfinished investigations, and work that still needs an owner belong in [`../todo/`](../todo/) instead.

## Keeping documentation useful

- Verify instructions against the current code and configuration before relying on them.
- Include exact file paths, commands, prerequisites, and expected outcomes where useful.
- State assumptions and platform-specific differences explicitly.
- Update affected documentation alongside code changes.
- Mark obsolete documents as deprecated and point to their replacement rather than leaving conflicting guidance.
- Set or refresh the `Last reviewed` field on substantial updates.

Code, tests, and configuration remain the source of truth when documentation and implementation disagree. Resolve the mismatch as part of the task whenever possible.

## Root files kept intentionally

Some documentation-like files must remain at the repository root:

- `README.md` is the standard project entrypoint.
- `AGENTS.md` is discovered automatically by Codex, OpenCode, and compatible agents.
- `CLAUDE.md` is the required shared startup context and Claude Code entrypoint.

Execution configuration and test data do not belong in this directory merely because they use text-based formats. In particular, the active `testspec.yml` and `testspec-android.yml` files remain at the root, and `Cargo_Test_Data.txt` remains test data.
