# Divergence check — SGAC resident screens (Android)

- Status: Done
- Owner: Claude (offline divergence analysis)
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

- [x] `docs/refactor/divergence/sgac-resident.md` committed, all in-scope screens covered.
- [x] The new required-fields divergence on the resident form is captured explicitly.
- [x] No changes to `Data/sgac2/android/**`.

## Validation

- Doc renders; cross-referenced to STATUS.md and the live-verified page-1 findings.

## Outcome

- Created `docs/refactor/divergence/sgac-resident.md` (offline, no device).
- Screens covered: `resident_profile_creation_form_page.yaml` (page-2 Contact Details only, per
  scope — 10 keys), `resident_confirmation_profile_page.yaml` (21), `res_indv_submission_form_page.yaml`
  (34), `res_declaration_summmary_page.yaml` (38). 103 existing keys total.
- Category counts (existing keys): unchanged 92 · renamed-SNAKE_CASE candidate 3 firm (+6
  fallback on the Contact Details fields) · flow-diverged/index-dependent 8 (the summary EDIT
  buttons) · removed 0.
- **Headline divergence captured explicitly:** SGAC2.0 adds three REQUIRED fields to the resident
  profile form page 1 — Nationality/Citizenship, Passport Number, Date of Passport Expiry — which
  block reaching page-2 Contact Details until filled, ripple new label/value rows onto the
  confirmation and summary Passport/Personal sections, and shift the summary's index-based EDIT
  locators. Proposed (Low-confidence) 2.0 testIDs given for the new fields; flagged for T33.
- Key prediction basis: page-1 `PassportDetails*` form-field testIDs were live-verified as-is on
  2.0, so the page-2 `ContactDetails*` fields are predicted `unchanged` (SNAKE_CASE only a
  fallback) — form-field ids are the exception to the app-wide SNAKE_CASE card/tile pattern.
- No edits to `Data/sgac2/android/**` (verified via git status).
