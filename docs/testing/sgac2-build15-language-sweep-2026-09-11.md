# SGAC2 Android build 15 regression — in-app language sweep

**Last reviewed:** 2026-09-11

Sweep of the three **in-app module language pickers** (SGAC, QR Code Clearance, Cargo
Clearance) across all 12 languages on the installed staging build. This closes the
language slice of the build 15 regression pass, after the
[resident + foreigner](sgac2-build15-regression-2026-09-10.md),
[QR](sgac2-build15-qr-regression-2026-09-11.md) and
[cargo/convoy](sgac2-build15-cargo-regression-2026-09-11.md) slices. The
[8 September baseline](sgac2-build15-e2e-2026-09-08.md) had only smoke-tested one
language per module; this run applies **every language in every module**. It sweeps the
module home/landing screens — it is not a per-language form-flow walk (the separate
19-language build 13 matrix in `Data/sgac2/android/STATUS.md` covered form screens).

## Environment

| Item | Value |
| --- | --- |
| App | MyICA Mobile staging, `sg.gov.ica.mobile.app`, 2.0.0/vc422 (build 15) |
| Device | `Pixel_7_Pro` emulator, Android 16, `emulator-5554` |
| Driver | Appium 3.1.2 / UiAutomator2, raw W3C HTTP harness (`lang_sweep_b15.py`, session scratchpad) against `http://127.0.0.1:4723` |
| Date | 2026-09-11, ~13:30–13:40 SGT |
| Evidence | `Output/sgac2-build15-language-sweep-2026-09-11/` — 42 PNGs + 42 XMLs (all validated) + `results.json` (per-language matrix) |

## Method

Per module: capture English baseline, then for each remaining language open the picker,
tap the language card (applies immediately — no confirm button), system-back to the
module home, capture PNG + page source. Recorded per language: picker/selection success,
whether the module's language-button testID still resolves, the screen's leading texts,
and every date-bearing string (English-month leak probe). English restored per module;
final state MyICA Home. A foreigner-SGAC spot check ran while the SGAC module was in
Korean.

## Results

**All 36 language applications succeeded (12 languages × 3 modules), and every module
screen fully localizes in every language** — titles, tiles, advisories render correctly
in 简体中文, Bahasa Melayu, हिंदी, தமிழ், Tiếng Việt, বাংলা, Deutsch, Français, ไทย,
日本語 and 한국어, with no crash, blank screen, clipping or tofu observed in the
spot-checked captures. The language-button testIDs resolved in **all 12 languages** for
all three modules — confirming the testID-vs-text stability rule from the earlier
sweeps. English was restored and verified in all three modules (`013`, `026`, `041`).

| Module | Picker inventory | Localization | Lang-button testID |
| --- | --- | --- | --- |
| QR (`QrLanguage`) | same 12 languages | 12/12 localize | resolves 12/12 |
| Cargo (`CargoLanguage`) | same 12 languages | 12/12 localize | resolves 12/12 |
| SGAC (**`SGArrivalCardLanguage`** — id discovered this run) | same 12 languages | 12/12 localize | resolves 12/12 |

The foreigner spot check confirmed the **SGAC language setting is shared** between the
resident and foreigner entry points: with the module set to Korean via the resident
landing, the Foreign Visitor landing rendered fully in Korean (`040`).

## Defects

- **English month names leak in ALL 11 non-English languages — generalizes the Hindi
  finding.** Every QR expiry line renders its label localized but its date in English:
  `过期日: 29 March 2028`, `Tamat Tempoh: 29 March 2028`, `காலாவதி: 29 March 2028`,
  `Ablauf: 29 March 2028` (not *März*), `Expiration: 29 March 2028` (not *mars*),
  `만료: 29 March 2028`, etc. The SGAC landing leaks the same way on profile passport
  expiries (`여권 만료: 18 January 2029`, `040`). This is a **date-formatting defect**
  (dates are not run through the active locale), not a per-language translation gap.
  Evidence: every `NNN_qr-<lang>` pair + `040`; machine-readable in `results.json`.
  The lower leak counts for Tamil (1) and French (2) are a layout artifact — longer
  advisory text pushes the remaining date rows below the fold — not partial fixes.
- **BENGALI picker entry styled in Latin script** while peers use native script/names —
  consistent across all three module pickers (known from the QR slice).
- **Possible Korean terminology inconsistency** (needs native review): the SGAC landing
  titles the module `SG 도착 카드` while its update tile reads `SG 입국 카드 업데이트` —
  two different renderings of "Arrival Card" on one screen (`039`–`040`).

## Boundaries

Swept: module home/landing screens per language. Not swept: per-language form flows,
web-form content, QR render screens in each language, or the cargo webviews (the
8 Sept smoke checks and the 19-language build 13 form matrix stand). Arabic/RTL is
absent from all three build 15 pickers (as recorded on 8 Sept) and the device-locale
override path was not re-run. No YAML, keyword, or Robot suite changed.

## Harness notes

- The SGAC module language button testID is **`SGArrivalCardLanguage`** (QR:
  `QrLanguage`, cargo: `CargoLanguage`) — all three stable across languages, suitable
  for locator files.
- Language cards apply on tap; **system back from the picker returns to the module
  home** reliably (the localized return button need not be located per language).
- 한국어 sits below the fold in every picker — one swipe required before tapping.
- Sweep driven by raw W3C HTTP against the Appium session (~6 s/language including
  captures); the QR welcome prompt needs dismissing once per module entry.
