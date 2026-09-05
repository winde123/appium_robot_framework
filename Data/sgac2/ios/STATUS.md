# SGAC2.0 iOS locator tree — walk status (T32)

Seeded 2026-09-05 by copying `Data/sgac1/ios/**` (37 YAMLs). To be corrected screen by
screen against the live SGAC2.0 iOS build on Edwin's iPad (real device, XCUITest via Xcode).

## iOS-specific method
- iOS is REAL-DEVICE ONLY (no simulator); iPad connected via Xcode (WDA signed with
  `IOS_XCODE_ORGID`). App ships via TestFlight — launch by `${IOS_BUNDLE_ID}`, nothing installed.
- Drive via Appium/XCUITest (NOT adb). Capture with appium_get_page_source; verify offline with
  `scratchpad/walk_check.py` (already handles Appium class-as-tag XML).
- iOS locators use `name`/`label`/`value`/`type` attributes and `xpath=` prefixes at call sites.
- HYPOTHESIS to check: RN testIDs map to iOS `accessibility id` / `name`, so the SNAKE_CASE
  testID rename found on Android (nav card-tiles) likely repeats on iOS — verify on device.
- Cross-check against the Android divergence docs (`docs/refactor/divergence/*.md`) and the
  live-verified Android findings; expect the SAME flow divergences (SGAC landing profile-centric
  restructure; resident form 3 pages incl. required Nationality/Passport; contact page email-only).

## Blockers / inputs needed
- SGAC2.0 iOS BUNDLE ID (open T00 item) — read from the device once connected; robotconfig
  `FORKS.sgac2.ios_bundle_id` is still `TODO(T00/T30)`.
- SGAC2.0 TestFlight build installed on the iPad.
- iPad likely needs the WireGuard staging profile (network_egress/sg-sng.conf) to reach staging,
  same as the Android emulator did.

## Screens
| Screen file | Status | Notes |
| --- | --- | --- |
| cargo/cargo_convoy_form_page.yaml | copied | |
| cargo/cargo_convoy_page.yaml | copied | |
| cargo/cargo_landing_page.yaml | copied | |
| cargo/cargo_permit_form_page.yaml | copied | |
| cargo/cargo_sub_res_page.yaml | copied | |
| citizen_res_page.yaml | copied | |
| foreign_vis_page.yaml | copied | |
| ios_common_selectors.yaml | copied | |
| landing_page.yaml | copied | |
| other_e_services/appt_services_page.yaml | copied | |
| other_e_services/birth_death_services_page.yaml | copied | |
| other_e_services/change_res_address_page.yaml | copied | |
| other_e_services/check_validity_verify_page.yaml | copied | |
| other_e_services/customs_dec_services_page.yaml | copied | |
| other_e_services/e727_services_page.yaml | copied | |
| other_e_services/ltvp_student_pass_services_page.yaml | copied | |
| other_e_services/other_e_services_page.yaml | copied | |
| other_e_services/others_services_page.yaml | copied | |
| other_e_services/passport_IC_page.yaml | copied | |
| other_e_services/sc_pr_services_page.yaml | copied | |
| other_e_services/sgac_epass_enquiry.yaml | copied | |
| sgac/declaration_page.yaml | copied | |
| sgac/foreigner/for_form_cty_page.yaml | copied | |
| sgac/foreigner/for_form_nationality_page.yaml | copied | |
| sgac/foreigner/for_form_residence_page.yaml | copied | |
| sgac/foreigner/for_profile_form.yaml | copied | |
| sgac/foreigner/for_profile_summary.yaml | copied | |
| sgac/indv_submission_page.yaml | copied | |
| sgac/profile_creation_method_page.yaml | copied | |
| sgac/profile_list_page.yaml | copied | |
| sgac/resident/res_declaration_summary.yaml | copied | |
| sgac/resident/res_profile_form_page.yaml | copied | |
| sgac/resident/res_profile_summary.yaml | copied | |
| sgac/resident/res_submission_form_page.yaml | copied | |
| sgac/sel_indv_profile_list_page.yaml | copied | |
| sgac/sgac_landing_page.yaml | copied | |
| sgac/sub_success_page.yaml | copied | |
