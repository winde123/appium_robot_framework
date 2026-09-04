# Project documentation

This directory is the durable reference point for humans and coding agents working on this repository. It should explain why the project is structured as it is, how important workflows operate, and which constraints should be preserved.

## Documentation map

| Document | Purpose |
| --- | --- |
| [`../README.md`](../README.md) | Project overview, prerequisites, configuration, and basic test commands |
| [`../AGENTS.md`](../AGENTS.md) | Repository-wide instructions for Codex, Claude Code, OpenCode, and other agents |
| [`../CLAUDE.md`](../CLAUDE.md) | Detailed project context that every agent reads at startup |
| [`../opencode.json`](../opencode.json) | OpenCode instruction loading and MCP server configuration |
| [`DOCUMENT_TEMPLATE.md`](DOCUMENT_TEMPLATE.md) | Starting point for new durable documentation |
| [`examples/README.md`](examples/README.md) | Reference-only configurations that are not part of active project execution |
| [`../todo/README.md`](../todo/README.md) | Shared task queue and handoff workflow |

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
