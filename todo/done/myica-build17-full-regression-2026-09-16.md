# MyICA 2.0.0(17) full regression

- Status: Done
- Owner: Codex
- Priority: High
- Created: 2026-09-16
- Updated: 2026-09-16

## Goal and scope

Run the requested MyICA Mobile 2.0.0(17) regression on the **iPad only**, including supplied Singpass password credentials. Cover resident/visitor SGAC lifecycles, profiles, QR, cargo/convoy, languages, service links and Home/help/settings. Retest applicable earlier findings and record actual results and coverage limits.

Mandatory startup recall and full CLAUDE.md read were completed. Current device evidence took precedence over older build-15 records. WDA provisioning was renewed and the user completed developer trust; a later runner disconnect was recovered without resetting MyICA.

## Acceptance criteria

- [x] Target, installed build and environment recorded: physical iPad Air 11-inch (M3), iPadOS 26.6.2, MyICA 2.0.0(17), STAGING.
- [x] Every planned module has observed outcomes/evidence and explicit unexecuted boundaries in the report. Physical decoding/clearance/printing, full branch/performance/security matrices and maximum-size backend submissions remain outside demonstrated coverage.
- [x] Supplied Singpass password flow executed: authentication/callback pass; required blank/locked passport data blocks profile completion.
- [x] Applicable earlier findings retested with current evidence; transient and harness failures distinguished from application findings.
- [x] Report/index updated; evidence, relative links, fork parity and whitespace checks pass.
- [x] Final app state and test fixtures documented; this run's local profiles/groups/vehicle and cargo/convoy server records cleaned up.

## Outcome

Execution completed on 16 September, approximately 10:49–14:02 SGT. **This is completion of the regression task, not product release approval.** Ten finding groups have proposed priorities: three High, six Medium and one Low. The High findings concern MyInfo profile completion, saved-visitor submission Loading, and an intermittent BiometricSDK MRZ-camera crash. The full report supplies reproduction details, evidence and limits.

- Nine accepted staging operations have matching delivered-email evidence: resident initial/update, visitor initial/two updates, cargo initial/update and convoy initial/update.
- Common e-Service catalogue: 32 entries, 31 expected destinations and one missing page. Visitor catalogue: 29 child links, 27 expected destinations and two missing pages, plus working direct Customs. Search exposes raw translation keys while matching and tested navigation work.
- QR tutorial, personal/mixed group QR and four vehicle types exercised; 36 SGAC/QR/cargo language selections completed. Favourites limit, cancellation, persistence and exact restoration verified.
- Earlier no-profile callback/no resident receipt, hotel rejection, missing visitor mail and cargo management handoff problems did not recur in the tested scenarios. Remaining/reproduced issues are listed in the report.

## Deliverables

- [Regression report](../../docs/testing/ios-build17-regression-2026-09-16.md)
- [Private local evidence gallery](../../Output/myica-build17-regression-2026-09-16/ios/gallery.html)
- [Validation record](../../Output/myica-build17-regression-2026-09-16/ios/evidence-validation.json)
- [Transaction/email ledger](../../Output/myica-build17-regression-2026-09-16/ios/submission-results.json)
- [Final device state](../../Output/myica-build17-regression-2026-09-16/ios/final-state.json)

Evidence is gitignored, owner-only and local to this workspace. Original screenshots can contain staging identity data. Credentials remain in the gitignored .env and are not included in these documents.

## Validation

- `venv/bin/python -B Output/myica-build17-regression-2026-09-16/ios/build_evidence.py`: 519 valid PNG/XML pairs, 63 input JSON files, 1,533 action entries; zero errors; receipt/email/crash/cleanup assertions pass; no configured secret values in 596 scanned text files.
- `venv/bin/python -B tools/check_fork_parity.py`: 0 errors, 0 warnings; 238 allowlisted intentional divergences.
- SGAC2 iOS Robot dry run: 42 passed / 0 failed. This is suite loading only, not 42 live application passes.
- Relative links and `git diff --check` pass. Production source/locator files were unchanged; unrelated user modifications were preserved.

## Final state and follow-up

MyICA is foregrounded on Home. Resident, visitor and QR profile stores, test QR group and cargo vehicle store are empty after restart. Original six favourites/order, English module languages and tutorial-on setting are restored. Camera permission is allowed. Own cargo and convoy server records were deleted and non-retrieval verified. **Two synthetic SGAC server records for arrival 17 September remain**; no SGAC server-deletion flow was exercised. New navigation-sweep browser tabs were closed and earlier tabs retained. At the user's later request, WDA and the port-8100 USB forwarder were stopped at 15:17 SGT; the general Appium server remains running.

No user input or permission is pending. Product owners should triage the ten findings, investigate the three High blockers, and rerun affected scenarios after fixes or an agreed disposition. Further coverage boundaries are explicit in the report; no unrelated queue item was claimed.
