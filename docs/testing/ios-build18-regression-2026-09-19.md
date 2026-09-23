# MyICA iPad build 18 regression — 19 September 2026

Last reviewed: 2026-09-19

**Completed — not a clean release sign-off.** The connected iPad running
**2.0.0(18), STAGING** was exercised on 19 September, approximately **16:46–19:08 SGT**,
against the [build-17 scope baseline](ios-build17-regression-2026-09-16.md).
This run does not cover Android.

There are **10 active finding groups: 2 High, 7 Medium and 1 Low** (proposed
priorities). Eight of the ten build-17 groups reproduce at least in part; saved
visitor entry and the passport-camera crash do not reproduce. Newly observed
groups are land-checkpoint QR generation failure and intermittent Customs
download prompts. CBNI forms are separately blocked by external maintenance.

## Environment and evidence

- Physical iPad Air 11-inch (M3), iPadOS 26.6.2; bundle `sg.gov.ica.mobile.app`.
- Installed metadata and About agree on **2.0.0(18), STAGING**; ICA base URL
  `https://eservices-stg.ica.gov.sg` (003, `build-baseline.json`).
- Appium 3.7.0, XCUITest, existing signed WebDriverAgent over USB, `noReset=true`.
  No app install/reset or application-code/locator changes were made. Android was offline.
- [Private evidence directory](../../Output/myica-build18-regression-2026-09-19/ios/)
  and [searchable screenshot gallery](../../Output/myica-build18-regression-2026-09-19/ios/gallery.html).
  Evidence is gitignored and local to this workspace. Numbered captures are paired
  PNG/XML artifacts, **not test-case totals**. Capture filenames describe intended
  steps; the outcomes below take precedence.
- [Regression task and handoff](../../todo/done/myica-build18-full-regression-2026-09-19.md).
- Credentials come only from the ignored `.env`; configured secrets are redacted
  from text evidence. Original screenshots can contain account identity and staging test data and
  are not publication-ready redacted artifacts.

## Core results

| Area | Observed result | Evidence |
| --- | --- | --- |
| Build / launch | Home and About load; target build/environment verified | 001–003 |
| Singpass / MyInfo | Password authentication and callback succeed. Required passport number/expiry and Malaysian ID remain blank and locked; Next cannot advance. Exit → Cancel preserves form, confirmed exit returns | 010–013 |
| Resident native profile | Required/invalid-email validation, summary, terms-gated save, restart persistence, exact name edit and delete-cancel pass | 016–034 |
| Resident submission / update | Initial No/No declaration accepted at 16:54 SGT; missing retrieval fields and wrong arrival rejected; correct retrieval and Yes/No update accepted at 16:56 | 042–061; actual settled initial receipt 047b |
| Resident acknowledgement | Both emails delivered; name, arrival, operation times and No/No → Yes/No answers correlate. Health wording still differs from form | `submission-results.json` |
| Visitor native profile | Required checks, Australian identity/contact/residence, terms-gated save and restart pass. Literal Albania test markup remains | 062–071 |
| Saved visitor entry | **B17-04 not reproduced:** saved-profile Continue loads promptly with correct identity, dates, nationality, residence and contact prefills | 072, 080–081 |
| Visitor trip / submission | Commercial air SQ218, catalogue hotel, 20 September arrival / 23 September departure reviewed; declaration Disagree/Agree works; one submission accepted at 17:04 | 090–102 |
| Visitor retrieval | Missing fields and wrong DE rejected; correct DE retrieves matching passport, birth/expiry dates, nationality and arrival; personal contact/trip fields masked | 146b, 149, 151–153 |
| Visitor mobile-only update | Changed only local mobile 412345678 → 412345679; accepted at 17:26. Email full number becomes **6412345679**, not expected **61412345679** | 155–159, 162b |
| Visitor country-code control | Explicit 61 + 412345679 produces correct full review and delivered acknowledgement **61412345679**, accepted at 17:40 | 165–167 |
| Visitor native edit / delete | Exact name change persists after restart and propagates to personal QR. Delete → Cancel retains it; Confirm removes this run's profile | 168–175, 600 |
| Passport camera | Permission pilot plus five repeat actual camera entry/dwell/return cycles complete, app state 4 throughout checked points, no new crash logs. No physical passport decoded | 181b–182, `183-mrz-trial-*`, `mrz-trials.json` |
| QR tutorial / shared store | All seven steps, Previous/Finish and both shared SGAC profiles work; own-profile designation and terms gate work | 105–119 |
| Personal / group QR | **Generation fails** for resident and independent visitor personal profiles and Car/Bus/Lorry/Motorcycle two-member groups; persists after retry/restart | 120b, 120e, 127, 134, 136, 138, 141, 145e |
| Group validation / lifecycle | Empty and one-member groups rejected. Two-member configuration and rename persist after restart; Delete → Cancel preserves, Confirm removes | 121–125, 139–145 |
| Cargo native vehicle | Required/invalid-email checks, save, plate/mobile edit, delete-cancel and restart persistence pass; web form prefills expected contact/vehicle | 301–313 |
| Cargo validation | LVG/permit selection, empty/short/duplicate permit and missing partial quantity rejected. Quantity 0 reaches review; allowed minimum unconfirmed. Only quantity **10** submitted | 314–329 |
| Cargo submission / retrieval | Initial accepted with QR and ARN **5651002088338**; matching ARN/vehicle retrieves expected fields. Empty retrieval rejected; wrong vehicle does not retrieve, but specific error text was not captured | 330–339 |
| Cargo update / acknowledgement | Mobile 81234568 → 81234569 accepted with same ARN; fresh native Manage retrieval confirms it. Both emails match plate, LVG No, full permit, partial permit/quantity 10 and operation times | 340–341, 347–348, `submission-results.json` |
| Cargo export | Direct Print gives no visible print interface on two attempts. PDF and Save QR open native share sheets; no physical output, sharing or file-save selected | 342–346 |
| Convoy validation / boundary | Empty contact/LVG/vehicles, missing second vehicle, duplicate vehicle and missing permit rejected. 15 rows allowed; attempted 16th prevented; removing blank rows preserves original two vehicles/contact | 352–361, `convoy-boundary-results.json` |
| Permit scanner | Instructions and actual camera open; Return exits. No physical permit decoded | 362–363, 366 |
| Active vehicle attempt | Existing active cargo vehicle SBC2930M rejected as **Invalid Vehicle Number**, no convoy ARN. Fresh vehicle control succeeds; build-17's explicit unfinished-journey message was not seen | 368c–371 |
| Convoy submission / amendment | Fresh SBE9157Y + SBD6389U, LVG Yes, full OO5E9900002 accepted with ARN **1928702088339**. Mobile 81234567 → 81234570 persists when retrieved using the second vehicle | 370–376 |
| Cargo / convoy cleanup | Convoy delete-cancel preserves the record; confirmed deletion acknowledged. Separate cargo remains unchanged, then its deletion is acknowledged. Both deleted ARN/vehicle pairs stay at retrieval; specific not-found error text was not captured. Native vehicle removed and absent after restart | 377–384 |
| Languages | 12 selections each for QR, SGAC and cargo: **36** settings/dashboard pairs, all restored to English. Rendering/navigation smoke only, not comprehensive linguistic approval | `500-qr-*`, `510-sgac-*`, `520-cargo-*` |

## Build-17 comparison and findings

Priorities are proposed triage priorities, not an agreed release policy. A repeated
symptom establishes the observed behavior, not whether its cause is application
code, staging services, reference data or account eligibility.

| Reference | Build-18 status | Proposed priority | Observation |
| --- | --- | --- | --- |
| B17-01 | Reproduced | High | MyInfo authenticates but required blank/locked passport fields prevent saving; returned Malaysian account also lacks a required locked Malaysian ID |
| B17-02 | Reproduced | Medium | Form asks 7 days, email asks 6; positive-health follow-up shows `X country**` |
| B17-03 | Reproduced | Low | Residence picker visibly contains `ALBANIA<h1>test</h1>` |
| B17-04 | Not reproduced | — | Saved visitor entry loads correctly without the build-17 manual-entry workaround |
| B17-05 | Partly reproduced; one improvement | Medium | QR months and cargo language-settings title remain English; French cargo vehicle-profile heading is now correctly French, not Japanese |
| B17-06 | Reproduced | Medium | Mobile-only update email loses the `1` from country code 61; explicit code re-entry workaround again verified |
| B17-07 | Not reproduced | — | Six actual camera sessions complete; five repeat trials each dwell 15 seconds; historical crash-log list unchanged |
| B17-08 | Reproduced | Medium | Cargo Print produces no visible interface; PDF/Save QR share sheets work |
| B17-09 | Reproduced | Medium | Trusted Traveller, Frequent Traveller eligibility and Loss of Foreign Passport reporting still open missing-page responses |
| B17-10 | Reproduced | Medium | Search shows raw title/duration translation keys; matching and tested destination work |
| B18-11 | Newly observed versus build 17 | High | Land-checkpoint personal and all four group-vehicle QR variants fail to generate |
| B18-12 | Newly observed, intermittent | Medium | Customs catalogue links sometimes open a download prompt instead of the information page; observed from both common and visitor catalogues |

### B18-11 — Land-checkpoint QR generation fails

Home → QR Code at Land Checkpoints → designate the saved resident as own profile,
accept terms/save, confirm and open personal QR. The result is **Unable to Display
QR Code**, with an error-generating/check-internet message. Direct dashboard retry
and retry after restart produce the same result (120b, 120e, 141).

A mixed resident/visitor group fails for **Car, Bus, Lorry and Motorcycle** (127,
134, 136, 138). After removing the resident fixture, the independent visitor-only
personal profile also fails (145e). Group configuration persists, but a usable QR
does not render. Build 17 rendered these variants successfully.

Expected: a usable QR or actionable service-specific recovery guidance. Both
profile types and all four vehicle configurations are affected in this run. Cargo
receipt QR renders successfully (330); that is a separate module. Successful SGAC
and cargo network operations do not establish that the land-QR service is healthy.
Application-versus-service root cause remains unisolated.

### Repeated data/content issues

- **B17-01:** populated callback, required-field rejection and locked-field attempt
  are recorded at 010–012. Confirm account eligibility/source data and the intended
  supported way to complete missing required fields; no MyInfo profile was saved.
- **B17-02:** 037 visibly contains `X country**`; 038/043 ask past 7 days. Matching
  initial resident and visitor emails ask past 6 days. Resident update email uses
  explicit country wording and confirms Yes/No. This is an answered-versus-
  acknowledged wording mismatch, not proof that stored answers were lost.
- **B17-03:** malformed Albania label visually confirmed at 067. No script
  execution was established.
- **B17-06:** same visitor DE/passport/arrival/hotel correlate the initial, mobile-
  only and explicit-country-code control emails. Actual full numbers are
  61412345678 → **6412345679** → 61412345679. Distinguishing persisted-country-code
  corruption from acknowledgement formatting requires backend inspection.
- **B17-05:** translated QR expiry labels still contain `September`. Cargo settings
  still say `Cargo Submission Language` under non-English selections. However,
  French cargo now visibly says **Sélectionnez les profils de véhicules**
  (`520-cargo-08-dashboard`), replacing build-17's Japanese heading.
- **B17-08:** normal Print and coordinate retry both retain the receipt (342–343),
  while PDF and Save QR open native share sheets (344, 346). Expected: print UI or
  actionable feedback. Printer availability/physical output were not tested.
- **B17-10:** Other e-Services → Search → `Report` returns the expected two rows,
  but visibly shows `REPORT_LOST_PASSPORT`, `REPORT_LOST_IDENTITY_CARD`,
  `MINUTES_5_TO_10` and `MINUTES_15_TO_20` (487, screenshot confirmed). The passport
  row opens the correct Online Report landing (488); `b18noresultxyz` returns zero
  rows (489). Expected: readable titles/time estimates as in category menus.
- **B17-09:** Home → Other e-Services → Others → SG–US Trusted Traveller (230),
  and Home → Foreign Visitor → Visitor e-Services → Frequent Traveller Programme
  → Check Eligibility and Procedure (709) or Loss of Foreign Passport → Report a
  Loss (710), all reach **“We are sorry, the page requested cannot be found.”**
  Expected: working service/information destinations. Verify configured URLs and
  service migrations; HTTP status and root cause were not inspected.

### Observations needing a rule/content decision

Partial-clearance quantity **0** can be saved and reaches review. The minimum and
backend acceptance are unverified; no zero-quantity submission was made. Cargo
continues to show repeated test broadcast content. Neither observation is counted
as a proven new functional defect. The convoy update receipt says **Submission
received** under **Manage Convoy Submission**, despite the amended value being
confirmed by independent retrieval; do not quote it as “Submission updated.”

## Navigation, settings and languages

Current-run sweeps and individual destination review are complete. Raw sweep
status “Captured” is not a pass assertion. No production application, payment,
appointment, cash declaration, feedback or vulnerability report is submitted.

| Area | Current verified result | Evidence |
| --- | --- | --- |
| Common e-Service catalogue | All **32** entries exercised: **31 expected destinations** (Customs succeeds on fresh retry) and one missing destination (Trusted Traveller) | 201–231, 403–404 and `404-customs-catalogue-retry` |
| Appointments | Booking homepage and check-in form both load in the first sweep, on staging | 226–227 |
| Help | Contact Us, Feedback, FAQ, Report Vulnerability and Troubleshooting all open | 430, 434–438 |
| About | About Us, ICA Website, Privacy Statement and Terms of Use open | 440–443 |
| Other Home links | IC favourite, ScamShield banner and translation-feedback footer reach relevant destinations; no feedback sent | 446, 469–470, 497–498 |
| Visitor catalogue | All 15 parent routes and **29 child links** exercised: **27 expected child destinations / 2 missing pages**. Direct Customs works on retry after the download-prompt anomaly | 465, 471–485, 700–728, `485-visitor-customs-retry` |
| Home hubs | All 8 citizen/resident and 9 visitor shortcuts exercised: **13 expected entries, 4 CBNI maintenance-blocked entries** | 401–402, 451–468 and CBNI `-settled` retries |
| Settings | Language entry has 12 choices; tutorial off persists across restart, original on restored | 431–433, 439, 444–445 |
| Favourites | Seventh selection rejected; Cancel preserves six; replacement with Customs saves and persists; exact original six IDs/order restored after another restart | 490–496, `favourites-results.json` |
| Search | Report yields two rows; passport result opens correct entry; nonsense query yields zero. Visible labels/durations still expose keys | 486–489 |

The two native Home hubs still contain eight citizen/resident and nine visitor
shortcuts (401–402). The MyICA shortcut reaches the production Singpass gate; no
authentication is performed there. The supplied staging account was used only for
the requested MyInfo flow. Public ICA catalogue pages generally use production
domains; the appointment entries use `eservices-stg.ica.gov.sg`.

Native inventory reconciliation confirms **10 common categories**, 31 child
entries across nine lists plus direct Customs, and **15 visitor categories**, 29
children across 14 lists plus direct Customs. No extra/uncovered child IDs were
found. See [per-destination review](../../Output/myica-build18-regression-2026-09-19/ios/navigation-reviewed.json),
[common counts](../../Output/myica-build18-regression-2026-09-19/ios/eservices-category-counts.json)
and [visitor child IDs](../../Output/myica-build18-regression-2026-09-19/ios/visitor-category-counts.json).
The navigation verifier covers **111 captured attempts**, including retries and
native menus, with zero missing planned entries, unreviewed captures or evidence
assertion errors. This is not a count of unique services or all-pass tests.

**External dependency limitation — CBNI:** Submit and Retrieve/Void Cash shortcuts
from both Home hubs initially show Loading. Fresh attempts with **30-second waits**
reach `eservices5-uat.police.gov.sg/e727/CBNIForm` and `/e727/voidreport`, which
explicitly state **“The e-service is undergoing system maintenance and not
available.”** All four routes confirm this (457/458/467/468 `-hub-entry-settled`).
Unlike build 17, the actual forms could not be verified in this run. This is
recorded separately from application findings; retry entry-form coverage after the
police UAT service returns. No declaration was submitted or voided.

**B18-12 — intermittent Customs destination/download prompt:** both common
catalogue → Customs (404) and visitor catalogue → Customs (485) open Safari's
“Do you want to download ‘customs-sg-web-application’?” prompt instead of rendering
the page; both screenshots visually confirm it. No download is accepted. A fresh
common-catalogue attempt reaches the expected Customs@SG page
(`404-customs-catalogue-retry`), as did both Home hub controls (456, 466).
The fresh visitor-catalogue retry also works (`485-visitor-customs-retry`). Across
six Customs opens in this run, **two show the prompt and four load the page**;
this is a small observed sample, not a failure-rate estimate. Expected: the relevant Customs information page,
not a download confirmation. This is an intermittent user-visible destination
issue, not proof that build-18 application code caused it. Compare configured URLs,
redirects and website response headers; none were modified in this regression.

## Transaction correlation, cleanup and validation

All **nine accepted operations** have one correlated delivered acknowledgement.
Matching uses operation time, current reference/identity and changed values, not
inbox ordering. Some messages were observed minutes after receipt UI; no operation
was resubmitted merely to obtain email. Exact message IDs and artifact paths are
in [`submission-results.json`](../../Output/myica-build18-regression-2026-09-19/ios/submission-results.json).

| Operation | Acknowledged time (SGT, 19 September) | Correlation |
| --- | --- | --- |
| Resident initial / health update | 16:54 / 16:56 | Same name, 20 September arrival; No/No → Yes/No |
| Visitor initial | 17:04 | DE **X2352A8729**, Australian passport, 20 September arrival, catalogue hotel, full mobile 61412345678 |
| Visitor mobile-only update | 17:26 | Same identity/trip; **mismatched full mobile 6412345679** |
| Visitor explicit-code control | 17:40 | Same identity/trip; correct full mobile **61412345679** |
| Cargo initial / update | 17:46:04 / 17:50:00 | ARN **5651002088338**, SBC2930M, LVG No, full OO5E9900000 + partial OO5E9900001 / quantity 10; mobile 81234568 → 81234569 |
| Convoy initial / update | 18:06:14 / 18:07:38 | ARN **1928702088339**, both fresh vehicles, LVG Yes, full OO5E9900002; mobile 81234567 → 81234570 |

Receipt/email verifier: **9/9 correlated**, one known mobile-value mismatch, zero
artifact errors. It deliberately does not classify that mismatch as a pass.

Run-owned resident/visitor native profiles, group QR and cargo vehicle have been
removed. Both run-owned cargo/convoy server deletions were acknowledged. Submitted
resident and visitor SGAC records remain in staging; deleting native profiles is
not server deletion. Final restart checks confirm empty resident, visitor, shared
QR and native cargo stores, plus no remaining run-owned personal/group QR fixture
(606–610). English, the original tutorial-on setting and the original six
favourites in exact order are restored (611–613). MyICA was left at Home in the
foreground. Camera permission granted for this run remains allowed; app data and
permissions were not reset.

All link-test Safari tabs are closed, and the exact pre-link-sweep tab UUID set
is preserved (`navigation-tabs-final.json`). That baseline was collected after
Singpass, not before the entire regression. The final crash-log listing still
contains only the same five historical 16 September entries (`crashes-final.json`).

The regression Appium session is closed (subsequent request returns invalid
session ID). Its WDA host runner and port-8100 USB forwarder are stopped. Appium
3.7.0 remains ready on port 4723; start WDA/forwarding and create a new session for
future device work. See `runtime-cleanup.json` for the observed cleanup checks.

Evidence validation checks **521 paired PNG/XML captures**, image decoding,
XML/JSON/JSONL parsing, helper syntax, result assertions, restoration, all nine
acknowledgements and complete per-destination review, with **zero errors**. The
gallery and SHA-256 manifest are generated from current-run captures. Configured
credentials are checked against text artifacts and handoff documents; original
screenshots remain private and are not asserted to be anonymized.
Handoff validation also passes **54 document links and 1,564 gallery links**,
with zero whitespace or fork-parity errors (`handoff-validation.json`).

Harness recovery is distinguished from product outcomes: the resident update
receipt says “Submission updated”; settled initial resident and mobile-update
visitor receipts are 047b and 162b. The native cargo keypad was dismissed before
verifying edited values. Early MRZ coordinate attempts stayed on the tutorial and
are excluded from the six camera sessions. Convoy captures 367/368 remained behind
the scanner modal; actual review was subsequently verified at 368c, before any
submission. Prior helpers/scenarios were adapted, but no previous result artifacts
were copied as build-18 evidence.

## Coverage boundaries

This is direct Appium UI regression coverage, not a live Robot-suite pass or
certification of all SGAC2 locators. The separate SGAC2 iOS Robot **dry run** loads
42 tests successfully; it does not execute product assertions. Fork parity reports
0 errors / 0 warnings. Unrelated working-tree changes are preserved.

Not exercised: Android/iPhone/other OS versions, physical passport or permit
decoding, real checkpoint clearance, production service completion, printer/file-
save persistence, every nationality/travel mode/multi-traveller combination,
translation accuracy of all screens, offline/poor-network recovery, security,
accessibility certification, load or prolonged camera stress. Six crash-free
camera sessions and one working saved-visitor route do not establish universal
fixes for the two build-17 failures.

Current-run blockers also prevent verification of MyInfo profile save, usable
land-checkpoint QR rendering/presentation and the downstream foreign-visitor QR
reminder. CBNI form coverage is maintenance-blocked as described above. These
blocked paths are not counted as successful flows.
