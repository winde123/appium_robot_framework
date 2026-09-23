# iOS module regression — 9 September 2026

- Status: Blocked — continuation complete; visitor update email/readback unverified
- Owner: Codex
- Priority: High
- Created: 2026-09-09
- Updated: 2026-09-11

## Current handover — 11 September 2026

### WDA stopped at Edwin's request — 11 September, 00:28 SGT

The regression Appium session was deleted successfully. WDA then reported no
active session; its verified `xcodebuild` runner (PID 69720) was stopped and the
WDA endpoint became unreachable before closing the USB forwarder (PID 52938).
Final checks found both processes absent, no listener on port 8100, and the old
Appium session returned `404 invalid session id`. The Appium server on port 4723
was left running and still responds.

**Current automation state: WDA STOPPED.** This supersedes the earlier running/
responsive-session notes below. Restart the signed WDA runner and USB forwarding,
then create a new Appium session before any further iPad testing. Evidence:
`Output/ios-sgac2-build15-regression-2026-09-10/wda-stop-verification.json`.
The shutdown performed no app reinstall/reset or test-data edits.

### Defect review, Word export and documentation checkpoint

Edwin requested a possible-issue review, reproduction instructions, a Word document
with screenshots under `docs/exported/`, and persistence to Mnemosyne/project docs.
These follow-up deliverables are complete; the regression verification dependency
below remains open.

- [Word issue review](../../docs/exported/myica-ios-sgac2-build15-possible-issues-2026-09-10.docx):
  eight findings, nine embedded original screenshots, 19 rendered pages. Each issue
  includes reproduction context, actual/expected behavior, observation date,
  suggested priority, verification status and remaining investigation.
- Current confirmed visible issues: cargo clipping IOS-03, `vechicle` under IOS-04,
  and QR residence test markup IOS-07 (visually verified in screenshot 079).
  MAIL-01 is a suspected notification issue, based on no new email by 23:39 SGT
  on 10 September; it does not establish update failure.
- Earlier same-build IOS-06 production routing, IOS-05 missing resident receipt,
  IOS-01 quantity-zero validation concern and intermittent IOS-02 raw translation
  keys are included with their 9 September evidence and retest caveats.
- DOCX ZIP/XML checks and all nine original-image hashes passed. Pages opened
  and exported the document to a 19-page layout preview; all eight evidence detail
  views and a full screenshot page were visually inspected. The page inventory
  and text bounds passed. Validation/build files are in
  `Output/ios-issues-word-export-2026-09-10/`.
- The regression report, export index, docs index, iOS status and `CLAUDE.md` now
  link the latest results. Mnemosyne records the regression, issue review, export
  and this handover. No new device/mailbox action occurred during the export or
  documentation follow-up.
- Last observed device state remains the **10 September 23:49 SGT** checkpoint:
  Home, English, with retained profiles/group and a responsive Appium session.
  Verify device/build/session readiness before future testing. Do not treat this
  documentation checkpoint as a fresh session or inbox check.

### SGAC2.0 continuation completed; remaining verification dependency

The physical iPad's installed metadata and About both verify **2.0.0(15), STAGING**
on iOS 26.6.1 (004). The wrong-fork blocker is resolved. The separate current
[SGAC2.0 report](../../docs/testing/ios-sgac2-build15-regression-2026-09-10.md)
records direct Appium UI evidence in
`Output/ios-sgac2-build15-regression-2026-09-10/`; no live Robot-suite pass is claimed.

- Resident and foreigner empty-field validation and existing-record retrieval passed.
  Foreigner identity/arrival matched again after the update (114–115).
- Edwin's **“yes please”** approved reading the named UAT mailbox and the exact
  visitor No/No health update. Both previously rejected actions then proceeded
  under accepted approval. No approvals remain pending.
- Sent that update exactly once. **Submission updated**, 10/09/2026 11:13 PM
  Singapore Time (048). Other masked fields were left untouched in the final edit.
  Fresh retrieval still masks health (116); no matching email was observed by the
  final inbox check at 23:39 Singapore (same five messages as baseline).
- Cargo/convoy existing ARN retrieval and earlier updated email/mobile persistence
  passed; unrelated vehicle/ARN pairing was rejected (050–059). No new cargo or
  convoy submission/update/deletion was sent. Preserve both existing records.
- Created resident/foreigner QR profiles and a two-member mixed group; Car,
  Motorcycle, Bus and Lorry rendered. Minimum-member validation, rename/restart
  persistence, individual QR, Delete → Cancel and regeneration passed (062–112).
  Retained group **IOS SGAC2 MIXED EDIT**, **Car**, 2 Pax, and both profiles.
- Cargo Important Note clipping (IOS-03) and the `vechicle` typo remain. Upper QR
  membership enforcement, convoy 15/16-vehicle boundary, multi-traveller success,
  MyInfo/MRZ/permit extraction and physical QR acceptance are untested here.
- Final app state: **Home, English** (117); no reinstall/reset. Appium/WDA were
  left running. `checkpoint-final.json` is the current session/data handover;
  older session and approval notes below are historical.

**Dependency and next action:** full sign-off awaits a matching visitor update
acknowledgement or an authorized readback that exposes persisted health values.
Recheck the already-approved inbox later; do not repeat the accepted update to
obtain mail or infer health persistence from masked retrieval. Record the other
coverage boundaries explicitly when determining release sign-off.

Validation: 117 matching PNG/XML pairs, JSON evidence and both helper ASTs parse;
fork parity reports **0 errors / 0 warnings**. Final integrity counts and whitespace
check are recorded in the report and `evidence-validation.json`.

### Historical correction — wrong fork tested (build blocker now resolved)

Edwin confirmed: **"this is the wrong version, whatever you done so far is for
sgac1.0"**. The 10 September run used **MyICA 1.19.1(1), SGAC1.0**. The intended
continuation is SGAC2.0. Stop SGAC1.0 testing and diagnosis under this task.

- All native results in `Output/ios-regression-2026-09-10/` and the
  [1.19.1 report](../../docs/testing/ios-1-19-1-regression-2026-09-10.md) are
  SGAC1.0 evidence, including the cargo/convoy Network Error and foreigner false
  failure. Do not carry those findings or passes into SGAC2.0 coverage.
- Staging Safari retrieval/update remains valid web evidence from this run; it
  does not prove the SGAC2.0 app's native retrieval/update behavior.
- Preserve all evidence, completed actions and existing test data. The separate
  earlier 2.0.0 build 15 results retain their recorded scope. Do not relabel that
  earlier run based on this correction.
- Edwin selected **2.0.0(15)** in reply to the target-build question. The subsequent
  Appium `mobile: listApps` query for `sg.gov.ica.mobile.app` still reported
  `CFBundleShortVersionString=1.19.1`, `CFBundleVersion=1`. The blocker is now
  switching the iPad to **SGAC2.0 2.0.0(15)** through TestFlight, then verifying it.
  No further build-selection question is needed.
- Before resuming, verify the actual installed version/build and SGAC2.0 screens
  on the physical iPad; record a new baseline and keep evidence in a separate
  SGAC2.0 directory. Configure `APP_FORK=sgac2` for Robot runs, but remember this
  does not replace the installed iOS app. Follow the repository's TestFlight
  workflow; sessions launch the installed app without installing/resetting it.
- Existing authorization for the requested testing remains recorded. No repeat
  approval is needed for completed actions. Do not repeat submissions using the
  already-accepted SGAC1.0 foreigner identity/date simply to obtain new evidence.
- Correction recorded in report/index, this task, SGAC2.0 locator status and
  private `fork-correction.json`. The only device operation was a read-only
  installed-app query; no installation, reset or further test submission occurred.
  Documentation checks and fork parity passed.

Current acceptance for the resumed SGAC2.0 run:

- [x] Reclassify the 10 September 1.19.1(1) evidence as SGAC1.0.
- [x] Identify the intended SGAC2.0 TestFlight version/build: **2.0.0(15)**.
- [x] Verify **2.0.0(15)** is installed: package metadata and About capture 004 agree; STAGING.
- [x] Re-establish the physical-device baseline and assess the requested resident,
  foreigner, cargo/convoy and mixed QR flows on that build.
- [x] Record SGAC2.0 results and remaining limitations separately from this SGAC1.0 run.
- [ ] Independently verify visitor health persistence/email delivery; UI acknowledgement
  and fresh masked retrieval are complete, but do not satisfy this remaining check.

### Historical SGAC1.0 result — approved mobile update completed

- Edwin's exact-value **"yes please"** approval was accepted. Changed only the
  staging foreigner mobile from **+61 412345678** to **+61 412345679**, reviewed
  the value, checked the declaration and submitted once (269–274).
- Staging displayed **Your Singapore Arrival Card submission is updated!** with
  transaction time **10/09/2026 06:50 PM Singapore Time** (276). The generated
  PDF identifies DE **X2350A4428** / passport **U60695720** (277), and page 2
  shows **+61 412345679** (278). These are captured PDF screenshots.
- Retrieved the record again in a fresh staging tab with the same DE and identity
  (280–283). Retrieval passed, but the mobile remained **Hidden** (284); neither
  old nor new mobile appeared in the retrieved page DOM or input values. Thus
  update acknowledgement and the exact value in its PDF are verified; fresh
  retrieval does **not** independently establish mobile persistence.
- No matching update email was observed in the final mailbox check. A new message
  belonged to another identity and was excluded. Do not treat it as this update's
  acknowledgement or submit again to obtain an email.
- Closed only the three test Safari tabs, preserving the original cargo tab (286).
  MyICA restarted without reset and is ready at **Home, English** (288).
  Capture 287 shows the launch splash, not a ready Home screen.
- No approvals remain pending. Earlier pending-approval and device-state notes
  below are historical and superseded by this checkpoint.
- Latest evidence: `approved-continuation-results.json`,
  `checkpoint-mobile-update.json`, `fresh-retrieval-dom-readback.json`, and
  captures 269–288 under `Output/ios-regression-2026-09-10/`.
- Validation: 284 PNG/XML pairs (20 new), one standalone diagnostic screenshot,
  all then-existing JSON files and two helper ASTs parsed successfully. Final
  counts are in `evidence-validation-mobile-update.json`. Fork parity: 0 errors /
  0 warnings; `git diff --check`: pass. Direct UI testing only; no live Robot-suite
  pass or production automation change is claimed.

Remaining blockers and next actions:

1. Native cargo/convoy **Network Error** still prevents current-build accepted
   ARN-backed submission/retrieval/deletion coverage. Diagnose or restore that
   service path and recheck matching mail before any further submission.
2. Independent mobile persistence needs an authorized readback surface that
   exposes the stored contact, or a matching update acknowledgement. The public
   retrieval form masks it. Do not resubmit or infer persistence from masked fields.
3. Upper QR membership limits and physical checkpoint/MRZ/permit acceptance remain
   untested; they require additional fixtures or physical testing facilities.

The approved SGAC1.0 continuation was completed. The gaps above are retained as
SGAC1.0 history; use the completed SGAC2.0 continuation and dependency at the top.
Keep original vehicle SYR0614 and convoy
5751502088140 intact. Current session details are in the latest checkpoint;
older shutdown/session descriptions below must not be used as current state.

### Exact mobile-value approval received

Edwin replied **"yes please"** to: "May I change the staging mobile from
**+61 412345678** to **+61 412345679**, submit, and retrieve again to verify
persistence?" This explicitly approves the exact replacement value, submission
and fresh retrieval on eservices-stg.ica.gov.sg. The narrow blocker below is
resolved; do not ask again. Startup recall and full CLAUDE.md read completed,
and the existing Safari review/Appium session remains responsive.

### Historical checkpoint — approved deletion and first retrieval

- Current user **"yes please"** approval below was accepted for the four named
  deletions and the staging retrieval. Do not ask for those permissions again.
- Confirm-deleted cargo SCB5528R, convoy SBH3349J / SCM1587M, foreigner draft
  TEST IOS FORE TEN and QR group IOS MIXED TEN. All absent after restart.
  Both vehicle profiles, original convoy 5751502088140, foreigner SGAC profile,
  both QR profiles and resident individual QR card remain (230–243).
- Retrieved foreigner DE X2350A4428 on **eservices-stg.ica.gov.sg** after deleting
  the draft, proving its accepted server record remains available. DOB 10/09/1992,
  AUSTRALIAN, passport U60695720, expiry24/11/2027, arrival10/09/2026,
  AIR/COMMERCIAL FLIGHT and HOTEL matched. Other values remain masked (258–267).
- **New narrow approval blocker:** auto-review rejected entering proposed mobile
  **+61 412345679**, requiring explicit authorization of this exact replacement
  value. Existing saved mobile is **+61 412345678**. The rejected command did not
  execute. Async question asks to change, submit and freshly retrieve that exact
  contact at staging; no answer received yet. Do not bypass the rejection.
- The masked-mobile button opened blank replacement inputs; used its undo control
  to restore the unchanged state. Reached unchanged Review; declaration unchecked
  (268). No server update or duplicate submission was made. Pending update capture
  baseline `foreigner-update-20260910-mail-baseline.json` contains two old messages.
- Safari is foreground on the staging Review page. **Previous** returns to the
  particulars. New tab UUID145CF244-AB79-440D-9C94-1B16153C6B49; existing production
  cargo tab UUID11BAB3D3-8FFD-474C-A9A6-5BD0D5CC6752 preserved and never populated.
  Same Appium session a0e3aea5-2dac-42e7-a454-1c1b82cfbd3b / WDA remains running.
- `approved-continuation-results.json` records approvals, observed results and
  automation recovery notes. Captures230–268 extend the evidence. Native
  cargo/convoy network failure and accepted ARN-backed deletion are still unproven.
- Validation: 264 PNG/XML pairs (39 new), one diagnostic screenshot, 21 then-existing
  JSON files and two helper ASTs passed; parity0/0; `git diff --check` pass.
  `checkpoint-approved.json` records the current responsive session and next step.

Next: await exact mobile-value approval, use Previous to edit only the mobile
contact, review/submit, check acknowledgement, and freshly retrieve to establish
whether the new contact persists. Keep the earlier approved retrieval scope active.

### Approval received — 10 September 2026

Edwin replied **"yes please"** to the explicit question authorizing deletion of
synthetic cargo **SCB5528R**, convoy **SBH3349J / SCM1587M**, foreigner draft
**TEST IOS FORE TEN**, and QR group **IOS MIXED TEN**; and use of
**DE X2350A4428 / AUSTRALIAN** at **eservices-stg.ica.gov.sg** for retrieval/update.
The question explicitly disclosed cargo/convoy web-service removal effects.
This is current conversation approval for both actions, superseding the pending
approval notes below. Preserve original vehicle SYR0614 and convoy 5751502088140.
Startup recall/CLAUDE read complete; existing WDA/Appium session is responsive.

### Historical checkpoint — 18:14 Singapore time

- Resumed at Edwin's request. Completed 55 new PNG/XML pairs (175–229), bringing
  the folder to 225 pairs. About reconfirmed **1.19.1(1)** (228).
- Mixed QR: Car regeneration after restart; Motorcycle, Bus and Lorry generation
  with both synthetic profiles; minimum-two validation (Motorcycle one; Bus zero
  and one); rename persistence; reminder alternate action to Foreign Visitor SGAC;
  reminder suppression after restart. Resident individual QR rendered (219).
- Restored group to **IOS MIXED TEN**, **Car**, 2 Pax. No group/profile deleted.
  Foreign-visitor reminder suppression is now enabled. Introductory QR tutorial
  remains unsuppressed. Upper membership limits and physical acceptance untested.
- Cargo, convoy, foreigner draft and QR-group Delete → Cancel retained records.
  Cargo (178) and convoy (224) warn that deletion prevents retrieval by this user
  **and other users through the SGAC web service/mobile app**. Earlier local-only
  assumptions below are superseded; backend effects must not be inferred from Draft.
- Automatic approval review rejected Confirm for cargo deletion and then QR-group
  deletion, requiring current explicit authorization for the specific records.
  No rejected command ran. Separate staging DE retrieval block still applies.
  Two asynchronous approval questions were sent for (1) the four test-record
  deletions and (2) DE `X2350A4428` / nationality `AUSTRALIAN` at
  `https://eservices-stg.ica.gov.sg` for retrieval/update. **No reply received yet.**
- Both cargo/convoy acknowledgement rechecks returned no matching messages.
  No new submission, DE retrieval or update was attempted. Native Network Error
  remains unresolved; no current-build ARN success is claimed.
- Preserved original vehicle **SYR0614** and convoy **5751502088140**, as well as
  synthetic vehicle SCB5528R, convoy SBH3349J / SCM1587M (permit IG1AA990046),
  the foreigner draft and both SGAC/QR profiles.
- MyICA at **Home, English** (229). Appium session
  `a0e3aea5-2dac-42e7-a454-1c1b82cfbd3b`, WDA and USB forwarding remain running
  awaiting approval. Processes: WDA 52939, iproxy 52938; session idle timeout 3600s.
  Read `checkpoint-resume.json`, `processes-resume.json`, `session.json` and the
  `*-resume.log` files under `Output/ios-regression-2026-09-10/` before continuing.
  Earlier shutdown records below apply to previous sessions only.
- Validation: 225 PNG/XML pairs, 17 then-existing JSON files and two helper ASTs
  passed integrity checks; fork parity 0 errors/0 warnings; `git diff --check` pass.
  These are direct Appium UI checks, not live Robot-suite passes. No application
  or automation production code was changed.

Next: await the two specific approvals; perform only approved actions, verify
deletion cancellation/confirmation/persistence and profile preservation, and
retrieve the already-accepted foreigner without resubmitting. Do not bypass the
automatic-review rejections. Network diagnosis and additional membership/physical
coverage remain open independently.

### Previous resume and handover history

Resumed at Edwin's request on 10 September 2026. Startup recall and full CLAUDE.md
read completed; connected physical iPad and Appium 4723 verified. Restarting the
existing signed WDA runner to continue local draft deletion and QR variants.
The previous pause below is historical; the specific DE retrieval review boundary
remains pending. Preserve all earlier evidence and pre-existing device records.

The user requested stopping at the next suitable checkpoint. Testing stopped after
creating the mixed resident/foreigner group QR and checking saved-group persistence.
Do not start further testing until the user resumes it. Historical sections below
describe build 15; the current installed app is **1.19.1 build 1**, confirmed by
package metadata and About. No build-selection reply arrived, so this run assessed
the installed build separately.

- Current report: [iOS 1.19.1 regression](../../docs/testing/ios-1-19-1-regression-2026-09-10.md).
- Evidence and private helper state: `Output/ios-regression-2026-09-10/`.
  `fixtures.json` holds exact identities/contact/trip/vehicle details;
  `submission-results.json` holds observed outcomes and references.
- The user explicitly authorized SGAC and cargo/convoy submissions, submission
  deletion checks and mixed resident/foreigner group QR testing. Startup recall
  and full CLAUDE.md read were completed. No production code changes were made.
- Reinstall baseline was not fully empty. Preserve vehicle **SYR0614** and convoy
  ARN **5751502088140** (receipt: SHN0852P / SBL2595P, permit IG1AA990047).
  Neither was edited or deleted. SGAC and QR profile stores were initially empty.
- Resident **TEST IOS RES TEN**: accepted native submission (031) and matching
  Mailinator acknowledgement `sgac-res-1789029920-096632987`. Device-only deletion:
  Cancel retained, Confirm removed, restart and Submitted filter confirmed absence;
  resident profile remained (037–043). Backend cancellation was not claimed.
- Foreigner **TEST IOS FORE TEN**, Australian, passport **U60695720**:
  LAND/CAR rejected invalid VEP (080). AIR/SQ222, arrival 10 September / departure
  12 September, Sydney, Crowne Plaza Changi Airport returned **Something went wrong**
  (099), then was saved as local Draft (102); Submitted filter empty (103).
  Matching email `sgac-fore-1789031479-096640681` confirms server acceptance at
  17:02 and DE **X2350A4428**. Actual Mailinator helper extraction saved
  `foreigner-20260910-de.json`. **Do not resubmit this accepted identity/date.**
  This false failure / local Draft despite server acceptance is a confirmed finding.
- Cargo own vehicle **SCB5528R**: initial OO5E9900003 / 0004 rejected (118).
  Full **OO5E9900000**, partial **OO5E9900001**, quantity 10 then returned
  **Network Error** (121), repeated after restart (137). QR fallback rendered
  correct details without ARN (122); native **Draft** remains.
- New convoy **SBH3349J / SCM1587M**, permit **IG1AA990046**, LVG Yes:
  Network Error (132), fallback QR with correct details and no ARN (133); local
  record persists (134–135). Later cargo and convoy matching-email checks were empty.
  Current-build successful ARN-backed submission/retrieval/deletion is unproven.
- QR profiles were recreated separately from SGAC: resident NRIC/FIN-holder Yes,
  Singaporean / own profile; foreigner NRIC/FIN-holder No, Australian (153, 160–161).
  **IOS MIXED TEN**, Car, 2 Pax reviewed both members (167), displayed readable
  foreign-visitor SGAC reminder (168), and generated QR after selecting
  **NO, I HAVE SUBMITTED SGAC** (169). Saved group survived restart (173).
  Reminder suppression remained unchecked. No duplicate SGAC created.
- MyICA returned to **Home, English** (174). SGAC and QR profiles, mixed group and
  foreigner/cargo/convoy local drafts are retained for follow-up.
- Native Submit SGAC e-Service opened production **eservices.ica.gov.sg** (140);
  no fields populated there. Staging web service loaded separately (141–143).
  Staging web reachability does not establish native cargo endpoint health.

### Remaining work and approval boundary

**Approval note — Edwin, 10 September 2026:** approved saving the synthetic DE
`X2350A4428` and nationality `AUSTRALIAN` for the regression handover and retained
test evidence. User wording: "can you add the note for the approval for saving the
synthetic de and nationality ?" This records approval to save/retain those values.
Testing remains paused. The separate automatic-review requirement for sending them
to the staging retrieval service is still recorded in item 3 below.

1. Test cargo/convoy local-record deletion: Cancel, Confirm, restart absence, profile
   preservation. Target only the new plates above; preserve the original vehicle/ARN.
   These are local records without confirmed server acceptance.
2. Test foreigner local-draft deletion separately from its accepted server record.
3. **Automatic approval review twice rejected entering DE X2350A4428 and nationality
   AUSTRALIAN into eservices-stg.ica.gov.sg. No retrieval fields were entered.**
   It requires explicit user authorization for the payload and destination; saved
   prior authorization was not accepted as proof. On resume, obtain that approval
   for the saved synthetic visitor details/DE before retrieval or update.
   Do not bypass the review or resubmit to obtain another DE.
4. Investigate cargo/convoy native Network Error; recheck acknowledgement inbox
   before any further submission. Earlier build-15 success does not close this.
5. QR follow-up: regenerate after restart, reminder alternate action/suppression,
   membership boundaries, edit/delete, other vehicle variants. Physical QR/MRZ/permit
   acceptance and MyInfo authentication remain outside demonstrated coverage.

### Resume automation

Use the current-day `drive.py`, `mail_capture.py`, fixtures and results. The saved
Appium session ID is historical after shutdown; create a fresh no-reset session.
The run used Appium 3.1.2 at localhost:4723, WDA 11.4.1 on USB localhost:8100,
physical iPad `00008122-000A08312186801C`, iOS 26.6.1.
Restart the existing signed WebDriverAgentRunner project under
`~/.appium/node_modules/appium-xcuitest-driver/node_modules/appium-webdriveragent/`
with the current signing configuration, plus iproxy 8100:8100.
No install, reset, simulator or signing changes are needed.
See `shutdown.json` and `processes.json` for final process state.

Shutdown verified: Appium session `7f9aceb4-33ed-4531-83d0-8f2cab78c0a4`
DELETE returned HTTP 200. Own WDA runner PID 37358 and iproxy PID 37357 were
stopped and verified absent. Existing Appium servers on 4723/4727 were left running.

Validation: 170 PNG/XML pairs, 15 JSON files and both local Python helpers passed
integrity/parsing checks, with zero errors. Capture numbering has intentional gaps
where an action stopped before capture; no missing partner files were found.
`venv/bin/python tools/check_fork_parity.py`: 0 errors, 0 warnings.
System `python3` lacked PyYAML, so the required check used the project venv.
`git diff --check` passed. No live Robot suites were run in this continuation.
Mnemosyne handover checkpoint: `62eb8df97c732c3a`.

UI notes: use slow slash-separated date entry; hide keyboard before dropdown choice.
QR member selection uses the member card; its right-side button opens View/Edit/Delete.
QR tutorial can recur after restart because Don't show this again was left unchecked.
Native text-input wrappers omit values in source; verify screenshots and summaries.
Use approved Mailinator helpers without printing the root .env token.

### Historical SGAC1.0 run acceptance status

- [x] Reconnect and confirm installed build and actual baseline.
- [x] Resident accepted submission, matching email and device-only deletion checks.
- [x] Foreigner accepted email/DE correlated despite native error; duplicate avoided.
- [x] Cargo/convoy submission attempts, error and fallback QR behavior documented.
- [x] Mixed Car group selection, reminder, generation and saved-group persistence.
- [x] Foreigner DE retrieval/update — acknowledged; PDF shows exact new mobile; fresh retrieval passed with contact masked.
- [x] Cargo/convoy and foreigner draft deletion — confirmed absent after restart; profiles and originals retained.
- [x] QR Car/Motorcycle/Bus/Lorry generation, tested minimum membership, rename persistence, reminder routes/suppression and group deletion.
- [ ] Current-build successful cargo/convoy ARN-backed flows — network issue unresolved.
- [ ] Independent stored-mobile readback — contact masked; no matching update email observed.
- [ ] Upper QR membership limits and physical acceptance — not counted as passes.

## Mailinator follow-up

Automation shutdown requested by Edwin: the regression WDA session
`3A007883-C2B6-4005-9966-0CAFEDE7AB20` was closed successfully. Its xcodebuild
runner (PID 28700) and USB forwarder (PID 24614, port 8100) were stopped and verified
absent. The old Appium session `e6b0eeb2-af13-4a22-9dab-60d4965cb386` had already
expired. Appium servers on ports 4723 and 4727 were left running. Session IDs and
resume instructions below are historical: restart WDA and create a fresh session
only when testing is requested again. App/test data and evidence were not removed.

- Edwin clarified that the foreigner DE number is in the successful-submission email
  and requested a Mailinator API helper. Implementation and usage are documented in
  [the Mailinator guide](../../docs/testing/mailinator-de-number.md).
- The helper captures new mail, matches submission identity and stores/reloads DE for
  update flows. Offline tests do not resolve this regression's live DE blocker.
- Edwin supplied resident `sgac-res`, foreigner `sgac-fore` and cargo `cargo` inboxes
  at `team380551.testinator.email`; saved in `Data/test_data/submission_email.yaml`.
- Edwin populated the token in root gitignored `.env`; authenticated inbox and message
  reads succeeded without exposing the credential. The user-supplied dummy foreigner
  acknowledgement is now saved in `Data/test_data/sgac_foreigner_acknowledgement.json`,
  with original HTML and API metadata. Existing parsing extracts its dummy DE, but
  capture needs `subject_contains=Singapore Arrival Card` for this email's subject.
  This is template/API validation, not a native update pass or the previous visitor's DE.
  WDA was not restarted and no submission was made. The previous submission went to `example.com`; configuring
  a new Mailinator inbox cannot recover that earlier email. Do not automatically
  duplicate the earlier SGAC submission.

## Goal

Assess SGAC resident, SGAC foreigner, cargo/convoy and QR functionality on the
intended **SGAC2.0** TestFlight build on Edwin's physical iPad. Verify the build
before testing. The 10 September SGAC1.0 run below is retained as separate history.

## Scope and validation

- Verify the device, app build and usable WDA/Appium session.
- Exercise entry/navigation, required-field validation, profile create/view/edit/delete,
  persistence, and available submission flows for resident and foreigner SGAC.
- Exercise cargo vehicle profiles, cargo/convoy forms, permit handling and review.
- Exercise individual/group QR creation, available vehicle variants and validation.
- Capture screenshots and page sources in `Output/ios-regression-2026-09-09/`.
- Distinguish observed application defects, outdated automated tests and prerequisites
  that prevent coverage. Record exact final submission boundaries.
- Preserve pre-existing device records and unrelated worktree changes.

## Historical acceptance criteria — earlier runs

These results retain their original build scope. Use the current SGAC2.0
acceptance checklist in the latest handover above for the resumed run.

- [x] WDA/Appium respond with a usable iPad session and the installed build is recorded.
- [x] Each requested module has observed results and evidence or a specific blocker.
- [x] A durable indexed report records coverage, defects and untested boundaries.
- [x] Obtain approval and attempt resident, visitor, cargo and convoy staging submissions.
- [x] Confirm resident server retrieval and acknowledged health update.
- [x] Capture successful visitor submission acknowledgement and tracking ID.
- [x] Complete cargo/convoy ARN receipt and successful retrieval/update with valid permits.
- [x] Complete visitor retrieval/update with a valid DE reference — staging acknowledgement and PDF verified; fresh retrieval masks mobile.

## Progress and decisions

- Startup recall and full `CLAUDE.md` read completed. Existing Android documentation
  and locator edits are pre-existing user work.
- Appium 3.1.2 is already running on port 4723; the remembered WDA Wi-Fi endpoint
  does not respond. The configured iPad is connected and paired.
- Current iOS Robot suites retain SGAC1 flow assumptions despite SGAC2 locator updates;
  there is no iOS QR suite. Direct UI regression is needed to assess current functionality.
- Device now runs iOS 26.6.1, MyICA 2.0.0 build 15. WDA runs from the existing signed
  Xcode project; USB forwarding serves localhost:8100. Session metadata is in the evidence
  folder's `session.json`; `drive.py` resumes it across invocations.
- Resident manual profile `TEST IOS RESIDENT` saved. Required-field, contact-format,
  terms-gating and no-profile-selection checks passed. Build 15 requires country code,
  mobile and email. All populated values matched the native summary.
- The previous profile-update-required loop did not reproduce. Resident web submission
  prefilled correctly, accepted arrival date and two health answers, and reached review
  (capture 034). The initial phase stopped at review pending approval; the user later
  explicitly approved synthetic staging writes (continuation results below).
- Automation note: RN wrapper element sendKeys can type into the previous focused field;
  coordinate focus plus session `/keys` and visible keyboard controls are more reliable.
  A first footer tap can dismiss focus, requiring a second tap to navigate. Inspect actual
  screenshot/summary values; wrapper source labels do not reliably expose their values.
- User requested Mnemosyne checkpoints and continuation on Sol if this model reaches a
  usage limit. Preference stored; current-session model switching is not exposed as a tool.

## Initial device-side results and validation

- See [the indexed report](../../docs/testing/ios-build15-regression-2026-09-09.md) for
  the coverage matrix, findings and exact limits. All four requested modules were exercised.
- Resident and foreigner reached review, saved email edits and survived restart.
  Required retrieval fields were validated; malformed resident NRIC was rejected.
- Cargo full/partial review and permit edit passed; quantity 0 reaches review and needs
  product-rule confirmation. Convoy two-vehicle review and duplicate rejection passed.
  Vehicle edit, optional blank mobile, restart autofill and delete/cancel passed.
- QR tutorial, individual and Motorcycle group generation, group rename, restart
  persistence, delete cancellation and confirmed group deletion passed locally.
- MRZ camera entry/exit worked from resident and foreigner. Singpass handoff opened
  staging login but no authentication was performed. Language smoke checks: SGAC Tamil,
  QR Malay, cargo Simplified Chinese; all restored to English.
- Visible issues include untranslated visitor group-prompt keys and clipped cargo web
  homepage Important Note text. Additional test-copy/localization observations are qualified
  separately; no app fixes were made.
- Only today's synthetic resident, visitor, cargo vehicle and QR group were removed.
  All empty stores persisted after restart (242–246); MyICA is left at Home (247).
  Inputs are retained in ignored `Output/ios-regression-2026-09-09/fixtures.json`.
- Camera permission was granted for testing and remains allowed. No app reinstall/reset.
  Pre-existing device records, Safari tabs and unrelated worktree changes were preserved.
- Evidence validation: 247 PNG/XML pairs, 0 integrity errors; JSON parsing/helper syntax pass.
- Robot dry run: 5/5 pass, **not** live-suite passes. The live suites need SGAC2 migration;
  there is no iOS QR suite. `tools/check_fork_parity.py`: 0 errors, 0 warnings.
  `git diff --check`: pass.
- Initial-pass WDA status ready (11.4.1). Appium session responded to `/timeouts` and had a
  3600-second idle timeout. Session ID: `3b0fc6ad-92b5-4293-82d4-848192a51673`.
  WDA actual session ID at final check: `3DBD588B-9A55-49A0-86DB-B7CAE8865429`.

## Approved continuation results

- Startup recall and full CLAUDE.md read completed again. The previous WDA had exited;
  its saved Appium session failed with ECONNRESET. Recovered WDA from the same signed
  project and attached a new no-reset Appium session. Existing Appium/iproxy were retained.
- Confirmed staging through read-only device WebKit origin and selected cache metadata:
  `eservices-stg.ica.gov.sg`, with SGAC and cargo submission paths. See
  `Output/ios-regression-2026-09-09/staging-verification.md`.
- Resident recreated with updated email. Final Submit loaded then returned to review with
  no observed receipt/error (262–265); subsequent NRIC/date retrieval confirmed persistence
  (268–269). No duplicate was sent. Changed health to Yes, follow-up No; the update returned
  `Submission updated`, transaction `09/09/2026 03:22 PM` Singapore time (275–276).
- Cargo full `IG2BB990021` and partial `IG2BB990022`, quantity 10, both rejected as
  `Invalid Permit Number` on Submit (284). Convoy `IG2BB990023` rejected likewise (289).
  Neither returned an ARN. Repository permit data is the same generated series, not
  a verified backend-valid fixture. Asked the user for valid staging permits.
- Cargo Scan tutorial/camera area opened; camera-use indicator present, captured preview
  black. Return preserved the form (290–292). No barcode extraction claimed.
- Visitor recreated with matching identity/contact summary (297). Arrival 9 September,
  departure 12 September, Sydney both cities, Business purpose, 8G212 commercial flight,
  Transit, no previous name and two No health answers matched review (315–319).
  Submit returned `Submission received` and a success message (320–321), transaction
  `09/09/2026 03:41 PM` Singapore time; tracking ID
  `TID:cbb8fa8cda5b4b051ec99e09554dcf4c`. No DE number shown. The update service requires
  DE (324), and native profile options offer only View / Edit and Delete (326).
- No email delivery verified; synthetic example.com inboxes are not accessible. Do not
  substitute the tracking ID for a DE number or resubmit a duplicate to obtain one.
- Later fresh visitor form had readable English group prompts (305–309); earlier raw
  translation keys were not consistently reproduced. Moving dropdowns above the keyboard
  with a W3C touch swipe and selecting before hiding the keyboard enabled Sydney/Aero Dili.
- Recreated resident, visitor and cargo vehicle are retained for follow-up. QR group was
  not recreated. Accepted server records were not deleted. MyICA is at Home (327), English.
  No app fixes, reinstall/reset, or unrelated worktree changes were made.
- Continuation validation: 327 PNG/XML pairs, 0 integrity errors; all JSON and helper AST
  checks pass. Fork parity: 0 errors, 0 warnings. `git diff --check`: pass.
  WDA 11.4.1 `/status` ready; current Appium `/timeouts` responds (3600-second idle timeout).
  Current WDA session at check: `3A007883-C2B6-4005-9966-0CAFEDE7AB20`.

## Data helper correction and successful cargo/convoy E2E

User clarified that valid UAT permits are in the Data helper. Reconciled code:
`Data/test_data/manual_field_random.py:generateListofPermit()` generates the distinct
`OO5E9900000`, `OO5E9900001`, ... series, used by `tests/ios/cargo/convoy.robot`.
Earlier `IG2BB...` fixtures came from `Cargo_Test_Data.txt`; those rejections do not
establish that the helper permits are invalid. The earlier assessment missed this
distinction. Startup recall/CLAUDE read and current WDA/Appium health checks passed.

- Exact helper output full `OO5E9900000` and partial `OO5E9900001`, quantity 10,
  succeeded for cargo vehicle `SBA1234G`: ARN `3514402088128`, QR and matching receipt
  (332–333). Retrieval passed (337–338), server email changed to
  `ios.cargo.server.updated@example.com`, update acknowledged (340), and fresh retrieval
  confirmed persistence (341). Mismatched ARN/vehicle retrieval rejected (356–357).
- Convoy initially reused `SBA1234G`, which the backend rejected for an unfinished
  cargo journey (345–346). Preserved cargo, generated distinct checksum-valid plates
  `SCC2817X` / `SAJ0397R` with `_ProfileFactory(seed=20260909,
  reference_date="2026-09-09").generate_list_of_vehno(2)`, and submitted `OO5E9900002`.
  Convoy ARN `3416002088129` and QR returned (349–350). Retrieval using `SCC2817X`
  passed (351–352); mobile changed to `81234568`, acknowledgement retained the ARN
  (354), and fresh retrieval using `SAJ0397R` confirmed persistence (355).
- Convoy update acknowledgement says `Submission received`, unlike cargo's
  `Submission updated`; record persistence still passed. Wording observation in report.
- New finding IOS-06: cargo receipt's Manage link opened production Safari host
  `eservices.ica.gov.sg` (334–335). No fields populated or writes made there. Closed
  only the newly opened tab; preserved all four earlier tabs and used the app's native
  staging retrieval path. Review environment routing.
- `docs/testing/test-data.md` now explains the UAT helper versus text-file distinction.
  `helper-permits.json` records exact provenance; `submission-results.json` records ARNs,
  updates and negative checks. No production app or Data helper code was changed.
- Native profiles and accepted server records are retained for follow-up. Convoy plates
  exist only in the server submission, not as added native profiles. MyICA at Home (358).
- Final helper-continuation validation: 358 PNG/XML pairs, 0 integrity errors; JSON and
  helper AST pass; fork parity 0 errors/0 warnings; `git diff --check` passes. WDA ready
  and Appium `/timeouts` responsive with the same session and 3600-second idle timeout.

## Historical build-15 blocker and next action

Cargo/convoy permit-data blocker is resolved. Need a valid DE reference for the
synthetic visitor, or a suitable existing test submission with matching identity fields,
to verify visitor retrieval/update. Email testing needs an approved accessible UAT inbox;
no new duplicate submissions should be created without agreeing that fixture.

Physical MRZ/permit/QR acceptance requires fixtures/equipment; MyInfo requires a test login.
Remaining variants and boundary cases are explicitly listed in the report, not counted
as passes. Full regression sign-off remains open.

Resume `Output/ios-regression-2026-09-09/drive.py` using `session.json`:
Appium `e6b0eeb2-af13-4a22-9dab-60d4965cb386` on port 4723, WDA USB localhost:8100,
WDA log `wda-submission-reconnect.log`. Check health first if the 3600-second idle timeout
has elapsed. Keep current signing; no IPA install or simulator. Known fixtures and exact
outcomes are in `fixtures.json` and `submission-results.json`.

Mnemosyne checkpoint `105aac1aa58e6473`; Sol-fallback preference `e8fa1e5344efc64a`.
No exposed in-place model-switch tool and no usage-limit switch occurred.
