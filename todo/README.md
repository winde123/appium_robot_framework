# Project task queue

This directory is the shared, version-controlled task queue for humans and coding agents. Each task is one Markdown file, so its scope, ownership, progress, and handoff notes travel with the repository.

## Queue states

| Directory | Meaning |
| --- | --- |
| [`backlog/`](backlog/) | Ready to be picked up and not currently owned |
| [`in-progress/`](in-progress/) | Claimed and actively being worked on |
| [`blocked/`](blocked/) | Started but waiting on a decision, dependency, or external change |
| [`done/`](done/) | Completed, validated work retained for history |

The directory is the canonical task state. Keep the task's `Status` field in sync so its state is also clear when the file is viewed directly.

## Create a task

1. Copy [`TASK_TEMPLATE.md`](TASK_TEMPLATE.md) into `backlog/`.
2. Name it with a concise kebab-case description, for example `fix-ios-profile-imports.md`.
3. Fill in the goal, context, scope, acceptance criteria, and validation plan.
4. Keep tasks small enough for one owner to complete or hand off cleanly. Split independent work into separate files.

## Pick up a task

1. Confirm the file is still in `backlog/` and has no owner.
2. Move it to `in-progress/` before changing implementation files.
3. Set `Status: In progress`, identify the owner, and update the date.
4. Record meaningful discoveries, decisions, and remaining work in the task file as work proceeds.

If multiple contributors share a branch, make the claim visible to them before doing substantial work.

## Block or hand off a task

- Move blocked work to `blocked/`, set `Status: Blocked`, and describe the exact blocker and the next action required.
- Move it back to `backlog/` if it is available for a new owner, or to `in-progress/` when the current owner resumes it.
- For a handoff, make the current state, changed files, validation results, and next step explicit.

## Complete a task

1. Check every acceptance criterion or explain any agreed exception.
2. Record the validation commands and results.
3. Summarize the outcome and any follow-up work.
4. Set `Status: Done`, update the date, and move the file to `done/`.

Do not delete completed task files unless the team intentionally adopts a separate archive or issue tracker.
