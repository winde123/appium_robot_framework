# SGAC2.0 Android locator tree — walk status (T31)

Last reviewed: 2026-09-08

Seeded 2026-09-05 by copying `Data/sgac1/android/**` (30 YAMLs), then corrected screen by
screen against the live SGAC2.0 build (versionName 2.0.0, **versionCode 420**, installed via
Play internal testing) on the `Pixel_7_Pro` emulator through the WireGuard staging tunnel.

Status legend: `copied` = unverified sgac1 copy · `verified` = checked against live 2.0, matches
· `diverged` = corrected because 2.0 differs · `n/a` = element removed in 2.0.

Method: Appium page source per screen → offline XPath eval with `scratchpad/walk_check.py`
(lxml). A key is verified only when its XPath resolves to exactly the intended node on 2.0.

## Screen documentation sessions (2026-09-07)

The [dated walkthrough package](../../../docs/project-documentation/android-sgac2-2026-09-07/README.md)
adds 207 original PNG/source-XML pairs, with 200 screens curated into six Word documents
and a gallery. Seven repeated views/loading transitions are archived. Environment:
Pixel_7_Pro, Android 16, versionName 2.0.0 / versionCode 420; About MyICA displays
`2.0.0(13) (STAGING)`. The package contains manual navigation evidence, not a new XPath
verification sweep. The locator status table below retains its existing verification states.

| Area | Newly observed result |
| --- | --- |
| Resident and visitor profiles | Synthetic profiles created and updated successfully. Malaysian nationality adds a required Malaysian identity-card field. |
| Native SGAC selection | Both new profiles repeatedly show **Profile update required** after update/save success. Native arrival/trip/declaration screens beyond selection remain blocked. |
| QR | Seven-step tutorial, individual resident QR and car/motorcycle/lorry/bus group QRs reached. Bus group renamed and deleted; the other walkthrough groups remain. |
| Cargo | Synthetic vehicle created/edited; full and partial clearance permits accepted through review. Updated contact details carry into the web form. |
| Convoy | Two vehicles and a permit accepted through review. With low value goods set to YES, Next without a permit still produced required-field feedback. No cargo/convoy declaration was submitted. |
| Other e-Services | All ten categories and 32 entry links opened. Trusted Traveller Programme reached `eservices.ica.gov.sg/404.html`; Race/Dialect reached FormSG with a Singpass requirement; Appointment links use `eservices-stg.ica.gov.sg`. The address label `FOR_LTVP_STP_HOLDER` and Digital Stillbirth Extract → general eRECEIVE routing remain recorded. |
| Service search | `Report` returned two services and its passport result opened. `test` returned no cards; clearing restored the list. Names/time estimates display raw translation keys such as `REPORT_LOST_PASSPORT` and `MINUTES_5_TO_10`. |
| Home/support | All Help destination entries, ICA website, loaded privacy/terms pages, expanded Terms General section, ScamShield banner destination and translation-feedback destination captured. |

To reproduce the observed SGAC blocker: create a manual profile, select it on the SGAC
dashboard, choose UPDATE PROFILE, continue from Contact Details to the summary, accept
the terms and SAVE, then return and select it again. The same update-required alert returns.
This was observed for the new resident and Malaysian visitor records; it is not a claim
about every possible profile. The scanner reached its landscape viewfinder but lacked a
passport fixture; Singpass reached staging login but lacked test credentials. Existing-card,
certificate and cargo-ARN retrieval, submission results and physical clearance remain pending.

The user resumed from the earlier Citizenship pause, adding 36 captures. See the
[documentation task](../../../todo/done/emulator-flow-documentation.md) and
[flow inventory](../../../docs/project-documentation/android-sgac2-2026-09-07/flow-inventory.md)
for coverage limits, retained synthetic records and Appium reconnect details. The app was
returned to **MyICA Home**; check the device/session before any future continuation.
No YAML, keyword or Robot suite was changed by the documentation sessions. Artifact
validation and repository checks are recorded in the package's `checks.json`.

## Build 15 E2E continuation (2026-09-08)

The [build 15 report](../../../docs/testing/sgac2-build15-e2e-2026-09-08.md) records 174
validated PNG/XML pairs from versionName 2.0.0 / versionCode 422 (in-app build 15). The
new resident and Australian visitor profiles both opened the web submission form and reached
review, so the build 13 **Profile update required** loop did not reproduce with these complete
profiles. No declaration was submitted.

Build 15 profile contact pages now require country/region code, mobile number and email; the
foreigner page also retains Place of Residence. This supersedes the build 13 email-only notes
below. Individual and two-member Motorcycle group QR codes rendered. Cargo full/partial permits
and a two-vehicle convoy reached review. Singpass visibly authenticated and handed back to
MyICA, but returned to `Choose profile creation method` without populating MyInfo.

The SGAC, QR and cargo module selectors each exposed 12 languages in this build. Bengali SGAC,
Hindi QR and Simplified Chinese cargo were smoke-tested and English restored. This was not a
repeat of the separate 19-language device-locale matrix retained below. Observed staging content
includes `Dummy Question 1`, `X country**`, duplicated resident questions/DOM IDs, literal
`ALBANIA<h1>test</h1>` residence data, a four-times repeated cargo test announcement and mixed
English month names in Hindi QR content.

## Resident + foreigner module regression (2026-09-10)

The [10 September regression report](../../../docs/testing/sgac2-build15-regression-2026-09-10.md)
re-drove both SGAC profile-to-review flows on build 15 (2.0.0/422) with fresh synthetic
identities (71 PNG / 70 XML evidence pairs). Both manual profiles created, saved and opened
their web submission forms; the build 13 **Profile update required** loop again did not
reproduce; both flows reached the final review/Submit boundary without submitting.
Staging content deltas: `X country**` and the visitor `Dummy Question 1` are replaced by a
properly worded Africa/Latin-America yellow-fever question (CDA link) in both flows, and
resident health questions no longer repeat; the `ALBANIA<h1>test</h1>` residence option and
the cosmetic `Required` helper on valid native fields remain. New automation hazard: a
Google Password Manager save dialog interrupts the visitor web flow — mitigated 2026-09-10
by nulling the AVD's `autofill_service`/`credential_service` secure settings (revert
commands in the regression report). Locator impact: none —
all verified locators in this tree resolved as recorded; no YAML changed.

## QR module regression (2026-09-11)

The [11 September QR regression report](../../../docs/testing/sgac2-build15-qr-regression-2026-09-11.md)
re-drove the QR Code Clearance module on build 15 (2.0.0/422) via direct Appium UI
(26 PNG/XML evidence pairs). Individual QR render, saved-group regenerate, new Car group
creation (BUILD15 QR REG CAR: CHRISTINA HUNTER + JOHNATHAN BROWN), app-restart persistence
and the 12-language selector all PASS; the foreign-visitor SGAC reminder fires correctly on
generation. Defects: Hindi content still mixes English month names (8 Sept baseline defect
reproduces); the cosmetic `Required` helper extends to the create-group form; the language
list styles BENGALI in Latin script unlike its peers; the welcome/tutorial prompt reappears
on every module entry unless suppressed. QR validity renders a fixed "31 August 2027" on all
codes; group-list Expiry = earliest member passport expiry. Locator impact: none — this was
UI regression evidence, not locator verification; `yaml_QR_pages/*` remain unverified sgac1
copies.

## Cargo + convoy module regression (2026-09-11)

The [11 September cargo regression report](../../../docs/testing/sgac2-build15-cargo-regression-2026-09-11.md)
re-drove the cargo submission and convoy flows on build 15 (2.0.0/422) via direct Appium UI
(37 PNG/XML evidence pairs). All PASS to the review/Submit boundary without submitting:
vehicle persistence (SBA1234G), new vehicle SGI5915Y saved via the verified Add Vehicle
locators, no-vehicle validation dialog, cargo webview carry-over, full+partial permits
(IG2BB990021/22 qty 10), convoy LVG=YES with two vehicles and permit IG2BB990023 including
the no-permit required feedback, and the 12-language picker inventory. Defects: the 4×
`This is for testing Common Broadcast Message.` announcement REMAINS (loads async — first
paint can show only the legitimate Customs/REIA banner); cosmetic Required/Optional helpers
on filled Add Vehicle fields; BENGALI Latin-script styling in the picker. Convoy does not
prefill contact (by design). Locator impact: none — the verified cargo native locators
resolved as recorded; webview parts remain documented as page markers (TODO(cargo-web)).

## Build 15 in-app language sweep — all 12 languages × 3 modules (2026-09-11)

The [11 September language sweep report](../../../docs/testing/sgac2-build15-language-sweep-2026-09-11.md)
applied every language in every module picker on build 15 (42 PNG/XML pairs +
results.json). All 36 applications succeeded; SGAC, QR and cargo home screens fully
localize in all 12 languages; the language-button testIDs — `SGArrivalCardLanguage`
(discovered this run), `QrLanguage`, `CargoLanguage` — resolve in every language; the
SGAC setting is shared between resident and foreigner entries (Korean spot check).
KEY DEFECT: English month names leak in ALL 11 non-English languages (QR expiry lines
and SGAC passport-expiry lines; e.g. `Ablauf: 29 March 2028`, `만료: 29 March 2028`) —
a date-formatting bug, generalizing the earlier Hindi-only observation. Minor: BENGALI
Latin-script picker entry (all three pickers); possible Korean 도착/입국 terminology mix
on the SGAC landing. This swept module home screens only; the 19-language build 13 form
matrix below still stands for form-level coverage. No YAML changes.

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
  Passport Expiry) + Contact Details (**Place of Residence**, country/region code, mobile and
  email on build 15).
- `for_profile_summary.yaml` — page 3: Passport Details + Contact Details cards, Edit,
  T&C checkbox (un/checked), SAVE.
- `for_form_cty_page.yaml` / `for_form_nationality_page.yaml` / `for_form_residence_page.yaml`
  — the three searchable modals (`resource-id="modal"`, text="Search" input, "Close modal",
  options `content-desc="searchable dropdown accessible label <X>"`; residence options are
  `COUNTRY, CITY, CITY`). Build specific option locators via the `*-OPTION-BY-NAME-TEMPLATE`.
Distinct from resident: foreigner has Sex + Country/Place of Birth and no NRIC. NOTE: the legacy shared
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
  Convoy webview. The 2026-09-07 walkthrough now supplies UI XML and screenshots through
  review; TODO(cargo-web) remains to implement and verify automation against the web flow.
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
| eservices_landing_page.yaml | diverged | 10 service cards → SNAKE_CASE `EServices<CONSTANT>` rids (13/17 verified; 4 search-flow keys remain unverified despite the later manual search captures) |
| sgac/sgac_landing_page.yaml | diverged | FLOW REDESIGN: profile-centric (Manage/Create/Update); Individual/Group split + tutorial gate removed → T33 |
| profile_creation_method_page.yaml | verified | 6/7 as-is; only PROFILE-CREATION-SINGPASS-LABEL text changed (button resolves) |
| manual_creation_profile_form.yaml | copied | |
| sgac/resident/resident_profile_creation_form_page.yaml | verified | page 1 fields resolve as-is; 2.0 adds REQUIRED Nationality/Passport No./Passport Expiry (Nationality = searchable dropdown picker). Build 15 page 2 requires country/region code, mobile and email; these locators were already present in the file. Full flow reached review 2026-09-08. |
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
| cargo/add_permit_page.yaml | diverged (web) | manual full/partial permit and convoy review evidence captured 2026-09-07; TODO(cargo-web): automation and locator verification |
| cargo/cargo_convoy_page.yaml | diverged (webview) | Convoy → webview; two-vehicle manual flow reached review 2026-09-07, without submission; no new locator validation |
| yaml_QR_pages/all_profiles_page.yaml | copied | |
| yaml_QR_pages/personal_qr_code_page.yaml | copied | |
| yaml_QR_pages/passport_qr_code_page.yaml | copied | |
| yaml_QR_pages/create_group_qr_code_page.yaml | copied | |
| yaml_tutorial_flow_pages/passport_qr_tutorial_flow.yaml | copied | |
