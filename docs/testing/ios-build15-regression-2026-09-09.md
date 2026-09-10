# iOS build 15 module regression — 9 September 2026

Last reviewed: 2026-09-09

Status: Cargo/convoy submission, retrieval and update verified with the Data helper UAT
permits. Visitor retrieval/update still needs a DE reference; full sign-off remains open.
A Robot dry run is not a
device pass, and reaching review is not a successful server submission.

## Result overview

| Module | Observed result | Remaining end-to-end boundary |
| --- | --- | --- |
| SGAC resident | CRUD, validation and prefill exercised; submitted record retrieved; health update acknowledged | Initial receipt navigation issue; email delivery; authenticated MyInfo |
| SGAC foreigner | CRUD, validation and prefill exercised; commercial-flight/transit submission acknowledged with tracking ID | DE number needed for retrieval/update; email delivery; multi-traveller completion |
| Cargo / convoy | Both submitted with ARNs/QRs; retrieval, updates and fresh-retrieval persistence passed; duplicate active vehicle rejected | Receipt link opens production Safari; email/export/scanner acceptance; remaining boundary cases |
| QR | Individual and two-person Motorcycle codes rendered; group edit/delete, validation and persistence passed locally | Physical decoding/checkpoint acceptance; other vehicle maximum enforcement |

## Findings for triage

| ID | Observation | Evidence / disposition |
| --- | --- | --- |
| IOS-01 | Partial cargo quantity `0` is accepted and reaches review | [Review screenshot](../../Output/ios-regression-2026-09-09/122-cargo-review-permits.png). Confirm the minimum allowed quantity; backend acceptance is untested. |
| IOS-02 | English foreigner form showed raw group-prompt translation keys | [Screenshot](../../Output/ios-regression-2026-09-09/230-visitor-health-positive-followup.png). Readable prompts on the later fresh load (305–309); not consistently reproducible. |
| IOS-03 | Cargo web homepage Important Note text clips at portrait viewport edges | [Stable screenshot](../../Output/ios-regression-2026-09-09/196-cargo-cancel-confirm.png). Visible layout defect. |
| IOS-04 | Minor copy/localization observations: `vechicle`, repeated test broadcast, English cargo-language header in Chinese, English expiry month in Malay, `X country**` health copy | Captures 095, 183, 201, 230. Confirm intended UAT content and date-localization rules before classifying all as product defects. |
| IOS-05 | Resident initial Submit returned to review without an observed acknowledgement/error, although the record persisted | Loading state (263), unchanged review (264–265), successful retrieval (268). A subsequent update acknowledged normally (275). Needs receipt/navigation investigation, not a claim that the submission failed. |
| IOS-06 | Staging cargo receipt's Manage Cargo Submission link opens Safari at production `eservices.ica.gov.sg` | [External host screenshot](../../Output/ios-regression-2026-09-09/335-cargo-receipt-link-external-host.png). No test data entered there; only the newly opened tab was closed. Native staging dashboard retrieval works (337). Review environment routing. |

No application fixes were implemented during this test run.

## Environment and evidence

- Physical iPad Air 11-inch (M3), iOS 26.6.1; UDID `00008122-000A08312186801C`.
- Installed TestFlight app: MyICA Mobile `sg.gov.ica.mobile.app`, version 2.0.0, build 15.
- Existing Appium 3.1.2 server on `http://127.0.0.1:4723`.
- WDA started with `xcodebuild test` using the existing signed
  `~/.appium/node_modules/appium-xcuitest-driver/node_modules/appium-webdriveragent/WebDriverAgent.xcodeproj`,
  scheme `WebDriverAgentRunner`, destination `id=00008122-000A08312186801C`.
- WDA is forwarded over USB with `iproxy -u 00008122-000A08312186801C 8100:8100`;
  Appium attaches using `appium:webDriverAgentUrl=http://127.0.0.1:8100`, `noReset=true`.
- [Local evidence](../../Output/ios-regression-2026-09-09/) includes numbered PNG/XML
  captures, `wda.log`, `fixtures.json`, `session.json` and the session-driving helper.
- [Task and continuation notes](../../todo/blocked/ios-module-regression-2026-09-09.md).
- Continuation recovered an expired/broken WDA connection using the same signed project;
  no app reinstall/reset. Current WDA log: `wda-submission-reconnect.log`.
  Current Appium session: `e6b0eeb2-af13-4a22-9dab-60d4965cb386`.

## Resident SGAC

Verified on device:

- Empty identity fields block Next and display required-field validation (007).
- Nationality search finds and selects Singaporean (009–011).
- Build 15 contact fields require country/region code, mobile number and email (014–015).
  This supersedes older iOS notes describing email-only contact.
- Malformed mobile/email values are rejected. Valid synthetic details reach the summary;
  name, date of birth, nationality, NRIC, passport, expiry, code, mobile and email match (024).
- Save is absent until the terms checkbox is checked (024–025). Profile creation succeeds (026).
- Continue without selection shows `Please select a minimum of 1 group member(s)` (028).
- Selecting the newly created profile opens Residents Submission and prefills name, NRIC,
  date of birth and email (030). The earlier **Profile update required** loop did not reproduce.
- Arrival 9 September 2026 and two No health answers reach review with matching values
  (031–035). The second health question appears after answering the first.
- Edit masks NRIC/passport, permits an email change, requires terms acceptance again,
  and confirms the update (038–041). The profile remains after restarting MyICA (042).

The initial device-side pass stopped at review. In the approved continuation, the
recreated resident record was submitted with arrival 9 September and two No health
answers (262–265). Submit displayed a loading state, then returned to the same review
without an observed receipt or error. A subsequent NRIC/date retrieval returned the
matching resident record (268–269), confirming persistence; no duplicate was submitted.
The health answer was then changed to Yes, with the follow-up No (273–274). Update
returned **Submission updated**, transaction `09/09/2026 03:22 PM` Singapore time
(275–276). Email delivery was not checked; the page's delivery statement is not proof
of inbox receipt. Retrieved date of birth, email and health answers are masked.

Update Residents Submission opens and rejects empty NRIC/arrival and malformed NRIC
(204–206). MRZ tutorial opens; granting the iOS camera prompt opens the scanner in
landscape, and its back button restores the portrait tutorial (208–213). No passport
was scanned. Singpass handoff opens Safari at `login.stg-id.singpass.gov.sg` showing
`UAT testing to retrieve MyInfo` (214). Authentication was not attempted. Only the
newly opened tab was closed. The leave-page dialog supports Cancel and OK (215–217).

The SGAC picker exposes 12 languages; Tamil settings/dashboard rendered and English
was restored (218–220). Resident delete cancellation retained the test record, and
Confirm removed it (221–223).

## Foreigner SGAC

Verified required identity/contact fields, gender options, searchable country of birth,
nationality and residence (043–053). The creation-method screen offers manual entry and
passport scanning, with no Singpass button (044). `TEST IOS VISITOR` saved successfully
(054), and the web form correctly prefilled all identity, residence and contact values
(057–058). The earlier profile-update loop did not reproduce for this profile either.

The traveller step accepted a 9 September arrival, 12 September departure, Sydney embarkation,
`Same as Last City`, Business purpose, No previous passport name and two No health answers.
The visit step validated empty fields and exposed Air/Land/Sea modes plus Hotel/Residential/
Transit/Day Trip accommodation branches (074–084). These captures verify branch rendering,
not completion of every transport/accommodation subtype.

A commercial-flight scenario with Aero Dili `8G212` and Transit accommodation reached review;
identity, trip, contact, health, transport and accommodation matched (087–090).
Approved continuation recreated this fixture with the edited email and verified the full
review again (315–319). Final Submit returned **Submission received** and a successful
submission message (320–321), transaction `09/09/2026 03:41 PM` Singapore time.
The displayed tracking ID is `TID:cbb8fa8cda5b4b051ec99e09554dcf4c`.
No DE number appeared on this acknowledgement. The update service requires a DE number
(324), whereas the native profile menu only offers View / Edit and Delete (326).
Successful retrieval/update remains blocked on a valid DE reference; the tracking ID was
not substituted for it. The synthetic `example.com` inbox is not accessible, so email
delivery was not verified. No duplicate visitor submission was sent.

The visitor email edit reached the native summary, saved successfully and the profile remained
after restarting MyICA (091–094).

Filtered Holiday and Singapore Airlines selection did not commit reliably through native
automation; selecting fully visible unfiltered Business and Aero Dili options succeeded.
Native accessibility reported dropdown entries as visible even when the screenshot showed
them clipped by the list/keyboard. The filtered-selection behavior remains an automation
limitation requiring a separate manual check, not a confirmed application defect.

Visitor update/retrieval opens and validates all empty required identity/reference
fields (224–225). A fresh submission prefills the edited email (226). Previous-name
Yes adds a required name input; positive-health answers display/select the follow-up
question (228–231). These positive branches were not completed through review or
submitted. Add Traveller validates the incomplete first traveller and returns to the
missing arrival field (232); successful multi-traveller submission is untested.

**Visible content issue:** the English foreigner form displays untranslated keys
`TRAVELLING_AS_A_GROUP_QUERY` and `CAN_SUBMIT_MULTIPLE_TRAVELLERS_TOGETHER` above Add
Traveller (230–231). The health follow-up also shows placeholder-like `X country**`
copy (230); confirm whether that is deliberate UAT test configuration. These are
visible screenshot contents, not merely accessibility labels.
On the later fresh load, readable English group prompts and the normal negative-health
follow-up appeared (305–309). This does not reproduce the earlier raw-key/positive-branch
state; preserve both observations for triage.

Foreigner MRZ scanner entry opens in landscape and back navigation restores portrait
(233–234); extraction was not tested. Delete cancellation retained the synthetic
visitor, and Confirm removed it (239–241). Both SGAC lists remained empty after restart
(242–243), and QR reflected the shared-profile removal (245–246).

## Cargo and convoy

Vehicle/email required-field validation and malformed-email rejection passed;
mobile is optional (097–099). Vehicle `SBA1234G` saved with valid email and mobile (100),
and Continue without selection showed the minimum-one-vehicle validation (102). The cargo
web form prefilled all three saved values (103). Missing low-value-goods answer and missing
clearance type blocked progress (104–106). Short permit numbers and duplicates are
rejected (109, 111); full permit `IG2BB990021` saved. A partial permit cannot be added
with empty quantity, but **quantity 0 is accepted and reaches review** (120–122).
Confirm the expected lower bound with the product rules; this is a validation concern,
not evidence that the backend accepts zero. Editing that permit to quantity 10 succeeded
and review reflected both permits, contact details, vehicle and LVG No (126–128).
The initial device-side pass stopped at review. In the approved continuation, Final
Submit with full `IG2BB990021` and partial `IG2BB990022`, quantity 10, returned
`Please check that the permit number is correct and valid.` Both permits showed
`Invalid Permit Number` (284). No ARN was issued for that attempt. This confirms
rejection of those text-file fixtures, not of the separate UAT helper fixtures below.

Convoy required-field validation and duplicate-vehicle rejection passed (131, 133).
Two distinct vehicles, LVG Yes and one full-clearance permit reached review, which
matched email, mobile, both vehicle numbers and the permit (135–136). The form says
up to 15 vehicles; the 15/16 boundary has not been exercised. Approved continuation
submitted the same two-vehicle scenario with `IG2BB990023`; the backend rejected
the permit with the same inline validation (288–289), so that attempt issued no ARN.

### Helper-based UAT continuation

The user identified the intended valid UAT source: `generateListofPermit()` in
`Data/test_data/manual_field_random.py`, also used by `tests/ios/cargo/convoy.robot`.
Calling `generateListofPermit(3)` returns `OO5E9900000`, `OO5E9900001`, `OO5E9900002`
(two letter O characters). This is distinct from `readfromfile()` / `Cargo_Test_Data.txt`
and the earlier rejected `IG2BB...` values. The previous assessment missed that distinction.
See [test-data guidance](test-data.md) and local `helper-permits.json` for provenance.

- Cargo: full `OO5E9900000`, partial `OO5E9900001`, quantity 10, LVG No and vehicle
  `SBA1234G` returned **Submission received**, ARN `3514402088128`, and a rendered
  QR (332–333). Both permits and quantity matched the receipt. Native dashboard
  retrieval returned the matching record (337–338). Changing the server email to
  `ios.cargo.server.updated@example.com` returned **Submission updated**, with the
  same ARN (340). Fresh retrieval confirmed the changed email (341).
  Pairing that cargo ARN with the unrelated test convoy vehicle `SCC2817X` was
  rejected with `Please check that the application details you have entered are correct.`
  No record details were returned for that mismatch (356–357).
- Convoy: using `SBA1234G` initially returned an unfinished-journey error, correctly
  identifying the vehicle already used by the accepted cargo record (345–346).
  Preserved that record and generated separate checksum-valid plates with
  `_ProfileFactory(seed=20260909, reference_date="2026-09-09").generate_list_of_vehno(2)`:
  `SCC2817X` and `SAJ0397R`. With LVG Yes and `OO5E9900002`, submission returned
  ARN `3416002088129` and a rendered QR (349–350). Retrieval by the first vehicle
  succeeded (351–352); changing mobile to `81234568` returned an acknowledgement
  with the same ARN (354). Fresh retrieval by the second vehicle confirmed the new
  mobile and both vehicles (355). The update acknowledgement says **Submission received**,
  whereas cargo's says **Submission updated**; wording differs, but persistence passed.

The cargo receipt's **Manage Cargo Submission** link opened Safari at the production
host (334–335). No fields were populated and no writes were made there. Closed only
that new tab and used the native dashboard's staging retrieval route for the successful
checks above. This is an environment-routing finding, not a reason to submit UAT data
to production. PDF/Print/Save QR Code controls were displayed, but their export operations
and physical decoding/clearance acceptance were not tested. Email delivery was not verified.

Cargo permit Scan opened its tutorial, then the in-page camera area with the iOS
camera-use indicator. The captured preview was black; no barcode extraction is
claimed. Return closed the scanner and retained the permit form (290–292).

The dashboard repeats a common test announcement four times and spells vehicle as `vechicle`
in its empty-state guidance (095).

Vehicle email editing and saving with optional mobile empty passed (188–189). Restarted
app autofill retained the updated email and blank mobile (194). Manage Cargo Submission
opened; empty ARN/vehicle fields were rejected (191–192). Successful retrieval/update
was verified in the helper-based continuation above. Cancel from the unsubmitted cargo form
returns to the cargo web homepage (196). Its Important Note content overflows/clips at
the portrait viewport edges (195–196), a visible layout issue.

Vehicle delete cancellation retained the test record; Confirm removed it (197–199).
Cargo exposes 12 languages; Simplified Chinese settings/dashboard rendered and English
was restored (200–202). The settings header stays `Cargo Submission Language` in Chinese.

## QR

All seven tutorial pages navigated and Finish returned to the dashboard (138–145).
QR's profile manager contains both synthetic SGAC profiles (146). Editing the resident
to `Save this as my own profile` preserved its values and masked identity numbers;
the summary and terms gate passed (148–152). The individual QR rendered with the
passport reminder and a validity date of 31 August 2027 (152).

Zero/one selected member blocks group progress (155–157). Vehicle options display:

| Type | Minimum | Maximum displayed |
| --- | ---: | ---: |
| Car | 2 | 10 |
| Bus | 2 | 4 |
| Lorry | 2 | 4 |
| Motorcycle | 2 | 2 |

These are displayed limits, not maximum-plus-one enforcement tests. Changing vehicle
type clears member selection. Two profiles reached Motorcycle review, saved group
`IOS REGRESSION`, triggered the foreign-visitor SGAC reminder, and rendered a group QR
with both names and the passport reminder (165–170). The reminder was dismissed for
this local synthetic test; it is not evidence of an SGAC submission. Individual and
group records persisted after app restart (173). Renaming the group updated its review
and generated-code title (176–177). Delete cancellation retained it; Confirm removed
only the synthetic group while retaining the individual profile (178–180).

Physical scanner decoding/checkpoint acceptance has not been tested.

QR exposes 12 language options. Malay language settings and dashboard rendered, then
English was restored (181–183). The expiry month remains `August` in Malay; record as
a localization observation pending the date-format specification.

## Automation observations

The five existing iOS SGAC/cargo Robot cases pass a dry run, but their live keywords retain
SGAC1 landing/form assumptions. There is no iOS QR suite. This regression therefore drives
the current UI directly and does not claim that those Robot suites pass on build 15.

RN wrapper inputs can accept Appium sendKeys into a previously focused field. Coordinate
focus plus session-level keyboard input and visible keyboard controls are more reliable.
Some first footer taps dismiss input focus; navigation requires a second tap. Verify values
on screenshots and summaries because native wrapper accessibility labels may omit values.
These input-driver observations are not classified as application defects.

Continuation workaround: a W3C touch swipe from `(600,690)` to `(600,250)` over 700 ms
moved a blocked dropdown above the keyboard. Selecting Sydney before hiding the keyboard
then committed correctly (305–306); the same positioning approach enabled Aero Dili
(313–314). A visible accessibility node alone did not establish an unobstructed tap target.

The in-app submission webview is accessible through the native tree. Appium context discovery
returned only `NATIVE_APP`; its DOM was not inspected. During approved continuation,
read-only device WebKit origin/cache metadata confirmed `eservices-stg.ica.gov.sg`,
including SGAC and cargo submission paths. See
[staging verification](../../Output/ios-regression-2026-09-09/staging-verification.md).

## Remaining boundaries

- The user approved synthetic staging submissions and the submission host was confirmed
  before writes. Resident submit/retrieval/update and visitor submission succeeded as
  described above; initial resident receipt navigation remains unresolved.
- Cargo/convoy helper fixtures now passed receipt/retrieval/update. Their UAT server records
  remain active; reuse of the same vehicle in another journey is rejected. Server deletion,
  PDF/Print/Save QR Code export and email delivery were not tested. Quantity-zero backend
  acceptance remains untested; successful partial-clearance submission used quantity 10.
- Visitor retrieval/update needs a DE reference associated with a suitable test submission.
  Email delivery was not checked for either SGAC scenario. Successful MyInfo authentication
  requires a suitable test account. No credentials were entered.
- Passport MRZ extraction, cargo barcode extraction and physical QR/checkpoint acceptance
  require suitable fixtures or equipment. Scanner entry/exit was exercised, not extraction.
- Transport/accommodation variants were inspected, but only the commercial-flight/transit
  visitor scenario was submitted. Resident positive-health update was acknowledged; visitor
  positive-health/prior-name and multi-traveller branches were not completed end-to-end.
  Maximum-plus-one profile/member/vehicle/permit limits,
  expiry-date edge cases, duplicate SGAC profiles and offline recovery remain outside the
  executed coverage; this report is not an exhaustive combinations or release certification.
- Filtered web dropdown selection remains a native-automation limitation, not a confirmed
  application defect. No iOS test automation migration was implemented.

## Cleanup and continuation

At the end of the initial device-side pass, only records created by this run were deleted: `TEST IOS RESIDENT`, `TEST IOS VISITOR`,
vehicle `SBA1234G`, and group `IOS REGRESSION` (renamed `IOS REGRESSION EDIT`). Their
synthetic inputs remain in local fixtures/evidence for recreation; app deletion has no
in-app undo established here. Empty stores persisted after restart (242–246).
Approved continuation recreated and **retained** the two synthetic SGAC profiles and
vehicle `SBA1234G` for follow-up. Their known inputs and submission outcomes are in
`fixtures.json` and `submission-results.json`. The QR group was not recreated.
The accepted SGAC, cargo and convoy server records were not deleted; the resident server health answer
was updated to Yes with follow-up No. Native profile deletion would not establish server
record deletion. Cargo ARN `3514402088128` retains server email
`ios.cargo.server.updated@example.com`; convoy ARN `3416002088129` retains mobile
`81234568` and vehicles `SCC2817X`/`SAJ0397R`. These convoy vehicles exist in the
server submission, not as newly created native vehicle profiles.

English is restored for SGAC, cargo and QR. MyICA is left at Home (358). Camera permission
was granted to MyICA for scanner testing and remains allowed. Existing Safari tabs were
preserved; only the new Singpass tab and the later cargo-receipt link tab were closed.
No application reinstall or device reset
was performed. WDA, USB forwarding and the Appium session are left available for continuation;
the session has a 3600-second idle timeout.

Mnemosyne contains the checkpoint and the user's preference to continue on Sol if a model
limit is reached. No tool exposes an in-place model switch. No model switch occurred;
resume on Sol from the saved checkpoint if the user selects it.

## Repository and evidence validation

- `APP_FORK=sgac2 venv/bin/python -B -m robot --dryrun --outputdir Output/ios-regression-2026-09-09/robot-dryrun tests/ios/sgac tests/ios/cargo` — 5/5 dry-run passes, not live-suite passes.
- `venv/bin/python -B tools/check_fork_parity.py` — 0 errors, 0 warnings.
- `git diff --check` — passed. Unrelated pre-existing changes were preserved.
- `venv/bin/python -B Output/ios-regression-2026-09-09/validate_evidence.py` — 358 screenshot/XML pairs, 0 integrity errors; JSON and helper syntax passed.
- Final WDA `/status` returned `ready: true`; Appium session `/timeouts` responded. WDA version 11.4.1; session metadata is retained in `session.json`.
