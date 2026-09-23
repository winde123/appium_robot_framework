# MyICA 2.0.0(18) full regression

- Status: Done
- Owner: Codex
- Priority: High
- Created: 2026-09-19
- Updated: 2026-09-19

## Goal and scope

Run the requested full regression on the connected physical iPad with MyICA Mobile
2.0.0(18), using the [build-17 regression](../../docs/testing/ios-build17-regression-2026-09-16.md)
as the scope baseline. Exercise resident/visitor profiles and SGAC lifecycles,
Singpass/MyInfo, personal/group QR, cargo/convoy, languages, service links,
Home/help/settings, and applicable prior findings. Record observed results and
explicit coverage boundaries. Preserve pre-existing device data and repository edits.

## Acceptance criteria

- [x] Record installed build, About/environment, physical device and automation baseline.
- [x] Exercise each baseline module with current evidence and assess all ten build-17 findings; record blocked downstream paths.
- [x] Correlate accepted staging transactions with retrieval and delivered email where available.
- [x] Restore settings and remove only fixtures created for this run; document retained SGAC server records and camera permission.
- [x] Publish an evidence-backed report and gallery, update the docs index, and validate artifacts.

## Validation plan

Live Appium/XCUITest UI checks with paired screenshot/page-source captures. Use
synthetic fixtures, scoped staging transactions, and private local credentials.
Verify receipt/email identifiers and changed values independently. Separate Robot
suite loading checks from live product outcomes. Validate evidence, links, fork
parity and whitespace. No physical passport/permit decoding, checkpoint clearance,
printer output, production e-Service transactions or load/security certification
is implied by this regression.

## Progress and decisions

- Mandatory Mnemosyne recall and complete CLAUDE.md read completed.
- Connected iPad Air 11-inch (M3), iPadOS 26.6.2; installed metadata confirms 2.0.0(18).
- Appium 3.7.0 is ready; WDA/port-8100 forwarding were stopped after the previous run.
- Android emulator is offline. Scope follows the previous iPad full regression and
  the connected device carrying the requested build.
- Existing unrelated worktree changes are retained.
- WDA restored using existing signing; fresh Appium session established without
  resetting MyICA. The prior Appium process exited during initial session creation;
  a fresh 3.7.0 server recovered connectivity.
- Installed metadata and About both confirm **2.0.0(18), STAGING** with
  `https://eservices-stg.ica.gov.sg`.
- Singpass staging password authentication and callback succeed. Required passport
  number/expiry remain blank and locked. The returned Malaysian profile additionally
  has a required blank/locked Malaysian identity-card field. Next cannot advance;
  exit/cancel preserves the form and confirmed exit returns safely.
- Fresh resident required-field and invalid-email validation exercised. Native
  profile lifecycle and subsequent transaction checks are in progress.
- SGAC2 iOS Robot dry run: 42 passed / 0 failed (loading only). Fork parity: 0 errors,
  0 warnings. These are separate from live product results.
- Resident manual profile validation/save/restart/edit/delete-cancel pass with
  paired evidence 016–034. Submission accepted at **16:54 SGT**, arrival 20 September,
  tracking ID `TID:94dfee6f2ced92e46b8f861b3d4cbe22`; correct retrieval and wrong-date
  rejection verified. Health update No/No → Yes/No accepted at **16:56 SGT** (061).
  A helper initially waited for "Submission received" on the update receipt;
  current UI correctly says "Submission updated", subsequently asserted. No retry
  submission was made for that harness timeout.
- Both resident acknowledgements arrived and match operation timestamps and
  No/No → Yes/No health answers. Initial acknowledgement still says past 6 days
  against the form's past 7 days. Positive health branch still displays
  `X country**` (037). Read-only poll history records delayed observation.
- Visitor native validation/save/restart pass. **B17-04 does not reproduce:** the
  saved-profile route loads promptly and correctly prefills identity, dates,
  nationality, residence, email, country code and mobile (072, 080–081).
- Visitor submission accepted at **17:04 SGT**, arrival 20 September/departure
  23 September, AUSTRALIAN, flight SQ218, catalogue hotel Ascott Singapore Raffles
  Place. Tracking ID `TID:582a095708177ecfc989e778a062d4c6`. Review fields and
  declaration Agree/Disagree checked (098–102). Acknowledgement and current DE
  received; body matches name/passport/mobile/date/hotel. Retrieval/update next.
- Literal Albania test markup reproduces in the residence picker (067), visually
  verified. The positive-health placeholder (037) was also visually confirmed.
- Passport crash-log baseline contains five historical 16 September logs only;
  no build-18 camera session has been run yet. QR stage is next.
- QR tutorial steps 1–7, Previous/Finish and shared resident/visitor store passed.
  Resident marked as own profile. **New failure:** personal QR generation shows
  "Unable to Display QR Code" / error generating QR / check internet, both after
  the save confirmation and a direct dashboard-card retry (120b, 120e).
  `120-qr-personal-render` is an error capture despite its intended-step filename;
  do not count it as a QR render. The save confirmation appeared before the old
  helper's navigation step; that helper ordering was corrected. Group tests for
  all four vehicle types (Car/Bus/Lorry/Motorcycle) return the same error.
  Group settings persist after restart, but QR image rendering is blocked.
  Personal QR also fails after restart. Root cause is not isolated.
- Independent visitor-only personal QR also returns the same generation error
  (145e). All 12 QR languages rendered and English was restored; translated
  expiry labels still retain `September`. Group Delete → Cancel preserves it;
  Confirm removes it. The run's completed resident native fixture was deleted
  (604–605), propagating to QR; visitor remains for further lifecycle checks.
- Visitor missing-field and wrong-DE retrieval rejected; correct current DE
  retrieves the expected passport, birth/expiry dates, nationality and arrival.
  Mobile-only update to 412345679 accepted at **17:26 SGT** (162b), leaving the
  masked country code untouched. Await acknowledgement for B17-06 comparison.
- Update acknowledgement now confirms **B17-06 reproduces**: `6412345679`
  instead of expected `61412345679`, same DE/passport/arrival and 17:26 operation.
  Explicit-country-code control is prepared, not yet submitted.
- All 12 SGAC language settings/dashboard pairs rendered; English restored.
- Visitor native name edit persisted and propagated to the personal QR card
  (168–172, 600). Delete → Cancel preserved it; Confirm removed only this run's
  visitor fixture (173–175). MRZ five-trial entry/dwell/return check started.
- MRZ required a fresh camera permission, allowed for this scanner test. Initial
  coordinate attempts remained on the tutorial and are not camera trials.
  Permission pilot plus **five** repeat camera entry/dwell/return cycles all
  passed (181b–182, 183-mrz-trial-1…5); every checked app state was foreground (4).
  Before/after crash-log lists contain the same five retired build-17 logs only.
  **B17-07 not reproduced in six actual camera sessions**, not proof of a general fix.
  No physical passport was scanned. Explicit-country-code SGAC control next.
- Explicitly entering country code 61 and local mobile 412345679 gives the correct
  full review number 61412345679 (165–166). Control update accepted **17:40 SGT**
  (167); awaiting its acknowledgement. Cargo/convoy lifecycle execution started.
- Cargo native required/invalid-email checks, save, exact plate/mobile edit,
  delete-cancel and restart persistence pass (301–312). Web form prefills
  SBC2930M / 81234568 / the current inbox (313), asserted. Clearing the native
  mobile field exposed a floating numeric keypad that hid accessibility nodes;
  the helper was recovered with focused typing and dismissal, then the actual
  form values were visually verified (308–309). No duplicate profile was created.
- Cargo LVG and permit selection, empty permit, short permit (`BAD`, minimum
  11 characters), duplicate permit and missing partial quantity are rejected
  (314–324). Partial quantity **0** still reaches review (325–327); product
  minimum is unconfirmed. Do not submit zero; positive transaction uses **10**.
- Cargo initial accepted with ARN **5651002088338**, SBC2930M, LVG No, full
  OO5E9900000 plus partial OO5E9900001/quantity 10; receipt QR renders (329–331).
  Receipt Manage link stays inside MyICA. Empty retrieval validation exercised;
  wrong vehicle remained on retrieval form, correct pair retrieved expected
  contact/vehicle/permits (334–339). Wrong-vehicle error text was not captured;
  do not claim a specific toast message from 335/335b/335c.
- Cargo delete-cancel preserves the record. Mobile amendment to 81234569 retains
  permits/quantity 10 at review (340); submission receipt captured (341).
- Visitor control acknowledgement received, with **61412345679**, correct DE,
  passport, arrival/hotel and **17:40** operation time. Explicit country-code
  re-entry is again a verified workaround for B17-06 (not a fix).
- **B17-08 reproduces:** Cargo Print gives no visible print interface on normal
  and coordinate taps (342–343). PDF opens native share sheet (344). No physical
  printing, messaging or file-save action selected.
- Save QR also opens native image share sheet (346). Fresh retrieval through
  native Manage Cargo confirms amended mobile **81234569** (347–348). Cargo
  receipt QR is visually verified; its working rendering is separate from the
  failing native land-checkpoint QR module. Convoy form-boundary tests started.
- Cargo initial **17:46:04** and update **17:50:00** acknowledgement emails both
  delivered. ARN, plate, LVG No, both permits, quantity 10 and mobile
  81234568 → 81234569 match independent UI evidence. Seven accepted operations
  so far (resident 2, visitor 3, cargo 2), each with a correlated acknowledgement;
  the visitor mobile-only value mismatch is recorded above, not counted as a pass.
- Convoy empty fields, missing second vehicle and duplicate vehicle rejected
  (352–355). 15 rows added; tapping Add at 15 keeps the count at 15 (357–358).
  All blank additions removed; original email/mobile/SBC2930M/SBD6389U values
  and exactly two rows verified unchanged (359, convoy-boundary-results.json).
- Permit selection is required (361). Scan instructions and live camera render
  (362–363). A replay omitted Return while the scanner modal was open: 367/368
  are **not** review evidence. The modal was explicitly exited and the permit
  re-entered; actual verified review is 368c. No submission occurred during the
  replay error. Physical permit decoding remains untested.
- Fixture values and replay inputs are private under the build-18 evidence
  directory. No old result artifacts are copied as new evidence.
- Convoy attempt with active cargo vehicle SBC2930M was rejected with **Invalid
  Vehicle Number** (369), not build-17's explicit unfinished-journey text. Fresh
  SBE9157Y + SBD6389U control accepted with ARN **1928702088339** (371), LVG Yes,
  full permit OO5E9900002. First-vehicle retrieval returns both vehicles and the
  permit (372–373). Mobile-only amendment to 81234570 verified at review (374).
- Convoy amendment accepted with same ARN (375 says **Submission received**, not
  updated); fresh second-vehicle retrieval asserts mobile 81234570 (376). Delete
  Cancel preserves it; confirmed delete shows **Submission deleted successfully**
  (378), same ARN/vehicle stays at retrieval (379). Separate cargo still retrieves
  amended mobile 81234569 (380). Own cargo delete acknowledged (381), post-delete
  retrieval stays on form (382). Native vehicle removed and empty after restart
  (383–384). Both run-owned cargo ARNs and native vehicle are now cleaned up.
- Convoy initial **18:06:14** and amended **18:07:38** emails arrived; same ARN,
  both vehicles, LVG Yes, permit and 81234567 → 81234570 match. Offline receipt/
  email correlation verifies **9 accepted operations / 9 acknowledgements**, with
  the one intentional failing mobile-only comparison and no artifact errors.
- All 36 language selections complete (12 each QR/SGAC/cargo), English restored.
  Cargo English settings title persists. **French cargo heading is now French**
  (`Sélectionnez les profils de véhicules`), visually verified in 520-cargo-08;
  that Japanese-heading component of B17-05 no longer reproduces.
- Common e-Service child sweep completed: **31** entries, **30 expected pages /
  one missing destination** (Trusted Traveller, 230, screenshot verified). Both
  staging appointment pages load in the first sweep (226–227); no long-wait retry
  is needed. Individual reviewed assertions are in navigation-review.json.
  Direct Customs, Home/help/about/visitor-only links and final restoration remain.
  Safari baseline UUID is preserved; every sweep-opened tab has been safely closed.
- Home hub inventories remain 8 citizen/resident and 9 visitor shortcuts (401–402).
  Settings language entry lists 12 options. Tutorial off persists across restart,
  then original on is restored (439, 444–445). Favourites seventh selection is
  rejected, Cancel retains six, replacing Other e-Services with Customs saves and
  persists; original six IDs **and exact order** restored after restart (490–496,
  favourites-results.json). Search and remaining link sweeps are next.
- **B17-10 reproduced**, screenshot-confirmed: Report search displays raw service/
  duration keys. Two expected matches, correct passport-report destination and
  zero rows for nonsense input pass (487–489).
- Help's five routes pass. Both Home hubs exercised: **13 expected destinations
  and four CBNI maintenance-blocked entries**. Initial short waits show Loading;
  fresh 30-second waits from all four Submit/Retrieve-Void shortcuts show the
  police UAT service's explicit maintenance/unavailable page (457/458/467/468
  `-settled`). Do not count these as working forms or as an app defect. No cash
  declaration was submitted/voided. About/extra/visitor catalogue sweeps remain.
- About's four destinations, IC favourite, ScamShield banner and translation-
  feedback footer pass. Direct common-catalogue Customs initially shows a Safari
  download prompt (404, screenshot verified); no download chosen. Fresh exact-
  route retry loads the expected Customs page, as do both Home hub controls.
  Retain this transient observation, not an isolated app defect. Common catalogue
  coverage now totals **32 entries: 31 expected destinations (one retry), one
  missing destination**. Visitor categories/29 child links are in progress.
- All 15 visitor category routes exercised. **B18-12 added, proposed Medium:**
  visitor Customs also shows the unexpected download prompt (485), then its
  exact-route fresh retry works. Across six Customs opens: two prompts, four
  expected pages (not a statistical rate). Both anomalies visually confirmed,
  no downloads accepted. Root cause app URL/redirect versus website response is
  unisolated; do not describe the anomaly as a single non-repeated occurrence.
  All 29 visitor child destinations are now being swept.
- Visitor child sweep complete: **27 expected destinations / two missing pages**
  (709 Frequent Traveller eligibility; 710 foreign-passport loss). Together with
  230, all three B17-09 routes reproduce. Native common/visitor category counts
  are 10/15; all child ID inventories match the planned 31/29 lists.
- Offline navigation verifier asserts **111 captured attempts**, with 98 expected
  entries, 3 missing destinations, 4 short-wait Loading observations, 4 explicit
  maintenance retries, and 2 Customs download prompts; **zero errors**, no
  unexecuted planned destinations or unreviewed captures. These are observations,
  not 111 unique services or all-pass tests. Final restoration checks underway.

## Completed outcome and validation

Live execution completed approximately **16:46–19:08 SGT**. The
[completed report](../../docs/testing/ios-build18-regression-2026-09-19.md) records
**10 active finding groups (2 High, 7 Medium, 1 Low)**, including two newly observed
groups: land-checkpoint QR generation failure and intermittent Customs download
prompts. Eight of ten build-17 groups reproduce at least in part. Saved visitor
entry and the passport-camera crash do not reproduce. This completes the requested
iPad regression, not defect remediation or a clean release sign-off. CBNI forms
remain externally maintenance-blocked; MyInfo save and downstream land-QR paths
are blocked by the observed findings, not marked passed.

Validation commands were run from the repository root:

```sh
env APP_FORK=sgac2 venv/bin/python -B -m robot --dryrun --exclude fork:sgac1-only --outputdir Output/myica-build18-regression-2026-09-19/ios/robot-dryrun tests/ios
venv/bin/python -B tools/check_fork_parity.py
venv/bin/python -B Output/myica-build18-regression-2026-09-19/ios/verify_submissions.py
venv/bin/python -B Output/myica-build18-regression-2026-09-19/ios/review_navigation.py verify
venv/bin/python -B Output/myica-build18-regression-2026-09-19/ios/build_evidence.py
venv/bin/python -B Output/myica-build18-regression-2026-09-19/ios/validate_handoff.py
git diff --check
```

- Robot dry run: **42 loaded, 0 failed**, not live product passes.
- Fork parity: **0 errors, 0 warnings**.
- Submission verification: **9 accepted / 9 correlated acknowledgements**, one
  known visitor mobile-value mismatch, zero artifact errors.
- Navigation verification: **111 reviewed observations**, zero errors/unreviewed
  captures/unexecuted planned entries; common and visitor child inventories match.
- Evidence: **521 PNG/XML pairs**, valid images/structured artifacts/helper syntax,
  result assertions and configured-secret checks pass. Private gallery and hashes
  generated. Final validation details are in `evidence-validation.json` and
  `handoff-validation.json` under the evidence directory.
- Handoff validation: **54 document links, 1,564 gallery links, 521 gallery
  captures**, zero errors. `git diff --check` exits 0. Unrelated pre-existing
  changes remain intact.

## Next-session handoff

- Final restart evidence 606–613 confirms resident/visitor/shared QR stores and
  native cargo store empty, no run-owned personal/group QR fixture, English,
  tutorial-on and original six favourites in exact order. MyICA left at Home,
  foreground state 4. Final crash-log list contains only five historical
  16 September logs. Camera permission newly allowed for scanning remains allowed.
- Both run-owned cargo/convoy server deletions were acknowledged. Resident and
  visitor SGAC server records **remain in staging**; native profile deletion does
  not remove them. Current references and correlation artifacts are in the report
  and private `submission-results.json`.
- All link-test Safari tabs closed; exact baseline UUID set preserved. The Safari
  baseline was taken after Singpass, before navigation testing, not before the run.
- Own Appium session closed and subsequent request returns invalid session ID.
  WDA host runner PID 29186 and USB forwarder PID 29195 stopped and absent from
  process listing. Appium 3.7.0 PID 29542 left ready on port 4723. Recheck state,
  restart WDA/forwarding and create a fresh session before future iPad testing.
- Private evidence and helpers are in
  `Output/myica-build18-regression-2026-09-19/ios/` (gitignored, restricted file
  permissions). Credentials stay in ignored `.env`. Text evidence is checked for
  configured secrets; original screenshots may contain account identity and are
  not publication-ready redacted artifacts. No external upload was performed.
- No application code, Robot resources, YAML locators or unrelated working-tree
  changes were modified. Report, docs index and CLAUDE.md contain the new handoff.
- Follow-up requires triaging the recorded findings and rerunning CBNI form entry
  when police UAT maintenance ends. Root cause and release disposition are not
  established by this run; no fixes or production transactions were attempted.
