# Visitor SGAC DE-number round trip — 10 September 2026

Last reviewed: 2026-09-10

Status: COMPLETE. Submission → confirmation email → DE capture → retrieval →
update → update-acknowledgement email all verified end-to-end on staging using
`Resources/MailinatorDE.py`. This closes the visitor DE retrieval/update
boundary left open by the [iOS build 15 regression](ios-build15-regression-2026-09-09.md);
the round trip ran on Android SGAC2, and the captured DE record remains valid
for an optional iOS-native update rerun without a new submission.

## Result overview

| Step | Result | Evidence |
| --- | --- | --- |
| Fresh foreigner submission (DAWN MARTIN, passport 012226858, seed 20260910) | Attempt 1 (HOTEL) rejected server-side (RT-01); attempt 2 (TRANSIT) succeeded: `Submission received`, 10/09/2026 06:26 PM SGT, `TID:8d888bfba3ed6a9778fbff71e22e237a` | r2-01…r2-20, receipt-02 |
| DE capture from confirmation email | DE `X2350A4526` from message `sgac-fore-1789036285-09726748145` (18:31); schema-1 record stored | `de-record.json` |
| Retrieval with DE + identity | Record retrieved; update flow entered | retrieval-01, update-01…07 |
| One low-risk update | Mobile `471170887→471170888` and health Q1 `NO→YES` (follow-up NO); `Submission updated`, 10/09/2026 07:34 PM SGT | update-08…19 |
| Server-side persistence | 19:41 update-ack email contains `YES` and `471170888`; the 18:31 original contains neither (old mobile only) | `update-ack-email.json` (`sgac-fore-1789040485-09726850111`) |
| Fresh retrieval after update | Record found with the same DE; previously submitted values render as `Hidden` (masked by design, matching iOS behaviour) | update-26…28 |
| Negative check | Wrong DE (`X8276T7137`) with correct identity → `Singapore Arrival Card record not found` | update-22, update-23 |

The device inbox correlation withstood a concurrent session: the shared
`sgac-fore` inbox simultaneously received emails for another submission
(DE `X2350A4428`, different passport); identity matching on passport number
selected only this run's messages.

## Findings for triage

| ID | Observation | Evidence / disposition |
| --- | --- | --- |
| RT-01 | HOTEL accommodation submissions fail server-side: `…submission.trip.hotelCd: size must be between 0 and 5`. The app sends the free-text Name of Hotel into a 5-char backend code field, so realistic hotel names cannot be submitted; the app bounces to Review with an error banner | receipt-01. Possibly related to iOS finding IOS-05 (silent bounce-to-review). Raise with app/backend team |
| RT-02 | First positive retrieval returned `The system has encountered an issue during retrieval. Please try again later.`; identical input succeeded ~90 s later | update-25 vs update-26. Transient staging error; note for suite retry logic |
| RT-03 | Update flow shows the known `X country**`/`*Kerala or West Bengal` placeholder health copy | update-10. Consistent with IOS-04 and Android build 15 observations |
| RT-04 | The update form does not prefill Purpose of Travel or Mobile Number (both required re-entry) while all other fields arrive masked; the declaration checkbox must be re-accepted and client-side-blocks Submit until checked | update-05…07, update-17…18. Confirm intended UX; suites must re-fill these fields in update flows |

## Verification chain for the helper

`Start SGAC Email Capture` was armed pre-submit with `expected_text` = passport
number; `Wait For SGAC DE Number` matched the fallback subject
(`Singapore Arrival Card` — the live subject is
`[Auto-Acknowledgement] Singapore Arrival Card (SGAC) - Acknowledgement…`,
which the default `SG Arrival Card` does NOT match — suites should pass
`subject_contains=Singapore Arrival Card`). The stored schema-1 record loaded
back for the update phase. Ambiguity guards excluded the concurrent session's
DE and the dummy fixture DE.

## Environment, evidence and process notes

- Pixel_7_Pro emulator (`emulator-5554`), `APP_FORK=sgac2`, MyICA 2.0.0 /
  versionCode 422 (in-app build 15), staging web flows inside the app.
- Evidence (gitignored): `Output/visitor-de-roundtrip-2026-09-10/` — submission
  journey `r2-01…20`, receipts, `retrieval-01`, `update-01…29`, `identity.json`
  (seed/overrides/outcomes), `de-record.json`, `update-ack-email.json`.
- Executed by OpenCode agents (`sgac-de-roundtrip` + subagents) for phases 1–2
  and the start of phase 3; the run was interrupted twice by infrastructure
  (model-provider account suspension, then headless permission auto-rejects on
  the macOS temp dir), and the dev lead completed the phase 3 remainder
  directly via Appium MCP. Exactly one submission and one update were sent.
- App returned to MyICA Home (English). The DAWN MARTIN native profile and the
  accepted server records are retained for follow-up (e.g. iOS-native update
  rerun using `de-record.json`).
