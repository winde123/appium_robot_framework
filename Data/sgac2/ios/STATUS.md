# SGAC2.0 iOS locator tree — walk status (T32)

Seeded 2026-09-05 by copying `Data/sgac1/ios/**` (37 YAMLs). To be corrected screen by
screen against the live SGAC2.0 iOS build on Edwin's iPad (real device, XCUITest via Xcode).

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
| citizen_res_page.yaml | verified | unchanged in 2.0 — 10/10 resolve as-is (same as Android) |
| foreign_vis_page.yaml | copied | |
| ios_common_selectors.yaml | copied | |
| landing_page.yaml | verified | favourites -> Home<CONSTANT> `name` (same as Android); scam text-header removed; e-service card buttons + banner resolve (9/9) |
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
| sgac/profile_creation_method_page.yaml | verified | 6/6 unchanged (mirrors Android) |
| sgac/profile_list_page.yaml | verified | 6/6 unchanged (checked with a saved card); + new Delete key; empty state reuses card-container (see note in file) |
| sgac/resident/res_declaration_summary.yaml | copied | |
| sgac/resident/res_profile_form_page.yaml | diverged | 3-PAGE FLOW (same as Android): p1 adds REQUIRED Nationality (searchable dropdown, `searchable dropdown accessible label <X>` options)/Passport No./Expiry; p2 Contact = EMAIL ONLY; full flow driven + saved 2026-09-06 |
| sgac/resident/res_profile_summary.yaml | diverged | + Nationality/Passport No./Expiry rows; contact email-only; EDIT→"Edit"; terms link merged into sentence; SAVE appears only after T&C checked (28/29 + unchecked state verified) |
| sgac/resident/res_submission_form_page.yaml | copied | |
| sgac/sel_indv_profile_list_page.yaml | copied | |
| sgac/sgac_landing_page.yaml | diverged | FLOW REDESIGN (same as Android): profile-centric (Manage/Create/Update/Select); Individual/Group split + tutorial gate removed → T33 |
| sgac/sub_success_page.yaml | copied | |
