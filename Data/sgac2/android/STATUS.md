# SGAC2.0 Android locator tree — walk status (T31)

Seeded 2026-09-05 by copying `Data/sgac1/android/**` (30 YAMLs), then corrected screen by
screen against the live SGAC2.0 build (versionName 2.0.0, **versionCode 420**, installed via
Play internal testing) on the `Pixel_7_Pro` emulator through the WireGuard staging tunnel.

Status legend: `copied` = unverified sgac1 copy · `verified` = checked against live 2.0, matches
· `diverged` = corrected because 2.0 differs · `n/a` = element removed in 2.0.

Method: Appium page source per screen → offline XPath eval with `scratchpad/walk_check.py`
(lxml). A key is verified only when its XPath resolves to exactly the intended node on 2.0.

## Known 2.0 drift patterns (apply while correcting)
- **App-wide SNAKE_CASE testIDs (dominant pattern):** testIDs (surfaced as `resource-id`, and
  often mirrored in `content-desc`) were converted from concatenated-label form to SNAKE_CASE
  constants. Confirmed on home favourites (`Home<label>` → `Home<CONSTANT>`, e.g.
  `HomeCITIZEN_RESIDENT_SG_ARRIVAL_CARD`) and Other-e-Services cards
  (`EServicesPassportandIdentityCard` → `EServicesPASSPORT_AND_IDENTITY_CARD`). When a
  resource-id/content-desc-based locator misses, first try the SNAKE_CASE form. Prefer resource-id.
- **Text/class-based locators mostly unchanged:** screens keyed on visible text or widget class
  (e.g. citizen_and_res_page) are identical in 2.0.
- **Scam banner**: now a single image (no text header); the old text-header locator has no
  2.0 equivalent.
- **SGAC arrival-card flow restructured** (see sgac_landing_page): Individual/Group Submission
  model replaced by a profile-centric model (Manage Profiles / Create New Profile / Update SG
  Arrival Card); tutorial gate removed. This is a FLOW divergence needing T33, not a locator swap.

## Screens
| Screen file | Status | Notes |
| --- | --- | --- |
| landing_page.yaml | verified | favourites → `Home<CONSTANT>` resource-ids; scam-banner header removed (n/a) |
| citizen_and_res_page.yaml | verified | unchanged in 2.0 — 10/10 locators resolve as-is |
| eservices_landing_page.yaml | diverged | 10 service cards → SNAKE_CASE `EServices<CONSTANT>` rids (13/17 verified; 4 search-flow keys need the search interaction) |
| sgac/sgac_landing_page.yaml | diverged | FLOW REDESIGN: profile-centric (Manage/Create/Update); Individual/Group split + tutorial gate removed → T33 |
| profile_creation_method_page.yaml | copied | |
| manual_creation_profile_form.yaml | copied | |
| android_common_selectors.yaml | copied | |
| sgac/individual_submission_page.yaml | copied | |
| sgac/indv_profile_list_page.yaml | copied | |
| sgac/sel_profile_submission_page.yaml | copied | |
| sgac/declaration_page.yaml | copied | |
| sgac/sub_success_page.yaml | copied | |
| sgac/resident/resident_profile_creation_form_page.yaml | copied | |
| sgac/resident/resident_confirmation_profile_page.yaml | copied | |
| sgac/resident/res_indv_submission_form_page.yaml | copied | |
| sgac/resident/res_declaration_summmary_page.yaml | copied | |
| other_e_services/sgac_epass_enquiry.yaml | copied | |
| other_e_services/customs_declaration_service.yaml | copied | |
| other_e_services/e727_service.yaml | copied | |
| cargo/cargo_clearance_home_page.yaml | copied | |
| cargo/cargo_clearance.yaml | copied | |
| cargo/add_vehicle_page.yaml | copied | |
| cargo/vehicle_profiles_page.yaml | copied | |
| cargo/add_permit_page.yaml | copied | |
| cargo/cargo_convoy_page.yaml | copied | |
| yaml_QR_pages/all_profiles_page.yaml | copied | |
| yaml_QR_pages/personal_qr_code_page.yaml | copied | |
| yaml_QR_pages/passport_qr_code_page.yaml | copied | |
| yaml_QR_pages/create_group_qr_code_page.yaml | copied | |
| yaml_tutorial_flow_pages/passport_qr_tutorial_flow.yaml | copied | |
