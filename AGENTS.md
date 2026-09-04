# Repository guidance

These instructions apply to every coding agent working in the repository, including Codex, Claude Code, and OpenCode, unless a more specific instruction file exists in a subdirectory.

## Mandatory startup order

Before planning, inspecting files, running repository commands, or making changes for each new task:

1. Call the Mnemosyne MCP `mnemosyne_recall` tool with a query describing the repository and the current task. Use the recalled context to identify relevant preferences, decisions, and prior work.
2. Read [`CLAUDE.md`](CLAUDE.md) in full for the current project context, commands, conventions, and known issues.
3. Reconcile recalled information with the current repository state. Current code, tests, and configuration take precedence over stale memory or documentation.

Do not silently skip either startup step. If Mnemosyne or `CLAUDE.md` is unavailable, tell the user before continuing with the best available context.

OpenCode loads this `AGENTS.md` natively. Its project configuration in [`opencode.json`](opencode.json) also loads `CLAUDE.md` as an instruction file and provides the `mnemosyne` MCP server, so OpenCode agents must follow the same startup order.

## Start here

- Read [`README.md`](README.md) for project setup, layout, and test commands.
- Use [`docs/README.md`](docs/README.md) as the index for durable project knowledge.
- Use [`todo/README.md`](todo/README.md) when creating, claiming, handing off, or completing repository tasks.
- Treat executable code, tests, and configuration as the source of truth. Update the relevant documentation in the same change when behavior or workflows change.

## Working with tasks

- Work only on the task requested or explicitly selected from the queue; do not claim unrelated work.
- To claim a queued task, move its file from `todo/backlog/` to `todo/in-progress/` and update its `Status`, `Owner`, and `Updated` fields before implementation.
- Keep acceptance criteria and validation notes current so another human or agent can resume the work.
- Move blocked work to `todo/blocked/` and record the blocker and the next action needed.
- After all acceptance criteria pass, record the result and validation performed, then move the task to `todo/done/`.

## Documentation expectations

- Put stable architecture, setup, testing, troubleshooting, and decision records in `docs/`.
- Keep temporary investigation notes and actionable work in the relevant task file under `todo/`.
- Add every durable document to the index in `docs/README.md`.
- Prefer repository-relative links and exact paths, commands, and expected outcomes.
