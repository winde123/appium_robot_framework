# Android emulator flow documentation

- Status: Done
- Owner: Codex
- Priority: Medium
- Created: 2026-09-07
- Updated: 2026-09-07

## Goal

Start the Android emulator, walk the installed MyICA app's flows, capture every reached screen, organise the evidence by category, and produce one illustrated Word document per category.

## Scope

Installed SGAC 2.0 Android build 2.0.0 (420), Pixel_7_Pro emulator. Include home/navigation, resident and foreign visitor profiles and arrival cards, QR codes, cargo, and e-services. Record authentication, hardware, service and unexercised-variant boundaries explicitly. Use synthetic data for newly created walkthrough records.

## Acceptance criteria

- [x] Emulator started and installed build identified.
- [x] Flow inventory reconciled against live navigation and repository suites.
- [x] Reached screens captured as original PNGs, with ordered descriptions and source XML.
- [x] Category folders and one illustrated DOCX per category created in docs/project-documentation/.
- [x] Screen coverage and uncompleted branches reported accurately.
- [x] DOCX archive/image integrity and fork parity checked; documentation indexed.

## Outcome

The [dated package](../../docs/project-documentation/android-sgac2-2026-09-07/README.md) contains **207 original PNG/source-XML captures, 200 documented screens, seven archived transitions/repeats, six Word documents and an HTML gallery**. The continuation added 36 documented captures: 24 e-Service/search screens and 12 home/support/About screens. The six-document download bundle was rebuilt.

All ten e-Service categories and all 32 entry links were opened. Service search covered an empty query, Report (two matches), navigation from a result, test (zero matches), clearing the query and closing search. All Help destination entries, ICA website, loaded privacy/terms pages, expanded Terms General text, the home scam banner and translation-feedback link were captured.

The [flow inventory](../../docs/project-documentation/android-sgac2-2026-09-07/flow-inventory.md) maps the live navigation to all eight Android suite files and their 24 test cases. Completion refers to the screenshot-documentation deliverable and its coverage accounting. It does not mean all application branches, input variants or automated tests passed.

## Observed issues and remaining boundaries

- Trusted Traveller Programme opens `eservices.ica.gov.sg/404.html`, displaying that the page cannot be found (e-Service screen 038).
- Search works for Report/test but exposes raw translation keys for service names and durations (screens 045, 046 and 049).
- Earlier resident and visitor captures show the repeated Profile update required alert after successful update/save. Native downstream arrival-card screens remain unverified; that blocker was not retried during this continuation.
- Race/Dialect reached FormSG with a Singpass requirement. Appointment links use the staging host and check-in needs an identity/application reference.
- Authenticated retrieval, passport/permit extraction, submitted-record retrieval and physical clearance require the corresponding credentials, fixtures or equipment. No government application, report, travel/cargo declaration, appointment action or payment was submitted.
- First-install onboarding, exhaustive languages/nationalities, separate visitor individual QR, profile/vehicle deletion and maximum-capacity QR/convoy/permit variants remain unexercised. Their relationship to the suites is recorded in the inventory.

## Validation

- All 200 documented and seven archived PNG hashes/decoding and matching UI XML passed.
- All six DOCX ZIPs, drawing counts and embedded original-PNG hashes passed.
- macOS textutil imported all six documents and found all 200 screen titles.
- Rebuilt six-document ZIP passed integrity and embedded-document hash checks.
- `venv/bin/python tools/check_fork_parity.py`: **0 errors, 0 warnings**, 238 intentional divergences suppressed.
- `git diff --check` passed. Final local Markdown/gallery link results are recorded in the package's `checks.json`.
- Representative new Citizenship, search, 404 and expanded Terms PNGs were visually inspected. Word page layout was not rendered in Microsoft Word.

The build reused the earlier session's local dependency target: `env PYTHONPATH=/private/tmp/myica-walkthrough-python venv/bin/python docs/project-documentation/_tools/build_documents.py`. Portable dependency/rebuild instructions remain in [the documentation index](../../docs/project-documentation/README.md). No dependency or application/test-code changes were made.

## Session history and retained state

The first session captured 171 originals and documented 164 screens, then paused at the user's request at Other e-Services → Singapore Citizenship and Permanent Residence. Its synthetic profiles, cargo vehicle and car/motorcycle/lorry groups were retained; only the walkthrough bus group was deleted in its management flow.

The user requested continuation on 2026-09-07. Mandatory Mnemosyne recall and full CLAUDE.md read were repeated. The installed build was rechecked (2.0.0/420, Play installer); the expired capture session/server was replaced. The continuation created no new profiles, vehicles, groups or declarations and preserved existing records. Original screenshot pixels were not edited, and the initial capture renumbering was not repeated.

**Final device state: MyICA Mobile Home; emulator left running.** Check the current device/session before future work. The dedicated Appium server uses port 4727 with `ANDROID_HOME=/Users/edwinwan/Library/Android/sdk`; session metadata is in `/private/tmp/myica-walkthrough-session.json`. The helper remains `docs/project-documentation/_tools/capture_android.py`. Only reconnect if the session has expired. Environment, synthetic records and the historical pause are retained in the package's `environment.json`.

The Mnemosyne handoff record is `2bffdc727592c27d`. Shared context is maintained in CLAUDE.md, README.md, docs/README.md, Android STATUS.md and the fork-refactor board. Locator verification states and refactor/runtime acceptance remain separate from this manual evidence.
