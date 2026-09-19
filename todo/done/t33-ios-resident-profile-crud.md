# T33 slice 1 (iOS): fork-dispatch the SGAC resident profile CRUD flow so `crud_res_profile.robot` is SGAC2.0-ready

- Status: Done (offline implementation + dev-lead review, merged to main 2026-09-19); runtime acceptance pending under T42
- Owner: OpenCode `deepseek/deepseek-v4-pro` (implementation) — dev lead Claude (review + merge)
- Priority: High
- Created: 2026-09-19
- Updated: 2026-09-19

## Goal

Make the iOS SGAC resident profile creation flow run on BOTH forks from ONE suite
(`tests/ios/sgac/crud_res_profile.robot`) by moving the fork-divergent navigation and form
steps into `Resources/ios/SGACcommands.robot` behind stable public keyword names
(fork-conventions §6 pattern A: `Run Keyword    <name> for ${APP_FORK}`), and by
reconciling the sgac2 iOS resident locator files with the LATEST captured build
(2.0.0(17), 16 Sept) — the files were verified on build 13 (6 Sept) and at least the
contact page has changed since. Every sgac2 locator the new flow touches must be verified
OFFLINE against the captured page sources in `Output/evidence/` with
`tools/xpath_evidence_check.py`. No device is available and none may be used (the iPad
and the Appium server are in use by another agent right now).

## Context (read these first, in this order)

1. `CLAUDE.md` in full (mandatory) and Mnemosyne recall (`mnemosyne_recall`, query: "appium_robot_framework T33 SGAC2 iOS resident profile flow dispatch"). Do NOT store anything in Mnemosyne; the dev lead does that.
2. `docs/refactor/fork-conventions.md` §5 (tags) and §6 (dispatch pattern) — follow verbatim.
3. `docs/refactor/sgac-fork-refactor-tasks.md` → T33 and T32.
4. `Data/sgac2/ios/STATUS.md` — READ ONLY (do not edit; it is being edited elsewhere). Note Sessions 2–5 and the Screens table rows for `sgac/sgac_landing_page.yaml`, `sgac/profile_list_page.yaml`, `sgac/resident/res_profile_form_page.yaml`, `sgac/resident/res_profile_summary.yaml`.
5. `docs/testing/ios-build17-regression-2026-09-16.md` (build 17 — the newest evidence) and `docs/testing/ios-sgac2-build15-regression-2026-09-10.md` (build 15).

### What the evidence already shows (dev lead pre-analysis)

Build 17 captures (`Output/evidence/myica-build17-regression-2026-09-16/ios/`), resident
profile creation: `005-resident-baseline.xml` (SGAC landing) → `006-resident-creation-method.xml`
→ `016-resident-empty-validation.xml` (page 1 empty + Required markers) →
`017-resident-nationality-search.xml` (nationality modal) → `018-resident-identity-filled.xml`
→ `019-resident-contact-validation.xml`, `020-resident-invalid-email.xml` (page 2) →
`021-resident-summary-unchecked.xml` → `022-resident-summary-accepted.xml` (T&C checked, SAVE
present) → `023-resident-saved.xml` → `024-resident-after-restart.xml`; then edit flow
`026`–`032` (View / Edit, masked fields, edit summary, saved).

Facts that CONTRADICT the current sgac2 YAML annotations and must be fixed from evidence:

- **Contact page is NOT email-only on build 17.** `021-resident-summary-unchecked.xml` shows the Contact Details card with `Country/Region Code` = `+65`, `Mobile Number` = `8 1 2 3 4 5 6 7` (rendered with spaces, exactly what `helper_func.Add Space Between String` produces and what the sgac1 suite already asserts) and `Email Address` (upper-cased). So the country-code and mobile inputs on page 2 (`019`/`020`) and their summary rows are back. Restore the corresponding keys in `Data/sgac2/ios/sgac/resident/res_profile_form_page.yaml` and `res_profile_summary.yaml` with locators verified against those captures, fix the file header comments, and REMOVE those keys from `tools/fork_parity_allowlist.yaml` (`ios/sgac/resident/res_profile_form_page.yaml: sgac1_only` and `ios/sgac/resident/res_profile_summary.yaml: sgac1_only`) so the linter's key parity is real again. Keep the keys that are still genuinely 2.0-only/removed (e.g. the terms-link merge) only if the build-17 captures confirm them.
- The creation-method buttons: `fill manually` and `scan passport mrz` share `name="ProfileAddProfile"` and differ by `label` (`006-resident-creation-method.xml`) — the existing `PROFILE-CREATION-METHOD-FILL-MANUALLY` (`@label="fill manually"`) is correct; do not switch it to `name`.
- Header/label keys that match TWO nodes per capture (RN duplicates a StaticText's name/label) show as `ambiguous` in the checker; that is acceptable for `Expect Element … visible` assertions but every key the flow TAPS or TYPES into must be `verified` (exactly one node).
- The landing tiles: `SGAC-LANDING-CREATE-NEW-PROFILE` (`name="Create New Profile"`) and `SGAC-LANDING-MANAGE-PROFILES` resolve on build 17 (`005-resident-baseline.xml`); check `SGAC-LANDING-ADD-PROFILE` ("add profile plus icon") too — on Android build 15 that element no longer exists; report what iOS build 17 shows and do not route the flow through it if it is absent.
- Summary values: DOB and passport expiry render as `dd / mm / yyyy` (`helper_func.Date Field Formatter`), nationality as `SINGAPOREAN`, NRIC and passport number unmasked in the Add Profile summary (masked only in Edit Profile).

`Generate Profile Record` (Data/test_data/manual_field_random.py) returns `name`, `nric`,
`dob`, `pp_num` (SG passport), `pp_expiry`, `cty_code`, `phno`, `email` (+ `foreign_pp_num`,
`country`, `seed`, `reference_date`). Use `country=SG`; select nationality `SINGAPOREAN` via
`RES-FORM-NATIONALITY-DROPDOWN` → `RES-FORM-NATIONALITY-SEARCH` → option from
`RES-FORM-NATIONALITY-OPTION-TEMPLATE` with `Format String`.

## Scope

### Included (files you own — edit nothing else)

- `Resources/ios/SGACcommands.robot`
- `tests/ios/sgac/crud_res_profile.robot`
- `tests/ios/sgac/crud_res_indv_submission.robot` (tags/documentation only)
- `Data/sgac2/ios/sgac/sgac_landing_page.yaml` (annotations / build-17 findings; do not delete keys)
- `Data/sgac2/ios/sgac/profile_list_page.yaml` (only if evidence requires a change)
- `Data/sgac2/ios/sgac/profile_creation_method_page.yaml` (only if evidence requires a change)
- `Data/sgac2/ios/sgac/resident/res_profile_form_page.yaml`
- `Data/sgac2/ios/sgac/resident/res_profile_summary.yaml`
- `tools/fork_parity_allowlist.yaml` (iOS entries only; the linter errors on unused entries, so the lists must match the YAMLs exactly)
- `tools/xpath_evidence_check.py` (provided by the dev lead; fix only if it is broken)
- this task file (keep Progress / Outcome current)

### Excluded

- `Data/sgac2/ios/STATUS.md`, `CLAUDE.md`, `docs/README.md`, `docs/**` — in flight elsewhere; put the notes the dev lead should port into the Outcome section of this file instead.
- Any Android file, any `Data/sgac1/**` file, `Resources/commands.robot`, `Resources/ios_appium_commands.py`, `robotconfig.yaml`, `opencode.json`, `venv`, `Output/**`.
- The foreigner profile suite (`crud_for_profile.robot`) and the SGAC2.0 submission/update webview flows — separate slices.
- Device/Appium/MCP sessions of any kind. Evidence XML only.

## Required design

Public keywords (suite-facing, fork-agnostic) in `Resources/ios/SGACcommands.robot`, each
dispatching with `Run Keyword    <name> for ${APP_FORK}    …` to `… for sgac1` / `… for sgac2`
implementations, per fork-conventions §6 pattern A:

1. `Navigate to resident SGAC landing page` — sgac1: today's two clicks (leave the commented tutorial line out); sgac2: tap `${CITIZEN&RESIDENT-SGARRIVAL-CARD-FAV-BUTTON}` (landing_page.yaml, `HomeCITIZEN_RESIDENT_SG_ARRIVAL_CARD`) then `Wait Until Element Is Visible    ${SGAC-LANDING-CREATE-NEW-PROFILE}`.
2. `Navigate to profile list page` — sgac1: `${SGAC-LANDING-VIEW-PROFILE}`; sgac2: `${SGAC-LANDING-MANAGE-PROFILES}` then wait for `${RES-PROFILE-LIST-HEADER}` (verify it against a build-17 capture of the Manage Profiles list if one exists — search the evidence for the `ProfileAddProfile` button together with the `Profile` header; if none exists, say so and keep the wait on the landing tap only).
3. `Navigate to resident profile creation method page` (NEW) — precondition: SGAC landing. sgac1: profile list → `${ADD-PROFILE-BTN}`; sgac2: `${SGAC-LANDING-CREATE-NEW-PROFILE}`. End with `Wait Until Element Is Visible    ${PROFILE-CREATION-METHOD-FILL-MANUALLY}`.
4. `Fill resident profile form    ${profile}` (NEW) — precondition: creation-method page. Taps `fill manually`, fills page 1 and page 2 (with the `${KEYBOARD-DONE-BTN}` taps the existing flow uses), ends on the summary. sgac1: today's fields; sgac2: name, DOB, NRIC, nationality (modal), passport number, passport expiry → next → country code, mobile, email → next. Field ORDER must follow the build-17 capture, not the sgac1 file.
5. `Verify resident profile summary    ${profile}` (NEW) — the `Format String` + `Expect Element … visible` assertions that live inline in the suite today, moved here (keep the `Add Space Between String` and `Convert To Upper Case` treatment the suite already applies); sgac2 additionally asserts nationality, passport number and passport expiry.
6. `Accept terms and save resident profile` (NEW, shared unless evidence differs) — `${RES-DECL-SUMMARY-TERMS-CHECKBOX-UNCHECKED}` then `${RES-DECL-SUMMARY-FOOTER-SAVE}` (on 2.0 SAVE only appears after the checkbox — use `Click on element`'s built-in wait, and state whether a `Wait Until Element Is Visible` is needed).
7. `Create resident profile manually    ${profile}=${NONE}` — keep the name and return value (`crud_res_indv_submission.robot` calls it). sgac1 precondition stays as today (a screen showing ADD PROFILE); sgac2 precondition is the SGAC landing. Implement as a composition of 3–6.

Suite `tests/ios/sgac/crud_res_profile.robot` becomes fork-agnostic: generate the record
(`country=SG`), call 1 → 3 → 4 → 5 → 6, no inline locators, `Force Tags    fork:both`
kept. Keep `Test Setup`/`Test Teardown` and the import order (fork_config.py first).

`tests/ios/sgac/crud_res_indv_submission.robot`: the native Individual Submission →
declaration → captcha flow does not exist in SGAC2.0 (2.0 submission is web-based / blocked
by the profile-update gate — see STATUS Session 3 and the build-15/17 reports). Tag BOTH tests
`fork:sgac1-only` (test-level tag alongside the suite `Force Tags`; the net effect must be
that sgac2 runs exclude them and sgac1 runs include them) and add a `[Documentation]` line
referencing `docs/testing/ios-build17-regression-2026-09-16.md` with `TODO(T33-web)`. Change
nothing else there. Leave `Navigate to individual submission creation page` in place with a
documentation line stating it is sgac1-only.

Locator rules: UPPER-KEBAB-CASE keys, raw XPath (this keyword file prefixes `xpath=` at some
call sites — keep whichever style each existing line uses; do not mass-normalise), prefer
`name`/testID over visible text, one-line comment per changed key naming the build-17
evidence file, keep the existing key families (`RES-FORM-…`, `RES-DECL-SUMMARY-…`).

## Acceptance criteria

- [ ] `APP_FORK=sgac1 venv/bin/robot --dryrun tests` and `APP_FORK=sgac2 venv/bin/robot --dryrun tests` both pass with zero errors.
- [ ] Every `${LOCATOR-KEY}` referenced on the sgac2 path exists in the sgac2 YAMLs the file imports, and every key on the sgac1 path exists in the sgac1 YAMLs (dev lead re-checks with a script; do your own pass).
- [ ] `venv/bin/python -B tools/check_fork_parity.py --strict` → 0 errors, 0 warnings (after the allowlist corrections).
- [ ] `venv/bin/python -B -m pytest tests/unit -q -p no:cacheprovider` → all pass (251 at start).
- [ ] `git diff --check` clean; no tabs in `.robot` files; 4-space separators.
- [ ] `tools/xpath_evidence_check.py` run for `landing_page.yaml`, `sgac/sgac_landing_page.yaml`, `sgac/profile_creation_method_page.yaml`, `sgac/resident/res_profile_form_page.yaml`, `sgac/resident/res_profile_summary.yaml` (sgac2 ios) against `Output/evidence/myica-build17-regression-2026-09-16/ios` (`--match resident` for the resident files, no filter for landing) and, as a cross-check, `Output/evidence/ios-sgac2-build15-regression-2026-09-10`: every key the sgac2 flow taps, types into or waits for is `verified` in at least one capture of the right screen; tables pasted into Outcome. Template keys: verify the filled value (`SINGAPOREAN` option) with a one-off lxml check and record the matching file.
- [ ] `sgac1` behaviour is the same sequence of clicks/typing as before the change (list before/after in Outcome).
- [ ] No file outside "Included" changed; nothing committed, nothing pushed; `venv`, `opencode.json`, `Output/` untouched and unstaged.

## Validation plan

```sh
venv/bin/python -B -m pytest tests/unit -q -p no:cacheprovider
venv/bin/python -B tools/check_fork_parity.py --strict
APP_FORK=sgac1 venv/bin/robot --dryrun -d Output/dryrun-sgac1 tests
APP_FORK=sgac2 venv/bin/robot --dryrun -d Output/dryrun-sgac2 tests
git diff --check
venv/bin/python tools/xpath_evidence_check.py --yaml Data/sgac2/ios/sgac/resident/res_profile_form_page.yaml --evidence Output/evidence/myica-build17-regression-2026-09-16/ios --match resident
# …repeat per YAML / evidence dir as listed above
```

Runtime verification on the iPad is NOT part of this task (real-device only, Edwin-in-the-loop);
say so in Outcome and list the runtime risks you could not close offline (e.g. keyboard
Done handling after the new fields, whether SAVE needs an explicit wait).

## Progress and decisions

- 2026-09-19 — Read brief, CLAUDE.md, fork-conventions §5/§6, task board T33/T32, and
  `Data/sgac2/ios/STATUS.md` (read-only). Note: `docs/testing/ios-build17-regression-2026-09-16.md`
  does NOT exist yet in the worktree (in flight elsewhere); evidence XML under
  `Output/evidence/myica-build17-regression-2026-09-16/ios/` is present and is the source of truth.
- 2026-09-19 — Re-verified the sgac2 iOS resident locators against build 17 page sources. Key
  findings: (1) contact page 2 is code+mobile+email again (019/020); (2) summary contact card
  has Country/Region Code + Mobile Number + Email rows (021/022); (3) `SGAC-LANDING-ADD-PROFILE`
  ("add profile plus icon") IS STILL PRESENT on iOS build 17 (005), unlike Android build 15 —
  the flow does not route through it; (4) creation-method buttons share `name="ProfileAddProfile"`
  and differ by `label` (006), so `PROFILE-CREATION-METHOD-FILL-MANUALLY` `@label` is correct;
  (5) summary renders DOB/expiry as `dd / mm / yyyy`, nationality `SINGAPOREAN`, NRIC/pp unmasked.
- 2026-09-19 — Restored 5 contact-page keys in `res_profile_form_page.yaml` and 4 contact rows in
  `res_profile_summary.yaml`, and reconciled `tools/fork_parity_allowlist.yaml` (dropped the two
  `sgac1_only` contact lists; kept `RES-DECL-SUMMARY-TERMS-LINK` sgac1_only and the 6
  nationality/passport sgac2_only entries). Parity linter stays 0/0.
- 2026-09-19 — `RES-FORM-MOBILE-NUMBER-LABEL` cannot be verified on build 17: the mobile field has
  no standalone "Mobile Number" StaticText label in the form page a11y tree (only the input and
  Required marker). Restored at the sgac1 locator for key parity; it is NOT a flow key.
- 2026-09-19 — Implemented dispatch per fork-conventions §6 pattern A (`Run Keyword … for ${APP_FORK}`)
  in `Resources/ios/SGACcommands.robot`; rewrote `crud_res_profile.robot` to the 1→3→4→5→6 flow;
  tagged both `crud_res_indv_submission.robot` tests `fork:sgac1-only` with a TODO(T33-web) doc
  line. Verified the tag net effect: sgac2 `--exclude fork:sgac1-only` drops the two tests, sgac1
  `--exclude fork:sgac2-only` keeps them.

- 2026-09-19 — DEV-LEAD REVIEW (Claude): diff accepted. Independent re-run: pytest 251/251, parity
  strict 0/0, dryrun 68/68 both forks (66/66 each with the fork exclude flags), diff --check clean;
  per-fork variable resolution check shows every key on the sgac2 path defined in the sgac2 tree
  (the sgac1-only keys are referenced only inside `… for sgac1` keywords, which never execute on
  sgac2); all 19 sgac2 flow keys `verified` (exactly one node) in build-17 captures; the
  `SINGAPOREAN` option resolves to one node in 017. Two adjustments applied at merge:
  (a) the four new `Wait Until Element Is Visible` screen-transition waits now pass
  `${INTERACTION_WAIT_TIMEOUT}` (AppiumLibrary's default wait is only a few seconds);
  (b) `crud_res_indv_submission.robot` carries `Force Tags    fork:sgac1-only` at suite level
  instead of `fork:both` plus a per-test tag, so every test keeps exactly one fork-scope tag
  (fork-conventions §5). The keyword-7 deviation (no summary verification inside
  `Create resident profile manually`) is accepted: it preserves the pre-refactor semantics and the
  unit-test regression guard. Note for STATUS: `RES-PROFILE-LIST-HEADER` (`name="Profile"`) also
  resolves on screens other than the Manage Profiles list, so the sgac2 `Navigate to profile list
  page` wait is weak; the Manage Profiles list screen itself has no clean build-17 capture and
  remains unverified for sgac2 iOS.

## Handoff or blocker

- **Design deviation (verify step not composed into keyword 7).** The brief says keyword 7
  `Create resident profile manually` is a "composition of 3–6". I composed it from 3 (navigate to
  creation-method page) + 4 (fill) + 6 (accept+save), and deliberately did NOT compose 5 (verify).
  Reason: `tests/unit/test_manual_field_random.py::test_ios_create_resident_profile_keyword` runs
  `Create resident profile manually` device-free with stubs for `Click on element`/`Type text` only —
  composing `Verify resident profile summary` would invoke the real AppiumLibrary `Expect Element`
  and fail with "No application is open". The acceptance battery requires 251 tests to pass and
  `tests/unit` is outside my file set, so keyword 7 keeps its pre-refactor semantics (fill + save,
  return the record; no summary verification). The fork-agnostic suite still verifies explicitly via
  1→3→4→5→6. If the dev lead wants verify inside keyword 7, the unit-test stub must also stub
  `Expect Element`.
- `docs/testing/ios-build17-regression-2026-09-16.md` referenced in the two `[Documentation]` lines
  does not exist in this worktree yet; it is authored elsewhere. The references are written to the
  exact path the brief named.

## Outcome

- Files changed: `Resources/ios/SGACcommands.robot`, `tests/ios/sgac/crud_res_profile.robot`,
  `tests/ios/sgac/crud_res_indv_submission.robot`, `Data/sgac2/ios/sgac/sgac_landing_page.yaml`,
  `Data/sgac2/ios/sgac/resident/res_profile_form_page.yaml`,
  `Data/sgac2/ios/sgac/resident/res_profile_summary.yaml`,
  `tools/fork_parity_allowlist.yaml` (iOS entries only), this task file. No file outside "Included"
  was touched; nothing committed/pushed. (`opencode.json` and `tools/xpath_evidence_check.py` were
  already modified/untracked in the worktree before this task began and were left untouched.)
- sgac1 step sequence before → after:
  - Before (`crud_res_profile.robot`, inline): landing (2 clicks) → profile list (VIEW-PROFILE) →
    ADD-PROFILE → fill-manually → type name,nric,dob → Done/next → Generate Random Cty Code SG(65),
    type cty_code,phno,email → Done/next → verify name,dob,nric,phno,email → checkbox → save.
  - Before (`Create resident profile manually` for `crud_res_indv_submission.robot`): ADD-PROFILE →
    fill-manually → type name,nric,dob → Done/next → type cty_code,phno,email → Done/next →
    checkbox → save (no verify).
  - After (`crud_res_profile.robot`): Generate record(country=SG) → 1 landing (same 2 clicks) →
    3 creation-method (profile list VIEW-PROFILE → ADD-PROFILE-BTN → wait fill-manually) → 4 fill
    (fill-manually → name,nric,dob → Done/next → cty_code,phno,email → Done/next) → 5 verify
    (name,dob,nric,phno,email) → 6 checkbox+save. Identical clicks/types; cty_code now `${profile}[cty_code]`
    (=65 for SG) instead of a separate `Generate Random Cty Code SG`.
  - After (`Create resident profile manually`): sgac1 = ADD-PROFILE (INDV-PROFILE-LIST-ADD-PROFILE) →
    Fill (4) → Accept+save (6); no verify, same as before.
- sgac2 step sequence (`crud_res_profile.robot`, and `Create resident profile manually` sgac2 branch):
  1 landing = tap `CITIZEN&RESIDENT-SGARRIVAL-CARD-FAV-BUTTON` → wait `SGAC-LANDING-CREATE-NEW-PROFILE`;
  3 creation-method = tap `SGAC-LANDING-CREATE-NEW-PROFILE` → wait `PROFILE-CREATION-METHOD-FILL-MANUALLY`;
  4 fill = fill-manually → name,DOB,NRIC → nationality dropdown → search "SINGAPOREAN" → option →
  passport number, expiry → Done/next → cty_code,mobile,email → Done/next;
  5 verify = name,dob,nric,SINGAPOREAN,pp_num,pp_expiry,phno,email; 6 checkbox → save.
- Evidence-check tables (paste tool output): see below.
- Validation results (paste the last lines of each command): see below.
- Notes for the dev lead to port into `Data/sgac2/ios/STATUS.md` (build-17 reconciliation: contact page fields restored, add-profile icon status, any other drift): see below.
- Runtime risks left for the iPad run: see below.

### Evidence-check tables (build 17, `Output/evidence/myica-build17-regression-2026-09-16/ios`)

`Data/sgac2/ios/landing_page.yaml` (no filter) — all 9 keys verified, 0 not verified:

```
CITIZEN&RESIDENT-SGARRIVAL-CARD-FAV-BUTTON  verified  one=11  e.g. 002-home-ready.xml
FORIEGNVISITOR-SGARRIVAL-CARD-FAV-BUTTON    verified  one=11
QR-CODE-FAV-BUTTON                          verified  one=11
CARGO-CLEARANCE-FAV-BUTTON                  verified  one=11
REGISTER-REREGISTER-REPLACE-FAV-BUTTON      verified  one=11
OTHER-E-SERVICES-FAV-BUTTON                 verified  one=9
CITIZEN-RESIDENT-ESERVICE-BUTTON            verified  one=250
FORIEGN-VISITOR-ESERVICE-BUTTON             verified  one=205
MYICA-SCAM-BANNER                           verified  one=29
checked 9 keys: 0 not verified
```

`Data/sgac2/ios/sgac/sgac_landing_page.yaml` (no filter) — flow keys verified:

```
SGAC-LANDING-CREATE-NEW-PROFILE   verified  one=22  e.g. 005-resident-baseline.xml
SGAC-LANDING-MANAGE-PROFILES      verified  one=22  e.g. 005-resident-baseline.xml
SGAC-LANDING-ADD-PROFILE          verified  one=4   e.g. 005-resident-baseline.xml   (present on iOS build 17)
SGAC-LANDING-BACK-BUTTON          verified  one=357
SGAC-LANDING-LANGUAGE-BUTTON      verified  one=22
SGAC-LANDING-UPDATE-ARRIVAL-CARD  verified  one=22
SGAC-LANDING-UPDATE-WEBVIEW-MARKER verified one=82
SGAC-LANDING-PROFILE-CARD-MENU    verified  one=18
SGAC-LANDING-CONTINUE             verified  one=20
SGAC-LANDING-CARD-MENU-VIEW-EDIT  verified  one=3
SGAC-LANDING-CARD-MENU-DELETE     verified  one=7
SGAC-LANDING-DELETE-CONFIRM-ALERT verified  one=3
SGAC-LANDING-DELETE-CONFIRM-BUTTON verified one=6
SGAC-LANDING-HEADER               ambiguous (2-node header; not tapped)
SGAC-LANDING-SELECT-PROFILES-SECTION ambiguous; PROFILE-SELECT-HINT ambiguous; EMPTY-STATE-HINT ambiguous
SGAC-LANDING-PROFILE-UPDATE-ALERT/BUTTON/CANCEL  unresolved (modal not in build-17 capture set; not flow keys)
checked 20 keys: 6 not verified (all non-flow; 3 ambiguous labels + 3 profile-update-modal keys)
```

`Data/sgac2/ios/sgac/profile_creation_method_page.yaml` (`--match resident`) — flow key verified:

```
PROFILE-CREATION-METHOD-FILL-MANUALLY       verified  one=1  e.g. 006-resident-creation-method.xml
PROFILE-CREATION-METHOD-SINGPASS            verified  one=1
PROFILE-CREATION-METHOD-SCAN-PASSPORT-MRZ   verified  one=1
PROFILE-CREATION-METHOD-BACK-BUTTON         verified  one=56
PROFILE-CREATION-METHOD-HEADER/TITLE        ambiguous (RN duplicate; not tapped)
checked 6 keys: 2 not verified (HEADER/TITLE ambiguous only)
```

`Data/sgac2/ios/sgac/resident/res_profile_form_page.yaml` (`--match resident`) — every flow key verified:

```
RES-FORM-NAME-INPUT            verified  one=5  e.g. 016-resident-empty-validation.xml
RES-FORM-DOB-INPUT             verified  one=6  e.g. 016
RES-FORM-NRIC-INPUT            verified  one=6  e.g. 016
RES-FORM-NATIONALITY-DROPDOWN  verified  one=3  e.g. 016
RES-FORM-NATIONALITY-SEARCH    verified  one=2  e.g. 017-resident-nationality-search.xml
RES-FORM-NATIONALITY-OPTION-TEMPLATE  template (skipped)  — filled value SINGAPOREAN resolves 1 node in 017 (one-off lxml check)
RES-FORM-PASSPORT-NUMBER-INPUT verified  one=6  e.g. 016
RES-FORM-PASSPORT-EXPIRY-INPUT verified  one=6  e.g. 016
RES-FORM-CTY-CODE-INPUT        verified  one=3  e.g. 019-resident-contact-validation.xml
RES-FORM-MOBILE-NUMBER-INPUT   verified  one=1  e.g. 019
RES-FORM-EMAIL-INPUT           verified  one=3  e.g. 019
RES-FORM-FOOTER-NEXT           verified  one=8  e.g. 016
RES-FORM-FOOTER-STEP-1/STEP-2  verified
checked 35 keys: 7 not verified (all ambiguous label/header keys, none are flow keys;
  RES-FORM-MOBILE-NUMBER-LABEL is ambiguous — no standalone label on the form page)
```

`Data/sgac2/ios/sgac/resident/res_profile_summary.yaml` (`--match resident`) — flow keys verified:

```
RES-DECL-SUMMARY-TERMS-CHECKBOX-UNCHECKED  verified  one=4  e.g. 021-resident-summary-unchecked.xml
RES-DECL-SUMMARY-FOOTER-SAVE               verified  one=1  e.g. 022-resident-summary-accepted.xml
RES-DECL-SUMMARY-TERMS-CHECKBOX-CHECKED    verified  one=1  e.g. 022
RES-DECL-SUMMARY-NAME-VALUE/DOB-VALUE/NRIC-VALUE  verified
RES-DECL-SUMMARY-NATIONALITY-VALUE         verified  one=5  e.g. 021
RES-DECL-SUMMARY-PASSPORT-NUMBER-VALUE     verified  one=9
RES-DECL-SUMMARY-PASSPORT-EXPIRY-VALUE     verified  one=10
RES-DECL-SUMMARY-COUNTRY-CODE-VALUE        verified  one=7  e.g. 019
RES-DECL-SUMMARY-MOBILE-VALUE              verified  one=5  e.g. 021
RES-DECL-SUMMARY-EMAIL-VALUE               verified  one=25 e.g. 021
checked 33 keys: 5 not verified (ambiguous label keys: HEADER, PASSPORT-HEADER, NATIONALITY-LABEL,
  CONTACT-HEADER, MOBILE-LABEL — none are flow keys)
```

Cross-check `Data/sgac2/ios/landing_page.yaml` vs build 15 (`Output/evidence/ios-sgac2-build15-regression-2026-09-10`):
`CITIZEN&RESIDENT-SGARRIVAL-CARD-FAV-BUTTON` verified (one=5, e.g. 002-home-baseline.xml); all 9 keys verified.
`Data/sgac2/ios/sgac/sgac_landing_page.yaml` vs build 15: `SGAC-LANDING-CREATE-NEW-PROFILE`,
`SGAC-LANDING-MANAGE-PROFILES`, `SGAC-LANDING-ADD-PROFILE` all verified (e.g. 005-resident-baseline.xml).
Build 15 has no resident creation form/summary captures (that run covered update/retrieval/foreigner/QR),
so the resident form/summary keys have no build-15 evidence — build-17 is the authoritative set.

One-off lxml check (nationality option template) — `017-resident-nationality-search.xml`:
`//XCUIElementTypeOther[@name="searchable dropdown accessible label SINGAPOREAN"]` → 1 node;
`//XCUIElementTypeTextField[@placeholderValue="Search"]` → 1 node;
`//XCUIElementTypeOther[@name="nationality/citizenship list"]` → 1 node.

### Validation results

```
venv/bin/python -B -m pytest tests/unit -q -p no:cacheprovider
  -> 251 passed in 1.20s
venv/bin/python -B tools/check_fork_parity.py --strict
  -> Summary: 0 errors, 0 warnings (strict: warnings treated as errors)
APP_FORK=sgac1 venv/bin/robot --dryrun -d Output/dryrun-sgac1 tests
  -> Tests | PASS | 68 tests, 68 passed, 0 failed
APP_FORK=sgac2 venv/bin/robot --dryrun -d Output/dryrun-sgac2 tests
  -> Tests | PASS | 68 tests, 68 passed, 0 failed
git diff --check
  -> clean (exit 0); no tabs in the three .robot files; 4-space separators
```

### Notes for the dev lead to port into `Data/sgac2/ios/STATUS.md`

- Build 17 (2.0.0(17)) restores the resident contact page to **Country/Region Code + Mobile Number +
  Email** (build 13 was email-only). `res_profile_form_page.yaml` + `res_profile_summary.yaml` are
  re-verified against 019/020/021/022; the "contact page is email-only" annotations are stale.
- `SGAC-LANDING-ADD-PROFILE` ("add profile plus icon") is still present on iOS build 17
  (005-resident-baseline.xml) — unlike Android build 15. Resident creation routes through
  Create New Profile, not this icon.
- `RES-FORM-MOBILE-NUMBER-LABEL` has no standalone StaticText label in the form-page a11y tree on
  build 17 (input + Required marker only); kept at the sgac1 locator for parity.
- The "Profile update required" alert keys (SGAC-LANDING-PROFILE-UPDATE-*) are still unverified
  against build-17 evidence (the modal was not captured in the 519-file build-17 set).

### Runtime risks left for the iPad run

- Nationality modal: after typing "SINGAPOREAN" into the search field the keyboard is up; tapping the
  option may require dismissing the keyboard first (the flow does not press Done before tapping the
  option). Watch for a swallowed option tap.
- Keyboard Done handling after the new passport-number/expiry fields on page 1 (before `next`).
- Whether `Accept terms and save resident profile` needs an explicit wait for SAVE after the checkbox —
  it relies on `Click on element`'s built-in wait; confirm SAVE appears promptly post-checkbox on device.
- The whole flow is only dry-run/offline-verified here; no device run was performed (real-device only,
  Edwin-in-the-loop).
