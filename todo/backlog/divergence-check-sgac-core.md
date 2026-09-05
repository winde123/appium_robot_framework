# Divergence check — SGAC core screens (Android)

- Status: Backlog
- Owner: Unassigned
- Priority: High
- Created: 2026-09-05
- Updated: 2026-09-05

## Goal

Produce a per-screen SGAC1.0→SGAC2.0 divergence report for the SGAC core Android screens,
with proposed SGAC2.0 locators (offline, pattern-based) and an on-device verification checklist,
so the live walk (T31) and the divergent-flow work (T33) can be finished quickly.

## Context

- Live-verified findings and the dominant 2.0 drift patterns are in
  `Data/sgac2/android/STATUS.md` (read it first) and the fork task board
  `docs/refactor/sgac-fork-refactor-tasks.md`.
- **Dominant 2.0 pattern:** React-Native testIDs (Android `resource-id`, often mirrored in
  `content-desc`) were converted from concatenated-label form to SNAKE_CASE constants
  (e.g. `HomeCitizen & Resident...` → `HomeCITIZEN_RESIDENT_SG_ARRIVAL_CARD`,
  `EServicesPassportandIdentityCard` → `EServicesPASSPORT_AND_IDENTITY_CARD`).
  Text/class-based locators are usually unchanged.
- **`sgac_landing_page` is already done (diverged):** 2.0 replaced the Individual/Group
  Submission model + tutorial gate with a profile-centric model (Manage Profiles / Create New
  Profile / Update SG Arrival Card). See `Data/sgac2/android/sgac/sgac_landing_page.yaml`.
- iOS is a separate effort (T32); this task is Android only.

## Scope

### Included — screens under `Data/sgac1/android/sgac/` (excluding the done `sgac_landing_page`)
- `individual_submission_page.yaml`
- `indv_profile_list_page.yaml`
- `sel_profile_submission_page.yaml`
- `declaration_page.yaml`
- `sub_success_page.yaml`

Note: 2.0's profile-centric flow may relocate/rename the Individual/Group submission concepts —
call out where a whole screen's role changed, not just locator strings.

### Excluded
- Any edit to `Data/sgac2/android/**` (the live walk owns that tree — avoid conflicts).
- iOS, cargo, QR, e-services, resident screens (other tasks).

## Method (offline)

1. For each screen, read the `Data/sgac1/android/sgac/<file>` locators.
2. Classify each key: likely `unchanged` (text/class-based) · `renamed-SNAKE_CASE`
   (testID-based → give the proposed 2.0 id) · `flow-diverged` · `removed`.
3. Write findings to `docs/refactor/divergence/sgac-core.md` (create dir) as a table per screen:
   key · sgac1 locator · proposed sgac2 locator · confidence · on-device check step.

## Acceptance criteria

- [ ] `docs/refactor/divergence/sgac-core.md` committed with every in-scope screen covered.
- [ ] Each key classified with a proposed sgac2 locator (or explicit "needs device").
- [ ] No changes to `Data/sgac2/android/**`.

## Validation

- Doc renders; every in-scope screen file is represented; cross-referenced to STATUS.md.
