# SGAC2 Android build 15 regression — QR code module

**Last reviewed:** 2026-09-11

Targeted regression of the **QR Code Clearance** module on the installed staging build,
continuing the build 15 regression pass after the
[resident + foreigner slice](sgac2-build15-regression-2026-09-10.md). It compares behavior
against the [8 September 2026 E2E baseline](sgac2-build15-e2e-2026-09-08.md) and the
[7 September walkthrough](../project-documentation/android-sgac2-2026-09-07/README.md).
This was a direct Appium UI regression (appium-mcp), not a Robot-suite run; the
`yaml_QR_pages/` locator files remain unverified sgac1 copies (see STATUS).

## Environment

| Item | Value |
| --- | --- |
| App | MyICA Mobile staging, `sg.gov.ica.mobile.app` |
| Installed build | `versionName=2.0.0`, `versionCode=422`; in-app build 15 (verified via dumpsys before the run) |
| Device | `Pixel_7_Pro` emulator, Android 16, `emulator-5554` |
| Driver | Appium 3.1.2 / UiAutomator2 (appium-mcp remote session against `http://127.0.0.1:4723`) |
| Date | 2026-09-11, ~12:27–12:40 SGT |
| Evidence | `Output/sgac2-build15-qr-regression-2026-09-11/` — 26 PNGs + 26 page-source XMLs, all validated (decode/parse) |

## Outcome summary

| Check | Result | Evidence |
| --- | --- | --- |
| QR module entry from Home favourite (`NEW` badge tile) | **PASS** — welcome/tutorial prompt shown, dismissible | `001`–`003` |
| Pre-existing data persistence (from 07/08/10 Sept sessions) | **PASS** — individual `WALKTHROUGH QR RESIDENT` and group `BUILD15 MOTORCYCLE` (2 Pax) still listed | `003` |
| Passport QR Profiles list (shared store) | **PASS** — all 4 profiles present: WALKTHROUGH QR RESIDENT (My Profile), JOHNATHAN BROWN, CHRISTINA HUNTER, QR VISITOR SEPT, expiries correct | `004` |
| Individual QR render | **PASS** — ICA crest QR, "Valid Until: 31 August 2027", correct profile binding, passport advisory | `005` |
| Saved group detail + regenerate (BUILD15 MOTORCYCLE) | **PASS** — 2 members intact; QR renders; foreign-visitor SGAC reminder dialog fires with correct wording | `006`–`008` |
| Create new group QR — step 1 form | **PASS** — name input, Vehicle Type dropdown (Car/Bus/Lorry/Motorcycle all render), member checkboxes (min 2/max 10) | `010`–`013` |
| Create new group QR — review + generate (**BUILD15 QR REG CAR**, Car, CHRISTINA HUNTER + JOHNATHAN BROWN) | **PASS** — review correct; QR renders; SGAC reminder fires (group contains a foreigner) | `014`–`016` |
| App-restart persistence (force-stop → relaunch) | **PASS** — both groups survive: BUILD15 QR REG CAR (Expiry 18 Jan 2029 \| 2 Pax), BUILD15 MOTORCYCLE (Expiry 03 Mar 2028 \| 2 Pax) | `017`–`019` |
| Language selector | **PASS** — 12 languages (matches 8 Sept count); Hindi applies on card tap; English restored after the check | `020`–`022`, `025` |
| Returned to MyICA Home, English | Done | `026` |

## Deltas vs baselines

**Defects still present:**

- **Mixed English month names in Hindi QR content** (8 Sept baseline defect) **reproduces**:
  QR home shows `समाप्ति: 29 March 2028` / `समाप्ति: 18 January 2029` and the QR view shows
  `QR कोड मान्य है: 31 August 2027`, `पासपोर्ट की समाप्ति: 29 March 2028` — Hindi labels,
  English month names (`023`–`024`). Proper nouns (Woodlands, Tuas, SG Arrival Card) staying
  in English appears intentional.
- **Cosmetic `Required` helper on valid fields** extends to the QR create-group form: both
  Group Name and Vehicle Type show `Required` even when filled/pre-selected with Car
  (`010`, `013`) — same defect family as the profile forms.

**New minor observations (not in prior reports):**

- The language list renders **BENGALI** in English/Latin while other entries use native
  script or native names (हिंदी, தமிழ், 简体中文, 日本語…) — inconsistent list styling (`020`–`021`).
- The **Welcome to MyICA! tutorial prompt reappears on every module entry** (including
  after app restart) unless "Don't show this again" is checked (`002`, `018`). Arguably
  by design, but noisy for automation — scripted flows must dismiss it on each entry.

**Consistent-by-design observations:**

- All QR codes (old and newly generated) show **"Valid Until: 31 August 2027"** — the QR
  validity looks like a fixed scheme end date, not generation date + N (`005`, `008`, `016`).
- The group card "Expiry" in lists is the **earliest member passport expiry** (REG CAR →
  18 Jan 2029 = Brown; MOTORCYCLE → 03 Mar 2028 = QR VISITOR SEPT) (`019`).
- The foreign-visitor SGAC reminder dialog (PROCEED TO CREATE SGAC / NO, I HAVE SUBMITTED
  SGAC) fires on QR generation whenever the group includes a foreigner — matches the iOS
  SGAC2 behavior observed 10 Sept.

## Test artifacts left on device

- New group **BUILD15 QR REG CAR** (Car; CHRISTINA HUNTER + JOHNATHAN BROWN) saved,
  joining BUILD15 MOTORCYCLE and the four profiles. No profile or group was renamed or
  deleted this run (rename/delete CRUD was covered by the 7 Sept walkthrough's bus group).
- QR module language restored to English; app left at **MyICA Home**.

## Harness findings

- Member selection on the create-group form: tap the row card
  (`content-desc="group qr member list card <NAME> …"`) — the checkbox has no separate
  accessibility node; row-tap toggles it.
- The Vehicle Type dropdown did not open from a tap on its text/value node; tapping the
  dropdown-arrow coordinates worked. Options then render as plain text nodes (tap by text
  or coordinates).
- The Group Name field accepted `setValue`-style W3C Actions typing after a focus tap
  (native, non-protected input — unlike the NRIC/passport fields).
- Back-navigation collapses: from a rendered group QR, one system back returns to the QR
  clearance home (not the review step); a second back exits to MyICA Home.
- The welcome prompt and the SGAC reminder are native dialog overlays; both must be
  dismissed before the underlying screen is interactable.

## Boundaries

Not covered by this run: the 7-step tutorial content (prompt shown, tutorial not
re-entered; walkthrough coverage stands); QR scanning at an actual checkpoint (needs
equipment); Bus/Lorry group creation on this build (dropdown options verified rendering
only; walkthrough covered all four types on build 13); rename/delete group CRUD;
non-Hindi language content sweeps; Robot suite execution (`yaml_QR_pages/` locators are
still unverified sgac1 copies — T33-adjacent work). Cargo/convoy and remaining build 15
slices stay queued.
