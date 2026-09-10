# iOS module regression — 9 September 2026

- Status: In progress — post-reinstall submissions, deletion and mixed group QR continuation
- Owner: Codex
- Priority: High
- Created: 2026-09-09
- Updated: 2026-09-10

## Post-reinstall continuation — 10 September

- Edwin reinstalled MyICA and reports that native app data was cleared. Recreate
  synthetic profiles after verifying the installed build and empty stores; reinstall
  does not establish that earlier backend submissions were deleted.
- Explicit authorization renewed for SGAC, cargo and convoy submissions, submission
  deletion behavior, and group QR testing with mixed resident/foreigner members.
- Use the approved Mailinator inboxes and fresh synthetic identities/vehicle plates.
  Capture successful submission, retrieval/update, delete cancellation/confirmation,
  and subsequent retrieval behavior wherever the UI supports deletion. Distinguish
  submission deletion from local profile/group deletion.
- Evidence for this continuation: `Output/ios-regression-2026-09-10/`.
- Installed build is 1.19.1(1), confirmed in About and package metadata; it uses
  SGAC1 native flows. A build clarification was sent; current-build checks proceed
  separately from build 15 evidence. Singpass staging/UAT handoff verified (013).
- Baseline was not fully empty: cargo vehicle SYR0614 and convoy ARN5751502088140
  pre-existed and are preserved. Resident/foreigner profile stores were empty.
- Resident TEST IOS RES TEN created and submitted successfully (031). Delete dialog
  specifies device-only removal; Cancel retained, Confirm removed, restart and
  Submitted Declarations verified absence (037–042). Profile retained (043).
- No matching resident email at initial follow-up checks. Foreigner creation underway.
- New indexed report: `docs/testing/ios-1-19-1-regression-2026-09-10.md`.
- [x] Reconnect WDA/Appium and confirm reinstalled build and actual native baseline.
- [ ] Recreate resident/foreigner profiles and complete authorized SGAC continuation,
  including matching confirmation email/DE and foreigner retrieval/update.
- [ ] Submit fresh cargo and convoy records, retrieve and verify their details.
- [ ] Validate submission deletion controls, cancellation, confirmation and persistence
  or document the observed lack of a supported deletion route per module.
- [ ] Validate mixed resident/foreigner group QR selection, reminders, generation,
  member identity, persistence and relevant edit/delete behavior.
- [ ] Record results, remaining boundaries, evidence validation and final device state.

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

Start WDA and an Appium session on Edwin's physical iPad and assess SGAC resident,
SGAC foreigner, cargo/convoy and QR functionality on the installed TestFlight build.

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

## Acceptance criteria

- [x] WDA/Appium respond with a usable iPad session and the installed build is recorded.
- [x] Each requested module has observed results and evidence or a specific blocker.
- [x] A durable indexed report records coverage, defects and untested boundaries.
- [x] Obtain approval and attempt resident, visitor, cargo and convoy staging submissions.
- [x] Confirm resident server retrieval and acknowledged health update.
- [x] Capture successful visitor submission acknowledgement and tracking ID.
- [x] Complete cargo/convoy ARN receipt and successful retrieval/update with valid permits.
- [ ] Complete visitor retrieval/update with a valid DE reference.

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

## Blocker and next action

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
