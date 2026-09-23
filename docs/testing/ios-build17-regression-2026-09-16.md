# MyICA iPad build 17 regression — 16 September 2026

Last reviewed: 2026-09-16

**Regression execution complete — findings prevent a clean release sign-off.** Tested on the iPad only, including the supplied Singpass password account, on 16 September 2026 (live actions approximately 10:49–14:02 SGT). Coverage and unexecuted boundaries are documented below.

**Ten finding groups: three High, six Medium and one Low (proposed priorities).** Singpass authentication and callback succeed, but required blank/locked passport fields prevent profile completion. The other High findings are saved-visitor submission entry remaining on Loading and an intermittent passport-camera crash. Resolve or disposition these blockers and rerun the affected scenarios before granting a clean regression sign-off.

## Environment and evidence

- Physical iPad Air 11-inch (M3), iPadOS 26.6.2.
- MyICA Mobile `sg.gov.ica.mobile.app`, **2.0.0(17), STAGING**. Installed metadata and About agree; base service URL is `https://eservices-stg.ica.gov.sg`.
- Appium 3.7.0, XCUITest, existing signed WebDriverAgent over USB; `noReset=true`. MyICA was not installed or reset.
- The expired WDA profile was renewed with Xcode automatic provisioning; the user completed device-side developer trust before testing.
- Evidence: [`Output/myica-build17-regression-2026-09-16/ios/`](../../Output/myica-build17-regression-2026-09-16/ios/). Numbered references identify paired PNG/XML captures, not test-case totals.
- [Searchable local screenshot gallery](../../Output/myica-build17-regression-2026-09-16/ios/gallery.html) contains all validated PNG/XML capture pairs. Evidence is gitignored and available in this workspace, not in a fresh clone.
- Credentials are loaded from the gitignored, mode-0600 `.env`, never from action arguments. XML summaries redact configured secrets. Original local screenshots can contain staging identity data and are not publication-ready redacted artifacts.
- [Completed task](../../todo/done/myica-build17-full-regression-2026-09-16.md).

## Observed results

| Area | Observed result | Evidence |
| --- | --- | --- |
| Build / launch | Home loads and About shows 2.0.0(17), STAGING | `build-baseline.json`, 002–004 |
| Resident entry | Empty profile store; creation method and manual form accessible | 005–006, 015–016 |
| Singpass password | Supplied credentials accepted; UAT gateway returns to MyICA and populates identity/DOB/nationality | 007–011 |
| Singpass profile completion | **Blocked in the UI:** passport number and expiry are blank and locked; Next rejects them. Profile cannot be saved with this returned data | 011–013 |
| Unsaved profile navigation | Exit → Cancel preserves form; Exit → OK returns to SGAC dashboard | 014–015 and `actions.jsonl` |
| Manual resident validation | Empty Next remains at step 1 and flags required identity, DOB, nationality and passport fields | 016 |
| Resident contact validation | Missing contact fields and malformed email rejected | 019–020 |
| Resident save / persistence | Summary matches fixture, Save appears after terms acceptance, new profile survives restart | 021–024 |
| Resident edit / delete | Identity fields masked on edit; exact name change saves; Delete → Cancel preserves profile; final Confirm removes it and absence survives restart | 027, 031–033, 604–606 |
| Resident submission | One No/No declaration accepted at 11:19 SGT for arrival 17 September; successful receipt shown | 042–047 |
| Resident retrieval | Missing fields rejected; wrong arrival returns `Traveller HDC not found`; correct arrival returns matching identity | 050–054 |
| Resident update | Masked health fields can be edited; empty health rejected; one Yes/No update acknowledged at 11:23 SGT | 055–061 |
| Resident email | Initial and update acknowledgements delivered; name, arrival, transaction times and No/No → Yes/No answers match | `resident-email-1.json`, `resident-email-0.json` |
| Visitor entry | Separate empty store; manual creation available, no Singpass option | 062–063 |
| Visitor profile | Required validation, Australian identity/contact summary, terms-gated save and restart persistence pass | 064–071 |
| Residence picker | Literal Albania test markup remains visible | 067 |
| Visitor saved-profile submission entry | Repeatedly stays on Loading | 072–076 |
| Visitor manual submission | Update SG Arrival Card → new submission loads the manual form; matching identity, trip, flight, hotel and No/No answers reviewed; one submission accepted at 11:46 SGT | 077–102 |
| Visitor email | Matching acknowledgement delivered with DE `X2352A0923`, passport, arrival, hotel and No/No answers | `visitor-email-0.json` |
| Visitor retrieval | Wrong DE rejected with the remaining identity fields verified; correct DE retrieves arrival, nationality, passport and dates; private fields masked | 149–153 |
| Visitor update | Mobile changed from 412345678 to 412345679; review shows changed digits and masked country code; one update acknowledged at 12:05 SGT | 154–162 |
| Visitor update email | **Mismatch:** initial mobile is `61412345678`; changing only local mobile to `412345679` yields acknowledgement `6412345679`, not expected `61412345679` | `visitor-email-0.json`, `visitor-update-email-0.json`, 155, 159 |
| Visitor country-code control | Explicitly entering country code 61 and mobile 412345679 reaches review with the correct full number; accepted at 12:43, and delivered email contains **61412345679** | 164–167, `visitor-control-email-0.json` |
| Visitor native edit / delete | Exact name edit saves and survives restart; Delete → Cancel retains it; Confirm removes this run's profile | 168–175 |
| Passport scanner | Tutorial and live camera open. One camera session crashes near a Back action; a second session returns to the tutorial successfully | 176–184, `sgac-2026-09-16-125036.ips` |
| Declaration consent | Visitor dialog opens; Disagree leaves checkbox off and Agree checks it | 161–162 and `actions.jsonl` |
| QR tutorial | All seven steps render; Previous and Finish work | 105–113 |
| QR shared profiles / personal QR | Both SGAC fixtures available; resident marked as personal profile through terms-gated edit; personal QR renders | 114–120 |
| Group QR | Empty and one-member attempts rejected; mixed two-member group renders; foreign-visitor SGAC reminder shown | 121–128 |
| QR vehicle types / rename | Car, Bus, Lorry and Motorcycle generate using the same two fixtures; group renamed to B17 IPAD QR MOTOR | 123–138 |
| QR persistence | Personal profile and renamed two-member group survive restart | 139–140 |
| QR languages | All 12 settings/dashboard pairs load, ending in English; translated expiry labels retain English month names | `500-qr-01`–`500-qr-12`, `500-qr-results.json` |
| Shared-profile cleanup | Visitor deletion leaves the resident and personal QR intact; final resident deletion clears resident, visitor and QR stores after restart, including personal QR | 600–609, actual final QR render 602b |
| Group delete | Cancel preserves the group; Confirm removes only the run's group and leaves profiles available | 143–145 |
| SGAC languages | All 12 settings/dashboard pairs load and English is restored | `510-sgac-01`–`510-sgac-12` |
| Cargo vehicle | Required/invalid-email attempts do not save; unsupported plate warning shown; saved fixture edited to SBC2929T / 81234568; Delete→Cancel and restart persistence pass | 301–312 |
| Cargo validation | Profile selection and LVG are required; short and duplicate permits rejected; partial quantity 0 still reaches review | 312, 314–327 |
| Cargo accepted submission | Full OO5E9900000 + partial OO5E9900001, quantity **10**, LVG No accepted with ARN **9392902088167** and QR | 329–331 |
| Cargo retrieval | Empty fields and wrong vehicle rejected; matching ARN/vehicle returns contact, LVG and both permits/quantity | 334–339 |
| Cargo update persistence | Mobile updated to **81234569**; same ARN acknowledged; fresh retrieval through native Manage entry confirms changed number | 340–341, 347–348 |
| Cargo email | Initial 12:15:46 and amended 12:19:02 acknowledgements match ARN, vehicle, permits, quantity 10 and mobile 81234568 → 81234569 | `cargo-final-email-1.json`, `cargo-final-email-0.json` |
| Cargo receipt routing / layout | Manage link stays inside MyICA and retrieves this run's ARN; Important Note text fits portrait viewport | 332–336 |
| Cargo export | PDF and Save QR open native share sheets; physical output/file-save persistence untested. Direct Print produces no visible print interface on two attempts | 342–346 |
| Convoy validation / limits | Empty contact/LVG/vehicles, missing second vehicle, duplicate vehicle and missing permit rejected; 15 form rows allowed, attempted 16th prevented, original values retained after removing blanks | 351–361, `convoy-boundary-results.json` |
| Permit scanner entry | Tutorial, first-use camera permission, camera view and Return work; no physical permit decoded | 362–366 |
| Active vehicle protection | Attempt using active cargo vehicle SBC2929T rejected as an unfinished journey; no convoy ARN issued for that attempt | 367–369 |
| Convoy accepted submission | Fresh SBE9156A + SBD6388Y, LVG Yes, full OO5E9900002 accepted with ARN **9793402088168** and QR | 370–371 |
| Convoy retrieval | Retrieval using SBE9156A returns both vehicles, original mobile, LVG Yes and permit | 372–373 |
| Convoy update / email | Mobile 81234567 → 81234570 acknowledged with the same ARN; fresh retrieval using SBD6388Y confirms persistence; both emails match | 374–376, `convoy-final-email-0.json` (initial), `-1.json` (update) |
| Convoy server delete | Cancel preserves the submission; Delete succeeds; same ARN/vehicle no longer retrieves. Separate cargo record still retrieves unchanged | 377–380 |
| Cargo server / native delete | Own cargo ARN deleted and no longer retrieves; native vehicle deleted and stays absent after restart | 381–384 |
| Cargo languages | All 12 settings/dashboard pairs load and English is restored; French dashboard has Japanese vehicle-profile heading; settings title remains English | `520-cargo-01`–`520-cargo-12` |
| e-Service catalogue | All **32 entries** across ten categories exercised: **31 expected landing/form entries, one missing destination** (Trusted Traveller) | 201–231, retries 208/209, 403–404, `eservices-reviewed.json` |
| Appointment destinations | Initial short-wait captures show Loading; fresh attempts with 30-second waits load booking homepage and check-in form on staging | 226–227, 232–233 |
| Home hubs | All eight citizen/resident and nine visitor shortcuts open their expected module/category, service landing or sign-in gate | 401–402, 451–458, 460–468 |
| Help | Contact Us, Feedback, FAQ, Report Vulnerability and Troubleshooting open; no message/report submitted | 430, 434–438 |
| About | About Us, ICA Website, Privacy Statement and Terms of Use open | 440–443 |
| Settings | Language entry displays 12 choices; tutorial off persists after restart and original on setting is restored | 431–433, 439, 444–445 |
| Visitor e-Services | 15 category cards; all 29 child links checked: 27 expected destinations, two missing pages; direct Customs works | 465, 471–485, 700–728, `visitor-links-reviewed.json` |
| Favourites | Seventh shortcut rejected; Cancel preserves original six; replacing Other e-Services with Customs saves and survives restart; exact original six/order restored and verified after another restart | 490–496, `favourites-results.json` |
| e-Service search | Report finds the expected two services; lost-passport result opens the correct entry page; nonsense query returns zero rows. Visible result titles/durations expose translation keys | 487–489 / B17-10 |
| Home external links | Identity-card favourite and scam banner reach relevant service/ScamShield pages; Customs works; translation-feedback footer opens ICA Contact Us | 404, 446, 469–470, 497–498 |

## e-Service entry results

These checks establish the destination opened from MyICA, not successful completion of the external service. The supplied staging credentials were used for the requested MyInfo flow only. No production application, appointment, identity change, payment or feedback was submitted.

| Category | Entries | Result |
| --- | ---: | --- |
| Passport and Identity Card | 4 | All expected entry pages; lost-IC entry correctly shares the register/replace page, which explicitly supports lost-IC reporting |
| Long-Term Visit Pass / Student's Pass | 4 | All expected entry pages, including both Student's Pass variants |
| Citizenship / Permanent Residence | 3 | Citizenship, PR and Re-Entry Permit entry pages load |
| Check Validity / Verify | 8 | IC, immigration pass and six certificate/extract entries load; stillbirth extract opens the generic Download/Verify Certificate portal |
| Change of Residential Address | 2 | Both supported user categories reach the common change-of-address portal |
| SGAC / Entry Visa / e-Pass / Extension | 4 | SGAC landing, visa information, e-Pass retrieval form and visit-pass extension entry load |
| Appointment | 2 | Booking homepage and check-in form load after a longer wait; both use `eservices-stg.ica.gov.sg` |
| Birth and Death | 1 | Birth/death extract application entry loads |
| Others | 3 | APEC entry and change-of-race/dialect FormSG gate load; SG–US Trusted Traveller entry returns missing-page response |
| Customs Declaration | 1 | Customs@SG information landing opens from the catalogue |

The main catalogue has ten category cards (403). Native service counts match the inventory for all nine service-list categories (`eservices-category-counts.json`); Customs is the additional direct entry. Destinations were reviewed individually in [`eservices-reviewed.json`](../../Output/myica-build17-regression-2026-09-16/ios/eservices-reviewed.json). The raw sweep's “Captured” status is not a pass assertion. Student's Pass Other Schools, Citizenship, PR, SGAC and APEC required current SNAKE_CASE IDs in the temporary helper; production locator YAML was left unchanged. Public catalogue destinations generally use production ICA pages; the two appointment entries use staging. This routing observation is distinct from the previously incorrect cargo receipt-to-management handoff.

The citizen/resident **MyICA** shortcut opens the production Singpass gate; no credentials were entered there. The CBNI Submit and Retrieve/Void shortcuts from both Home hubs open `eservices5-uat.police.gov.sg`. Both forms render, including an old 2024 test-maintenance notice; no cash declaration was submitted or voided. Native QR shortcuts correctly show the welcome prompt while tutorial settings are enabled.

Home → Foreign Visitor → Visitor e-Services exposes **15 additional category cards** (465), comprising 29 child links across 14 native sections plus direct Customs. These are outside the older common e-Service suite's inventory. Parent menus are captured at 471–485; all 29 child destinations were reviewed (700–728): **27 expected entry pages/forms and two missing destinations**. The direct Customs entry also loads. See [`visitor-links-reviewed.json`](../../Output/myica-build17-regression-2026-09-16/ios/visitor-links-reviewed.json).

## Findings

Priorities below are proposed triage priorities, not an agreed release policy.

| Finding | Proposed priority | Impact / next investigation |
| --- | --- | --- |
| B17-01 | High | Supplied MyInfo account authenticates but cannot complete the required profile; confirm account data and supported completion behavior |
| B17-04 | High | Saved visitor profile cannot enter its submission form; inspect saved-profile handoff and request handling |
| B17-07 | High | Native camera-processing crash; symbolicate the supplied build-17 BiometricSDK crash |
| B17-06 | Medium | Full mobile number differs after a mobile-only update; compare persisted country code and acknowledgement formatting |
| B17-02 | Medium | Health declaration wording differs between what was answered and acknowledged |
| B17-05 | Medium | Wrong-language cargo heading, untranslated settings/date components |
| B17-03 | Low | Malformed reference label visible to users |
| B17-08 | Medium | Receipt Print action gives no visible print interface |
| B17-09 | Medium | Service/information links land on missing-page responses; three routes confirmed |
| B17-10 | Medium | e-Service search results display internal translation keys instead of readable titles/durations |

### B17-01 — Retrieved MyInfo profile cannot advance with missing, locked passport data

Home → Citizen & Resident SG Arrival Card → Create New Profile → Retrieve MyInfo with Singpass → password login → accept Safari's Open MyICA prompt.

Authentication and callback succeed. The returned profile contains name, NRIC, DOB and nationality. Passport number and expiry are blank; the page states that Singpass profiles are not editable. Tapping the passport field does not open an editor or keyboard. Next leaves the user at step 1 with required errors for those two fields. No profile is saved.

Expected: a supported way to complete profile creation when the supplied MyInfo account has missing passport data, or clear guidance explaining the unsupported account/required source-data correction. Root cause and intended account eligibility require confirmation; observed blocking behavior is established. The earlier build-15 no-profile callback failure did **not** reproduce in this run.

Evidence: [populated callback](../../Output/myica-build17-regression-2026-09-16/ios/011-singpass-myica-return.png), [required fields](../../Output/myica-build17-regression-2026-09-16/ios/012-singpass-required-fields.png), [locked passport field](../../Output/myica-build17-regression-2026-09-16/ios/013-singpass-passport-disabled.png); 014–015 record safe exit. No credentials are included in this report.

### B17-02 — Form and acknowledgement health wording disagree

The initial resident declaration asks about Africa/Latin America in the past **7 days** (038, 043), while the matching 11:19 acknowledgement asks **6 days** (`resident-email-1.json`). Both carry No/No answers and the same arrival/name. This reproduces the prior build-15 discrepancy.

The Yes branch shows `X country**` in the 21-day follow-up (037), while the matching update email uses explicit country/region wording (`resident-email-0.json`). The update acknowledgement confirms the submitted Yes/No answers; retrieval itself masks them.

The visitor acknowledgement repeats the 6-day wording (`visitor-email-0.json`), whereas its submitted web form uses 7 days (091, 100).

### B17-03 — Literal test markup in residence reference content

Visitor profile → Contact Details → Place of Residence includes `ALBANIA<h1>test</h1>` in the location label (067). The previously reported malformed reference content remains present. This is a content finding, not evidence of script execution.

### B17-04 — Visitor arrival-card entry remains on Loading

A newly created, complete Australian visitor profile is selectable and survives restart (069–071). Continue opens the Foreign Visitors / IPA Holders submission header but remains on `Loading...` without identity or trip fields. The first attempt persisted through an explicit 35-second condition wait and additional inspection; returning to the dashboard and trying again showed the same state (072–076). No Submit action occurred on that route. Application/backend cause is not yet isolated.

Workaround verified: Update SG Arrival Card → **new submission** loads a manual visitor form (077–079). Entering the same synthetic identity plus an air/hotel trip reaches review (098–101), and one submission succeeds at **11:46 SGT**, arrival 17 September (102). Tracking ID: `TID:32d88e99197c7d9d34d4a75ca3fe09a1`. This narrows the observed failure to the saved-profile entry route; it does not establish its root cause. [Repeated Loading state](../../Output/myica-build17-regression-2026-09-16/ios/076-visitor-retry-still-loading.png).

### B17-05 — QR expiry months remain English across translated dashboards

With the saved resident and mixed group, switch QR language through all 12 options. Non-English expiry labels still contain `16 September 2030` (`500-qr-01`–`500-qr-11`). This repeats the earlier date-localization observation. Language switching and dashboard rendering succeed; this check does not establish translation quality for every string or screen. The picker lists Bengali as `BENGALI` while the dashboard itself uses Bengali script.

Cargo settings retain the English title `Cargo Submission Language` for all 11 non-English selections (`520-cargo-*-settings`). The French cargo dashboard has the Japanese heading `車両プロファイルの選択` amid otherwise French UI (`520-cargo-08-dashboard`, visually confirmed). QR, SGAC visitor and cargo settings/dashboard smoke coverage totals **36 language selections**, all restored to English. This is navigation/rendering coverage, not a linguistic review of all application content.

### B17-06 — Visitor mobile-only update does not preserve the full country code in acknowledgement

The 11:46 initial acknowledgement carries full mobile `61412345678`. In the retrieved edit form, Country Code and Mobile Number are masked (155). Only Mobile Number was cleared and changed to `412345679`; Country Code was untouched. Capture 156's XML confirms the exact nine-digit input. Review shows masked prefix plus those nine digits (159). The accepted 12:05 update's email instead carries `6412345679`, losing the `1` from the original `61` country code. Both emails have DE `X2352A0923`, passport `E18961956`, same arrival and hotel.

Control: retrieve again, explicitly enter Country Code **61** and Mobile Number **412345679**, verify both input values (165) and full review number (166), and submit once. The 12:43 acknowledgement (167) and delivered `visitor-control-email-0.json` now contain the expected **61412345679**. Explicitly re-entering the country code is a verified workaround. The form/email mismatch is established; distinguishing stored-data corruption from formatting/template behavior requires backend inspection. The update emails omit health answers; that omission alone does not establish loss of stored health data.

### B17-07 — Intermittent native crash during passport MRZ camera session

Home → Foreign Visitor SG Arrival Card → Create New Profile → Scan Passport MRZ → Scan Passport. The camera opens (179). Near the attempted Back action, the app disappears (180), and iPadOS subsequently displays **“MyICA Mobile” Crashed** (181). Choosing No Thanks sends no additional diagnostic report through that dialog.

The locally copied device crash report identifies `sg.gov.ica.mobile.app`, version **2.0.0**, build **17**, at **12:50:33.9128 SGT**. It records `EXC_BAD_ACCESS / SIGSEGV`, invalid address `0x10`, on queue `morpho.rt.libgrab.sampleBuffer`; the leading frames are in **BiometricSDK**, followed by `AVCaptureVideoDataOutput`. This establishes an application crash associated with camera processing. The capture timestamp slightly precedes the logged Back action, so Back is **not established as the cause**. SDK symbolication is needed to identify the fault.

A second camera session and Back return successfully to the tutorial, with app state 4 (foreground), captures 182–184. Observed frequency: **one crash in two camera sessions**; do not describe it as consistently reproducible. Original evidence: [device crash log](../../Output/myica-build17-regression-2026-09-16/ios/sgac-2026-09-16-125036.ips), [iPadOS crash alert](../../Output/myica-build17-regression-2026-09-16/ios/181-mrz-exit-ios-crash-alert.png), extracted `mrz-crash-summary.json`, 179–184 and `actions.jsonl`.

### B17-08 — Cargo receipt Print action gives no visible response

On the accepted cargo receipt, tap Print, wait and inspect the screen; repeat by tapping the control's coordinates. Both attempts retain the receipt without a visible print sheet (342–343). In the same session, PDF and Save QR open native share sheets (344, 346). Expected: a print interface or actionable feedback. This finding concerns action response; printer availability and physical output were not tested.

### Observations needing a product rule or content decision

- Partial-clearance quantity **0** saves and reaches review (325–327). The allowed minimum and backend acceptance of zero are unverified; the accepted test uses quantity **10**. This remains a validation concern rather than a proven rule violation.
- The cargo dashboard repeats a test broadcast four times (311). Confirm intended staging content.
- Native fields retain neutral `Required` helper text when populated; forms save successfully. The manually created visitor's Edit screen also shows the general Singpass-not-editable message despite allowing its name edit (168–172). These are copy/usability observations, not evidence that manual profiles are locked.

### B17-09 — Service and information links reach missing pages

Home → Other e-Services → Others → Apply for SG–US Trusted Traveller Programme opens Safari on `eservices.ica.gov.sg`, which says **“We are sorry, the page requested cannot be found.”** (230). The service cannot be entered from that catalogue item. Expected: a working service or current information page. Verify the app's configured destination and any service migration; an HTTP status code was not inspected. The same symptom was reported in the earlier Android walkthrough, but this is fresh iPad/build-17 evidence.

Two additional visitor routes reach the same missing-page response:

- Home → Foreign Visitor → Visitor e-Services → Frequent Traveller Programme → Check Eligibility and Procedure ([709](../../Output/myica-build17-regression-2026-09-16/ios/709-visitor-leaf.png)).
- Home → Foreign Visitor → Visitor e-Services → Loss of Foreign Passport → Report a Loss ([710](../../Output/myica-build17-regression-2026-09-16/ios/710-visitor-leaf.png)).

### B17-10 — e-Service search exposes translation keys

Home → Other e-Services → Search → enter `Report`. The two expected result rows appear, but their visible titles are `REPORT_LOST_PASSPORT` and `REPORT_LOST_IDENTITY_CARD`; their durations are `MINUTES_5_TO_10` and `MINUTES_15_TO_20`. This is confirmed in the screenshot, not inferred from accessibility IDs. Expected: readable service names and durations consistent with the category menus.

The lost-passport row still opens the correct Online Report entry page (488). A nonsense query returns zero rows (489), so matching and tested result navigation work despite the display defect.

Evidence: [search results](../../Output/myica-build17-regression-2026-09-16/ios/487-search-report.png).

## Earlier findings retested

These dispositions apply only to the tested build-17 scenarios; they do not establish when a fix was made or eliminate intermittent failures.

| Earlier observation | Build-17 disposition | Evidence |
| --- | --- | --- |
| Singpass returns no populated profile | Does not recur: authentication and populated callback succeed; new passport-data blocker B17-01 remains | 007–013 |
| Resident Submit has no visible receipt | Does not recur: initial receipt and update receipt both appear, with delivered matching emails | 047, 061, resident emails |
| Visitor acknowledgement email missing | Does not recur: initial and both update emails delivered | Three visitor email files in `submission-results.json` |
| HOTEL submission rejected with `hotelCd` length error | Does not recur with catalogue-selected Ascott Singapore Raffles Place, including updates retaining that hotel | 095–102, 162, 167 |
| Cargo receipt Manage opens production Safari | Does not recur: stays inside MyICA and retrieves this run's staging ARN | 332–336 |
| Cargo Important Note clips in portrait | Does not recur in the captured viewport | 335 |
| Cargo empty state spells `vechicle` | Corrected in current UI | 301 |
| Residence picker includes literal test markup | Reproduced | 067 / B17-03 |
| Form asks 7 days but email says 6 | Reproduced for resident and visitor initial submissions | B17-02 |
| `X country**` positive-health copy | Reproduced in resident positive branch | 037 |
| Visitor raw group-prompt translation keys | Readable English in the exercised No/No branch; prior intermittent positive-branch state not reproduced here | 090–091 |
| Zero partial quantity reaches review | Reproduced; minimum-rule/backend question remains | 325–327 |
| English cargo settings header / expiry months | Reproduced; additional French/Japanese mismatch found | B17-05 |

## Accepted transactions and cleanup ledger

All **nine accepted transactions** have delivered acknowledgement evidence. See [`submission-results.json`](../../Output/myica-build17-regression-2026-09-16/ios/submission-results.json) for file-level correlation. A receipt's email-delivery statement was not treated as proof of delivery.

| Record | Accepted operations | Independent verification | Server state |
| --- | --- | --- | --- |
| Resident SGAC, arrival 17 September | Initial 11:19; health update 11:23 SGT | Correct retrieval; initial/update email answers No/No → Yes/No | Retained |
| Visitor SGAC, DE X2352A0923, arrival 17 September | Initial 11:46; mobile update 12:05; country-code control 12:43 SGT | Correct retrieval; all three emails; phone mismatch and corrected control documented | Retained |
| Cargo ARN 9392902088167, SBC2929T | Initial 12:15:46; mobile update 12:19:02 SGT | Fresh retrieval and both emails preserve permits/quantity and changed phone | Deleted; retrieval rejection verified |
| Convoy ARN 9793402088168, SBE9156A / SBD6388Y | Initial 12:30:17; mobile update | Both vehicle retrieval routes and both emails verified | Deleted; retrieval rejection verified |

Native deletion is separate from server deletion. Only this run's records were selected for cleanup. No older submission was edited or removed. The two SGAC server records remain; no SGAC server-deletion flow was exercised.

Final device state (600–613, [`final-state.json`](../../Output/myica-build17-regression-2026-09-16/ios/final-state.json)):

- Resident, visitor and shared QR profile stores are empty after restart. Personal QR is cleared, the test group is absent, and the cargo vehicle store is empty.
- Original six Home favourites and their exact order are restored; English is restored for SGAC, QR and cargo; the original QR tutorial setting is on.
- MyICA is foregrounded on Home; final About still confirms 2.0.0(17), STAGING. Camera permission remains allowed after the scanner tests.
- New destination-sweep Safari tabs were closed; pre-sweep tabs were retained. At the user's later request, WDA and the port-8100 USB forwarder were stopped at 15:17 SGT; the general Appium server on port 4723 remains running.

## Execution method and limits

SGAC2 iOS Robot dry run: **42 passed, 0 failed**. This establishes suite loading only; it is not a live product test result. Existing suites contain older flow assumptions and are not sufficient for build-17 sign-off. One initial direct About assertion expected different spacing/text; it was corrected against the captured current label and passed. That mismatch is a harness issue.

Initial declaration-link taps showed no dialog (044–045), but the visitor update's dialog subsequently opened and Agree/Disagree correctly controlled the checkbox (161–162); no declaration-link defect is established.

Capture 602 is the personal-QR action menu, despite its intended-step filename; 602b is the successful final QR render. The incorrect initial menu/back locator was a harness issue, with no extra profile deletion. Search input clearing also required a value-independent locator.

The runner disconnected at visitor form entry around 11:24 SGT. The device stayed connected and unlocked; a fresh no-reset session recovered the same unsaved form (064). Native name clearing and duplicated accessibility radio nodes required helper corrections; intended values were verified before saving or submitting. Resident email lookup initially required NRIC, but resident emails omit NRIC; reading only the two newly arrived messages in the run's dedicated inbox allowed matching by name, arrival, email address and transaction time. These are harness observations, not product defects.

Safari snapshots of an old active tab occasionally timed out. The destination sweep reused its captured original-tab identities, reviewed each new destination, and closed only newly opened tabs. Appointment pages initially captured Loading at a short wait; fresh 30-second checks loaded the expected pages and supersede those transient captures. These are distinct from the saved-visitor entry, which remained Loading through an explicit longer wait and a repeated attempt.

Coverage boundaries:

- One synthetic resident and one Australian visitor completed SGAC initial/update lifecycles. The visitor used commercial air travel and a catalogue hotel. Successful multi-traveller submission, every transport/accommodation branch and additional Singpass account types were not exercised.
- QR generation used two members for Car, Bus, Lorry and Motorcycle, with zero/one-member rejection. Displayed maxima are Car 10, Bus/Lorry 4 and Motorcycle 2; maximum-plus-one membership enforcement was not tested.
- Convoy **15/16 form-row enforcement** was tested. The accepted convoy used two vehicles and one full-clearance permit; accepted cargo used full and partial permits with quantity 10. Neither a 15-vehicle server submission nor 100-permit submission was run. The existing Robot case's “15 veh and 100 permits” name must not be treated as proof: its current shared input file sets `VEH-NUM: 2` and `PERMIT-NUM: 2`, and this run reports direct UI evidence separately.
- Passport/permit camera entry was exercised, with the MRZ crash documented. Physical document decoding, checkpoint/clearance acceptance, printer output and saved-file persistence were not established.
- Language coverage is 36 settings/dashboard selections, not exhaustive translation review of nested forms. No broad accessibility audit, offline-recovery matrix, security assessment, upgrade/reinstall test or performance/load certification is claimed.
- External e-Service checks stop at the relevant landing, form or authentication gate. CAPTCHA/identity-protected completion and production submissions are outside these entry checks.

## Final validation

- **519 PNG/XML pairs** decoded/parsed and indexed with SHA-256 hashes; searchable [gallery](../../Output/myica-build17-regression-2026-09-16/ios/gallery.html) and [manifest](../../Output/myica-build17-regression-2026-09-16/ios/evidence-manifest.json) generated.
- Evidence validator parsed 63 input JSON files, all helper Python files and **1,533 action-log entries**; receipt/deletion, email correlation, crash and final-state checks passed. [Validation result](../../Output/myica-build17-regression-2026-09-16/ios/evidence-validation.json): **zero errors**. Capture and action counts are evidence volumes, not passed test-case counts.
- All 596 scanned text artifacts were free of the three configured credential/token values. Evidence files are owner-only (0600), and the evidence directory is 0700. Screenshot identity content remains private as described above.
- `venv/bin/python -B tools/check_fork_parity.py`: **0 errors, 0 warnings** (238 documented intentional divergences). The existing Robot dry run remains 42/0 for loading only.
- Report/task/gallery relative links and final whitespace checks passed. No app source or production locator YAML was changed; unrelated working-tree changes were preserved.
