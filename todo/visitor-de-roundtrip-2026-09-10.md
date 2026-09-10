# Visitor (foreigner) SGAC DE round trip — mission brief

- Status: Ready — execute with the `sgac-de-roundtrip` OpenCode agent
- Author: Claude (dev lead), 2026-09-10
- Closes: the last open acceptance box in
  [`todo/in-progress/ios-module-regression-2026-09-09.md`](in-progress/ios-module-regression-2026-09-09.md)
  ("Complete visitor retrieval/update with a valid DE reference") and verifies the
  submission → email → update round trip left unverified in
  [`docs/testing/mailinator-de-number.md`](../docs/testing/mailinator-de-number.md).

## Objective

Make ONE fresh synthetic foreigner SGAC submission on staging whose contact email
is the Mailinator UAT inbox, capture the confirmation email's DE number with the
repository helper, then verify retrieval and update of that submission using the DE.

## Platform decision

Run on the **Android Pixel_7_Pro emulator, `APP_FORK=sgac2`, MyICA 2.0.0 build 15
(vc422)**. Rationale: the iPad's WDA session was shut down on 2026-09-10, and the
DE record is server-side — capturing it via Android still yields a valid DE +
identity that can later close the iOS-native update check without a new submission.
Keep `Output/visitor-de-roundtrip-2026-09-10/de-record.json` and the identity
fixture for that follow-up.

## Preconditions (verify before phase 1; stop and report if missing)

1. Appium server responding at `http://127.0.0.1:4723` (start with `appium` or
   `python3 subprocess_call.py`).
2. Emulator booted; `sg.gov.ica.mobile.app` is the SGAC2 build (versionCode 422).
   If the installed fork is wrong, one run with `ENFORCE_APP_INSTALL=True`.
3. Mailinator token usable — verify WITHOUT printing it, e.g.:
   `venv/bin/python -c "from Resources.MailinatorDE import MailinatorDE; m=MailinatorDE(); m.start_sgac_email_capture('precheck','sgac-fore@team380551.testinator.email','PRECHECK'); print('token+inbox OK')"`
4. Evidence directory `Output/visitor-de-roundtrip-2026-09-10/` (gitignored).

## Hard rules (all phases)

- Staging only (`eservices-stg.ica.gov.sg` paths inside the app's webview).
- Exactly ONE submission. A failed/ambiguous Submit = capture evidence, stop, report.
- Never print/log `MAILINATOR_API_TOKEN` or `Authorization` headers.
- No `git commit`/`git push` — the dev lead reviews and commits all output.
- Preserve pre-existing app records; delete only artifacts this run created if
  cleanup is required; return the app to MyICA Home at the end.

## Phase 1 — submission (`de-submission-driver`)

1. `Generate Profile Record` (Library `Data/test_data/manual_field_random.py`)
   with an explicit seed; save seed/reference-date/identity to
   `Output/visitor-de-roundtrip-2026-09-10/identity.json`.
   Contact email MUST be `SGAC_FOREIGNER_SUBMISSION_EMAIL`
   (`sgac-fore@team380551.testinator.email` from `Data/test_data/submission_email.yaml`).
2. Create the foreigner profile (locators: `${FORK_DATA_DIR}/android/sgac/foreigner/`;
   build 15 contact page needs residence + country code + mobile + email).
3. Proceed to the individual arrival-card submission; fill arrival details
   (near-term arrival date, simple purpose, two health answers) and reach review.
4. **Same Robot/rf-mcp session as phase 2 if possible:** arm
   `Prepare Foreigner SGAC Email Capture    de-rt-20260910-<seed>    <email>    <passport|arrival-date as rendered>`
   immediately BEFORE tapping Submit.
5. Submit once; capture receipt/acknowledgement (numbered PNG+XML pairs).

## Phase 2 — DE capture (`de-email-capturer`)

- Preferred: in the SAME process that armed the capture, call
  `Capture Foreigner SGAC DE Number    de-rt-20260910-<seed>    store_path=Output/visitor-de-roundtrip-2026-09-10/de-record.json`
  (default subject first; on timeout retry once with
  `subject_contains=Singapore Arrival Card` — the subject observed on the dummy email).
- **Re-arm caveat:** `Start SGAC Email Capture` snapshots existing message IDs and
  its start time at arm time. Arming AFTER the confirmation email has landed will
  classify that email as old and never match it. If the arming process died after
  Submit, do NOT re-arm-and-wait; instead run the documented recovery: use the
  helper class directly in Python (token-safe) to list the inbox, fetch the newest
  message matching subject + this run's passport number, extract via
  `_message_text` + `_extract_de_number`, and write a schema-1 record JSON loadable
  by `Load SGAC DE Number`. Record in the report that recovery was used.
- Never reuse the dummy fixture DE `X8276T7137`.

## Phase 3 — retrieval/update (`de-update-verifier`)

1. Load the DE (`Get Foreigner SGAC DE Number For Update` with the store_path).
2. In-app visitor update/retrieval: retrieve with DE + identity; verify visible
   fields match phase 1 (note masked fields as masked, not mismatched).
3. ONE low-risk update (health answer or mobile). Do NOT change the email address.
   Confirm acknowledgement wording verbatim; fresh retrieval to confirm persistence.
4. Negative check: one wrong-DE/identity retrieval must be rejected.

## Deliverables

- `docs/testing/visitor-de-roundtrip-2026-09-10.md` — indexed report (result
  overview, findings, evidence ranges, exact boundaries), linked from `docs/README.md`.
- Updated `todo/in-progress/ios-module-regression-2026-09-09.md` (tick the DE box
  ONLY if phase 3 verifies on-device; an Android pass closes the round trip but
  note it was Android — leave an explicit line if the iOS-native rerun is still wanted).
- Mnemosyne checkpoint: outcome, DE record path, seed, evidence location, open items.
- NO git commits — leave the tree for dev-lead review.
