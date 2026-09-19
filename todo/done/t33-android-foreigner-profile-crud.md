# T33 slice 2 (Android): foreigner (visitor) profile CRUD suite on SGAC2.0, fork-dispatched

- Status: Done (offline implementation + dev-lead review, merged to main 2026-09-19); runtime acceptance pending under T42
- Owner: OpenCode `moonshotai/kimi-k2.7-code` (implementation) — dev lead Claude (review + merge)
- Priority: High
- Created: 2026-09-19
- Updated: 2026-09-19

## Goal

Add the missing Android SGAC **foreigner** profile creation automation, mirroring the resident
slice merged today (commit c423241 — read it: `git show c423241 --stat` and the resident
keywords in `Resources/android/SGACcommands.robot`). Deliver a new suite
`tests/android/sgac/crud_for_profile.robot` and fork-dispatched public keywords in
`Resources/android/SGACcommands.robot`, using the existing sgac2 foreigner locator tree
`Data/sgac2/android/sgac/foreigner/` (via `${FORK_DATA_DIR}`), with every sgac2 flow locator
verified OFFLINE against the captured build-15 page sources in `Output/evidence/` using
`tools/xpath_evidence_check.py`. No device is available and none may be used.

## Context (read these first, in this order)

1. `CLAUDE.md` in full (mandatory) and Mnemosyne recall (`mnemosyne_recall`, query: "appium_robot_framework T33 slice 2 Android foreigner profile CRUD"). Do NOT store anything in Mnemosyne.
2. `docs/refactor/fork-conventions.md` §5 (tags) and §6 (dispatch pattern A) — follow verbatim.
3. `todo/done/t33-android-resident-profile-crud.md` — the resident slice: same shape, same review bar. Reuse its keyword structure (`Fill … page 1 for ${APP_FORK}`, shared contact fill, `Verify … summary` + `extras for ${APP_FORK}`) where it fits.
4. `Data/sgac2/android/STATUS.md` — READ ONLY (do not edit). See "Foreigner form correctness walk (2026-09-06)" and the build-15 notes.
5. `docs/testing/sgac2-build15-regression-2026-09-10.md` and `docs/testing/sgac2-build15-submission-regression-2026-09-11.md` (foreigner sections) — the device runs whose page sources are your ground truth.

### What the evidence already shows (dev lead pre-analysis, build 2.0.0(15)/vc422)

SGAC2.0 foreigner flow, Home → saved profile (captures under `Output/evidence/`; `E1` =
`sgac2-build15-regression-2026-09-10`, `E2` = `android-sgac-regression-2026-09-11`; tracked
walkthrough sources: `docs/project-documentation/android-sgac2-2026-09-07/03-foreign-visitor-profiles-and-arrival-cards/sources/`):

| Step | sgac2 (from captures) | Evidence |
| --- | --- | --- |
| Enter SGAC | Home favourite `${FORIEGNVISITOR-SGARRIVAL-CARD-FAV-BUTTON}` (rid `HomeFOREIGN_VISITOR_SG_ARRIVAL_CARD`, `landing_page.yaml`) lands directly on the SAME profile-centric SGAC landing as the resident flow (`sgac/sgac_landing_page.yaml`: `SGAC-CREATE-NEW-PROFILE-BUTTON`, `SGAC-MANAGE-PROFILES-BUTTON`), but with a separate, initially empty foreigner profile store | `E1/027-for-sgac-landing.xml`, `E1/038-for-dashboard.xml`, `E2/028-foreigner-dashboard.xml` |
| Creation method | `Create New Profile` tile → `profile_creation_method_page.yaml` keys (`fill manually`) unchanged | walkthrough `002-foreign-visitor-creation-methods.xml` |
| Form page 1 (`for_profile_form.yaml`) | Full Name (`PassportDetailsFullName`), Sex (EditText `PassportDetailsSex`; opens via the `expand dropdown` button; option buttons MALE/FEMALE/OTHERS — see walkthrough `004-foreign-visitor-sex-selection.xml`), DOB (`PassportDetailsDateOfBirth`), Country/Place of Birth (TextView rid `PassportDetailsCountry`, content-desc `country/place of birth list` → searchable modal `for_form_cty_page.yaml`, options `searchable dropdown accessible label AUSTRALIA`), Nationality (`PassportDetailsNationality` → `for_form_nationality_page.yaml`, option `… AUSTRALIAN`), Passport Number (`PassportDetailsPassportNumber`), Date of Passport Expiry (`PassportDetailsDatePassportExpiry`), `next` | `E1/028-for-empty-form.xml`, `029-for-cty-modal.xml`, `030-for-nat-modal.xml`, `031-for-form-filled.xml`; `E2/029-foreigner-empty-validation.xml`, `030-foreigner-profile-details.xml`; walkthrough `003`, `005`, `006`, `007` |
| Form page 2 | Place of Residence (TextView rid `ContactDetailsResidence`, content-desc `city of residence text input` → `for_form_residence_page.yaml` modal; typing `SYDNEY` in the modal search lists options whose content-desc is `searchable dropdown accessible label AUSTRALIA, NEW SOUTH WALES, SYDNEY (AUSTRALIA)` and `… CANADA, NOVA SCOTIA, SYDNEY (CANADA)`), Country/Region Code (`ContactDetailsCountryCode`, shows `+` then e.g. `+61`), Mobile (`ContactDetailsMobileNumber`), Email (`ContactDetailsEmailAddress`), `next` | `E1/032-for-contact-page.xml`, `033-for-residence-modal.xml`, `034-for-residence-search.xml`, `035-for-contact-filled.xml`; `E2/031-foreigner-contact.xml`, `032-foreigner-residence-options.xml`; walkthrough `011`, `012`, `013` |
| Summary (`for_profile_summary.yaml`) | Passport Details card: Full Name (In Passport), **Sex rendered as a single letter (`M` for MALE — expect `F` for FEMALE)**, DOB `dd / mm / yyyy`, Country/Place of Birth `AUSTRALIA`, Nationality `AUSTRALIAN`, Passport Number, Expiry `dd / mm / yyyy`; Contact Details card: Place of Residence (full option string, e.g. `AUSTRALIA, NEW SOUTH WALES, SYDNEY (AUSTRALIA)`), Country/Region Code `+61`, Mobile Number (text unspaced, e.g. `481255591`), Email Address as typed; terms checkbox `uncheckterms of use checkbox`; `save` | `E1/036-for-summary-top.xml`; `E2/033-foreigner-summary.xml`, `034-foreigner-summary-contact.xml`; walkthrough `014`, `015` |
| Saved | back on landing with the profile card | `E1/037-for-after-save.xml`, `E2/035-foreigner-saved.xml` |

`Generate Profile Record` returns `name`, `dob`, `foreign_pp_num` (use this, NOT `pp_num`),
`pp_expiry`, `cty_code` (random 1–999 unless `country=SG`), `phno`, `email`. Use a fixed
persona for the pickers and the code so the flow matches the evidence: country of birth
`AUSTRALIA`, nationality `AUSTRALIAN` (NOT `MALAYSIAN` — that reveals an extra required
identity-card field), residence search `SYDNEY` → option `AUSTRALIA, NEW SOUTH WALES, SYDNEY (AUSTRALIA)`,
sex `FEMALE`, country code `61` (override the record with `Set To Dictionary    ${profile}    cty_code=61`
inside the suite, with a comment). Put the persona strings in a `*** Variables ***` block of the
keyword file (`${FOREIGNER-COUNTRY-OF-BIRTH}` etc.) so they are not scattered.

## Scope

### Included (files you own — edit nothing else)

- `Resources/android/SGACcommands.robot` (add foreigner keywords; do not change the resident ones except to share a helper if identical)
- `tests/android/sgac/crud_for_profile.robot` (NEW)
- `Data/sgac2/android/sgac/foreigner/*.yaml` (only if evidence requires a correction or a missing key — e.g. sex option buttons, modal search inputs; these files are whole-file sgac2-only in the allowlist, so new keys there need NO allowlist change)
- `tools/fork_parity_allowlist.yaml` (only if you touch a non-foreigner file — you should not need to)
- this task file (keep Progress / Outcome current)

### Excluded

- `Data/sgac2/android/STATUS.md`, `CLAUDE.md`, `docs/README.md`, `docs/**` — in flight elsewhere; put STATUS notes in the Outcome section instead.
- Any iOS file, any `Data/sgac1/**` file, `Resources/commands.robot`, `robotconfig.yaml`, `opencode.json`, `venv`, `Output/**`, unit tests.
- The SGAC2.0 foreigner SUBMISSION webview flow (TODO(T33-web)), QR, cargo.
- Device/Appium/MCP sessions of any kind (the Appium server and the iPad are in use by another agent).

## Required design

Public keywords (fork-agnostic) in `Resources/android/SGACcommands.robot`, dispatching with
`Run Keyword    <name> for ${APP_FORK}    …` (fork-conventions §6 pattern A). SGAC1.0 Android
has NO foreigner locator tree (it used the shared manual profile form via QR flows), so every
`… for sgac1` implementation of a foreigner keyword is a one-liner:
`Fail    Foreigner SGAC profile flow is not implemented for sgac1 on Android (no sgac1 foreigner locator tree); run with APP_FORK=sgac2`
— keep the public name stable for a later sgac1 implementation.

1. `Navigate to foreigner SGAC landing page` — sgac2: tap `${FORIEGNVISITOR-SGARRIVAL-CARD-FAV-BUTTON}`, then `Wait Until Element Is Visible    ${SGAC-CREATE-NEW-PROFILE-BUTTON}    ${INTERACTION_WAIT_TIMEOUT}`.
2. `Navigate to foreigner profile creation method page` — sgac2: `${SGAC-CREATE-NEW-PROFILE-BUTTON}` then wait for `${PROFILE-CREATION-FILL-MANUALLY-BUTTON}` (same timeout arg).
3. `Fill foreigner profile form    ${profile}` — precondition: creation-method page; taps fill manually; page 1: name, sex (expand dropdown → option), DOB, country of birth (modal: open list, type in the modal search, tap the option built with `Format String` from `FOR-CTY-OPTION-BY-NAME-TEMPLATE`), nationality (same pattern), `${profile}[foreign_pp_num]`, `${profile}[pp_expiry]` → next; page 2: residence (modal search `SYDNEY` → option template), country code, mobile, email → next. Field ORDER must follow the captures. Factor the three modal selections into one helper `Select foreigner searchable option    ${list_locator}    ${search_locator}    ${option_template}    ${search_text}    ${option_text}` (or similar) — one source of truth for the modal pattern, with a `Wait Until Element Is Visible` on the modal search input.
4. `Verify foreigner profile summary    ${profile}` — `Format String` + `Expect Element … visible` for: name, sex letter, DOB (`helper_func.Date Field Formatter`), country of birth, nationality, passport number, expiry, residence string, `+61`, mobile (unspaced, `Convert To String`), email — exactly as rendered in the summary captures (use `contains(@text,…)` for dates as the resident keyword does).
5. `Accept terms and save foreigner profile` — `${FOR-PROFILE-SUMMARY-TERMS-CHECKBOX-UNCHECKED}` then `${FOR-PROFILE-SUMMARY-SAVE-BUTTON}`.
6. `Create foreigner profile manually    ${profile}=${NONE}` — generates a record when none is given, sets `cty_code=61`, composes 2 → 3 → 5 (no verify), RETURNs the record; sgac2 precondition: SGAC foreigner landing.

Suite `tests/android/sgac/crud_for_profile.robot`: imports `fork_config.py` FIRST, then
AppiumLibrary, Collections, `manual_field_random.py`, `commands.robot`, `SGACcommands.robot`;
`Force Tags    fork:sgac2-only` (the flow has no sgac1 tree — say so in a `Documentation`
setting); `Test Setup    Open MyICA App on Android Emulator`, `Test Teardown    Close Application`;
ONE test `User is able to create foreigner profile`: generate record → override `cty_code` →
1 → 2 → 3 → 4 → 5. No inline locators.

Locator rules: UPPER-KEBAB-CASE, raw XPath, prefer resource-id/content-desc over text, one-line
comment naming the evidence file for every key you add or change, keep the `FOR-PROFILE-FORM-…`
/ `FOR-PROFILE-SUMMARY-…` / `FOR-<MODAL>-…` families. Never reuse resident YAML files for
foreigner-specific fields (the shared landing / method-page files are fine).

## Acceptance criteria

- [ ] `APP_FORK=sgac1 venv/bin/robot --dryrun tests` and `APP_FORK=sgac2 venv/bin/robot --dryrun tests` both pass with zero errors (68 → 69 tests).
- [ ] Every `${LOCATOR-KEY}` on the sgac2 path exists in a sgac2 YAML the keyword file imports (add the foreigner YAML imports to the keyword file's Settings, `${FORK_DATA_DIR}` paths only).
- [ ] `venv/bin/python -B tools/check_fork_parity.py --strict` → 0 errors, 0 warnings.
- [ ] `venv/bin/python -B -m pytest tests/unit -q -p no:cacheprovider` → all pass (251).
- [ ] `git diff --check` clean; no tabs; 4-space separators.
- [ ] `tools/xpath_evidence_check.py` run for `landing_page.yaml`, `sgac/sgac_landing_page.yaml`, `profile_creation_method_page.yaml` and all five `sgac/foreigner/*.yaml` (sgac2) against `Output/evidence/sgac2-build15-regression-2026-09-10` (`--match for-`) and `Output/evidence/android-sgac-regression-2026-09-11` (`--match foreigner`): every key the flow taps, types into or waits for is `verified` (exactly one node) in at least one capture of the right screen; template keys verified by a one-off lxml check with the persona values (AUSTRALIA / AUSTRALIAN / the SYDNEY residence option) and the matching file recorded; tables pasted into Outcome.
- [ ] Resident keywords/suites unchanged in behaviour (`git diff` shows no edits to their bodies).
- [ ] No file outside "Included" changed; nothing committed, nothing pushed; `venv`, `opencode.json`, `Output/` untouched and unstaged.

## Validation plan

```sh
venv/bin/python -B -m pytest tests/unit -q -p no:cacheprovider
venv/bin/python -B tools/check_fork_parity.py --strict
APP_FORK=sgac1 venv/bin/robot --dryrun -d Output/dryrun-sgac1 tests
APP_FORK=sgac2 venv/bin/robot --dryrun -d Output/dryrun-sgac2 tests
git diff --check
venv/bin/python tools/xpath_evidence_check.py --yaml Data/sgac2/android/sgac/foreigner/for_profile_form.yaml --evidence Output/evidence/sgac2-build15-regression-2026-09-10 --match for-
# …repeat per YAML / evidence dir as listed above
```

Runtime verification on the emulator is NOT part of this task (T42); list the runtime risks you
could not close offline (sex dropdown option tap, keyboard state before/after the modals, date
`Type text`, whether `+` is pre-filled in the country-code field so typing `61` yields `+61`).

## Progress and decisions

- 2026-09-19: Added foreigner persona variables and fork-dispatched public keywords to
  `Resources/android/SGACcommands.robot`. The sgac1 implementations fail fast because
  `Data/sgac1/android/sgac/foreigner/` does not exist; the sgac2 implementations dynamically
  import the foreigner YAMLs at runtime (static Settings import is impossible for the same
  reason — see Handoff).
- 2026-09-19: Added `tests/android/sgac/crud_for_profile.robot` as a `fork:sgac2-only`
  suite. It generates a profile, overrides `cty_code` to `61`, and calls the new public
  keywords end-to-end.
- 2026-09-19: Verified every flow-touched locator offline with `tools/xpath_evidence_check.py`
  against `Output/evidence/sgac2-build15-regression-2026-09-10` and
  `Output/evidence/android-sgac-regression-2026-09-11`, plus the tracked walkthrough
  sources for the foreigner method page and the sex-dropdown options; template option
  XPaths checked with a one-off `lxml` evaluation.
- 2026-09-19: Full validation battery passes (pytest 251, parity linter 0/0, dryrun
  69/69 for both forks, `git diff --check` clean).

- 2026-09-19 — DEV-LEAD REVIEW (Claude): diff accepted. Independent re-run: pytest 251/251, parity
  strict 0/0, dryrun 69/69 both forks (66/65 with the fork exclude flags), diff --check clean;
  per-fork variable check clean; all 22 sgac2 flow keys `verified` (exactly one node) across the
  09-10/09-11 captures and the tracked walkthrough sources; the AUSTRALIA / AUSTRALIAN /
  `AUSTRALIA, NEW SOUTH WALES, SYDNEY (AUSTRALIA)` option templates and the FEMALE option each
  resolve to one node. The runtime `Import Variables` deviation is ACCEPTED as the pattern for
  sgac2-only locator trees (a static Settings import would error on sgac1 because
  `Data/sgac1/android/sgac/foreigner/` does not exist; the runtime import fails loudly on a wrong
  path and keeps every public keyword self-sufficient). Adjustment at merge: the suite pins the
  country code via `${FOREIGNER-COUNTRY-CODE}` instead of a literal.

## Handoff or blocker

- Completed. One deliberate deviation from the brief: the foreigner YAMLs are loaded with
  `Import Variables` inside the sgac2 keywords rather than in the `*** Settings ***` section.
  Static `Variables    ${FORK_DATA_DIR}/android/sgac/foreigner/...` imports would make
  `APP_FORK=sgac1` dryruns fail loudly because `Data/sgac1/android/sgac/foreigner/` does
  not exist, and creating files under `Data/sgac1/` is outside the Included list. The
  runtime import works, keeps sgac1 dryruns green, and still gives the sgac2 path a single
  source of truth for locator loading. If the dev lead prefers a static import, a small
  `Data/sgac1/android/sgac/foreigner/` placeholder tree or a Python variables shim would
  be needed.

## Outcome

- Files changed:
  - `Resources/android/SGACcommands.robot`
  - `tests/android/sgac/crud_for_profile.robot` (new)
  - `todo/in-progress/t33-android-foreigner-profile-crud.md` (this file)

- sgac2 step sequence:
  1. Home favourite `${FORIEGNVISITOR-SGARRIVAL-CARD-FAV-BUTTON}` → wait for
     `${SGAC-CREATE-NEW-PROFILE-BUTTON}`.
  2. Tap `${SGAC-CREATE-NEW-PROFILE-BUTTON}` → wait for
     `${PROFILE-CREATION-FILL-MANUALLY-BUTTON}`.
  3. Tap `${PROFILE-CREATION-FILL-MANUALLY-BUTTON}` → fill page 1 in order:
     Full Name → Sex dropdown (`FEMALE`) → DOB → Country/Place of Birth modal
     (`AUSTRALIA`) → Nationality modal (`AUSTRALIAN`) → Passport Number → Passport Expiry
     → `${FOR-PROFILE-FORM-FOOTER-NEXT-BUTTON}`.
  4. Fill page 2: Place of Residence modal (`SYDNEY` →
     `AUSTRALIA, NEW SOUTH WALES, SYDNEY (AUSTRALIA)`) → Country/Region Code `61` →
     Mobile → Email → `${FOR-PROFILE-FORM-CONTACT-NEXT-BUTTON}`.
  5. Verify summary: name, sex letter `F`, formatted DOB, country of birth, nationality,
     passport number, formatted expiry, residence string, `+61`, mobile (unspaced), email.
  6. Tap `${FOR-PROFILE-SUMMARY-TERMS-CHECKBOX-UNCHECKED}` →
     `${FOR-PROFILE-SUMMARY-SAVE-BUTTON}`.

- Evidence-check tables (paste tool output):

`landing_page.yaml` vs
`Output/evidence/android-sgac-regression-2026-09-11/001-home-baseline.xml`:
```
evidence files: 1
CITIZEN-RESIDENT-ESERVICE-BUTTON            verified             one=1    multi=0    zero=0    e.g. 001-home-baseline.xml
FORIEGN-VISITOR-ESERVICE-BUTTON             verified             one=1    multi=0    zero=0    e.g. 001-home-baseline.xml
CITIZEN&RESIDENT-SGARRIVAL-CARD-FAV-BUTTON  verified             one=1    multi=0    zero=0    e.g. 001-home-baseline.xml
FORIEGNVISITOR-SGARRIVAL-CARD-FAV-BUTTON    verified             one=1    multi=0    zero=0    e.g. 001-home-baseline.xml
QR-CODE-FAV-BUTTON                          verified             one=1    multi=0    zero=0    e.g. 001-home-baseline.xml
CARGO-CLEARANCE-FAV-BUTTON                  verified             one=1    multi=0    zero=0    e.g. 001-home-baseline.xml
REGISTER-REREGISTER-REPLACE-FAV-BUTTON      verified             one=1    multi=0    zero=0    e.g. 001-home-baseline.xml
OTHER-E-SERVICES-FAV-BUTTON                 verified             one=1    multi=0    zero=0    e.g. 001-home-baseline.xml
MYICA-SCAM-BANNER                           unresolved           one=0    multi=0    zero=1    e.g. -
checked 9 keys: 1 not verified
```
Flow key `FORIEGNVISITOR-SGARRIVAL-CARD-FAV-BUTTON` is verified.

`sgac/sgac_landing_page.yaml` vs
`Output/evidence/sgac2-build15-regression-2026-09-10` (`--match for-`):
```
evidence files: 43
SGAC-HEADER                      verified             one=32   multi=0    zero=11   e.g. 027-for-sgac-landing.xml
SGAC-BACK-BUTTON                 verified             one=42   multi=0    zero=1    e.g. 027-for-sgac-landing.xml
SGAC-LANGUAGE-BUTTON             verified             one=2    multi=0    zero=41   e.g. 027-for-sgac-landing.xml
SGAC-MANAGE-PROFILES-BUTTON      verified             one=2    multi=0    zero=41   e.g. 027-for-sgac-landing.xml
SGAC-CREATE-NEW-PROFILE-BUTTON   verified             one=2    multi=0    zero=41   e.g. 027-for-sgac-landing.xml
SGAC-UPDATE-ARRIVAL-CARD-BUTTON  verified             one=2    multi=0    zero=41   e.g. 027-for-sgac-landing.xml
SGAC-ADD-PROFILE-BUTTON          unresolved           one=0    multi=0    zero=43   e.g. -
checked 7 keys: 1 not verified
```

`sgac/sgac_landing_page.yaml` vs
`Output/evidence/android-sgac-regression-2026-09-11` (`--match foreigner`):
```
evidence files: 60
SGAC-HEADER                      verified             one=49   multi=0    zero=11   e.g. 028-foreigner-dashboard.xml
SGAC-BACK-BUTTON                 verified             one=60   multi=0    zero=0    e.g. 028-foreigner-dashboard.xml
SGAC-LANGUAGE-BUTTON             verified             one=3    multi=0    zero=57   e.g. 028-foreigner-dashboard.xml
SGAC-MANAGE-PROFILES-BUTTON      verified             one=3    multi=0    zero=57   e.g. 028-foreigner-dashboard.xml
SGAC-CREATE-NEW-PROFILE-BUTTON   verified             one=3    multi=0    zero=57   e.g. 028-foreigner-dashboard.xml
SGAC-UPDATE-ARRIVAL-CARD-BUTTON  verified             one=3    multi=0    zero=57   e.g. 028-foreigner-dashboard.xml
SGAC-ADD-PROFILE-BUTTON          unresolved           one=0    multi=0    zero=60   e.g. -
checked 7 keys: 1 not verified
```
Flow key `SGAC-CREATE-NEW-PROFILE-BUTTON` is verified in both dirs;
`SGAC-ADD-PROFILE-BUTTON` is not on the execution path.

`profile_creation_method_page.yaml` vs tracked walkthrough source
`docs/project-documentation/android-sgac2-2026-09-07/03-foreign-visitor-profiles-and-arrival-cards/sources/002-foreign-visitor-creation-methods.xml`
(Output evidence dirs do not contain a foreigner method-page capture):
```
evidence files: 1
PROFILE-CREATION-HEADER                verified             one=1    multi=0    zero=0    e.g. 002-foreign-visitor-creation-methods.xml
PROFILE-CREATION-BACK-BUTTON           verified             one=1    multi=0    zero=0    e.g. 002-foreign-visitor-creation-methods.xml
PROFILE-CREATION-TITLE                 verified             one=1    multi=0    zero=0    e.g. 002-foreign-visitor-creation-methods.xml
PROFILE-CREATION-SINGPASS-BUTTON       unresolved           one=0    multi=0    zero=1    e.g. -
PROFILE-CREATION-SINGPASS-LABEL        unresolved           one=0    multi=0    zero=1    e.g. -
PROFILE-CREATION-SCAN-PASSPORT-BUTTON  verified             one=1    multi=0    zero=0    e.g. 002-foreign-visitor-creation-methods.xml
PROFILE-CREATION-FILL-MANUALLY-BUTTON  verified             one=1    multi=0    zero=0    e.g. 002-foreign-visitor-creation-methods.xml
checked 7 keys: 2 not verified
```
Flow key `PROFILE-CREATION-FILL-MANUALLY-BUTTON` is verified.

`sgac/foreigner/for_profile_form.yaml` vs
`Output/evidence/sgac2-build15-regression-2026-09-10` (`--match for-`) — flow keys:
```
FOR-PROFILE-FORM-FULL-NAME-INPUT        verified             one=4    multi=0    zero=39   e.g. 028-for-empty-form.xml
FOR-PROFILE-FORM-SEX-DROPDOWN-EXPAND    verified             one=4    multi=0    zero=39   e.g. 028-for-empty-form.xml
FOR-PROFILE-FORM-DOB-INPUT              verified             one=4    multi=0    zero=39   e.g. 028-for-empty-form.xml
FOR-PROFILE-FORM-CTY-BIRTH-LIST         verified             one=4    multi=0    zero=39   e.g. 028-for-empty-form.xml
FOR-PROFILE-FORM-NATIONALITY-LIST       verified             one=4    multi=0    zero=39   e.g. 028-for-empty-form.xml
FOR-PROFILE-FORM-PASSPORT-NO-INPUT      verified             one=4    multi=0    zero=39   e.g. 028-for-empty-form.xml
FOR-PROFILE-FORM-PASSPORT-EXPIRY-INPUT  verified             one=4    multi=0    zero=39   e.g. 028-for-empty-form.xml
FOR-PROFILE-FORM-FOOTER-NEXT-BUTTON     verified             one=8    multi=0    zero=35   e.g. 028-for-empty-form.xml
FOR-PROFILE-FORM-RESIDENCE-LIST         verified             one=4    multi=0    zero=39   e.g. 032-for-contact-page.xml
FOR-PROFILE-FORM-COUNTRY-CODE-INPUT     verified             one=4    multi=0    zero=39   e.g. 032-for-contact-page.xml
FOR-PROFILE-FORM-MOBILE-NUMBER-INPUT    verified             one=4    multi=0    zero=39   e.g. 032-for-contact-page.xml
FOR-PROFILE-FORM-EMAIL-INPUT            verified             one=4    multi=0    zero=39   e.g. 032-for-contact-page.xml
FOR-PROFILE-FORM-CONTACT-NEXT-BUTTON    verified             one=8    multi=0    zero=35   e.g. 028-for-empty-form.xml
```

`sgac/foreigner/for_profile_form.yaml` vs
`Output/evidence/android-sgac-regression-2026-09-11` (`--match foreigner`) — flow keys:
```
FOR-PROFILE-FORM-FULL-NAME-INPUT        verified             one=2    multi=0    zero=58   e.g. 029-foreigner-empty-validation.xml
FOR-PROFILE-FORM-SEX-DROPDOWN-EXPAND    verified             one=2    multi=0    zero=58   e.g. 029-foreigner-empty-validation.xml
FOR-PROFILE-FORM-DOB-INPUT              verified             one=2    multi=0    zero=58   e.g. 029-foreigner-empty-validation.xml
FOR-PROFILE-FORM-CTY-BIRTH-LIST         verified             one=2    multi=0    zero=58   e.g. 029-foreigner-empty-validation.xml
FOR-PROFILE-FORM-NATIONALITY-LIST       verified             one=2    multi=0    zero=58   e.g. 029-foreigner-empty-validation.xml
FOR-PROFILE-FORM-PASSPORT-NO-INPUT      verified             one=2    multi=0    zero=58   e.g. 029-foreigner-empty-validation.xml
FOR-PROFILE-FORM-PASSPORT-EXPIRY-INPUT  verified             one=2    multi=0    zero=58   e.g. 029-foreigner-empty-validation.xml
FOR-PROFILE-FORM-FOOTER-NEXT-BUTTON     verified             one=5    multi=0    zero=55   e.g. 029-foreigner-empty-validation.xml
FOR-PROFILE-FORM-RESIDENCE-LIST         verified             one=3    multi=0    zero=57   e.g. 031-foreigner-contact.xml
FOR-PROFILE-FORM-COUNTRY-CODE-INPUT     verified             one=3    multi=0    zero=57   e.g. 031-foreigner-contact.xml
FOR-PROFILE-FORM-MOBILE-NUMBER-INPUT    verified             one=3    multi=0    zero=57   e.g. 031-foreigner-contact.xml
FOR-PROFILE-FORM-EMAIL-INPUT            verified             one=3    multi=0    zero=57   e.g. 031-foreigner-contact.xml
FOR-PROFILE-FORM-CONTACT-NEXT-BUTTON    verified             one=5    multi=0    zero=55   e.g. 029-foreigner-empty-validation.xml
```

Sex option buttons verified against the tracked walkthrough source
`004-foreign-visitor-sex-selection.xml`:
```
FOR-PROFILE-FORM-SEX-OPTION-MALE    verified             one=1    multi=0    zero=0    e.g. 004-foreign-visitor-sex-selection.xml
FOR-PROFILE-FORM-SEX-OPTION-FEMALE  verified             one=1    multi=0    zero=0    e.g. 004-foreign-visitor-sex-selection.xml
FOR-PROFILE-FORM-SEX-OPTION-OTHERS  verified             one=1    multi=0    zero=0    e.g. 004-foreign-visitor-sex-selection.xml
checked 3 keys: 0 not verified
```

Modal `*-OPTION-BY-NAME-TEMPLATE` keys verified by one-off `lxml` checks:
```
029-for-cty-modal.xml:   //android.view.ViewGroup[@content-desc="searchable dropdown accessible label AUSTRALIA"] -> 1 node
030-for-nat-modal.xml:  //android.view.ViewGroup[@content-desc="searchable dropdown accessible label AUSTRALIAN"] -> 1 node
034-for-residence-search.xml:
  //android.view.ViewGroup[@content-desc="searchable dropdown accessible label AUSTRALIA, NEW SOUTH WALES, SYDNEY (AUSTRALIA)"] -> 1 node
```

`sgac/foreigner/for_profile_summary.yaml` vs
`Output/evidence/sgac2-build15-regression-2026-09-10` (`--match for-`) — flow keys:
```
FOR-PROFILE-SUMMARY-TERMS-CHECKBOX-UNCHECKED  verified             one=1    multi=0    zero=42   e.g. 036-for-summary-top.xml
FOR-PROFILE-SUMMARY-SAVE-BUTTON               verified             one=1    multi=0    zero=42   e.g. 036-for-summary-top.xml
```

`sgac/foreigner/for_profile_summary.yaml` vs
`Output/evidence/android-sgac-regression-2026-09-11` (`--match foreigner`) — flow keys:
```
FOR-PROFILE-SUMMARY-TERMS-CHECKBOX-UNCHECKED  verified             one=4    multi=0    zero=56   e.g. 033-foreigner-summary.xml
FOR-PROFILE-SUMMARY-SAVE-BUTTON               verified             one=4    multi=0    zero=56   e.g. 033-foreigner-summary.xml
```

`sgac/foreigner/for_form_cty_page.yaml`, `for_form_nationality_page.yaml`, and
`for_form_residence_page.yaml` all report every non-template key `verified` against
both evidence dirs (modal, surface, search input, close button, and indexed options).

- Validation results (paste the last lines of each command):
```
venv/bin/python -B -m pytest tests/unit -q -p no:cacheprovider
251 passed in 1.29s

venv/bin/python -B tools/check_fork_parity.py --strict
Summary: 0 errors, 0 warnings (strict: warnings treated as errors)

APP_FORK=sgac1 venv/bin/robot --dryrun -d Output/dryrun-sgac1 tests
Tests | PASS | 69 tests, 69 passed, 0 failed

APP_FORK=sgac2 venv/bin/robot --dryrun -d Output/dryrun-sgac2 tests
Tests | PASS | 69 tests, 69 passed, 0 failed

git diff --check
(no output)
```

- Notes for the dev lead to port into `Data/sgac2/android/STATUS.md`:
  - `tests/android/sgac/crud_for_profile.robot` automates the SGAC2.0 foreigner
    manual profile creation flow; it is tagged `fork:sgac2-only` because
    `Data/sgac1/android/sgac/foreigner/` does not exist.
  - `Resources/android/SGACcommands.robot` now provides fork-dispatched foreigner
    keywords: `Navigate to foreigner SGAC landing page`,
    `Navigate to foreigner profile creation method page`,
    `Fill foreigner profile form`, `Verify foreigner profile summary`,
    `Accept terms and save foreigner profile`, and
    `Create foreigner profile manually`.
  - All flow-touched foreigner locators were verified offline against the build-15
    evidence sets and the tracked 7 Sept walkthrough sources; runtime acceptance
    remains with T42.
  - The foreigner method-page `fill manually` key and sex-dropdown option keys are
    not present in the `Output/evidence/` captures; they were verified against the
    tracked walkthrough XML sources.

- Runtime risks left for the emulator run:
  - Sex dropdown option tap timing and whether the dropdown closes cleanly before
    the next field.
  - `Type text` behaviour on the 2.0 DOB and passport-expiry date inputs
    (`dd/mm/yyyy` into masked fields with a calendar picker).
  - Whether the Country/Region Code field pre-fills `+`, so typing `61` renders as
    `+61` in the summary.
  - Searchable modal search/option selection timing (country of birth, nationality,
    place of residence).
  - The foreigner locators are loaded via runtime `Import Variables`; an sgac2 run
    must reach the sgac2 keyword branch before the variables are available.
  - The `Output/evidence/` directories do not contain a foreigner creation-method
    capture; the `fill manually` key was verified against the walkthrough source and
    should be re-checked on the first live run.
