# Divergence check — e-Services + root/common screens (Android)

- Status: Done
- Owner: Claude (offline divergence analysis)
- Priority: Medium
- Created: 2026-09-05
- Updated: 2026-09-05
- Deliverable: `docs/refactor/divergence/eservices-root.md` (6 screens, 51 keys: 38 unchanged / 4 renamed-SNAKE_CASE / 9 flow-diverged / 0 removed)

## Goal

Per-screen SGAC1.0→SGAC2.0 divergence report for the Other-e-Services detail screens and the
remaining root/common screens, with proposed 2.0 locators (offline) and on-device steps.

## Context

- Read `Data/sgac2/android/STATUS.md` first.
- **Already verified this session (do NOT re-edit):** `landing_page.yaml`,
  `citizen_and_res_page.yaml` (unchanged), `eservices_landing_page.yaml` (cards →
  `EServices<SNAKE_CASE>`), `profile_creation_method_page.yaml` (6/7).
- Dominant pattern: testID → SNAKE_CASE `resource-id`; the e-Services CARDS confirm the
  `EServices<label>` → `EServices<CONSTANT>` form.

## Scope

### Included
- `Data/sgac1/android/other_e_services/customs_declaration_service.yaml`
- `Data/sgac1/android/other_e_services/e727_service.yaml`
- `Data/sgac1/android/other_e_services/sgac_epass_enquiry.yaml`
- `Data/sgac1/android/manual_creation_profile_form.yaml`
- `Data/sgac1/android/android_common_selectors.yaml`
- The 4 not-yet-verified `eservices_landing_page.yaml` search-flow keys (search input, Customs@SG
  header, Report Lost Passport/IC results) — propose 2.0 forms + on-device search steps.

### Excluded
- Edits to `Data/sgac2/android/**`; SGAC core/resident, cargo, QR (other tasks).

## Method (offline)

Same as `divergence-check-sgac-core.md`. Write to `docs/refactor/divergence/eservices-root.md`.

## Acceptance criteria

- [x] `docs/refactor/divergence/eservices-root.md` committed, all in-scope screens covered.
- [x] No changes to `Data/sgac2/android/**`.

## Validation

- Doc renders; cross-referenced to STATUS.md.
