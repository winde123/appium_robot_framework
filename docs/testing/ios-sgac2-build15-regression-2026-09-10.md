# SGAC2.0 iOS build 15 regression continuation — 10 September 2026

Last reviewed: 2026-09-11

[Illustrated Word issue review](../exported/myica-ios-sgac2-build15-possible-issues-2026-09-10.docx)
compiled 11 September: eight findings from the current and earlier build-15 runs,
with reproduction steps, verification status and embedded screenshots.

The requested continuation ran on verified **SGAC2.0 2.0.0(15), STAGING**.
Resident/foreigner retrieval, an approved visitor update, cargo/convoy retrieval
and prior-update persistence, and individual/mixed QR flows were exercised.
Full regression sign-off remains open: no visitor update email was observed by
the last inbox check on 10 September at 23:39 SGT,
masked retrieval cannot independently confirm the changed health answer, and the
coverage boundaries below remain. No live Robot-suite pass is claimed.

## Results

| Area | Result in this continuation | Evidence |
| --- | --- | --- |
| Build baseline | Package metadata and About both show 2.0.0(15), STAGING; real iPad on iOS 26.6.1 | `build-baseline.json`, 004 |
| Resident | Empty NRIC/arrival rejected; existing synthetic record retrieved with matching name, NRIC and arrival | 006–010 |
| Foreigner retrieval | Empty DE/identity fields rejected; existing SGAC2 DE record retrieved with matching passport, DOB, nationality, expiry and arrival | 013–028, 041–042, 114–116 |
| Foreigner update | Exactly one approved No/No health update sent; **Submission updated**, 10/09/2026 11:13 PM Singapore Time | 043–048 |
| Visitor email | Approved inbox still has the same five messages as the pre-update baseline; no new acknowledgement observed | `visitor-health-update-mail-baseline.json`, `visitor-email-final-status.json` |
| Cargo | Existing ARN retrieved; prior updated email, vehicle, LVG, full/partial permits and quantity persist through review | 050–055 |
| Convoy | Existing ARN retrieved by its second vehicle; both vehicles, prior updated mobile, LVG and permit persist | 056–058 |
| Negative cargo retrieval | Correct synthetic ARN paired with unrelated synthetic vehicle rejected | 059 |
| QR profiles | Resident and Australian foreigner created with matching identity/contact summaries; terms gate controls Save | 062–084 |
| Mixed group | Car, Motorcycle, Bus and Lorry QR codes rendered with both profiles | 089–103 |
| QR validation | Zero/one member rejected; vehicle change clears selection and requires two members again | 087–088, 096–097 |
| QR persistence | Rename survives restart with 2 Pax; individual QR renders; Delete → Cancel retains group; saved group regenerates | 104–112 |

Evidence is in `Output/ios-sgac2-build15-regression-2026-09-10/`. References above
are capture-number prefixes of paired PNG/XML files, not formal test-case counts.
[Task and resume state](../../todo/blocked/ios-module-regression-2026-09-09.md).

## Build and isolation

- Physical iPad Air 11-inch (M3), iOS 26.6.1, UDID `00008122-000A08312186801C`.
- Installed TestFlight bundle `sg.gov.ica.mobile.app`; metadata identifies
  `Environment=STAGING` and `https://eservices-stg.ica.gov.sg`.
- Existing signed WebDriverAgent restarted with `xcodebuild test-without-building`;
  Appium uses USB localhost:8100 and `noReset=true`. No MyICA installation/reset.
- Resident, foreigner, cargo vehicle and QR profile stores were empty at baseline
  (005, 012, 049, 062). Existing accepted server records were preserved.
- The [earlier same-day 1.19.1(1) run](ios-1-19-1-regression-2026-09-10.md) is
  SGAC1.0 evidence and contributes no SGAC2.0 passes or defects. The separate
  [9 September build-15 run](ios-build15-regression-2026-09-09.md) retains its
  original build and coverage scope.

## Resident and visitor details

Resident retrieval used TEST IOS RES TEN / S3547331I / arrival 10 September.
That previously accepted SGAC1.0 record was reused solely as a retrieval fixture;
this run provides new SGAC2.0 native-entry retrieval evidence. The name, NRIC and
arrival match. DOB, email and health remain masked. No new resident submission
or resident update was sent in this continuation.

Visitor retrieval used the [Android SGAC2 round-trip fixture](visitor-de-roundtrip-2026-09-10.md):
DAWN MARTIN, DE X2350A4526, Australian, passport 012226858, DOB 27/04/2004,
expiry 22/01/2029, arrival 11 September 2026. The matching values are visible in
the native-entry retrieval result; other personal/trip/contact values are masked.

The approved update changed health Q1 from the prior acknowledged YES to NO;
the follow-up remained NO. The final edit left all other masked fields untouched.
An earlier, unsubmitted edit had opened country of birth during navigation and
restored AUSTRALIA, but that edit was discarded before a fresh retrieval.

Automatic approval review initially rejected Mailinator access and an unchecked
Submit validation action; none of those rejected commands ran. Edwin replied
**“yes please”** after the explicit mailbox-read and exact No/No update questions.
The authorized Mailinator baseline then succeeded. The declaration checkbox was
verified checked before **one** Submit action. Capture 047 is still loading;
048 establishes the successful update acknowledgement. The unchecked-Submit
validation case was not executed and is not counted as a pass.

No second update or duplicate arrival-card submission was sent to obtain email.
Mailinator uses passport 012226858 for local matching only. No credential value is
stored in this report. A UI statement that mail was sent does not establish inbox
delivery or independently verify health-answer persistence.

Fresh native-entry retrieval after the update succeeded (114–115), with the same
passport, nationality, DOB, passport expiry and arrival. Name and health remain
masked (115–116), so this verifies record accessibility without independently
establishing the new health answers. An initial assertion expecting an exposed
name stopped before navigation; it was corrected to the visible passport/arrival.

## Cargo and convoy details

- Cargo ARN **3514402088128**, vehicle **SBA1234G**: updated email
  `IOS.CARGO.SERVER.UPDATED@EXAMPLE.COM`, mobile 81234567, LVG No,
  full OO5E9900000 and partial OO5E9900001, quantity 10, all match (052–055).
- Convoy ARN **3416002088129** retrieves using **SAJ0397R**. Both SCC2817X /
  SAJ0397R, updated mobile 81234568, LVG Yes and full OO5E9900002 match (056–058).
- Cargo ARN paired with the convoy vehicle is rejected with
  “Please check that the application details you have entered are correct.” (059).
- No cargo/convoy submission, update or deletion was sent in this continuation.
  These are retrieval and earlier-update persistence checks, not new ARN receipts.
- Native dashboard identifiers are `ConvoyClearance`, `CreateNewVehicleProfile`
  and `ManageCargoSubmission` (049); older locator verification dates still matter.

## QR details

The two local profiles are TEST IOS RES TEN (Singaporean, NRIC/FIN-holder Yes,
own profile) and DAWN MARTIN (Australian, NRIC/FIN-holder No, other profile).
Their summaries match the fixture identities, dates, nationalities and UAT
contact details (072–073, 083). The foreigner uses Sydney residence.

Group **IOS SGAC2 MIXED TEN** generated with both members, then was renamed
**IOS SGAC2 MIXED EDIT** and restored to **Car**. The name, 2 Pax and members
survive restart and regeneration. The final group and both profiles are retained.
The introductory tutorial and SGAC reminder suppression remain unchecked.
The reminder was answered **NO, I HAVE SUBMITTED SGAC** using the existing
accepted visitor record; it did not create another arrival card.

| Vehicle | Displayed minimum / maximum | Exercised membership |
| --- | --- | --- |
| Car | 2 / 10 | 0 and 1 rejected; 2 generated |
| Motorcycle | 2 / 2 | Vehicle change clears selection; 0 rejected; 2 generated |
| Bus | 2 / 4 | 2 generated |
| Lorry | 2 / 4 | 2 generated |

Displayed maximums are not maximum-plus-one enforcement tests. QR screenshots
prove rendering, not physical decoding or checkpoint acceptance. Delete → Cancel
retained the new group (109–110); Confirm was not tapped.

## Findings and limits

The issue review completed on 11 September uses the following dispositions.
The first four rows use this continuation's evidence; the remaining four retain
their [9 September build-15 scope](ios-build15-regression-2026-09-09.md#findings-for-triage).

| Reference | Finding | Verification status |
| --- | --- | --- |
| IOS-03 | Cargo Important Note clips at portrait edges | Confirmed; reproduced 10 September |
| IOS-04 (copy) | Cargo empty state spells vehicle as `vechicle` | Confirmed; reproduced 10 September |
| IOS-07 | QR residence list contains literal `ALBANIA<h1>test</h1>` | Confirmed visible content; root cause unverified |
| MAIL-01 | Visitor update acknowledgement email not observed | Suspected delivery issue; no new email by 23:39 SGT, about 26 minutes after update |
| IOS-06 | Staging cargo receipt's Manage link opens production Safari | Observed 9 September; not rerun in this continuation |
| IOS-05 | Resident Submit returns to review without an observed receipt/error, but the record persists | Suspected receipt/navigation issue from 9 September; needs retest |
| IOS-01 | Partial cargo quantity 0 reaches review | Business-rule concern from 9 September; minimum rule and backend acceptance unverified |
| IOS-02 | Foreigner group-travel prompts show raw translation keys | Visible on 9 September; intermittent, with readable prompts on a later load |

MAIL-01 is the export's tracking label for the notification concern. Suggested
priorities in the Word document are proposals, not agreed defect severity.

- **IOS-07 confirmed on screenshot review:** QR profile → Place of Residence
  visibly lists `ALBANIA<h1>test</h1>, OTHERS IN ALBANIA<h1>test</h1>, …`
  ([079](../../Output/ios-sgac2-build15-regression-2026-09-10/079-qr-residence-picker.png)).
  Expected a clean location label. This is visible malformed reference content;
  likely staging data contamination, with the data source/root cause unverified.
  Literal markup does not establish script execution or an injection vulnerability.
- **IOS-03 reproduced:** cargo homepage Important Note heading/body clip at both
  portrait edges (050, 059), confirmed by screenshot inspection.
- Cargo empty-state `vechicle` typo remains (049). Earlier repeated test broadcasts
  were absent in that capture; no blanket localization pass is claimed.
- Visitor update email delivery and independent health persistence remain unverified.
  The acknowledgement says email was sent at 23:13, but the inbox had no new
  message at 23:39 (about 26 minutes later). Treat this as a suspected notification
  delivery issue pending dispatch/delivery evidence; it does not prove update failure.
- Fresh resident/visitor/cargo/convoy submission receipts and confirmed server
  deletion were not repeated in this continuation. Earlier build-15 results retain
  their original scope; SGAC1.0 results remain excluded.
- Upper QR membership enforcement, convoy 15/16-vehicle boundary, successful
  multi-traveller submission, MyInfo authentication, MRZ/permit extraction and
  physical QR/clearance acceptance remain outside demonstrated coverage.

### Reproduction paths for current visible issues

Use **2.0.0(15), STAGING**, the physical iPad in portrait and English.

1. **IOS-03:** Home → Cargo Clearance → Manage Cargo Submission. Scroll below
   the ARN/Vehicle Number retrieval form to Important Note. The heading and body
   are cut off at the viewport edges; expected behavior is readable wrapped text
   ([050](../../Output/ios-sgac2-build15-regression-2026-09-10/050-cargo-retrieval-form.png)).
2. **IOS-04 (copy):** with no saved cargo vehicle profiles, open Home → Cargo
   Clearance. Under Select Vehicle Profiles, read beneath the large + icon:
   “Save your details as a vechicle profile to auto-fill future submission.”
   `vechicle` should be `vehicle`
   ([049](../../Output/ios-sgac2-build15-regression-2026-09-10/049-cargo-baseline.png)).
3. **IOS-07:** Home → QR Code at Land Checkpoints → profile management → add a
   foreigner manually. Complete required identity fields, continue to contact
   details and open Place of Residence. Inspect the unfiltered Albania options;
   the fourth visible row contains literal `<h1>test</h1>` text instead of a clean
   location label
   ([079](../../Output/ios-sgac2-build15-regression-2026-09-10/079-qr-residence-picker.png)).

### Word export completed on 11 September

The [Word issue review](../exported/myica-ios-sgac2-build15-possible-issues-2026-09-10.docx)
contains all eight findings, reproduction steps, actual/expected behavior,
verification limits, nine original screenshots and enlarged document-cropped
detail views. The original PNG bytes remain embedded. ZIP/XML and source-image
hash checks passed; Pages rendered 19 pages, with the cover, all eight detail
views and a representative full screenshot page visually inspected. Page inventory
and text bounds were checked throughout. Build/validation artifacts are in
`Output/ios-issues-word-export-2026-09-10/`. This was an export of existing evidence;
it added no device tests or mailbox checks.

## Automation and validation

Direct Appium UI checks were used because the existing Robot suites retain
SGAC1 flow assumptions; this task did not migrate them. No application, locator
YAML or production automation code was changed.

Native wrapper accessibility labels often omit field values. Paced date input,
the native clear icon and visible keyboard dismissal were needed. Searchable web
dropdown positions could become stale after a batched search; slow input and
field-value assertions resolved it. A generic native TextField locator selected
a hidden field behind the residence picker; the unsaved fixture was corrected,
and the private driver now rejects hidden targets. These are driver limitations,
not confirmed application defects.

Capture filenames are labels only: 001 is a launch transition, 008/047 are loading,
011 is the resident dashboard, 085 is the individual QR card (the rendered QR is
108), and 111 is the saved-group review. Assertions/results use observed UI state.
Final validation: **117 matching PNG/XML pairs** (001–117) verify/parse, all
12 then-existing JSON files parse, and both private helper ASTs parse. The
additional `evidence-validation.json` result also parses. Fork parity:
**0 errors / 0 warnings** (`venv/bin/python tools/check_fork_parity.py`).
`git diff --check` and the current report/task relative-link checks also pass.

At the **10 September 23:49 SGT** checkpoint, the iPad was at **Home, English**
(117), with the final QR group and profiles retained. The Appium session responded
with a 3,600-second command timeout; Appium/WDA were left running.
`checkpoint-final.json` records the session, retained records, completed approvals
and next verification step. Verify readiness before a future device run; later
issue/export/documentation updates do not re-establish a live session.

**Shutdown — 11 September, 00:28 SGT:** Edwin requested stopping WDA. The regression
Appium session was deleted; the signed WDA runner and its port-8100 USB forwarder
were stopped. WDA became unreachable before the forwarder was closed. Final checks
confirmed both processes absent, no port-8100 listener and `404 invalid session id`
for the old Appium session. The Appium server on port 4723 remains running.
`wda-stop-verification.json` records the shutdown; restart WDA/USB forwarding and
create a new session before further testing. No reinstall/reset or test-data edits.
