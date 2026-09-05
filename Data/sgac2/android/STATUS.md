# SGAC2.0 Android locator tree — walk status (T31)

Seeded 2026-09-05 by copying `Data/sgac1/android/**` (30 YAMLs), then corrected screen by
screen against the live SGAC2.0 build (versionName 2.0.0, **versionCode 420**, installed via
Play internal testing) on the `Pixel_7_Pro` emulator through the WireGuard staging tunnel.

Status legend: `copied` = unverified sgac1 copy · `verified` = checked against live 2.0, matches
· `diverged` = corrected because 2.0 differs · `n/a` = element removed in 2.0.

Method: Appium page source per screen → offline XPath eval with `scratchpad/walk_check.py`
(lxml). A key is verified only when its XPath resolves to exactly the intended node on 2.0.

## Known 2.0 drift patterns (apply while correcting)
- **Home favourites**: content-desc changed from `Home<label>` to SNAKE_CASE testIDs exposed as
  `resource-id="Home<CONSTANT>"` (e.g. `HomeCITIZEN_RESIDENT_SG_ARRIVAL_CARD`). Prefer resource-id.
- **Scam banner**: now a single image (no text header); the old text-header locator has no
  2.0 equivalent.

## Screens
| Screen file | Status | Notes |
| --- | --- | --- |
| landing_page.yaml | verified | favourites → `Home<CONSTANT>` resource-ids; scam-banner header removed (n/a) |
| citizen_and_res_page.yaml | copied | |
| eservices_landing_page.yaml | copied | |
| profile_creation_method_page.yaml | copied | |
| manual_creation_profile_form.yaml | copied | |
| android_common_selectors.yaml | copied | |
| sgac/sgac_landing_page.yaml | copied | |
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
