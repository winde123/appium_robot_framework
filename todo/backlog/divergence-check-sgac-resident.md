# Divergence check — SGAC resident screens (Android)

- Status: Backlog
- Owner: Unassigned
- Priority: High
- Created: 2026-09-05
- Updated: 2026-09-05

## Goal

Per-screen SGAC1.0→SGAC2.0 divergence report for the resident SGAC screens, with proposed
2.0 locators (offline) and on-device verification steps.

## Context

- Read `Data/sgac2/android/STATUS.md` first (patterns + already-verified screens).
- **Already verified this session:** `resident_profile_creation_form_page.yaml` page 1 — most
  fields resolve as-is, BUT 2.0 adds REQUIRED Nationality/Citizenship + Passport Number + Date
  of Passport Expiry to the resident form (a divergence), and Contact Details is page 2 (not yet
  reached). Do NOT re-edit that file; extend the analysis for its page-2 contact fields and the
  other resident screens.
- Dominant 2.0 pattern: testID → SNAKE_CASE `resource-id` (see sgac-core task / STATUS.md).

## Scope

### Included — `Data/sgac1/android/sgac/resident/`
- `resident_profile_creation_form_page.yaml` — ONLY the page-2 Contact Details keys
  (`ContactDetailsCountryCode` / `MobileNumber` / `EmailAddress` and labels) — hypothesise the
  2.0 ids and give on-device steps to reach page 2.
- `resident_confirmation_profile_page.yaml`
- `res_indv_submission_form_page.yaml`
- `res_declaration_summmary_page.yaml`

### Excluded
- Edits to `Data/sgac2/android/**`; other areas.

## Method (offline)

Same as `divergence-check-sgac-core.md`: classify each key (unchanged / renamed-SNAKE_CASE /
flow-diverged / removed), propose the 2.0 locator, note confidence and on-device check.
Write to `docs/refactor/divergence/sgac-resident.md`.

## Acceptance criteria

- [ ] `docs/refactor/divergence/sgac-resident.md` committed, all in-scope screens covered.
- [ ] The new required-fields divergence on the resident form is captured explicitly.
- [ ] No changes to `Data/sgac2/android/**`.

## Validation

- Doc renders; cross-referenced to STATUS.md and the live-verified page-1 findings.
