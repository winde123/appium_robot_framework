# SGAC2.0 iOS locator tree — walk status (T32)

Seeded 2026-09-05 by copying `Data/sgac1/ios/**` (37 YAMLs). To be corrected screen by
screen against the live SGAC2.0 iOS build on Edwin's iPad (real device, XCUITest via Xcode).

**Build correction — 10 September 2026:** Edwin confirmed that the later
MyICA **1.19.1(1)** regression used **SGAC1.0**, the wrong target version. Its
[report](../../../docs/testing/ios-1-19-1-regression-2026-09-10.md) and captures
do not verify this SGAC2.0 locator tree or establish SGAC2.0 defects/passes.
The SGAC2.0 sessions below remain historical evidence on their recorded builds.
Edwin then installed **SGAC2.0 2.0.0(15)**. The resumed run verified both installed
metadata and About as **2.0.0(15), STAGING** on the physical iPad (iOS 26.6.1).
See the [separate SGAC2 continuation](../../../docs/testing/ios-sgac2-build15-regression-2026-09-10.md):
resident/foreigner native-entry retrieval, acknowledged visitor health update,
cargo/convoy retrieval and earlier-update persistence, and mixed QR checks.
This is direct UI evidence; no locator files or Robot suites were migrated or
certified by this continuation. The older locator status rows below retain their
original verification dates and may not describe the current build.

**Issue review / export — 11 September 2026:** screenshot review additionally
confirmed literal `ALBANIA<h1>test</h1>` content in the QR residence picker (IOS-07).
Cargo clipping (IOS-03) and the `vechicle` copy issue remain confirmed; missing
visitor update email remains suspected, with independent health persistence
unverified. The [Word issue review](../../../docs/exported/myica-ios-sgac2-build15-possible-issues-2026-09-10.docx)
contains eight findings and nine original screenshots in 19 rendered pages.
This export is complete and does not change locator verification status.

## T33 slice 1 — resident profile CRUD fork dispatch (2026-09-19, offline vs build 17)

`Resources/ios/SGACcommands.robot` now dispatches the resident profile flow per fork (same public
keyword names as Android: `Navigate to resident SGAC landing page`, `Navigate to profile list
page`, `Navigate to resident profile creation method page`, `Fill resident profile form`,
`Verify resident profile summary`, `Accept terms and save resident profile`, `Create resident
profile manually`); `tests/ios/sgac/crud_res_profile.robot` is fork-agnostic;
`crud_res_indv_submission.robot` is tagged `fork:sgac1-only` (TODO(T33-web)). Every sgac2 flow
key was re-verified OFFLINE with `tools/xpath_evidence_check.py` (exactly one node) against the
519 build-17 page sources in `Output/myica-build17-regression-2026-09-16/ios` (resident captures
005–032); no device run (real-device only, T42). Implementation: OpenCode
`deepseek/deepseek-v4-pro`; review/merge: dev lead. Task record:
`todo/done/t33-ios-resident-profile-crud.md`.

- **Build-17 reconciliation:** the resident contact page is Country/Region Code + Mobile Number +
  Email again (build 13 was email-only): `RES-FORM-CTY-CODE-{INPUT,REQUIRED}` and
  `RES-FORM-MOBILE-NUMBER-{INPUT,LABEL,REQUIRED}` are restored in `res_profile_form_page.yaml`
  (019/020) and `RES-DECL-SUMMARY-{COUNTRY-CODE,MOBILE}-{LABEL,VALUE}` in
  `res_profile_summary.yaml` (021/022); their `sgac1_only` allowlist entries were removed. The
  summary renders the mobile with spaces (`8 1 2 3 4 5 6 7`), the email upper-cased and
  DOB/expiry as `dd / mm / yyyy`. `RES-FORM-MOBILE-NUMBER-LABEL` has no standalone StaticText on
  build 17 (kept at the sgac1 locator for parity; not a flow key).
- `sgac/sgac_landing_page.yaml`: `SGAC-LANDING-ADD-PROFILE` ("add profile plus icon") IS still
  present on iOS build 17 (005), unlike Android build 15; creation routes through
  `SGAC-LANDING-CREATE-NEW-PROFILE`. The `SGAC-LANDING-PROFILE-UPDATE-*` alert keys have no
  build-17 capture. `RES-PROFILE-LIST-HEADER` (`name="Profile"`) also matches on other screens,
  so the sgac2 Manage Profiles list wait is weak and that list screen stays unverified.
- Header/label keys that match two RN-duplicated StaticText nodes report `ambiguous` in the
  checker; they are assertion-only and never tapped.
- Runtime risks for the iPad run (T42): keyboard state when tapping the nationality option and
  before `next` after the new passport fields; whether SAVE needs an explicit wait post-checkbox.

## T33 slice 2 — foreigner profile CRUD fork dispatch (2026-09-19, offline vs build 17)

`Resources/ios/SGACcommands.robot` now dispatches the foreigner profile flow per fork
(`Navigate to foreigner SGAC landing page` / `… profile creation method page`, `Fill foreigner
profile form`, `Verify foreigner profile summary`, `Accept terms and save foreigner profile`,
`Create foreigner profile manually`, plus the `Select foreigner modal option` helper) and
`tests/ios/sgac/crud_for_profile.robot` is fork-agnostic (five keyword calls). sgac1 keeps its
first-option picks and generated country code; sgac2 uses the persona sex FEMALE (`F`),
AUSTRALIA, AUSTRALIAN, residence search SYDNEY → `AUSTRALIA, NEW SOUTH WALES, SYDNEY (AUSTRALIA)`,
country code 61 (`+61`; mobile spaced, email upper-cased on the summary). Every sgac2 flow key
`verified` (exactly one node) against the 519 build-17 page sources (visitor captures 062–071)
with `tools/xpath_evidence_check.py`; the FEMALE option and the AUSTRALIA / AUSTRALIAN templates
have no build-17 capture and were verified in the 9 Sept build-15 set (`047-foreigner-gender.xml`,
`048-foreigner-birth-search.xml`, `250-resident-nationality.xml`). Implementation: OpenCode
`deepseek/deepseek-v4-pro`; review/merge: dev lead. Task record:
`todo/done/t33-ios-foreigner-profile-crud.md`.

- **Build-17 reconciliation (already true on build 15):** the foreigner contact page is Place of
  Residence + Country/Region Code + Mobile Number + Email — the build-13 "residence + email only"
  annotation was stale. `FOR-PROFILE-FORM-COUNTRY-CODE-{INPUT,REQUIRED}`,
  `FOR-PROFILE-FORM-MOBILE-NO-INPUT`, `FOR-PROFILE-FORM-MOBILE-NUMBER-REQUIRED` are restored in
  `for_profile_form.yaml` (066) and `FOR-PROFILE-SUMMARY-{CODE,MOBILE}-LABEL` in
  `for_profile_summary.yaml` (069); the allowlist `sgac1_only` lists shrink to
  `FOR-PROFILE-FORM-FULL-NAME-LABEL` (build 17 has only an invisible, inaccessible RN shadow
  StaticText) and `FOR-PROFILE-SUMMARY-TERMS-LINK` (merged sentence).
- The three modal files gain `FOR-{CTY,NATIONALITY,RESIDENCE}-OPTION-BY-NAME-TEMPLATE`
  (sgac2-only, Format String), mirroring the resident nationality template.
- The country/nationality list wrappers keep their empty-state `name` (`country/place of birth
  list`, `nationality/citizenship list`) and switch to a combined name once filled; the flow taps
  them empty, so the locators hold.
- No foreigner summary was captured in the T&C-checked state on build 15/17; the footer `save`
  component is proven by the resident 022 capture.
- Runtime risks for the iPad run (T42): keyboard state when tapping the sex/modal options,
  `KEYBOARD-DONE-BTN` timing after the new fields, `+` prefill of the country code, SAVE wait
  after the checkbox.

## Session 4 (2026-09-06 evening) — SGAC language verification (all 19 languages)
Verified the SGAC **landing**, **profile-creation-method**, and **profile form (page 1)** across
ALL 19 in-app languages on the live 2.0 build (English, 中文, Bahasa Melayu, தமிழ், Bahasa
Indonesia, Deutsch, Español, Filipino, Français, Italiano, Nederlands, Tiếng Việt, Русский,
العربية, हिन्दी, বাংলা, ไทย, 日本語, 한국어) — for BOTH the **resident** (Citizen & Resident entry)
and **foreigner** (Foreign Visitor entry) flows. Method: relaunch per language → set language via
the SGArrivalCardLanguage picker → capture page source; offline locator checks in
`scratchpad/analyze_lang.py` (resident) / `analyze_lang_for.py` (foreigner). Matrices saved as
`LANG_VERIFICATION_matrix.txt` (resident) and `LANG_VERIFICATION_foreigner_matrix.txt`.

**Foreigner flow (verified 2026-09-06):** entry `HomeFOREIGN_VISITOR_SG_ARRIVAL_CARD` → same
profile-centric SGAC landing → Create New Profile → creation-method (NO SingPass option;
fill-manually sits higher) → foreigner form (Full Name, Gender dropdown, DOB, Country/Place of
Birth, Nationality, Passport No./Expiry — no NRIC). Same result as resident: **all 19 languages
localize correctly** (incl. RTL Arabic, Thai/Tamil/Hindi/Bengali/CJK). Locator survival 52%
(landing 6/10, method 3/5, form 10/22). STABLE (language-independent): back/language buttons,
nav cards, MRZ + fill-manually method buttons, gender dropdown, DOB/expiry inputs+calendars,
country-of-birth & nationality list triggers, passport-number input, footer step. BREAK under
non-English: every header/section-title/hint/note, all `name="Required"` markers, and the
Full Name label/input (composed from the localized field label). NOTE: the foreigner form YAMLs
(`sgac/foreigner/*`) are still sgac1 copies — this sweep confirms localization + locator classes
but the 2.0 foreigner form itself still needs a correctness walk (separate from this i18n check).

**RESULT 1 — localization is correct everywhere.** Every screen fully localizes in all 19
languages, including RTL Arabic (e.g. method title "إضافة ملف شخصي") and complex scripts
(Thai เพิ่มโปรไฟล์, Tamil, Hindi प्रोफ़ाइल जोड़ें, Bengali, CJK 选择配置文件创建方法 / プロファイルの追加 /
프로필 추가). No crashes, blank, or clipped screens; page sources well-formed and populated in
every language. (The submission step itself stays blocked by the Session-3 app bug — not tested.)

**RESULT 2 — locator robustness (57% of locators are language-independent).** Consistent across
all 18 non-English languages: landing 6–7/10, method 4/6, form(p1) 12–13/23 survive.
- **STABLE (language-independent) — keep using these:** all `back`/`SGArrivalCardLanguage`
  buttons; nav-card a11y labels (Manage Profiles, Create New Profile, Update SG Arrival Card,
  add profile plus icon); method buttons (retrieve myinfo with singpass, scan passport mrz,
  fill manually); form inputs with hardcoded-English a11y labels (nric/fin, passport number,
  nationality/citizenship, DOB, passport expiry) + footer next/step. These are testIDs or
  hardcoded accessibilityLabels that DO NOT localize.
- **BREAK under non-English (avoid for cross-language assertions):** every screen HEADER /
  section title / instructional hint (SG Arrival Card, Add Profile, Profile Details, Choose
  profile creation method, Contact Details, empty-state & "Create a profile…" hints, Select
  Profiles); the `name="Required"` validation markers (localize to Diperlukan / 必填 / etc.);
  and the **Name** and **Email** input a11y labels (composed from the localized field label,
  e.g. "Nametext input"→"Namatext input"). These key on visible/localized copy.
- Consequence: mirrors the Android finding — testID/a11y-label locators are language-safe;
  visible-text locators (headers, "Required", section titles, Name/Email inputs) fail under
  non-English and need testID/structural alternatives for i18n test runs.

## Session 5 (2026-09-06) — iOS foreigner form correctness walk DONE
Drove the full 2.0 foreigner Add Profile flow on the iPad (Foreign Visitor → Create New
Profile → fill manually → p1 → p2 contact → p3 summary) and corrected the sgac1-copy
`sgac/foreigner/*` YAMLs. The 3 searchable modals (for_form_cty_page / for_form_nationality_page
/ for_form_residence_page) were verified UNCHANGED (8/8 each). Divergences corrected + allowlisted:
- for_profile_form: DOB/Expiry labels lost "(DD/MM/YYYY)" → repointed to the language-independent
  `-label-inactive` testIDs; standalone "Full Name (In Passport)" label gone; **Contact page is
  now Place of Residence + Email ONLY** (country-code + mobile removed) — matches Android.
- for_profile_summary: Sex label "Sex as indicated in passport"→"Sex"; EDIT→"Edit"; Country/Region
  Code + Mobile Number rows removed; standalone Terms link merged into the sentence.
Every key re-verified against captured page source; linter 0/0. This closes the last locator gap
noted in Session 4. (Test artifact: a foreigner profile JORDAN PHILLIPS was left on the iPad.)

## Session 3 (2026-09-06 late afternoon) — tunnel up; submission blocked by APP BUG
- **WireGuard staging tunnel INSTALLED and VERIFIED working** (VPN badge; staging web loads).
  "Update SG Arrival Card" opens an IN-APP WEBVIEW of the SGAC update e-service ("ICA | SG
  Arrival Card"; fields: Date of Arrival, NRIC/FIN, Full Name, DOB, Email). The e-services
  "Submit SG Arrival Card" tab opens the portal in SAFARI and loads fine.
- **"Profile update required" modal loop is an APP-SIDE issue, not network:** with staging
  reachable, EVERY locally-created profile still fails profile selection (tested: original
  profile, edit-wizard resave, NRIC/DOB-year-aligned data, full delete + fresh re-create as
  JEFFREY SERRANO). Suspect the iOS-26.6 requirement gate or a 2.0.0-build bug — RAISE WITH
  APP TEAM. The in-app submission screens (sel_indv_profile_list, res_submission_form,
  declaration, sub_success, foreigner tree) stay unwalkable until it clears — and may not
  exist at all in 2.0 (submission appears to be entirely web-based now).
- **e-Service search returns NO results for any term** (tested "Report Lost", "passport",
  with tunnel + Return) — 2.0 search looks broken on this build; 3 search keys stay blocked.
- **New landing coverage:** profile-card kebab menu (View / Edit + Delete only), Delete
  confirmation alert, Profile-update-required alert, Continue button, empty-state hints,
  selection checkbox NOT in a11y tree (coordinate tap ~x=55). Edit mode verified: header
  "Edit Profile", NRIC/Passport masked with a data-privacy helper (keys added).
- **Test-data note:** generated NRIC year-prefix and DOB are independent in
  manual_field_random.py; consistency did NOT unblock selection, but keep in mind for
  server-side validations.

## Session 2 (2026-09-06 afternoon) — WDA recovery + resident flow walked
- **WDA recovery recipe:** if WDA answers /status but sessions fail with
  `XCTDaemonErrorDomain Code=41 "Not authorized for performing UI testing actions"`, the
  instance is ORPHANED (its Xcode test session died — e.g. USB flap severed the tunnel).
  Relaunch headlessly, no Xcode GUI needed:
  `cd ~/.appium/node_modules/appium-xcuitest-driver/node_modules/appium-webdriveragent &&
  xcodebuild test -project WebDriverAgent.xcodeproj -scheme WebDriverAgentRunner
  -destination "id=<udid>"` — do NOT pass `DEVELOPMENT_TEAM`: the project file already
  carries Edwin's team `SMJS6ACH9K` (robotconfig's `IOS_XCODE_ORGID=W6PMZD7K72` is a
  DIFFERENT team and breaks headless signing). First run after reinstall may die with
  "Test crashed with signal kill" ~35s in — retry once, it sticks. Edwin also enabled
  performance trace + hang monitoring on the iPad (possible cause of first-run kills).
- **RN input quirks (iOS):** wrapper inputs (`…text input` XCUIElementTypeOther) do NOT
  expose typed text in the page source — verify values via screenshot or on the summary
  page. setValue APPENDS (clear first: focus + backspaces via WDA `/wda/keys`; the (x)
  clear icon is not in the a11y tree). The NRIC field drops trailing chars on fast typing
  (same as Android) — type char-by-char or append the tail. The footer `next` tap is
  swallowed while the keyboard is up — dismiss ("Done") first.
- **Walked live:** profile list (verified with a real card after saving), full 3-page
  Add Profile flow (profile MARVIN RIVERA saved on-device), summary incl. both checkbox
  states. All updated keys re-verified offline against the captured XMLs.

## Session 1 (2026-09-06)
Live XCUITest session established after a connectivity fight (see notes): needed appium-xcuitest
driver 10.43.1 (was 10.12.0, too old for iOS 26), Edwin's WDA signing, and a STABLE USB port
(the device kept flapping between USB/Wi-Fi; usbmux dropping broke `isAppInstalled`). Working
recipe: WDA run from Xcode (serves at the iPad Wi-Fi IP:8100 — check the `ServerURLHere` log
line); attach with `appium:webDriverAgentUrl=http://<ipad-ip>:8100` + `noReset` (do NOT use
usePreinstalledWDA — it terminates Edwin's WDA). On launch the app shows an OS-requirement modal
("device will need iOS 26.6 or above", iPad is 26.5.2) — dismiss the **OK** button first.
CONFIRMED: RN testIDs map to iOS `name`, so the SNAKE_CASE nav-card rename is IDENTICAL to
Android — the Android divergence docs (docs/refactor/divergence/) apply directly to iOS.

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
- ~~SGAC2.0 iOS BUNDLE ID~~ RESOLVED (T00/T30): `sg.gov.ica.mobile.app`, robotconfig filled.
- ~~SGAC2.0 TestFlight build installed on the iPad~~ RESOLVED (2.0.0 installed).
- ~~STAGING TUNNEL~~ RESOLVED (2026-09-06 late afternoon): WireGuard installed on the iPad
  and verified — staging web flows load (in-app SGAC update webview + Safari submit portal).
- **APP BUG — "Profile update required" loop (CURRENT blocker):** with staging reachable,
  profile selection still rejects every locally-created profile (see Session 3 notes).
  Raise with the app team (suspect the iOS-26.6 gate on 26.5.2, or a 2.0.0 build bug).
  Blocks the in-app submission screens — which may anyway be REMOVED in 2.0 (submission
  looks entirely web-based now).
- **e-Service search broken on this build** (no results for any term, tunnel up) — the 3
  search keys stay unverifiable.

## Screens
| Screen file | Status | Notes |
| --- | --- | --- |
| cargo/cargo_convoy_form_page.yaml | diverged | old in-app convoy form has no 2.0 entry point — the "Convoy" tile opens the web portal in Safari (loads with tunnel); likely REMOVED → T33 |
| cargo/cargo_convoy_page.yaml | diverged | same — convoy flow is web-based in 2.0 |
| cargo/cargo_landing_page.yaml | diverged | PROFILE-CENTRIC REDESIGN (like SGAC): Manage Cargo Submission / Create New Vehicle Profiles / Convoy Clearance / Select Vehicle Profiles (9/9 new keys verified); old convoy shortcut removed; note app typo "vechicle" in empty-state |
| cargo/cargo_permit_form_page.yaml | blocked | permit flow sits behind submission (needs tunnel) |
| cargo/cargo_sub_res_page.yaml | blocked | submission-success page (needs tunnel) |
| cargo/vehicle_profiles_page.yaml | NEW (verified) | 2.0-only page: Vehicle Profiles list + Add Vehicle form (15/15 across both states); no sgac1 counterpart |
| citizen_res_page.yaml | verified | unchanged in 2.0 — 10/10 resolve as-is (same as Android) |
| foreign_vis_page.yaml | diverged | PAGE REMOVED in 2.0: Home foreign-visitor favourite routes into the profile-centric SGAC landing (separate, empty foreigner profile store) → T33 |
| ios_common_selectors.yaml | copied | |
| landing_page.yaml | verified | favourites -> Home<CONSTANT> `name` (same as Android); scam text-header removed; e-service card buttons + banner resolve (9/9) |
| other_e_services/appt_services_page.yaml | verified | tabs → SNAKE_CASE (BOOK_CHANGE_CANCEL_APPOINTMENT, ONLINE_CHECK_IN_QUEUE); durations DROPPED on this page; web-header keys unverified (network) |
| other_e_services/birth_death_services_page.yaml | verified | tab → APPLY_FOR_BIRTH_OR_DEATH_EXTRACT; web-header unverified |
| other_e_services/change_res_address_page.yaml | verified | tabs → FOR_IC_HOLDER / FOR_LTVP_STP_HOLDER; web-header unverified |
| other_e_services/check_validity_verify_page.yaml | verified | 8 tabs → SNAKE_CASE; web-header keys unverified |
| other_e_services/customs_dec_services_page.yaml | diverged | e-services Customs card now DEEP-LINKS to Safari (Customs@SG) — no in-app category page; keys are sub-success/web only, unverifiable now |
| other_e_services/e727_services_page.yaml | blocked | CBNI submit lives behind submission flows (needs tunnel) |
| other_e_services/ltvp_student_pass_services_page.yaml | verified | 3 tabs → SNAKE_CASE, Other-Schools tab KEPT human label (partial conversion); web-headers unverified |
| other_e_services/other_e_services_page.yaml | diverged | 10 cards → SNAKE_CASE EServices<CONSTANT> (identical to Android, 12/15); Customs@SG sub-header now "Customs Declaration"; 3 search keys need server (blocked) |
| other_e_services/others_services_page.yaml | verified | 2 tabs → SNAKE_CASE, APEC tab kept human label; web-headers unverified |
| other_e_services/passport_IC_page.yaml | verified | 4 tabs → SNAKE_CASE (durations unchanged); web-headers unverified |
| other_e_services/sc_pr_services_page.yaml | verified | Re-entry tab → SNAKE_CASE, Citizenship/PR tabs kept human labels; web-headers unverified |
| other_e_services/sgac_epass_enquiry.yaml | verified | 3 tabs → SNAKE_CASE, Submit-SGAC tab kept human label; web-headers unverified |
| sgac/declaration_page.yaml | blocked (app bug) | in-app submission gated by the Profile-update-required loop; may not exist in 2.0 (submission is web-based) |
| sgac/foreigner/for_form_cty_page.yaml | verified | Country/Place of Birth searchable modal — unchanged 8/8 |
| sgac/foreigner/for_form_nationality_page.yaml | verified | Nationality searchable modal — unchanged 8/8 |
| sgac/foreigner/for_form_residence_page.yaml | verified | Place of Residence searchable modal — unchanged 8/8 |
| sgac/foreigner/for_profile_form.yaml | verified/diverged | 3-page flow driven live; DOB/Expiry labels→testIDs; contact = Residence+Email only on build 13, residence+code+mobile+email on builds 15/17 (keys restored, T33 slice 2, 2026-09-19) |
| sgac/foreigner/for_profile_summary.yaml | verified/diverged | Sex label shortened, EDIT→Edit, terms link merged; code/mobile rows removed on build 13 but back on builds 15/17 (restored, T33 slice 2, 2026-09-19) |
| sgac/indv_submission_page.yaml | blocked (app bug) | same |
| sgac/profile_creation_method_page.yaml | verified | 6/6 unchanged (mirrors Android) |
| sgac/profile_list_page.yaml | verified | 6/6 unchanged (checked with a saved card); + new Delete key; empty state reuses card-container (see note in file) |
| sgac/resident/res_declaration_summary.yaml | blocked (app bug) | same |
| sgac/resident/res_profile_form_page.yaml | diverged | 3-PAGE FLOW (same as Android): p1 adds REQUIRED Nationality (searchable dropdown, `searchable dropdown accessible label <X>` options)/Passport No./Expiry; p2 Contact = EMAIL ONLY on build 13, code+mobile+email again on build 17 (keys restored, T33 2026-09-19); full flow driven + saved 2026-09-06 |
| sgac/resident/res_profile_summary.yaml | diverged | + Nationality/Passport No./Expiry rows; contact email-only on build 13, code+mobile+email rows on build 17 (restored, T33 2026-09-19); EDIT→"Edit"; terms link merged into sentence; SAVE appears only after T&C checked (28/29 + unchecked state verified) |
| sgac/resident/res_submission_form_page.yaml | blocked (app bug) | same |
| sgac/sel_indv_profile_list_page.yaml | blocked (app bug) | same |
| sgac/sgac_landing_page.yaml | diverged | FLOW REDESIGN (same as Android): profile-centric (Manage/Create/Update/Select); Individual/Group split + tutorial gate removed → T33 slice 1 dispatch merged 2026-09-19 (resident profile CRUD) |
| sgac/sub_success_page.yaml | blocked (app bug) | same |
