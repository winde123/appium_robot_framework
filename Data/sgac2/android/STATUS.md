# SGAC2.0 Android locator tree — walk status (T31)

Seeded 2026-09-05 by copying `Data/sgac1/android/**` (30 YAMLs), then corrected screen by
screen against the live SGAC2.0 build (versionName 2.0.0, **versionCode 420**, installed via
Play internal testing) on the `Pixel_7_Pro` emulator through the WireGuard staging tunnel.

Status legend: `copied` = unverified sgac1 copy · `verified` = checked against live 2.0, matches
· `diverged` = corrected because 2.0 differs · `n/a` = element removed in 2.0.

Method: Appium page source per screen → offline XPath eval with `scratchpad/walk_check.py`
(lxml). A key is verified only when its XPath resolves to exactly the intended node on 2.0.

## Language verification — all 19 languages (2026-09-06)
Verified the SGAC **landing**, **profile-creation-method**, and **profile form (page 1)** across
ALL 19 in-app languages (English, 中文, Bahasa Melayu, தமிழ், Bahasa Indonesia, Deutsch, Español,
Filipino, Français, Italiano, Nederlands, Tiếng Việt, Русский, العربية, हिन्दी, বাংলা, ไทย, 日本語,
한국어) on the Pixel_7_Pro emulator (2.0.0/420, staging tunnel), for BOTH the **resident**
(Citizen & Resident) and **foreigner** (Foreign Visitor) flows — mirroring the iOS sweep.
Harness `scratchpad/android_lang_sweep.py` (Appium UiAutomator2; navigate by xpath on
resource-id/content-desc; language picker APPLIES on card-tap, then close — no GO button;
per-language reset via `adb am force-stop`+`am start`). Analyzer `analyze_lang_and.py`;
matrices `LANG_VERIFICATION_resident_matrix.txt` / `LANG_VERIFICATION_foreigner_matrix.txt`.

**RESULT 1 — localization correct everywhere.** All screens fully localize in all 19 languages
in both flows, incl. RTL Arabic (landing "إدارة الملفات الشخصية", form "بيانات الملف الشخصي") and
CJK/Thai/Tamil/Hindi/Bengali (e.g. ja "SG到着カード", zh form "添加个人资料"). No crash/blank/clip.

**RESULT 2 — clean testID-vs-text split (matches iOS).** EVERY locator that survives all
languages is a resource-id/content-desc testID; EVERY locator that breaks is a `@text` locator.
- Resident: landing 5/6 stable (only SGAC-HEADER breaks), method 4/6 (header+title break),
  form 10/21 (headers, reminder, section title, all `Required` markers, footer BACK/NEXT text
  labels break; all resource-id field/nav locators survive). Overall 58%.
- Foreigner: landing 6/7 stable, method 3/5; foreigner form localizes and its resource-id
  locators (PassportDetailsFullName/Nationality/next…) are stable across scripts (no Android
  foreigner form YAML exists yet, so form is localization-verified, not YAML-scored).
- Actionable: `@text`-based locators (headers, section titles, `Required` markers, footer
  BACK/NEXT labels) fail under non-English — use the resource-id/content-desc equivalents for
  cross-language runs. Same conclusion as the earlier Android text-vs-testID finding and iOS.

## Foreigner form correctness walk (2026-09-06) — NEW sgac2 Android tree
SGAC1.0 Android had **no dedicated foreigner tree** — it used the shared
`manual_creation_profile_form.yaml` (resident+foreigner mixed, fragile index-based confirm
locators). Walked the live 2.0 foreigner Add Profile flow end-to-end (Foreign Visitor →
Create New Profile → fill manually → …reached the summary) and created a clean, testID-based
`Data/sgac2/android/sgac/foreigner/` tree mirroring the iOS foreigner layout. Every key
live-verified against captured page source; registered in `tools/fork_parity_allowlist.yaml`
as sgac2-only (no sgac1/android counterpart); linter 0/0. New files:
- `for_profile_form.yaml` — 3-page flow, pages 1+2: Profile Details (Full Name, **Sex**
  dropdown MALE/FEMALE/OTHERS, DOB, **Country/Place of Birth**, Nationality, Passport No.,
  Passport Expiry) + Contact Details (**Place of Residence**, Email — no country-code/mobile).
- `for_profile_summary.yaml` — page 3: Passport Details + Contact Details cards, Edit,
  T&C checkbox (un/checked), SAVE.
- `for_form_cty_page.yaml` / `for_form_nationality_page.yaml` / `for_form_residence_page.yaml`
  — the three searchable modals (`resource-id="modal"`, text="Search" input, "Close modal",
  options `content-desc="searchable dropdown accessible label <X>"`; residence options are
  `COUNTRY, CITY, CITY`). Build specific option locators via the `*-OPTION-BY-NAME-TEMPLATE`.
Distinct from resident: foreigner has Sex + Country/Place of Birth, no NRIC, and contact is
Residence+Email (resident is NRIC-based, contact email-only). NOTE: the legacy shared
`manual_creation_profile_form.yaml` is now superseded for the foreigner flow by this tree.

## Cargo flow correctness walk (2026-09-06)
Walked the live 2.0 cargo module end-to-end (Cargo Clearance card → …) and corrected all 6
`Data/sgac2/android/cargo/*.yaml` (were unverified sgac1 copies). Key/flow divergences from
sgac1 recorded in `tools/fork_parity_allowlist.yaml`; every 2.0 key live-verified against
captured page source; linter 0/0. The 2.0 cargo module split into NATIVE and WEBVIEW parts:
- **NATIVE (corrected + verified):** `cargo_clearance_home_page.yaml` — profile-centric
  landing (Manage Cargo Submission / Create New Vehicle Profiles / Convoy / Select Vehicle
  Profiles + add-vehicle "+" + CargoLanguage + CargoAnnouncement banner), replacing the
  sgac1 icon-grid + "+" menu. `vehicle_profiles_page.yaml` — list (empty state; items indexed
  `vehicle list N` / kebab `vehicle list right iconN` → Edit/Delete; verified with a saved
  profile SOX3229J). `add_vehicle_page.yaml` — simplified to Vehicle Number + Mobile + Email
  + Save (sgac1's NRIC/passport toggles gone).
- **WEBVIEW (diverged; documented with page markers, not native locators):**
  `cargo_clearance.yaml` — Manage Cargo Submission opens an in-app webview (ARN + Vehicle
  Number retrieve form; generic `text-input` ids). `cargo_convoy_page.yaml` — Convoy opens a
  webview (Convoy Submission form). `add_permit_page.yaml` — permit step now lives INSIDE the
  Convoy webview; TODO(cargo-web) to walk its DOM.
- Test artifact: vehicle profile SOX3229J left on the device (like the SGAC test profiles).

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
| cargo/cargo_clearance_home_page.yaml | diverged | profile-centric landing (Manage Submission/Create Vehicle Profiles/Convoy/Select) — verified; replaces sgac1 icon-grid+menu |
| cargo/cargo_clearance.yaml | diverged (webview) | Manage Cargo Submission → in-app webview (ARN+Vehicle retrieve form) |
| cargo/add_vehicle_page.yaml | diverged | Vehicle Number+Mobile+Email+Save (verified, saved SOX3229J); sgac1 NRIC/passport toggles removed |
| cargo/vehicle_profiles_page.yaml | verified | list + indexed items (vehicle list N / kebab) → Edit/Delete; empty state |
| cargo/add_permit_page.yaml | diverged (web) | permit step now inside the Convoy webview — TODO(cargo-web) |
| cargo/cargo_convoy_page.yaml | diverged (webview) | Convoy → webview (Convoy Submission form) |
| yaml_QR_pages/all_profiles_page.yaml | copied | |
| yaml_QR_pages/personal_qr_code_page.yaml | copied | |
| yaml_QR_pages/passport_qr_code_page.yaml | copied | |
| yaml_QR_pages/create_group_qr_code_page.yaml | copied | |
| yaml_tutorial_flow_pages/passport_qr_tutorial_flow.yaml | copied | |
