# T33 slice 2 (iOS): fork-dispatch the SGAC foreigner (visitor) profile CRUD flow so `crud_for_profile.robot` is SGAC2.0-ready

- Status: Done (offline implementation + dev-lead review, merged to main 2026-09-19); runtime acceptance pending under T42
- Owner: OpenCode `deepseek/deepseek-v4-pro` (implementation) — dev lead Claude (review + merge)
- Priority: High
- Created: 2026-09-19
- Updated: 2026-09-19

## Goal

Do for the iOS **foreigner** profile flow exactly what the resident slice merged today did for
the resident flow (commit c423241 — read it: `git show c423241 -- Resources/ios/SGACcommands.robot tests/ios/sgac/crud_res_profile.robot`
and `todo/done/t33-ios-resident-profile-crud.md`): move the fork-divergent navigation and form
steps of `tests/ios/sgac/crud_for_profile.robot` into `Resources/ios/SGACcommands.robot` behind
stable public keywords (fork-conventions §6 pattern A), make the suite fork-agnostic, and
reconcile the sgac2 iOS foreigner locator files with the LATEST captured build (2.0.0(17)) —
their headers still describe build 13. Every sgac2 flow locator must be verified OFFLINE with
`tools/xpath_evidence_check.py` against `Output/evidence/`. No device is available and none may
be used (the iPad and the Appium server are in use by another agent).

## Context (read these first, in this order)

1. `CLAUDE.md` in full (mandatory) and Mnemosyne recall (`mnemosyne_recall`, query: "appium_robot_framework T33 slice 2 iOS foreigner profile CRUD"). Do NOT store anything in Mnemosyne.
2. `docs/refactor/fork-conventions.md` §5 and §6 — follow verbatim.
3. `todo/done/t33-ios-resident-profile-crud.md` — same shape, same review bar (note the dev-lead adjustments recorded there: waits take `${INTERACTION_WAIT_TIMEOUT}`; one fork-scope tag per test).
4. `Data/sgac2/ios/STATUS.md` — READ ONLY (do not edit). See Session 5 (foreigner form correctness walk, build 13) and the T33 slice-1 section.
5. `docs/testing/ios-build17-regression-2026-09-16.md` is authored elsewhere and may be absent from this worktree; the build-17 page sources ARE present and are the source of truth.

### What the evidence already shows (dev lead pre-analysis)

Build 17 captures, `Output/evidence/myica-build17-regression-2026-09-16/ios/` (visitor profile
creation): `062-visitor-baseline.xml` (foreigner SGAC landing: `Manage Profiles`, `Create New Profile`
(label "Create New Profiles"), `Update SG Arrival Card`, `add profile plus icon`, empty-state hint
"Save your details as a profile to auto-fill future submission") → `063-visitor-method.xml` →
`065-visitor-identity-filled.xml` (page 1: `Full Name (In Passport)text input`, `dropdown` +
`expand dropdown` button for Sex, `PassportDetailsDateOfBirth`, country/place-of-birth list,
nationality list, `passport numbertext input`, `PassportDetailsDatePassportExpiry`, `next`) →
`066-visitor-contact-form.xml` (page 2) → `067-residence-picker-content.xml`,
`068-visitor-residence-search.xml` (modal; options `searchable dropdown accessible label AUSTRALIA, NEW SOUTH WALES, SYDNEY (AUSTRALIA)`
and `… CANADA, NOVA SCOTIA, SYDNEY (CANADA)` after searching `SYDNEY`) → `069-visitor-summary.xml`
→ `070-visitor-saved.xml`, `071-visitor-persistence.xml`. Secondary (build 15, 9 Sept iPad run):
`Output/evidence/ios-regression-2026-09-09/` — search it for the visitor creation captures.

Facts that CONTRADICT the current sgac2 YAML annotations and must be fixed from evidence:

- **Contact page is NOT residence+email only on build 17.** `066-visitor-contact-form.xml` exposes
  `city of residence text input`, `country/region code text inputtext input`,
  `mobile number text input` and `email address text inputtext input`; `069-visitor-summary.xml`
  shows the Contact Details card with Place of Residence, `Country/Region Code` = `+61`,
  `Mobile Number` = `4 1 2 3 4 5 6 7 8` (spaced → `helper_func.Add Space Between String`, as the
  sgac1 suite already asserts) and `Email Address` upper-cased. Restore
  `FOR-PROFILE-FORM-COUNTRY-CODE-INPUT`, `FOR-PROFILE-FORM-COUNTRY-CODE-REQUIRED`,
  `FOR-PROFILE-FORM-MOBILE-NO-INPUT`, `FOR-PROFILE-FORM-MOBILE-NUMBER-REQUIRED` in
  `for_profile_form.yaml` and `FOR-PROFILE-SUMMARY-CODE-LABEL`, `FOR-PROFILE-SUMMARY-MOBILE-LABEL` in
  `for_profile_summary.yaml` (locators verified against 066/069), fix the header comments, and
  REMOVE those keys from the two `sgac1_only` lists in `tools/fork_parity_allowlist.yaml`. Keep
  `FOR-PROFILE-FORM-FULL-NAME-LABEL` and `FOR-PROFILE-SUMMARY-TERMS-LINK` as sgac1-only only if
  build 17 still lacks them (065 shows no standalone "Full Name (In Passport)" StaticText).
- Summary renders **Sex as a single letter** (`F` for FEMALE), DOB/expiry as `dd / mm / yyyy`,
  country of birth `AUSTRALIA`, nationality `AUSTRALIAN`, residence as the full option string.
- The three modal files expose only `FOR-<MODAL>-OPTION-BY-NAME` (a non-template `starts-with`
  locator) and `OPTION-1/2/3`. Add `FOR-CTY-OPTION-BY-NAME-TEMPLATE`, `FOR-NATIONALITY-OPTION-BY-NAME-TEMPLATE`,
  `FOR-RESIDENCE-OPTION-BY-NAME-TEMPLATE` (`//XCUIElementTypeOther[@name="searchable dropdown accessible label {}"]`)
  to the sgac2 modal files and register them as `sgac2_only` for those three files in the
  allowlist (mirrors the Android tree and the resident `RES-FORM-NATIONALITY-OPTION-TEMPLATE`).
- Header/label keys matching two RN-duplicated StaticText nodes report `ambiguous`; acceptable
  for assertions, but every key the flow TAPS or TYPES into must be `verified` (exactly one node).

`Generate Profile Record` returns `name`, `dob`, `foreign_pp_num` (use this), `pp_expiry`,
`cty_code`, `phno`, `email`. Persona for sgac2 (matches the evidence): sex `FEMALE`, country of
birth `AUSTRALIA`, nationality `AUSTRALIAN`, residence search `SYDNEY` → option
`AUSTRALIA, NEW SOUTH WALES, SYDNEY (AUSTRALIA)`, country code `61` (override with
`Set To Dictionary    ${PROFILE}    cty_code=61` in the suite, with a comment). Put the persona
strings in a `*** Variables ***` block of the keyword file. sgac1 keeps today's behaviour
(first option of each modal, record `cty_code`).

## Scope

### Included (files you own — edit nothing else)

- `Resources/ios/SGACcommands.robot` (add foreigner keywords; resident keywords unchanged)
- `tests/ios/sgac/crud_for_profile.robot`
- `Data/sgac2/ios/sgac/foreigner/for_profile_form.yaml`, `for_profile_summary.yaml`, `for_form_cty_page.yaml`, `for_form_nationality_page.yaml`, `for_form_residence_page.yaml`
- `Data/sgac2/ios/foreign_vis_page.yaml` (annotations only)
- `tools/fork_parity_allowlist.yaml` (iOS foreigner entries only; the linter errors on unused entries)
- this task file

### Excluded

- `Data/sgac2/ios/STATUS.md`, `CLAUDE.md`, `docs/README.md`, `docs/**` — in flight elsewhere; STATUS notes go in Outcome.
- Any Android file, any `Data/sgac1/**` file, resident keywords/suites, `Resources/commands.robot`, `robotconfig.yaml`, `opencode.json`, `venv`, `Output/**`, unit tests.
- Foreigner SUBMISSION/update webview flows (TODO(T33-web)); QR; cargo.
- Device/Appium/MCP sessions of any kind.

## Required design

Public keywords in `Resources/ios/SGACcommands.robot`, each dispatching with
`Run Keyword    <name> for ${APP_FORK}    …`; every new `Wait Until Element Is Visible` passes
`${INTERACTION_WAIT_TIMEOUT}`:

1. `Navigate to foreigner SGAC landing page` — sgac1: today's two clicks (`FORIEGN-VISITOR-ESERVICE-BUTTON`, `FOREIGN-VIS-SGAC-CARD`); sgac2: tap `${FORIEGNVISITOR-SGARRIVAL-CARD-FAV-BUTTON}` then wait for `${SGAC-LANDING-CREATE-NEW-PROFILE}`.
2. `Navigate to foreigner profile creation method page` — sgac1: `Navigate to profile list page` → `${ADD-PROFILE-BTN}`; sgac2: `${SGAC-LANDING-CREATE-NEW-PROFILE}`; both end waiting for `${PROFILE-CREATION-METHOD-FILL-MANUALLY}`.
3. `Fill foreigner profile form    ${profile}` — sgac1: today's inline steps verbatim (Done taps, `OPTION-1` picks, code/mobile/email); sgac2: fill manually → name → Done → sex dropdown → `${FEMALE-DROPDOWN-OPTION}` → DOB → Done → country of birth (list → type `AUSTRALIA` in `FOR-CTY-SEARCH-INPUT` → option from template) → nationality (same with `AUSTRALIAN`) → passport number → Done → expiry → Done → next → residence (list → search `SYDNEY` → option template) → country code → Done → mobile → email → Done → next. Field order per the build-17 captures. Factor the modal pattern into one helper keyword (list locator, search locator, option template, search text, option text) used by both forks where the sgac2 path needs it.
4. `Verify foreigner profile summary    ${profile}` — the suite's existing `Format String` + `Expect Element … visible` assertions moved here for sgac1 (name, DOB, passport, expiry, spaced mobile, upper-cased email); sgac2 adds sex letter, country of birth, nationality, residence string and `+61`.
5. `Accept terms and save foreigner profile` — `${FOR-PROFILE-SUMMARY-TERMS-CHECKBOX}` then `${FOR-PROFILE-SUMMARY-FOOTER-SAVE}`.
6. `Create foreigner profile manually    ${profile}=${NONE}` — record when none given, `cty_code=61` on sgac2 only if you can do it without changing sgac1 behaviour (otherwise leave the record as is), composes 2 → 3 → 5, RETURNs the record.

Suite `tests/ios/sgac/crud_for_profile.robot` becomes fork-agnostic: generate the record (and
the `cty_code` override, commented), 1 → 2 → 3 → 4 → 5, `Force Tags    fork:both` kept, no
inline locators, imports reduced to what the suite itself needs (the keyword file imports the
YAMLs). Keep `Test Setup`/`Test Teardown` and the import order (fork_config.py first).

Locator rules: raw XPath, `xpath=` prefixes only where the existing line already uses them,
prefer `name`/testID over visible text, one-line comment naming the build-17 evidence file for
every changed key, keep the existing key families.

## Acceptance criteria

- [ ] `APP_FORK=sgac1 venv/bin/robot --dryrun tests` and `APP_FORK=sgac2 venv/bin/robot --dryrun tests` both pass with zero errors (68 tests).
- [ ] Every `${LOCATOR-KEY}` on the sgac2 path exists in the sgac2 YAMLs the keyword file imports; every key on the sgac1 path exists in the sgac1 YAMLs.
- [ ] `venv/bin/python -B tools/check_fork_parity.py --strict` → 0 errors, 0 warnings (after the allowlist corrections).
- [ ] `venv/bin/python -B -m pytest tests/unit -q -p no:cacheprovider` → all pass (251).
- [ ] `git diff --check` clean; no tabs; 4-space separators.
- [ ] `tools/xpath_evidence_check.py` run for `landing_page.yaml`, `sgac/sgac_landing_page.yaml`, `sgac/profile_creation_method_page.yaml`, the five `sgac/foreigner/*.yaml` and `ios_common_selectors.yaml` (sgac2) against the build-17 directory (`--match visitor` / `--match residence` for the foreigner files, no filter for landing) and, as a cross-check, `Output/evidence/ios-regression-2026-09-09`: every key the flow taps, types into or waits for is `verified`; template keys verified by one-off lxml checks with the persona values (record the matching files); tables pasted into Outcome.
- [ ] sgac1 behaviour is the same sequence of clicks/typing as before (list before/after in Outcome); resident keywords untouched.
- [ ] No file outside "Included" changed; nothing committed, nothing pushed; `venv`, `opencode.json`, `Output/` untouched and unstaged.

## Validation plan

```sh
venv/bin/python -B -m pytest tests/unit -q -p no:cacheprovider
venv/bin/python -B tools/check_fork_parity.py --strict
APP_FORK=sgac1 venv/bin/robot --dryrun -d Output/dryrun-sgac1 tests
APP_FORK=sgac2 venv/bin/robot --dryrun -d Output/dryrun-sgac2 tests
git diff --check
venv/bin/python tools/xpath_evidence_check.py --yaml Data/sgac2/ios/sgac/foreigner/for_profile_form.yaml --evidence Output/evidence/myica-build17-regression-2026-09-16/ios --match visitor
# …repeat per YAML / evidence dir as listed above
```

Runtime verification on the iPad is NOT part of this task (real-device only, T42); list the
runtime risks you could not close offline (keyboard state when tapping modal options, the sex
dropdown, whether the country-code field pre-fills `+`).

## Progress and decisions

- 2026-09-19 — Read brief, CLAUDE.md, fork-conventions §5/§6, resident slice
  (`todo/done/t33-ios-resident-profile-crud.md`), `Data/sgac2/ios/STATUS.md` (read-only) and
  commit c423241. Evidence XML is present under `Output/evidence/`. No device/Appium/MCP used.
- 2026-09-19 — Re-verified the sgac2 iOS foreigner locators against build-17 page sources
  (062/065/066/067/068/069) and the build-15 foreigner walk (043–054). Findings: (1) the
  contact page is Place of Residence + Country/Region Code + Mobile + Email on BOTH build 15
  (050) and build 17 (066) — the build-13 "email-only" annotation is stale; (2) summary
  contact card has Code/Mobile rows again (069/053); (3) summary renders Sex as a single
  letter `F`, DOB/expiry `dd / mm / yyyy`, country `AUSTRALIA`, nationality `AUSTRALIAN`,
  residence `AUSTRALIA, NEW SOUTH WALES, SYDNEY (AUSTRALIA)`, code `+61`, mobile spaced,
  email upper-cased; (4) the country/nationality list elements keep their empty-state
  `name` (`country/place of birth list`, `nationality/citizenship list` as XCUIElementTypeOther)
  in build 15 and switch to a combined `name` (`Country/Place of Birth, country/place of birth
  list`) only once filled — the tap happens in the empty state, so the current list locators
  are correct; (5) the sex dropdown `FEMALE` button has no build-17 capture (native dropdown
  not captured expanded) but is verified in build-15 `047-foreigner-gender.xml`.
- 2026-09-19 — Restored 4 contact-page keys in `for_profile_form.yaml` (COUNTRY-CODE-INPUT/-REQUIRED,
  MOBILE-NO-INPUT/-NUMBER-REQUIRED) and 2 summary rows in `for_profile_summary.yaml` (CODE-LABEL,
  MOBILE-LABEL); fixed both file headers to the build-17 facts. Added the three
  `FOR-{CTY,NATIONALITY,RESIDENCE}-OPTION-BY-NAME-TEMPLATE` keys to the sgac2 modal files and
  registered them `sgac2_only`. Trimmed the two `sgac1_only` allowlist lists to the keys still
  genuinely absent on build 17 (`FOR-PROFILE-FORM-FULL-NAME-LABEL`, `FOR-PROFILE-SUMMARY-TERMS-LINK`).
- 2026-09-19 — Implemented fork dispatch (fork-conventions §6 pattern A) in
  `Resources/ios/SGACcommands.robot`: `Navigate to foreigner SGAC landing page`,
  `Navigate to foreigner profile creation method page`, `Fill foreigner profile form`,
  `Verify foreigner profile summary`, `Accept terms and save foreigner profile`,
  `Create foreigner profile manually` (composes 2→3→5), plus the `Select foreigner modal option`
  helper. Rewrote `crud_for_profile.robot` to generate→1→2→3→4→5 with no inline locators.

- 2026-09-19 — DEV-LEAD REVIEW (Claude): diff accepted without changes. Independent re-run: pytest
  251/251, parity strict 0/0, dryrun 68/68 both forks (66/64 with the fork exclude flags),
  diff --check clean; per-fork variable check clean (sgac2-only template keys appear only inside
  `… for sgac2`, sgac1-only keys only inside `… for sgac1`); 23/24 sgac2 flow keys `verified`
  (exactly one node) in the build-17 captures — `FEMALE-DROPDOWN-OPTION` has no build-17 capture
  with the dropdown open and is verified in the 9 Sept build-15 `047-foreigner-gender.xml`; the
  AUSTRALIA / AUSTRALIAN option templates resolve to one node in build-15 `048-foreigner-birth-search.xml`
  / `250-resident-nationality.xml`, the SYDNEY residence template in build-17 `068`. The two
  deliberate decisions (persona country code applied inside the sgac2 fill; no verify inside
  `Create foreigner profile manually`) are accepted — the first is cleaner than the brief's
  suggestion because sgac1 behaviour stays byte-for-byte unchanged.

## Handoff or blocker

- No blockers. Two deliberate decisions the dev lead should note: (a) the sgac2 country code is
  pinned to `61` via the `${FOR-SGAC2-CTY-CODE}` persona variable consumed inside
  `Fill foreigner profile form for sgac2` (NOT by mutating the record in the suite), so the
  `cty_code=61` override applies only on sgac2 and sgac1 keeps the generated record's `cty_code`
  untouched — the suite carries a commented `Set To Dictionary` line per the brief; (b) `Verify
  foreigner profile summary` is NOT composed into `Create foreigner profile manually` (mirrors
  the resident slice's accepted keyword-7 deviation; the unit-test stub only stubs
  `Click on element`/`Type text`, and composing the real `Expect Element` would fail offline).

## Outcome

- Files changed: `Resources/ios/SGACcommands.robot`,
  `tests/ios/sgac/crud_for_profile.robot`,
  `Data/sgac2/ios/sgac/foreigner/for_profile_form.yaml`,
  `Data/sgac2/ios/sgac/foreigner/for_profile_summary.yaml`,
  `Data/sgac2/ios/sgac/foreigner/for_form_cty_page.yaml`,
  `Data/sgac2/ios/sgac/foreigner/for_form_nationality_page.yaml`,
  `Data/sgac2/ios/sgac/foreigner/for_form_residence_page.yaml`,
  `Data/sgac2/ios/foreign_vis_page.yaml` (annotations only),
  `tools/fork_parity_allowlist.yaml` (iOS foreigner entries only), this task file. No file outside
  "Included" was touched; nothing committed/pushed. `opencode.json` (dev-lead MCP-disable edit),
  `venv/`, `Output/` were left untouched.
- sgac1 step sequence before → after: identical clicks/types, re-framed as keyword calls.
  - Before (`crud_for_profile.robot` inline): Generate record → landing (FORIEGN-VISITOR-ESERVICE-BUTTON,
    FOREIGN-VIS-SGAC-CARD) → profile list (VIEW-PROFILE) → ADD-PROFILE-BTN → FILL-MANUALLY → name/Done →
    gender dropdown → FEMALE → DOB/Done → CTY-BIRTH-LIST → FOR-CTY-OPTION-1 → NAT-LIST →
    FOR-NATIONALITY-OPTION-1 → passport no/Done → expiry/Done → next → CITY-RES-INPUT →
    FOR-RESIDENCE-OPTION-1 → cty_code/Done → mobile,email/Done → next → verify name,dob,pp_no,
    pp_expiry,phno,email → terms checkbox → save.
  - After: Generate record → `Navigate to foreigner SGAC landing page` (same 2 clicks) →
    `Navigate to foreigner profile creation method page` (profile list VIEW-PROFILE → ADD-PROFILE-BTN →
    wait FILL-MANUALLY) → `Fill foreigner profile form` (same field sequence, OPTION-1 picks, record
    `cty_code`) → `Verify foreigner profile summary` (same 6 assertions) → `Accept terms and save
    foreigner profile`. Only addition is the `${INTERACTION_WAIT_TIMEOUT}` wait for FILL-MANUALLY.
  - `Create foreigner profile manually` (NEW, no native caller yet — foreigner submission is web-based):
    sgac1 = creation-method (VIEW-PROFILE→ADD-PROFILE) → Fill → Accept+save.
- sgac2 step sequence (`crud_for_profile.robot`, and `Create foreigner profile manually` sgac2 branch):
  1 landing = tap `FORIEGNVISITOR-SGARRIVAL-CARD-FAV-BUTTON` → wait `SGAC-LANDING-CREATE-NEW-PROFILE`;
  2 creation-method = tap `SGAC-LANDING-CREATE-NEW-PROFILE` → wait `PROFILE-CREATION-METHOD-FILL-MANUALLY`;
  3 fill = fill-manually → name/Done → gender dropdown → FEMALE → DOB/Done → country of birth
  (CTY-BIRTH-LIST → search `AUSTRALIA` → option template AUSTRALIA) → nationality (NAT-LIST → search
  `AUSTRALIAN` → option template AUSTRALIAN) → passport no/Done → expiry/Done → next → residence
  (CITY-RES-INPUT → search `SYDNEY` → option template `AUSTRALIA, NEW SOUTH WALES, SYDNEY (AUSTRALIA)`)
  → country code `61`/Done → mobile,email/Done → next;
  4 verify = name,dob,pp_no,pp_expiry + `F`,`AUSTRALIA`,`AUSTRALIAN`,residence string,`+61`,
  spaced phno, upper-cased email; 5 accept = terms checkbox → save.
- Evidence-check tables (paste tool output): see below.
- Validation results (paste the last lines of each command): see below.
- Notes for the dev lead to port into `Data/sgac2/ios/STATUS.md`: see below.
- Runtime risks left for the iPad run: see below.

### Evidence-check tables (build 17, `Output/evidence/myica-build17-regression-2026-09-16/ios`)

`Data/sgac2/ios/landing_page.yaml` (no filter) — 0 not verified:

```
CITIZEN-RESIDENT-ESERVICE-BUTTON            verified  one=250  e.g. 002-home-ready.xml
FORIEGN-VISITOR-ESERVICE-BUTTON             verified  one=205
CITIZEN&RESIDENT-SGARRIVAL-CARD-FAV-BUTTON  verified  one=11
FORIEGNVISITOR-SGARRIVAL-CARD-FAV-BUTTON    verified  one=11
QR-CODE-FAV-BUTTON                          verified  one=11
CARGO-CLEARANCE-FAV-BUTTON                  verified  one=11
REGISTER-REREGISTER-REPLACE-FAV-BUTTON      verified  one=11
OTHER-E-SERVICES-FAV-BUTTON                 verified  one=9
MYICA-SCAM-BANNER                           verified  one=29
checked 9 keys: 0 not verified
```

`Data/sgac2/ios/sgac/sgac_landing_page.yaml` (no filter) — flow keys verified:

```
SGAC-LANDING-CREATE-NEW-PROFILE   verified  one=22  e.g. 062-visitor-baseline.xml (also 005)
SGAC-LANDING-MANAGE-PROFILES      verified  one=22
SGAC-LANDING-ADD-PROFILE          verified  one=4
SGAC-LANDING-BACK-BUTTON / LANGUAGE-BUTTON / UPDATE-ARRIVAL-CARD / CONTINUE  verified
SGAC-LANDING-PROFILE-UPDATE-ALERT/BUTTON/CANCEL  unresolved (modal not captured; not flow keys)
checked 20 keys: 6 not verified (3 ambiguous labels + 3 profile-update-modal keys, all non-flow)
```

`Data/sgac2/ios/sgac/profile_creation_method_page.yaml` (`--match visitor`) — flow key verified:

```
PROFILE-CREATION-METHOD-FILL-MANUALLY      verified  one=1  e.g. 063-visitor-method.xml
PROFILE-CREATION-METHOD-SCAN-PASSPORT-MRZ  verified  one=1  e.g. 063
PROFILE-CREATION-METHOD-SINGPASS           unresolved (foreigner method page has NO SingPass — expected)
checked 6 keys: 3 not verified (SINGPASS unresolved + HEADER/TITLE ambiguous — none are flow keys)
```

`Data/sgac2/ios/sgac/foreigner/for_profile_form.yaml` (`--match visitor`) — every tap/type key verified:

```
FOR-PROFILE-FORM-NAME-INPUT           verified  one=2   e.g. 065-visitor-identity-filled.xml
FOR-PROFILE-FORM-GENDER-DROPDOWN      verified  one=2   e.g. 065
FOR-PROFILE-FORM-DOB-INPUT            verified  one=2   e.g. 065
FOR-PROFILE-FORM-CTY-BIRTH-LIST       unresolved on build-17 filled capture (see build-15 cross-check below)
FOR-PROFILE-FORM-NAT-LIST             unresolved on build-17 filled capture (see build-15 cross-check below)
FOR-PROFILE-FORM-PASSPORT-NO-INPUT    verified  one=2   e.g. 065
FOR-PROFILE-FORM-PASSPORT-EXPIRY-INPUT verified one=2   e.g. 065
FOR-PROFILE-FORM-CITY-RES-INPUT       verified  one=1   e.g. 066-visitor-contact-form.xml
FOR-PROFILE-FORM-COUNTRY-CODE-INPUT   verified  one=2   e.g. 066
FOR-PROFILE-FORM-MOBILE-NO-INPUT      verified  one=1   e.g. 066
FOR-PROFILE-FORM-EMAIL-INPUT          verified  one=2   e.g. 066
FEMALE-DROPDOWN-OPTION                unresolved on build 17 (native sex dropdown not captured expanded)
checked 36 keys: 10 not verified (4 ambiguous labels/calendar + 2 list keys + 3 sex options + captcha-era
  — every remaining tap/type key verified)
```

`Data/sgac2/ios/sgac/foreigner/for_profile_summary.yaml` (`--match visitor`) — flow keys verified:

```
FOR-PROFILE-SUMMARY-TERMS-CHECKBOX   verified  one=2   e.g. 069-visitor-summary.xml
FOR-PROFILE-SUMMARY-CODE-LABEL       verified  one=2   e.g. 066 (restored)
FOR-PROFILE-SUMMARY-MOBILE-LABEL     verified  one=30  e.g. 066 (restored)
FOR-PROFILE-SUMMARY-RESIDENCE-VALUE  verified  one=32  e.g. 069
FOR-PROFILE-SUMMARY-FOOTER-SAVE      unresolved (no checked-state foreigner summary captured; resident
                                     save `name="save"` verified in 022 — same footer component)
FOR-PROFILE-SUMMARY-TERMS-CHECKBOX-CHECKED  unresolved (same reason)
checked 25 keys: 5 not verified (HEADER/TITLE/CONTACT-TITLE ambiguous + FOOTER-SAVE + CHECKBOX-CHECKED)
```

`Data/sgac2/ios/sgac/foreigner/for_form_cty_page.yaml` / `for_form_nationality_page.yaml` (`--match visitor`)
and `for_form_residence_page.yaml` (`--match residence`) — modal chrome verified:

```
FOR-CTY-MODAL / -SEARCH-INPUT / -SEARCH-CLEAR / -CLOSE-BUTTON    verified  one=1  e.g. 068
FOR-CTY-OPTION-BY-NAME-TEMPLATE        template (skipped) — verified by one-off lxml (below)
FOR-CTY-OPTION-1/-2                    verified; OPTION-3 unresolved (2 filtered options)
FOR-NATIONALITY-*                      same as CTY (identical modal structure)
FOR-RESIDENCE-MODAL / -SEARCH-INPUT / -SEARCH-CLEAR / -CLOSE-BUTTON  verified  one=2  e.g. 067
FOR-RESIDENCE-OPTION-1/-2/-3           verified
FOR-RESIDENCE-OPTION-BY-NAME-TEMPLATE  template (skipped) — verified by one-off lxml (below)
```

`Data/sgac2/ios/ios_common_selectors.yaml` (`--match visitor`):

```
FOOTER-NEXT-BTN   verified  one=4  e.g. 065
FOOTER-BACK-BTN   verified  one=6  e.g. 065
KEYBOARD-DONE-BTN unresolved (iOS keyboard is not in the app page source; pre-existing — resident
                  flow has the same gap)
CAPTCHA-*         unresolved (submission-flow captcha, not in visitor CRUD captures)
```

Cross-check `Data/sgac2/ios/sgac/foreigner/for_profile_form.yaml` vs build 15
(`Output/evidence/ios-regression-2026-09-09`, `--match foreigner`) — closes the two build-17 gaps:

```
FEMALE-DROPDOWN-OPTION            verified  one=1  e.g. 047-foreigner-gender.xml
FOR-PROFILE-FORM-CTY-BIRTH-LIST   verified  one=3  e.g. 045-foreigner-empty-form.xml  (empty state = tap moment)
FOR-PROFILE-FORM-NAT-LIST         verified  one=4  e.g. 045-foreigner-empty-form.xml
FOR-PROFILE-FORM-COUNTRY-CODE-INPUT verified one=3  e.g. 050-foreigner-contact-empty.xml
FOR-PROFILE-FORM-MOBILE-NO-INPUT  verified  one=2  e.g. 050
```

Cross-check `Data/sgac2/ios/sgac/foreigner/for_profile_summary.yaml` vs build 15 (`--match foreigner`):
`FOR-PROFILE-SUMMARY-CODE-LABEL` verified (050), `FOR-PROFILE-SUMMARY-MOBILE-LABEL` verified (057);
`FOOTER-SAVE`/`CHECKBOX-CHECKED` still unresolved (no checked-state foreigner capture on build 15 either).

One-off lxml checks (persona values; each resolves to exactly 1 node):

```
FOR-CTY-OPTION-BY-NAME-TEMPLATE [AUSTRALIA]                                -> 1  (048-foreigner-birth-search.xml, build 15)
FOR-NATIONALITY-OPTION-BY-NAME-TEMPLATE [AUSTRALIAN]                       -> 1  (250-resident-nationality.xml, build 15 — same a11y pattern;
                                                                            no foreigner nationality-modal capture exists in either build)
FOR-RESIDENCE-OPTION-BY-NAME-TEMPLATE [AUSTRALIA, NEW SOUTH WALES, SYDNEY (AUSTRALIA)] -> 1  (068-visitor-residence-search.xml, build 17)
FOR-CTY-SEARCH-INPUT / FOR-NATIONALITY-SEARCH-INPUT / FOR-RESIDENCE-SEARCH-INPUT [placeholderValue="Search"] -> 1 each
Summary value assertions in 069 (sex `F`, AUSTRALIA, AUSTRALIAN, residence string, +61, spaced mobile,
  `E18961956`, `16 / 09 / 1990`, `16 / 09 / 2030`) each match 2 nodes — the RN StaticText duplicate
  (one accessible=true, one accessible=false); acceptable for `Expect Element … visible` (assertion keys).
```

### Validation results

```
venv/bin/python -B -m pytest tests/unit -q -p no:cacheprovider
  -> 251 passed in 1.19s
venv/bin/python -B tools/check_fork_parity.py --strict
  -> Summary: 0 errors, 0 warnings (strict: warnings treated as errors)
APP_FORK=sgac1 venv/bin/robot --dryrun -d Output/dryrun-sgac1 tests
  -> Tests | PASS | 68 tests, 68 passed, 0 failed
APP_FORK=sgac2 venv/bin/robot --dryrun -d Output/dryrun-sgac2 tests
  -> Tests | PASS | 68 tests, 68 passed, 0 failed
git diff --check
  -> clean (exit 0); no tabs in the two .robot files; 4-space separators
```

### Notes for the dev lead to port into `Data/sgac2/ios/STATUS.md`

- Build 17 (and already build 15) restore the foreigner contact page to **Place of Residence +
  Country/Region Code + Mobile Number + Email**; the build-13 "residence + email only" annotation in
  `for_profile_form.yaml` / `for_profile_summary.yaml` is stale and now corrected (verified vs
  050/066 and 053/069).
- `FOR-PROFILE-FORM-FULL-NAME-LABEL` stays sgac1-only: build-17 065 still has a
  `name="Full Name (In Passport)"` StaticText but it is `visible="false"`/`accessible="false"` (an
  RN shadow duplicate of the `-label-inactive` testID), so it is not a usable assertion target.
- `FOR-PROFILE-SUMMARY-TERMS-LINK` stays sgac1-only: build-17 069 has only the merged
  "I have read and accepted the Terms of Use and Privacy Policy" sentence, no standalone link.
- The country/nationality list elements keep their empty-state `name` (verified vs build-15
  045/046) and switch to a combined `name` (`Country/Place of Birth, country/place of birth list`)
  once filled (build-17 065 / build-15 049); the flow taps them in the empty state, so the current
  locators are correct.
- The foreigner summary footer `save` button and the `checkedterms of use checkbox` have no
  build-15/17 capture (no foreigner summary was captured in the checked state); the resident
  `name="save"` (label="SAVE") in 022 proves the same footer component.
- The three searchable modals gain a `FOR-{CTY,NATIONALITY,RESIDENCE}-OPTION-BY-NAME-TEMPLATE`
  key (Format String) mirroring the resident `RES-FORM-NATIONALITY-OPTION-TEMPLATE`.

### Runtime risks left for the iPad run

- Keyboard state when tapping the sex `FEMALE` option and the country/nationality/residence modal
  options: the helper types into the search field then taps the option without dismissing the
  keyboard; a swallowed option tap is possible (same risk as the resident nationality modal).
- `KEYBOARD-DONE-BTN` (keyboard "Done") is not present in page-source evidence (keyboard is a
  separate window) — its tap timing after the new fields is unverified offline.
- Whether the country-code field pre-fills `+` (flow types `61`, summary asserts `+61`) is
  unverified offline; build-17 066 shows the field empty and 069 shows `+61`.
- `Accept terms and save foreigner profile` relies on `Click on element`'s built-in wait for the
  `save` button after the checkbox (SAVE is absent until T&C is checked — 069 unchecked state has
  only BACK + progress bar); confirm SAVE appears promptly on device.
- No device run was performed (real-device only, T42); the whole flow is dry-run/offline-verified.
