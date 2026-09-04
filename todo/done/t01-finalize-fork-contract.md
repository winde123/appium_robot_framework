# T01 — Finalize the SGAC fork contract and conventions

- Status: Done
- Owner: opencode (Edwin's agent)
- Priority: High
- Created: 2026-09-05
- Updated: 2026-09-05

## Goal

Write and land the authoritative fork contract document (`docs/refactor/fork-conventions.md`)
that every downstream Wave 1–2 task implements verbatim, and update the entry-point docs
(`CLAUDE.md`, `README.md`) so contributors and agents learn the fork model there.

## Context

Board task T01 from [`docs/refactor/sgac-fork-refactor-tasks.md`](../../docs/refactor/sgac-fork-refactor-tasks.md).
The MyICA app has two forks (SGAC1.0 / SGAC2.0); the repo is SGAC1.0-only today. Waves 1–2
(T10–T21) need exact names for `APP_FORK`, the `fork_config.py` variable exports, the per-fork
directory layout, the tag scheme, and the keyword-dispatch pattern — pinned in one place so
parallel agents do not invent conflicting names.

## Scope

### Included

- `docs/refactor/fork-conventions.md` (new) — the contract.
- `CLAUDE.md` — fork model in layout/conventions/running sections.
- `README.md` — binaries and `APP_FORK` usage in running/config sections.
- `docs/README.md` — index rows for the new contract doc and the task board.
- `todo/` task file for this work (this file).

### Excluded

- Any implementation: `fork_config.py`, `robotconfig.yaml`, `commands.robot`, suites,
  `getabspath.py`, testspecs, `icaApp/` moves (T10–T21).
- T00 inputs (SGAC2.0 binaries/IDs/divergence list) — Edwin-owned.

## Acceptance criteria

- [x] `docs/refactor/fork-conventions.md` exists and pins: `APP_FORK` values/default and the
      env-var mechanism; the exact variables `fork_config.py` exports; the per-fork directory
      layout; the tag scheme; the keyword-dispatch pattern with one worked example.
- [x] `CLAUDE.md` and `README.md` updated to present the fork model.
- [x] New durable docs indexed in `docs/README.md`.
- [x] Doc content consistent with the board's "Target architecture" section (no invented names).

## Validation plan

- [x] Re-read the board's target-architecture section and diff against the contract doc.
- [x] `git diff` review of the three docs; confirm no implementation files touched.

## Progress and decisions

- Claimed by opencode agent on branch `refactor/t01-fork-conventions`.
- Pinned concrete names the board left open: `robotconfig.yaml` gets a `FORKS:` mapping with
  keys `android_package` / `android_activity` / `ios_bundle_id` / `android_binary` /
  `ios_binary`; `fork_config.py` reads it and resolves `APP_FORK` (board T10 asked for
  "per-fork sections" without names — contract §2/§4 now names them).
- Dispatch naming: public keyword keeps plain name; forks as `<public name> for sgac1|sgac2`.
- Contract doc kept deliberately illustrative where T00 has not delivered facts (sgac2 values
  are `TODO(T00/T30)` placeholders; the worked dispatch example is marked illustrative).

## Handoff or blocker

- None.

## Outcome

- Created `docs/refactor/fork-conventions.md` (contract: §1 `APP_FORK`, §2 `fork_config.py`
  exports, §3 layout, §4 `robotconfig.yaml` FORKS split, §5 tags, §6 dispatch patterns A/B with
  worked example, §7 import ordering, §8 shared DoD).
- Updated `CLAUDE.md` ("Fork model" section + APP_FORK run example), `README.md` (fork-aware
  binaries section + APP_FORK example), `docs/README.md` (index rows for contract + board).
- Validation: contract cross-checked against the board's target architecture — all names match;
  only the board-plus-CLAUDE.md/README.md files touched (git status confirmed no implementation
  files modified).
- **Follow-up:** merge branch `refactor/t01-fork-conventions` to main (board says T01 lands first).
