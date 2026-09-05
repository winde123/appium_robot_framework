# SGAC2.0 Android locator tree — walk status (T31)

Seeded 2026-09-05 by copying `Data/sgac1/android/**` (30 YAMLs), then corrected screen by
screen against the live SGAC2.0 build (versionName 2.0.0, **versionCode 420**, installed via
Play internal testing) on the `Pixel_7_Pro` emulator through the WireGuard staging tunnel.

Status legend: `copied` = unverified sgac1 copy · `verified` = checked against live 2.0, matches
· `diverged` = corrected because 2.0 differs · `n/a` = element removed in 2.0.

Method: Appium page source per screen → offline XPath eval with `scratchpad/walk_check.py`
(lxml). A key is verified only when its XPath resolves to exactly the intended node on 2.0.

## Known 2.0 drift patterns (apply while correcting)
- **SNAKE_CASE testIDs — NAVIGATION CARD-TILES ONLY (refined after divergence analysis):**
  the concatenated-label → SNAKE_CASE conversion applies to navigation card/tile testIDs
  (home favourites `Home<label>`→`Home<CONSTANT>`; Other-e-Services cards
  `EServicesPassportandIdentityCard`→`EServicesPASSPORT_AND_IDENTITY_CARD`). It is NOT app-wide:
  form-field/component testIDs are UNCHANGED (`PassportDetails*`, `ContactDetails*`, `next`,
  `save`, `card`, `modal`, `CaptchaModal*`) — live-verified on the profile form. So: nav tile
  misses → try SNAKE_CASE; form/component locators → expect as-is. The conversion is also NOT
  purely mechanical (small words like "of" dropped, long labels hand-abbreviated) — treat
  offline SNAKE_CASE proposals as hypotheses (see docs/refactor/divergence/*.md).
- **Back-button drift risk:** the verified e-Services page flipped its back control from
  `resource-id="back"` → `content-desc="Back"`; audit `resource-id="back"` locators.
- **e-Services detail screens are Chrome web views** (torn down via Close Android Chrome Browser)
  — their text locators are external gov web content, outside the RN testID refactor.
- **Text/class-based locators mostly unchanged:** screens keyed on visible text or widget class
  (e.g. citizen_and_res_page) are identical in 2.0.
- **Scam banner**: now a single image (no text header); the old text-header locator has no
  2.0 equivalent.
- **SGAC arrival-card flow restructured** (see sgac_landing_page): Individual/Group Submission
  model replaced by a profile-centric model (Manage Profiles / Create New Profile / Update SG
  Arrival Card); tutorial gate removed. This is a FLOW divergence needing T33, not a locator swap.
- **Language flow fully validated (2026-09-05):** all 13 languages localize the SGAC module
  correctly and the testID (resource-id/content-desc) locators resolve language-independently;
  only text=-based locators break under non-English. A full profile-creation flow was driven
  end-to-end in Chinese and SAVED to staging (profile "TRACEY MORRIS"). The Nationality picker
  is a searchable dropdown — use Appium scroll_to_element, not blind taps.

## Screens
| Screen file | Status | Notes |
| --- | --- | --- |
| landing_page.yaml | verified | favourites → `Home<CONSTANT>` resource-ids; scam-banner header removed (n/a) |
| citizen_and_res_page.yaml | verified | unchanged in 2.0 — 10/10 locators resolve as-is |
| eservices_landing_page.yaml | diverged | 10 service cards → SNAKE_CASE `EServices<CONSTANT>` rids (13/17 verified; 4 search-flow keys need the search interaction) |
| sgac/sgac_landing_page.yaml | diverged | FLOW REDESIGN: profile-centric (Manage/Create/Update); Individual/Group split + tutorial gate removed → T33 |
| profile_creation_method_page.yaml | verified | 6/7 as-is; only PROFILE-CREATION-SINGPASS-LABEL text changed (button resolves) |
| manual_creation_profile_form.yaml | copied | |
| sgac/resident/resident_profile_creation_form_page.yaml | verified | page 1 fields resolve as-is; 2.0 adds REQUIRED Nationality/Passport No./Passport Expiry (Nationality = searchable dropdown picker). PAGE 2 (Contact) DIVERGED: 2.0 shows ONLY Email (电子邮件) — no separate country-code/mobile fields that sgac1 had. Full flow driven + saved to staging 2026-09-05 |
| sgac/resident/resident_confirmation_profile_page.yaml | verified | 3-page form's confirmation/summary (护照详情 + 联系方式 cards + T&C checkbox + Save); rendered correctly with all entered data; localizes across languages |
| android_common_selectors.yaml | copied | |
| sgac/individual_submission_page.yaml | copied | |
| sgac/indv_profile_list_page.yaml | copied | |
| sgac/sel_profile_submission_page.yaml | copied | |
| sgac/declaration_page.yaml | copied | |
| sgac/sub_success_page.yaml | copied | |
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
