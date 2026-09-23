# SGAC1.0 iOS 1.19.1 regression — 10 September 2026

Last reviewed: 2026-09-10

**Fork correction — confirmed by Edwin on 10 September:** MyICA **1.19.1(1)**
is **SGAC1.0**, the wrong version for the intended SGAC2.0 regression. All native
checks in this report belong to SGAC1.0. The cargo/convoy Network Error and
foreigner submission-status discrepancy are SGAC1.0 observations and must not be
reported as SGAC2.0 defects. The Safari staging retrieval/update checks also do
not establish native SGAC2.0 coverage. Preserve this run as separate evidence.

Testing on this build has stopped. Edwin selected **SGAC2.0 2.0.0(15)** for the
resumed regression. An Appium installed-app query after that selection still
reported **1.19.1(1)**. Resume only after 2.0.0(15) is installed through TestFlight
and verified on the physical iPad.
Earlier results from the separate 2.0.0 build 15 run retain their original scope;
this run does not extend or invalidate them.

Status: Four approved synthetic-record deletions and staging DE retrieval passed.
The approved mobile update to **+61 412345679** was acknowledged, and the generated
PDF shows that value. Fresh retrieval passed but masks the contact, so independent
stored-mobile readback remains unverified. Native cargo/convoy Network Error still
blocks SGAC1.0 ARN coverage in this run. No user approval is pending; earlier approval
blocks and device-state notes below are historical checkpoints.
Continuation after the user reinstalled MyICA and authorized
SGAC, cargo/convoy submissions, submission deletion and mixed resident/foreigner QR.
The installed app is **1.19.1 build 1**, confirmed by device package metadata and
the About screen. These results are separate from the [2.0.0 build 15 run](ios-build15-regression-2026-09-09.md).

## Environment and baseline

- Physical iPad Air 11-inch (M3), iOS 26.6.1; Appium 3.1.2, WDA 11.4.1.
- Existing signed WDA runner restarted and a fresh no-reset Appium session created.
- Native SGAC1-style screens are present. Singpass handoff opened
  `login.stg-id.singpass.gov.sg` and displayed `UAT testing to retrieve MyInfo` (013).
  No login was performed; only the newly opened tab was closed.
- Resident profiles and submissions were empty. Cargo had pre-existing vehicle
  `SYR0614` and two-vehicle convoy ARN `5751502088140` (003–007). Preserve these.
  The reported reinstall does not establish that local or server stores are all empty.
- New synthetic fixtures and approved Mailinator addresses are recorded under
  `Output/ios-regression-2026-09-10/fixtures.json`. All captures below refer to that folder.

## Resident submission and deletion

- Created `TEST IOS RES TEN`; summary matched identity, date of birth, +65 mobile
  and approved resident inbox (018–019).
- Submitted arrival 10 September with both health answers No after checking review
  (025–028) and completing the displayed CAPTCHA. `Submission Successful` appeared
  (031), and the record appeared on the dashboard (032). View / Edit loaded matching
  saved declaration details (035).
- Delete confirmation says: `This will only remove the submitted declaration from
  your device` (037). Cancel preserved the submission (038). Confirm removed it
  (039); it remained absent after restart (041) and from Submitted Declarations (042).
  This demonstrates local removal; it does not demonstrate backend cancellation.
- Mail capture was prepared before Submit. A matching acknowledgement subsequently
  arrived: message `sgac-res-1789029920-096632987`. It confirms the resident name,
  10 September arrival, submitted contact details and both No answers; email records
  submission time 16:41 Singapore time. The original response is retained privately.
- The resident profile remained after submission deletion (043).

## Foreigner continuation

- Created Australian profile `TEST IOS FORE TEN` with Sydney residence, the approved
  foreigner inbox and matching identity/contact summary (055–056).
- LAND/CAR, synthetic plate `SWH8237S`, holiday purpose and hotel accommodation
  reached a matching review. Submit returned **Invalid Vehicle Entry Permit** for
  that plate (080); acknowledging it returned to the declaration. No success claimed.
- BUS also exposes a required vehicle number. Revised the unaccepted scenario to
  AIR / COMMERCIAL FLIGHT / SQ222, Crowne Plaza Changi Airport, 10–12 September,
  Sydney both cities, no previous name and both health answers No (089–095).
- Changing the embarkation city cleared Same as Last City and retained the old
  destination. Reselecting the checkbox correctly copied Sydney (093–095).
- Revised Submit returned **Something went wrong / Please try again** (099).
  Saved the form as a local draft (101–102); Submitted filter was empty (103).
  A matching acknowledgement later arrived for the 17:02 submission, message
  `sgac-fore-1789031479-096640681`, including matching name/passport and DE
  `X2350A4428`. The repository helper extracted and privately stored it.
  **Server acceptance despite the error and local Draft state is a confirmed
  submission-status discrepancy. Do not resubmit this accepted identity/date.**

## Cargo and convoy continuation

- Created synthetic cargo vehicle and corrected its plate to `SCB5528R`. Native
  registration warning appeared for both the original `SUG6385P` and `SCB5528R`,
  but saving and selecting the profile remained possible (105–110).
- Full `OO5E9900003` and partial `OO5E9900004`, quantity 10, were rejected with
  `[3]Please check that the permit number is correct and valid.` (118).
- Changed the unaccepted permits to the previous build-15 successful pair
  `OO5E9900000` / `OO5E9900001`. Submit showed **Network Error** (121).
  Retrieve QR Code generated a QR with matching vehicle, email and permits (122);
  it explicitly refers to using the code when no ARN has been received. The local
  list labels this record **Draft** (123). Retrying after restart returned the same
  Network Error (137). No matching acknowledgement was found in later inbox checks;
  no ARN or server acceptance is claimed.
- Read-only inspection of the preserved convoy receipt (125) showed ARN
  `5751502088140`, vehicles `SHN0852P` / `SBL2595P` and permit `IG1AA990047`.
  That permit series is in `Cargo_Test_Data.txt`; the separate new convoy uses
  `SBH3349J` / `SCM1587M` and a different entry, `IG1AA990046`.
- New convoy review matched both plates, approved inbox, mobile, permit and LVG
  selection (131). Submit returned **Network Error** immediately (132). Retrieve QR
  Code rendered the two-vehicle QR without an ARN (133); a local record appeared
  and survived restart (134–135). Later matching-email checks remained empty.
- Native Other e-Services → Submit SG Arrival Card opened production
  `eservices.ica.gov.sg` (140). No fields were populated there. The confirmed staging
  web service loaded separately (141–143), so staging web reachability does not
  establish that the native cargo/convoy endpoint was healthy.

## Foreigner retrieval approval boundary

The matching email supplies a valid DE candidate. The staging retrieval form loaded,
but automatic approval review twice rejected entering that DE and nationality into
`eservices-stg.ica.gov.sg`, requiring explicit approval for this payload/destination.
No retrieval fields were entered. The saved prior authorization record was not
accepted by review. Obtain that specific approval before continuing retrieval/update;
do not repeat the accepted submission.

Approval note, 10 September 2026: Edwin approved saving the synthetic DE
`X2350A4428` and nationality `AUSTRALIAN` in the retained regression evidence and
handover. This records storage approval; the separate automatic-review requirement
for sending those values to the staging retrieval service remains pending.
Testing remains paused at the requested checkpoint.

## Mixed resident/foreigner group QR checkpoint

- QR All Profiles was empty despite the SGAC profiles (148), confirming a separate
  native profile store. Created resident `TEST IOS RES TEN` with NRIC/FIN-holder Yes,
  Singaporean nationality and own-profile Yes (153, 157). Created Australian
  `TEST IOS FORE TEN` with NRIC/FIN-holder No and own-profile No (158, 160–161).
  Both summaries matched the synthetic passport details.
- Selected Car and both profiles for `IOS MIXED TEN` (164, 166). Review showed
  **2 Pax**, both names and correct passport expiries (167).
- Generate displayed a readable **SG Arrival Card for Foreign Visitor** reminder,
  with routes to create SGAC or acknowledge an existing submission (168).
  Selected **NO, I HAVE SUBMITTED SGAC**, consistent with the verified foreigner email.
  The Don't show this again option remained unchecked; no duplicate SGAC was created.
- A visible QR rendered with both members (169), and the saved dashboard card showed
  2 Pax (170). The card labels passport expiry 21 October 2027; the generated QR
  separately states valid until 31 August 2027. This is an observation, not a verified
  expiry-rule defect. Saved group presence after app restart is captured in 173.
- Physical checkpoint acceptance, regeneration after restart, reminder suppression,
  alternate reminder action, min/max membership, group edit/delete and other vehicle
  variants remain untested in this build. Earlier build-15 results do not close them.

## Handover and remaining work

The user requested stopping at the next suitable checkpoint. Testing stopped after
the mixed group was generated and saved. MyICA was returned to Home (174), English.
Both SGAC profiles, both QR profiles, mixed group, cargo vehicle and local cargo,
convoy and foreigner drafts are retained. The original vehicle `SYR0614` and convoy
ARN `5751502088140` were never edited or deleted.

1. Resume cargo/convoy local-record deletion: cancel, confirm, restart absence and
   profile preservation. Target only `SCB5528R` and `SBH3349J` / `SCM1587M`; preserve
   the original vehicle and ARN. These currently have no confirmed server acceptance.
2. Validate foreigner local-draft deletion separately from backend cancellation.
   Its server submission was accepted despite the app error; do not resubmit it.
3. Obtain explicit approval to send saved synthetic visitor details, DE `X2350A4428`
   and Australian nationality to `eservices-stg.ica.gov.sg` for retrieval/update.
   The automatic review boundary above remains in force.
4. Investigate native cargo/convoy Network Error before claiming current-build
   ARN-backed submission/retrieval/deletion coverage. The earlier build-15 ARNs are
   historical results. Recheck mail before considering any further submission attempt.
5. Continue QR variants and deletion only when testing resumes.

See the [handover task](../../todo/blocked/ios-module-regression-2026-09-09.md) for
session recovery, exact fixtures, process state and validation. Evidence is local and
gitignored under `Output/ios-regression-2026-09-10/`; private mail/DE responses remain
there. Results are direct Appium-driven UI observations, not live Robot-suite passes.

Validation: 170 PNG/XML pairs, all 15 then-existing JSON files and both local Python
helpers passed integrity/parsing checks with zero errors. Fork parity using the
project venv returned 0 errors and 0 warnings; `git diff --check` passed.
Appium session deletion returned HTTP 200. The run's WDA runner and iproxy were
stopped and verified absent; existing Appium servers were retained. Resume with a
fresh no-reset session when testing is requested again.

## Resumed regression — 10 September, from 17:57 Singapore time

Fresh Appium session on the same physical iPad, existing signed WDA 11.4.1 and
USB forwarding. Earlier pause/shutdown descriptions above are historical.
Evidence continues in the same folder from capture 175. No app install or reset.

- Cargo and convoy acknowledgement checks returned no matching messages before
  further UI work. The cargo draft and both convoy entries remained (176).
- Cargo Delete warns that the submission will no longer be retrievable by the
  user **or other users**, through SGAC web or mobile (178). This contradicts the
  previous assumption that draft deletion is necessarily local-only. Cancel
  retained `SCB5528R - Draft` (179). Automatic approval review rejected Confirm,
  citing an irreversible service/app deletion without explicit current-message
  authorization. No Confirm action ran; further destructive cargo deletion is
  pending approval for this specific scope.
- Mixed Car group regenerated after restart with both correct profiles (182–184).
  The reminder's **PROCEED TO CREATE SGAC** action navigated to the Foreign Visitor
  SGAC dashboard (185); no new declaration was submitted.
- Foreigner draft Delete showed only `Are you sure?` (187), without stating local
  versus server scope. Cancel retained the draft (188). No backend cancellation
  or confirmed draft deletion is established by this check.
- Motorcycle rejected a single selected profile with a minimum-two error (193),
  and generated with two (199). Changing vehicle type cleared member selections;
  reselecting both allowed review. Capture 194's filename incorrectly says
  zero-member validation; its actual content is a two-member review, so it is
  **not evidence of zero-member rejection**.
- A group rename persisted after restart (200). Initial cursor-based text editing
  left an extra `TEN` suffix; this was a driver-input issue, corrected using the
  field's clear button before entering the Bus group name (205).
- Selected **Don't show this again** on the foreign-visitor reminder (198).
  Generating the mixed group after restart showed the QR without that reminder
  (201). Suppression remains enabled; the separate introductory QR tutorial still
  appears and was dismissed using **NO, THANKS**.
- Bus displayed minimum 2 / maximum 4 (202), rejected zero and one selected
  member (203–204), and generated with both profiles and the corrected name (205–206).
  Displayed upper limits are not proof of enforced maximum membership.
- Lorry displayed minimum 2 / maximum 4 (207) and generated with both profiles
  (208–209). Screenshots confirm visible QR rendering for the vehicle variants;
  no physical checkpoint scan or acceptance was performed.
- Group Delete → Cancel retained the group (210–213). Automatic review also
  rejected Confirm for this specific group; no deletion ran. Restored the name
  **IOS MIXED TEN**, Car and both members, then generated again (214–217).
- Resident individual QR rendered with the correct profile (219). Capture 218 is
  its options menu, not a generated QR.
- Convoy edit inspection retained `SBH3349J` / `SCM1587M` and permit `IG1AA990046`
  (221–222). Delete repeats the web/mobile retrieval-removal warning (224); Cancel
  retained both convoy entries (225). Both vehicle profiles remain, including
  pre-existing `SYR0614` (226). The original ARN was never edited or deleted.
- About reconfirmed **1.19.1(1)** (228). MyICA is at Home, English (229). The
  Appium/WDA session remains available pending replies to the two specific
  approval questions (deletion of the four test records; staging DE retrieval/update).
  No deletion, new submission, foreigner retrieval or server update occurred in
  this resumed session. Native cargo/convoy Network Error remains unresolved.

Resumed evidence validation: **225 total PNG/XML pairs**, including 55 new pairs,
all 17 then-existing JSON files and two Python helper ASTs passed with zero errors.
Fork parity: 0 errors / 0 warnings; `git diff --check`: pass. Recovery details are
in `checkpoint-resume.json` and `processes-resume.json`. These remain direct UI
observations; no live Robot-suite pass is claimed.

## Approved deletion and retrieval continuation — 10 September

Edwin replied **"yes please"** to the explicit request to delete cargo `SCB5528R`,
convoy `SBH3349J / SCM1587M`, foreigner draft `TEST IOS FORE TEN` and QR group
`IOS MIXED TEN`, and use DE `X2350A4428` / nationality `AUSTRALIAN` at
`eservices-stg.ica.gov.sg` for retrieval/update. The request disclosed the
cargo/convoy web-service deletion warning. This approval supersedes the earlier
pending authorization for those named records and staging retrieval.

| Check | Observed result | Evidence |
| --- | --- | --- |
| Cargo Confirm deletion | Draft removed; absent after restart; vehicle profile retained | 230–231, 234–235 |
| Convoy Confirm deletion | New convoy removed; only original ARN `5751502088140` remained after restart | 232–234 |
| Foreigner draft Confirm deletion | Draft removed; absent after restart; SGAC profile retained | 236–239 |
| QR-group Confirm deletion | Group removed; absent after restart; both QR profiles and resident individual QR card retained | 240–243 |
| Original records | Vehicle `SYR0614` and original convoy ARN preserved; synthetic cargo vehicle also retained | 234–235 |
| Foreigner server retrieval after draft deletion | Passed with matching DE, birth date, nationality, passport, passport expiry and arrival | 248–260, 266 |

Cargo/convoy had no confirmed acceptance/ARN before deletion. Their disappearance
from the device is verified; deletion of an accepted backend record is not proven.
By contrast, successful foreigner retrieval **after** draft deletion demonstrates
that its accepted server record remained available.

Safari initially resumed the pre-existing production cargo tab (244); no data
was entered there. A new tab opened `https://eservices-stg.ica.gov.sg/sgarrivalcard/`
and navigated Update SGAC → Foreign Visitor (245–248). The retrieved record showed
DE `X2350A4428`, birth date `10/09/1992`, nationality `AUSTRALIAN`, passport
`U60695720`, expiry `24/11/2027`, arrival `10/09/2026`, AIR / COMMERCIAL FLIGHT,
and HOTEL (258–260, 266–267). Name, contacts and several trip/health values remained
masked as **Hidden**, so they were not independently verified in this retrieval.
The initial CAPTCHA transcription was rejected; a new challenge succeeded.
One Safari accessibility snapshot timed out after activation and recovered on retry.

Clicking the mobile's **Hidden** control opens blank replacement inputs, rather
than revealing the existing value (261). Proposed changing the saved synthetic
contact from `+61 412345678` to `+61 412345679`. **Automatic approval review rejected
entering the new value**, requiring explicit approval of that exact contact value
despite the approved general update scope. No replacement input or update was sent.
The control was reverted with its undo button, then the unchanged record reached
review (262–268); the declaration checkbox remained unchecked.

An asynchronous question requests approval to enter, submit and retrieve the exact
replacement mobile at staging. No reply had arrived at this checkpoint. The
general deletion/retrieval approval remains valid; do not request it again.
The prepared Mailinator update baseline is
`foreigner-update-20260910-mail-baseline.json` (two existing messages). Native
cargo/convoy Network Error and current-build ARN-backed success remain unresolved.

The existing Appium/WDA session remains running. Safari's new staging tab is on
the unchanged review page; use **Previous** to return to the particulars before
an approved mobile update. The earlier production cargo tab is preserved.
Results are in `approved-continuation-results.json`. No live Robot-suite pass
or completed server update is claimed.

Validation: **264 PNG/XML pairs** (39 new), one standalone diagnostic screenshot,
all 21 then-existing JSON files and two helper ASTs passed with zero errors.
Fork parity returned 0 errors / 0 warnings; `git diff --check` passed. Live session
recovery is saved in `checkpoint-approved.json`.

## Approved mobile update and fresh retrieval — 10 September, 18:50 Singapore time

Edwin explicitly approved changing the staging mobile from **+61 412345678** to
**+61 412345679**, submitting, and freshly retrieving the declaration. This resolves
the exact-value approval block above; all authorized continuation actions are complete.

| Check | Observed result | Evidence |
| --- | --- | --- |
| Mobile edit and review | Country code +61 and mobile 412345679 matched the approved value; declaration checked; submitted once | 269–274 |
| Server response | **Your Singapore Arrival Card submission is updated!**, transaction **10/09/2026 06:50 PM Singapore Time** | 276 |
| Generated PDF | Page 1 identifies DE X2350A4428 / passport U60695720 and transaction time; page 2 shows **+61 412345679** | 277–278 |
| Fresh staging retrieval | Same DE and identity successfully retrieved from a new tab | 280–283 |
| Independent contact readback | Mobile remains **Hidden**; neither old nor new mobile is present in retrieved DOM/input values | 284, `fresh-retrieval-dom-readback.json` |
| Update email | No new matching acknowledgement observed; an unrelated mailbox message was excluded by identity | `foreigner-mobile-update-mail-check.json` |
| Final device state | Only the three test tabs closed; original cargo tab preserved; MyICA ready at Home after restart without reset | 286, 288 |

The update acknowledgement and exact contact in its generated PDF are verified.
Fresh retrieval proves that the record is still accessible, but does **not**
independently verify the stored mobile because contacts are masked. No duplicate
SGAC submission or second update was made to obtain a readback/email. PDF evidence
is screenshots of the Safari preview, not a separately saved PDF file.

Capture 275 shows the transient review before the success response; use 276 for
the acknowledgement. Capture 287 shows the launch splash; use 288 for ready Home.
The MyICA/Appium/WDA session remains available. Current recovery state is in
`checkpoint-mobile-update.json`; `checkpoint-approved.json` is historical.

Remaining coverage is native cargo/convoy accepted ARN-backed flows (Network Error),
independent stored-contact readback, upper QR membership limits and physical
acceptance. The [blocked task](../../todo/blocked/ios-module-regression-2026-09-09.md)
records the required next actions. No user permission remains outstanding.

Validation: **284 PNG/XML pairs** (20 new), one diagnostic screenshot, all
then-existing JSON files and two helper ASTs passed integrity/parsing checks;
exact counts are in `evidence-validation-mobile-update.json`. Fork parity returned
0 errors / 0 warnings; `git diff --check` passed. These are direct Appium UI
observations, not live Robot-suite passes. No production automation code changed.
