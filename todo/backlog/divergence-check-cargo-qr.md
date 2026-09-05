# Divergence check — cargo + QR screens (Android)

- Status: Backlog
- Owner: Unassigned
- Priority: Medium
- Created: 2026-09-05
- Updated: 2026-09-05

## Goal

Per-screen SGAC1.0→SGAC2.0 divergence report for the cargo-clearance and QR-code screens,
with proposed 2.0 locators (offline) and on-device verification steps.

## Context

- Read `Data/sgac2/android/STATUS.md` first (patterns + verified screens).
- Dominant 2.0 pattern: testID → SNAKE_CASE `resource-id`; text/class locators usually unchanged.
- These areas were NOT walked live yet — all screens are unverified sgac1 copies; this task
  pre-stages them for on-device verification.

## Scope

### Included
- `Data/sgac1/android/cargo/` — `cargo_clearance_home_page.yaml`, `cargo_clearance.yaml`,
  `add_vehicle_page.yaml`, `vehicle_profiles_page.yaml`, `add_permit_page.yaml`,
  `cargo_convoy_page.yaml`
- `Data/sgac1/android/yaml_QR_pages/` — `all_profiles_page.yaml`, `personal_qr_code_page.yaml`,
  `passport_qr_code_page.yaml`, `create_group_qr_code_page.yaml`
- `Data/sgac1/android/yaml_tutorial_flow_pages/passport_qr_tutorial_flow.yaml`

### Excluded
- Edits to `Data/sgac2/android/**`; SGAC core/resident, e-services/root (other tasks).

## Method (offline)

Same as `divergence-check-sgac-core.md`. Write to `docs/refactor/divergence/cargo-qr.md`.
Flag the QR "NEW" badge on the home QR favourite as a possible 2.0 addition to verify.

## Acceptance criteria

- [ ] `docs/refactor/divergence/cargo-qr.md` committed, all in-scope screens covered.
- [ ] No changes to `Data/sgac2/android/**`.

## Validation

- Doc renders; cross-referenced to STATUS.md.
