# Android SGAC resident and foreigner submission regression

- Status: Done
- Owner: Codex
- Priority: High
- Created: 2026-09-11
- Updated: 2026-09-16

## Goal and authorization

Open Pixel_7_Pro and regress SGAC resident and foreigner flows on the installed
SGAC2 staging build. Edwin explicitly authorized submissions in this request.
Use fresh synthetic identities and the configured module UAT email addresses.

## Acceptance criteria

- [x] Verify emulator, installed version/build and staging environment.
- [x] Exercise resident profile validation, save/persistence, arrival-card form,
  review and one accepted submission; record the acknowledgement outcome.
- [x] Exercise foreigner profile validation, save/persistence, trip/health form,
  review and one accepted submission; correlate email and DE when available.
- [x] Check retrieval and update behavior where supported, including negative
  validation and independent persistence evidence where exposed.
- [x] Record defects, evidence, coverage boundaries and retained records.
- [x] Return app to Home; validate artifacts and fork parity; index final report.

## Progress

- Mandatory Mnemosyne recall and full CLAUDE.md startup completed.
- Pixel_7_Pro launched without resetting its saved data.
- Existing Appium 3.1.2 server is reachable on port 4723. Appium MCP local device
  discovery lacks ANDROID_HOME; use the repository's configured Appium server.
- Existing iOS documentation/export changes belong to earlier work and are retained.

## Evidence and validation

Run evidence: `Output/android-sgac-regression-2026-09-11/`.
Direct Appium UI regression; this does not establish a Robot-suite pass.

## Outcome

- Verified installed 2.0.0/422 and About 2.0.0(15), STAGING.
- One resident and one foreigner submission accepted at 16:17 and 16:25 SGT.
  Both matching emails arrived; visitor DE captured; both records retrieved.
- Resident/foreigner native creation and restart persistence passed; visitor
  native residence correction persisted into the submission form.
- Negative checks covered empty profiles, resident malformed email, no selected
  traveller, missing health/hotel, empty retrieval, wrong resident arrival and
  wrong foreigner DE. Resident update field validation/cancel passed; visitor
  masked fields advanced through both update steps to Review without re-entry.
- Catalogue hotel L0059 succeeded; the previous hotel-code error did not
  reproduce for this selected hotel. No server update/deletion was submitted.
- New discrepancy: health question says past 7 days in both forms but past
  6 days in both acknowledgement emails. Albania test markup remains.
- Final device state 16:34 SGT: MyICA Home, English; emulator/Appium left running.
  Both synthetic profiles and accepted records remain for follow-up.
- [Final report](../../docs/testing/sgac2-build15-submission-regression-2026-09-11.md)
  contains exact coverage, reproduction steps, retained fixtures and limitations.

Validation: 100 original PNG/XML pairs decoded/parsed; all JSON and helper ASTs
parse; SHA-256 manifest and local gallery produced; both receipts, both negative
retrieval errors, email identities/content and final Home asserted. Exactly two
Submit actions in the log. Fork parity: 0 errors / 0 warnings. No production
Robot/YAML code changed, so no automated suite pass is claimed.

## Next-session handover

Prepared on 11 September 2026 at Edwin's request. This regression and its
documentation are **complete**; there is no running test or pending email poll.
The next session should use this handover to resume context and then work on
Edwin's selected follow-up. The findings below have not been claimed as new tasks.

### Read first and reconcile older memories

1. Recall Mnemosyne for this repository and the new task, then read
   [CLAUDE.md](../../CLAUDE.md) in full before repository work.
2. Read the [final Android report](../../docs/testing/sgac2-build15-submission-regression-2026-09-11.md)
   and this handover. The 11 September run supersedes older **review-only** Android
   checkpoints for these two flows: Edwin explicitly authorized submissions, and
   both were actually accepted. Do not repeat them merely to reconstruct context.
3. Recheck installed build, device/session availability and the working tree.
   Runtime state below is a dated checkpoint, not a promise that processes survive
   into the next session.

### Retained device and session

**Shutdown update:** Edwin subsequently requested closing the emulator. SDK adb
accepted `emu kill` on 11 September at approximately 16:51 SGT, and the following
device list was empty. Process absence was confirmed on 16 September. App data
was not cleared; evidence and retained records were not deleted. The Appium server
was not stopped. Restart the AVD and create a fresh session for future testing.

Last UI verification: **11 September, 16:34 SGT**, screenshot 100, MyICA Home in
English. Pixel_7_Pro (`emulator-5554`, Android 16) and Appium were initially left
running at the end of the regression, before the shutdown above.
No reset, reinstall, profile deletion or server-record deletion occurred.
Installed Android metadata was 2.0.0/422; About showed **2.0.0(15) (STAGING)**.

- Appium: `http://127.0.0.1:4723`, version 3.1.2, UiAutomator2.
- Saved session: `ef34c018-01f3-4845-b24f-be8f95ed2de6`, `noReset=True`,
  `newCommandTimeout=7200` seconds. Historical snapshot; do not reuse after shutdown.
- Session file: `Output/android-sgac-regression-2026-09-11/session.json`.
- Use `/Users/edwinwan/Library/Android/sdk/platform-tools/adb`; mixing it with the
  Homebrew adb caused server-version conflicts in earlier work.
- MCP device discovery lacked `ANDROID_HOME`. This run used the existing local
  Appium server through `drive.py`; it did not require a second server.

Read-only readiness checks from the repository root:

```sh
/Users/edwinwan/Library/Android/sdk/platform-tools/adb devices -l
curl --max-time 10 --fail --silent --show-error http://127.0.0.1:4723/status
```

The emulator should be absent until restarted. For future device work, launch
the existing AVD with `emulator -avd Pixel_7_Pro`; then expect `emulator-5554` in
state `device` and a successful Appium status response. Create a new UiAutomator2
session against the installed package with `noReset=True`. The task-local
`drive.py` has the previously working capabilities in its `start` action.
For further testing, copy the helper into a new dated evidence directory and
save the new session there: its paths are relative to the helper's own directory.
Keep this completed run's captures, action log, session snapshot and manifest intact.

### Records to reuse for retrieval

All identities below are synthetic. Exact contact/profile inputs and generator
overrides are in `Output/android-sgac-regression-2026-09-11/identities.json`.

| Field | Resident | Foreigner |
| --- | --- | --- |
| Native profile name | TEST SEPT ELEVEN RESIDENT | TEST SEPT ELEVEN VISITOR |
| Retrieval identity | NRIC `S6332084F` | Passport `627306406` |
| Nationality | Resident retrieval uses NRIC | AUSTRALIAN |
| DOB | 07/11/1983 | 17/05/1983 |
| Passport expiry | 05/10/2027 | 07/06/2029 |
| Arrival date | **12/09/2026** | **12/09/2026** |
| Issued DE | Not needed | **X2351A2728** |
| Submitted health answers | No / No | No / No |

Use the fixed submitted arrival date for these existing records, not a newly
computed tomorrow. Date eligibility/record retention may change in a later session;
check any retrieval failure before attributing it to an app regression. The visitor
passport is the `foreign_pp_num` value, not the unused generated `pp_num` field.
Tracking IDs and email message IDs are in the report.

Both acknowledgements arrived. Resident mail omits NRIC: match unique name,
recipient, arrival and submission time. Visitor mail was passport-correlated by
the actual `Resources/MailinatorDE.py` helper, with `foreigner-de.json` saved.
Root `.env` supplies the Mailinator token; do not print or copy it into handover
files. Retrieval masks health/contact values; the received acknowledgement emails
independently confirm the original No/No answers.

### Follow-up choices and limits

- **AND-SGAC-01:** reconcile the form/review's past **7 days** with both emails'
  past **6 days**. Evidence already exists in captures 023/061 and saved emails;
  another submission is unnecessary to demonstrate the recorded discrepancy.
- **AND-SGAC-02:** literal Albania test markup remains in residence choices,
  capture 032. Valid fields also retain `Required` helper text; that is an
  observation awaiting intended-behavior confirmation, not a proven save failure.
- Catalogue hotel L0059 submitted successfully. The older hotel-code length error
  was not reproduced on this path; arbitrary free-text hotel handling remains
  unverified. Visitor update reached Review without masked-field re-entry.
- No server update was submitted in this run. If a later task exercises updates,
  independently verify resulting values; reaching Review or seeing masked fields
  does not prove backend persistence. Deletion, multi-traveller, scanning,
  Singpass/MyInfo and other trip variants remain outside this run's coverage.
- For UI automation, let keyboard/conditional-layout changes settle, then inspect
  the selected value. Native Sydney initially resolved to Canada and was corrected
  to Australia before submission. Capture 095's filename mentions validation, but
  the actual result is successful navigation to Visit Details.

### Files, verification and other work in the checkout

Android changes are this completed task, the final report,
`Data/sgac2/android/STATUS.md`, and the Android entries in `CLAUDE.md` and
`docs/README.md`. No production Robot/YAML files changed. No commit or push was
made; the checkout was on `main` at `ec44d54` when this handover was prepared.

The local, gitignored evidence directory contains 100 original PNG/XML pairs,
`gallery.html`, `manifest.json` with SHA-256 hashes, `evidence-validation.json`,
`actions.jsonl`, `identities.json`, `drive.py`, `mail_capture.py`, session metadata
and saved email responses. Raw email files have owner-only access. This evidence
will not be present in a fresh clone; retain the local directory for follow-up.
Exactly two Submit actions were recorded, with zero server updates/deletions.
Image/XML, JSON/helper syntax and outcome assertions passed in the regression.

Pre-existing iOS work remains uncommitted: `Data/sgac2/ios/STATUS.md`, iOS entries
in the shared docs, `docs/testing/ios-1-19-1-regression-2026-09-10.md`,
`docs/testing/ios-sgac2-build15-regression-2026-09-10.md`, `docs/exported/`, and
the task move from `todo/in-progress/ios-module-regression-2026-09-09.md` to
[the blocked iOS handover](../blocked/ios-module-regression-2026-09-09.md).
Preserve these changes. WDA and its port-8100 forwarder were stopped at Edwin's
request at 00:28 SGT; this Android run did not restart or otherwise touch iOS.

Documentation validation for this handover: relative links checked;
`git diff --check` clean; mandatory
`venv/bin/python -B tools/check_fork_parity.py` reports **0 errors / 0 warnings**.
