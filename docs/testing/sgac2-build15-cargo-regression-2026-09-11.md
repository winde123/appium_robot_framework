# SGAC2 Android build 15 regression — cargo and convoy modules

**Last reviewed:** 2026-09-11

Targeted regression of the **Cargo Clearance** module (cargo submission + convoy) on the
installed staging build, continuing the build 15 regression pass after the
[resident + foreigner](sgac2-build15-regression-2026-09-10.md) and
[QR](sgac2-build15-qr-regression-2026-09-11.md) slices. It compares behavior against the
[8 September 2026 E2E baseline](sgac2-build15-e2e-2026-09-08.md). Both submission flows were
driven to the final review; **Submit was not used** in either flow, consistent with the
standing review block. This was a direct Appium UI regression (appium-mcp), not a
Robot-suite run.

## Environment

| Item | Value |
| --- | --- |
| App | MyICA Mobile staging, `sg.gov.ica.mobile.app` |
| Installed build | `versionName=2.0.0`, `versionCode=422`; in-app build 15 |
| Device | `Pixel_7_Pro` emulator, Android 16, `emulator-5554` |
| Driver | Appium 3.1.2 / UiAutomator2 (appium-mcp remote session against `http://127.0.0.1:4723`) |
| Date | 2026-09-11, ~13:09–13:25 SGT |
| Evidence | `Output/sgac2-build15-cargo-regression-2026-09-11/` — 37 PNGs + 37 page-source XMLs, all validated (decode/parse) |

## Outcome summary

| Check | Result | Evidence |
| --- | --- | --- |
| Cargo module entry from Home favourite (`HomeCARGO_CLEARANCE`) | **PASS** — profile-centric landing renders | `001`–`002` |
| Vehicle profile persistence | **PASS** — `SBA1234G` (from 8 Sept E2E) still listed | `002` |
| CONTINUE with no vehicle selected | **PASS** — `Please select a minimum of 1 vehicle profile(s)` alert dialog (baseline behavior) | `003` |
| Add Vehicle flow (**SGI5915Y**, generator seed 1109202611) | **PASS** — saved via `AddVehicleVehicleNumber` / `InfoAndVehiclesAddEmail` / `AddVehicleMobileNo`, listed newest-first | `004`–`007` |
| Vehicle row-tap selection + CONTINUE | **PASS** — opens 3-step Cargo Submission webview | `008`–`010` |
| Cargo webview contact/vehicle carry-over | **PASS** — profile email `cargo.build15@example.com`, mobile `81234567`, vehicle `SBA1234G` prefilled | `010` |
| Cargo step 1: Low Value Goods = NO (webview radio, coordinate tap) | **PASS** | `011` |
| Cargo step 2: full permit `IG2BB990021` + partial permit `IG2BB990022` qty 10 | **PASS** — both saved with per-type counters, edit/delete controls | `012`–`018` |
| Cargo step 3 Review + Submit boundary | **PASS** — all values correct at review; Submit captured, unused | `019`–`021` |
| Convoy entry (3-step webview with full gov-site chrome) | **PASS** | `023` |
| Convoy step 1: contact, LVG = YES, vehicles `SBA1234G` + `SGI5915Y` (15-vehicle max noted) | **PASS** — contact NOT prefilled (convoy is not profile-bound) | `023`–`027` |
| Convoy step 2: Next without permit | **PASS** — `Please fill in the field above` required feedback (baseline behavior, now with LVG=YES) | `028`–`029` |
| Convoy step 2: full permit `IG2BB990023` | **PASS** — saved, counter 1 | `030` |
| Convoy Review + Submit boundary | **PASS** — LVG YES, both vehicles, permit at review; Submit captured, unused | `031`–`033` |
| Cargo language picker inventory | **PASS** — same 12 languages as QR/SGAC (English left selected) | `035`–`036` |
| Returned to MyICA Home | Done | `037` |

## Deltas vs the 2026-09-08 baseline

**Defects still present:**

- The native cargo announcement still renders
  `This is for testing Common Broadcast Message.` **four times** (`009`, `022`, `034`).
  It loads asynchronously — on first entry the banner area may show only the
  (legitimate) Customs Act/REIA reminder before the test broadcast appears (`002` vs
  `009`), which can fool a quick check into thinking it was removed.
- The cosmetic `Required`/`Optional` helper text renders under the native Add Vehicle
  fields even when filled (`006`) — same defect family as the profile and QR forms.
- The language list styles **BENGALI** in Latin script while peers use native
  script/names (`035`) — consistent with the QR module observation.

**Not re-checked this run:** the `vechicle` typo (empty-state guidance never shown —
vehicle profiles existed throughout); permit/vehicle barcode scanning and ARN retrieval
(need fixtures/references); the 100-permit / 15-vehicle maxima (noted on screen, not
load-tested); language content beyond the picker inventory.

**Consistent-by-design observations:**

- Convoy step 1 does **not** prefill contact details (unlike the cargo flow, which pulls
  them from the selected vehicle profile) — matches the baseline flow split.
- Webview email input auto-uppercases (`CARGO.BUILD15@EXAMPLE.COM`), as on the SGAC forms.
- Convoy permits offer Full Clearance only; the cargo flow offers Full + Partial (with
  quantity), as in the baseline.

## Test artifacts left on device

- New vehicle profile **SGI5915Y** (email `DANIEL_THOMAS@test.co`, mobile `83516599`)
  saved alongside `SBA1234G`. No profile was deleted.
- Cargo and convoy drafts were driven to review but **not submitted**; permits
  `IG2BB990021`–`IG2BB990023` exist only in those abandoned drafts.
- Cargo module language remains English; app left at **MyICA Home**.

## Harness findings

- The no-vehicle validation is a **native alert dialog** (`android:id/message` /
  `android:id/button1`), not an inline helper — it blocks the page until dismissed.
- Add Vehicle native inputs accept plain `setValue` directly (no protected-input
  clearing); the webview inputs needed tap-then-W3C-Actions typing.
- Webview permit/quantity inputs surface in the accessibility tree as generic
  `android.widget.EditText` nodes with no ids; the convoy step 1 inputs were **absent
  from the tree** on first load and appeared only after interaction — locate them from
  screenshot coordinates first, then re-read the tree.
- Convoy LVG radios expose `checked=false` regardless of state (same webview radio
  limitation as the SGAC forms); verify selection from screenshots or the review page.
- One system back from the cargo review webview returns to the cargo native home
  (draft abandoned silently — no confirmation prompt).

## Boundaries

Not covered: actual Submit results (both flows stopped at the boundary); ARN/submitted
record retrieval via Manage Cargo Submission (needs a submitted reference; the earlier
iOS UAT ARNs belong to the iOS run — retrieval was intentionally out of scope here);
scanning; language content sweeps beyond the picker; Robot suite execution (cargo suites
still fail on sgac1-era refs pending T33; `readfromfile()`'s 100-permit contract remains
covered by unit tests). The remaining build 15 slice is the **language sweep**.
