# Android SGAC2 build 15 — resident and foreigner submission regression

Last reviewed: 2026-09-16

For the next session, use the [handover](../../todo/done/android-sgac-submission-regression-2026-09-11.md#next-session-handover)
for retained fixtures, Appium readiness checks, follow-up choices and checkout state.
The emulator was subsequently closed at Edwin's request; shutdown was accepted
on 11 September and process absence confirmed on 16 September. App data and
evidence were retained. Restart the AVD and create a new session for further testing.

**Outcome:** Both fresh synthetic submissions succeeded, both acknowledgement emails
arrived, and both records were retrieved successfully. The visitor submission used a
hotel selected from the catalogue. Negative validation and update-form navigation
were also exercised. Two content issues remain: literal test markup in the residence
picker, and a **7-day question in the forms versus 6 days in both acknowledgement
emails**. This is a targeted direct Appium regression, not a live Robot-suite pass
or full release sign-off.

Edwin explicitly authorized submissions for this regression. Exactly **two Submit
actions** were executed: one resident submission and one foreigner submission. No
server update or deletion was submitted. Native visitor profile editing was tested
before submission; both accepted server records and both native profiles remain.

## Environment and evidence

| Item | Verified value |
| --- | --- |
| Device | Pixel_7_Pro, `emulator-5554`, Android 16 |
| App | `sg.gov.ica.mobile.app`, `versionName=2.0.0`, `versionCode=422` |
| About | **Current Version: 2.0.0(15) (STAGING)**, capture 002 |
| Driver | Existing Appium 3.1.2 server on port 4723, UiAutomator2 |
| Run | 11 September 2026; submissions 16:17 and 16:25 SGT; final Home 16:34 SGT |
| Evidence | `Output/android-sgac-regression-2026-09-11/`, 100 numbered original PNG/XML pairs |
| Browse | [Local screenshot gallery](../../Output/android-sgac-regression-2026-09-11/gallery.html) |

The emulator was launched with its existing data. No APK was installed or app data
reset. Appium MCP device discovery lacked `ANDROID_HOME`, so the task-local driver
used the repository's existing Appium server and the Android SDK's adb. This run
did not touch iOS/WDA. Evidence is local and gitignored; it is not included in a
fresh repository clone.

## Results

| Check | Result and evidence |
| --- | --- |
| Resident minimum traveller selection | PASS: Continue with no selected profile produced minimum-member feedback (004) |
| Resident empty profile and malformed email | PASS: required fields blocked Next; `bad-email` rejected (006, 009) |
| Resident creation and restart persistence | PASS: reviewed name/identity/contact, saved, present after app restart (007–013) |
| Resident profile → web form | PASS: identity/DOB/UAT email carried over; update-required loop absent (015–017) |
| Resident health validation and review | PASS: unanswered Q1 blocked Next; both No answers and 12 September arrival verified in Review (018–024) |
| Resident submission | PASS: `Submission received`, 11/09/2026 **04:17 PM SGT** (026–027) |
| Resident acknowledgement | PASS: name, arrival date, submission time and No/No answers matched in the new email |
| Resident retrieval | PASS: correct NRIC with 13 September rejected as `Traveller HDC not found`; same NRIC with 12 September retrieved the record (068–071) |
| Resident update entry/validation/cancel | PASS: health Edit revealed unanswered controls; Next required an answer; Cancel returned to the record (072–076). No update submitted |
| Foreigner empty profile | PASS: required identity fields blocked Next (029) |
| Foreigner creation/edit/restart persistence | PASS: profile saved, residence corrected through native Edit, saved again and present after restart (030–040) |
| Foreigner profile → web form | PASS: passport, DOB, expiry, sex, nationality, residence and contact carried over (043–049) |
| Foreigner trip and hotel validation | PASS: dates/cities/health completed; absent hotel blocked Next; a catalogue hotel was selected (046–057) |
| Foreigner review and submission | PASS: reviewed all sections; HOTEL submission accepted at **04:25 PM SGT** (058–064) |
| Foreigner acknowledgement/DE | PASS: passport, name, arrival, mobile, hotel and No/No matched; DE captured with the actual `MailinatorDE.py` helper |
| Foreigner retrieval validation | PASS: empty fields rejected; unrelated dummy DE with this traveller's identity rejected; issued DE with matching identity retrieved the record (080–089) |
| Foreigner update navigation | PASS: both steps advanced to Review with masked fields retained and without re-entering mobile/purpose (090–098). Left through the native Back control; no update submitted |
| Final state | MyICA Home, English; emulator and Appium session left running (099–100) |

Capture 095 was named `foreigner-update-required-validation` before its result
was known. Its actual result is **successful progression to Visit Details**,
not a required-field error.

## Findings and comparison with prior runs

### AND-SGAC-01 — health lookback differs between form and email

Newly observed consistency issue, suggested priority **Medium**. Both resident and
foreigner forms/reviews ask whether the traveller visited listed countries in
Africa or Latin America in the past **7 days**. Both delivered acknowledgement
emails instead describe the past **6 days**. Answers were No in both channels.

Reproduce by completing either manual submission, recording the health question
on Review, submitting once, then comparing the matching acknowledgement's
declaration table. Expected: the acknowledgement repeats the same time window
that the traveller answered. Evidence: 023 and 061, plus the two saved email
responses listed below. This observation does not establish which time window
the underlying requirement intends; the app/email owners need to reconcile it.

### AND-SGAC-02 — literal test markup remains in residence data

Confirmed existing content issue, suggested priority **Low**. Foreign Visitor →
Create New Profiles → Fill Manually → Contact Details → Place of Residence lists
`ALBANIA<h1>test</h1>, OTHERS IN ALBANIA<h1>test</h1>, …`.
Expected: clean country/place labels. Original evidence: 032.

### Other observations and improvements

- Valid native profile fields continue to show `Required` helper text (007, 009,
  030, 036). Forms still save successfully. Confirm whether this is intended
  required-field guidance or should disappear after validation.
- The earlier HOTEL `hotelCd` length error from the
  [10 September round trip](visitor-de-roundtrip-2026-09-10.md) **did not reproduce
  with catalogue selection**: searching MARINA and selecting
  `nameOfHotel-option-L0059` submitted MARINA BAY SANDS SINGAPORE successfully.
  This does not certify arbitrary free-text hotel entries or prove when a fix occurred.
- The same earlier report's forced mobile/purpose re-entry did not reproduce on
  this record: untouched masked fields advanced through both update steps to Review.
  Backend persistence after an actual update was not exercised here.
- The earlier profile-update-required loop and placeholder health question copy
  did not reproduce. No Google Password Manager dialog interrupted this run.
- Native and web forms can move when a keyboard closes or a conditional field
  appears. An initial native Sydney selection resolved to Sydney, Canada; review
  caught it, and native Edit corrected it to Sydney, Australia before submission
  (034–039). This was handled as a harness selection issue, not an app defect.

## Retained records and email correlation

| Item | Resident | Foreigner |
| --- | --- | --- |
| Synthetic name | TEST SEPT ELEVEN RESIDENT | TEST SEPT ELEVEN VISITOR |
| Generator seed | 2026091101 | 2026091102 |
| Arrival | 12/09/2026 | 12/09/2026 |
| Tracking ID | `20426a175c93aaf369a7ba30aeac61a0` | `1abdb99eb807d2d35f2a22d3a2f49a7a` |
| DE | Not required for resident retrieval | `X2351A2728` |
| Inbox | Configured `sgac-res` UAT inbox | Configured `sgac-fore` UAT inbox |
| Message ID | `sgac-res-1789115125-09730094686` | `sgac-fore-1789115480-09730102052` |

`identities.json` retains exact synthetic inputs and generator overrides. The
visitor used AUSTRALIAN nationality, Sydney residence/embarkation/disembarkation,
departure 14 September, Holiday/Sightseeing/Leisure, SQ232 and catalogue hotel L0059.
The resident's adult DOB, test names, UAT email addresses and valid-length phone
numbers were explicit fixture overrides. Both health answers were No.

Mail snapshots were armed before submission. Resident mail arrived at approximately
16:25 SGT; visitor mail at 16:31 SGT. The resident email omits NRIC, so correlation
was verified using the unique name, exact submission time, recipient and arrival
date. The foreigner email was correlated by passport through the shared helper,
which persisted `foreigner-de.json`. Saved raw messages are:

- `resident-message-sgac-res-1789115125-09730094686.json`
- `foreigner-email-0.json`

These live under the run's ignored evidence directory with owner-only file access.
No credentials were recorded. Retrieval masks health/contact fields; the matching
emails independently expose the submitted No/No answers. Masked retrieval alone
must not be used as proof of those values.

## Validation and coverage limits

All 100 numbered screenshots decode and all 100 paired XML sources parse. The
manifest records SHA-256 hashes; local helper ASTs and JSON records parse. Evidence
assertions verify both success receipts, both negative retrieval responses, update
Review, email correlations, the 7/6-day mismatch and final Home. The action log
contains exactly two Submit taps. `venv/bin/python -B tools/check_fork_parity.py`
reports **0 errors / 0 warnings**. See `evidence-validation.json` and
[the completed task](../../todo/done/android-sgac-submission-regression-2026-09-11.md).

No production Robot resources, YAML locators or suites changed. This run covers
one manually created traveller per module and the specified negative checks.
Actual server-update submission/persistence, deletion, multi-traveller submission,
Singpass/MyInfo, MRZ scanning, other transport/accommodation variants, language
coverage and physical immigration clearance are outside this run's results.
