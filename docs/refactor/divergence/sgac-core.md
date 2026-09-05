# Divergence report — SGAC core screens (Android), SGAC1.0 → SGAC2.0

- Status: OFFLINE / pattern-based (no device). Every proposal is a **hypothesis** needing
  on-device confirmation against build 2.0.0 / versionCode 420.
- Date: 2026-09-05
- Scope: the SGAC core Android screens under `Data/sgac1/android/sgac/`, **excluding**
  `sgac_landing_page.yaml` (already diverged — see `Data/sgac2/android/sgac/sgac_landing_page.yaml`).
  5 screens, 53 keys.
- Sources: `Data/sgac2/android/STATUS.md` (live-walk status + drift patterns),
  `docs/refactor/fork-conventions.md`, the diverged `sgac_landing_page.yaml`, and
  `Resources/android/SGACcommands.robot` (flow usage).

## How to read this

**Classification** (one per key):

- **unchanged** — text- or class-based, or a generic/structural testID (`back`, `next`, `save`,
  `card`, `card-container`, `progress-bar`); expected identical in 2.0. Still device-confirm.
- **renamed-SNAKE_CASE** — a *concatenated-label* testID (surfaced as `resource-id`, sometimes
  mirrored in `content-desc`); 2.0 converts the label suffix to an UPPER_SNAKE constant while
  keeping the component/namespace prefix. Proposed id given.
- **flow-diverged** — the element's parent screen/flow concept was restructured in 2.0; the
  locator *string* may be unchanged but its screen no longer exists in the same role. Needs device.
- **removed** — element is specific to a concept 2.0 dropped; no 2.0 equivalent expected.

**Confidence**: high / med / low — how sure the *proposed 2.0 locator* is. Pattern-based
renames are **med at best** (see the caveat below).

## Dominant 2.0 drift pattern (applied here)

React-Native testIDs in *concatenated-label* form → SNAKE_CASE constants, keeping the prefix:

- `Home` + label → `HomeCITIZEN_RESIDENT_SG_ARRIVAL_CARD`
- `EServices` + `PassportandIdentityCard` → `EServicesPASSPORT_AND_IDENTITY_CARD`

Transform = keep the namespace prefix in its original case; split the label into words, uppercase,
join with `_`. Applied in this report:

| sgac1 resource-id | proposed 2.0 (SNAKE_CASE) |
| --- | --- |
| `ProfileAddProfile` | `ProfileADD_PROFILE` |
| `SgacGoBackToDashboard` | `SgacGO_BACK_TO_DASHBOARD` |
| `individualSubmissionsAddSubmission` | `individualSubmissionsADD_SUBMISSION` (only if the concept survives — likely removed) |
| `GoToSgac` | `GO_TO_SGAC` (no clear namespace prefix — low confidence) |

> **CAVEAT that caps confidence at med:** 2.0 does **not** SNAKE_CASE *everything*. The diverged
> landing shows **new** profile-centric buttons using **spaced, human-readable** resource-ids
> (`resource-id="Manage Profiles"`, `"Create New Profile"`, `"Update SG Arrival Card"`), not
> SNAKE_CASE. So a surviving button may surface as the SNAKE_CASE form **or** a spaced label. For
> every renamed-SNAKE_CASE key below, the on-device step says to also try the spaced form
> (e.g. `"Add Profile"`, `"Go Back To Dashboard"`, `"Go To Sgac"`). Generic/structural testIDs
> (`back`/`next`/`save`/`card`/…) were untouched by the SNAKE_CASE conversion and stay as-is.

## Flow-divergence callouts (for T33)

The Individual/Group Submission model was replaced by a **profile-centric** model
(Manage Profiles / Create New Profile / Update SG Arrival Card), and the tutorial gate was
removed (confirmed on `sgac_landing_page`). Consequences for these 5 screens:

1. **`individual_submission_page.yaml` — FULL FLOW DIVERGENCE (highest priority for T33).**
   This *is* the "Individual Submission" list (All/Submitted/Draft/Expired tabs, "No individual
   submissions" empty state, ADD SUBMISSION). 2.0 has no such screen — the Individual/Group split
   is gone and "add individual submission" is superseded by profile-centric "add profile". Treat
   as removed/replaced, not a locator swap. Any surviving submissions list in 2.0 is reached
   differently and needs a fresh walk.

2. **`sel_profile_submission_page.yaml` — PARTIAL flow divergence.** The "Select Profile"
   submission step's *locator strings are mostly generic and likely unchanged*, but its **role and
   entry point changed**: in 1.0 it sits inside Individual Submission; in 2.0 the equivalent is
   reached via **"Update SG Arrival Card"**. Verify the step still exists and is entered that way.

3. **`indv_profile_list_page.yaml` — role ELEVATED (survives, renamed ids).** The profile list is
   now central, reached via **"Manage Profiles"**. It very likely persists, but its title/entry
   nomenclature and the two testIDs (`ProfileAddProfile`, `SgacGoBackToDashboard`) probably
   changed. Not a teardown, but T33 should confirm the entry path.

4. **`declaration_page.yaml`** and **5. `sub_success_page.yaml`** — generic submit/terminal steps,
   **not** flow divergences; expected to persist near-verbatim in 2.0's submit flow.

---

## 1. `individual_submission_page.yaml` — FULL FLOW DIVERGENCE

**Screen verdict:** removed/replaced in 2.0 (Individual/Group model dropped). The keys below are
classified by their most likely fate; several plain-label widgets (Back, status tabs) may
reappear on whatever profile-centric submissions/declarations list replaces this — hence
*flow-diverged* rather than *removed* for those.

| key | sgac1 locator | proposed sgac2 locator | confidence | on-device check step |
| --- | --- | --- | --- | --- |
| SGAC-INDIVIDUAL-HEADER | `//android.widget.TextView[@text="Individual Submission"]` | — (no 2.0 equivalent) | med | After entering SGAC in 2.0, confirm no screen titled "Individual Submission" exists. |
| SGAC-INDIVIDUAL-BACK-BUTTON | `//android.widget.Button[@content-desc="Back"]` | needs device (string is generic Back) | med | Generic Back persists app-wide; confirm which 2.0 screen (if any) hosts this list. |
| SGAC-INDIVIDUAL-TAB-ALL | `//android.view.ViewGroup[@content-desc="All"]` | needs device (plain content-desc likely unchanged) | low | Look for a 2.0 submissions/declarations list with All/Submitted/Draft/Expired tabs; if found, plain content-desc should resolve. |
| SGAC-INDIVIDUAL-TAB-SUBMITTED | `//android.view.ViewGroup[@content-desc="Submitted"]` | needs device (plain content-desc likely unchanged) | low | Same tabbed list as above. |
| SGAC-INDIVIDUAL-TAB-DRAFT | `//android.view.ViewGroup[@content-desc="Draft"]` | needs device (plain content-desc likely unchanged) | low | Same tabbed list as above. |
| SGAC-INDIVIDUAL-TAB-EXPIRED | `//android.view.ViewGroup[@content-desc="Expired"]` | needs device (plain content-desc likely unchanged) | low | Same tabbed list as above. |
| SGAC-INDIVIDUAL-EMPTY-STATE | `//android.widget.TextView[@text="No individual submissions"]` | — (no 2.0 equivalent) | med | With no submissions, check 2.0's empty-state copy; "No individual submissions" wording is 1.0-specific. |
| SGAC-INDIVIDUAL-ADD-SUBMISSION-BUTTON | `//android.view.ViewGroup[@resource-id="individualSubmissionsAddSubmission"]` | — (likely removed; if it survives → `individualSubmissionsADD_SUBMISSION`) | low | 2.0 replaced this with profile-centric add-profile (`content-desc="add profile plus icon"` on landing). Confirm no add-submission testID remains. |
| SGAC-INDIVIDUAL-ADD-SUBMISSION-LABEL | `//android.widget.TextView[@text="ADD SUBMISSION"]` | — (no 2.0 equivalent) | med | Confirm 2.0 uses ADD PROFILE / profile-centric copy instead of "ADD SUBMISSION". |

Classification: removed = 4 · flow-diverged = 5.

## 2. `indv_profile_list_page.yaml` — role ELEVATED (survives), 2 SNAKE_CASE renames

**Screen verdict:** the profile list is now central (entered via "Manage Profiles"). Text/labels
likely persist; the two concatenated-label testIDs likely rename. Confirm the entry path in T33.

| key | sgac1 locator | proposed sgac2 locator | confidence | on-device check step |
| --- | --- | --- | --- | --- |
| SGAC-PROFILE-LIST-HEADER | `//android.widget.TextView[@text="Profile"]` | same (verify wording) | med | Enter via "Manage Profiles"; confirm title — may read "Manage Profiles" / "Profiles" instead of "Profile". |
| SGAC-PROFILE-LIST-BACK-BUTTON | `//android.widget.Button[@content-desc="Back"]` | same | high | Generic Back; confirm present on the 2.0 profile list. |
| SGAC-PROFILE-LIST-EMPTY-STATE | `//android.widget.TextView[@text="No profiles"]` | same (verify wording) | med | With zero profiles, confirm empty-state copy still "No profiles". |
| SGAC-ADD-PROFILE-BUTTON | `//android.widget.Button[@resource-id="ProfileAddProfile"]` | `//android.widget.Button[@resource-id="ProfileADD_PROFILE"]` | med | Try SNAKE_CASE id first; if it misses, try spaced `resource-id="Add Profile"` and the label fallback (text "ADD PROFILE"). |
| SGAC-ADD-PROFILE-LABEL | `//android.widget.TextView[@text="ADD PROFILE"]` | same | med | Confirm button label text unchanged. |
| SGAC-PROFILE-LIST-GO-BACK-DASHBOARD-BUTTON | `//android.view.ViewGroup[@resource-id="SgacGoBackToDashboard"]` | `//android.view.ViewGroup[@resource-id="SgacGO_BACK_TO_DASHBOARD"]` | med | Try SNAKE_CASE id first; fallback spaced `resource-id="Go Back To Dashboard"` or label text. Also verify this action still exists (no tutorial/dashboard gate in 2.0). |
| SGAC-PROFILE-LIST-GO-BACK-DASHBOARD-LABEL | `//android.widget.TextView[@text="GO BACK TO DASHBOARD"]` | same (verify still present) | med | Confirm the "GO BACK TO DASHBOARD" action still exists in 2.0's profile-centric nav. |

Classification: unchanged = 5 · renamed-SNAKE_CASE = 2.

## 3. `sel_profile_submission_page.yaml` — PARTIAL flow divergence (role/entry changed)

**Screen verdict:** locator strings mostly generic/unchanged, but the step is reached differently
in 2.0 (via "Update SG Arrival Card", not Individual Submission). Confirm the step still exists
and its entry path.

| key | sgac1 locator | proposed sgac2 locator | confidence | on-device check step |
| --- | --- | --- | --- | --- |
| SGAC-SEL-PROFILE-HEADER | `//android.widget.TextView[@text="Select Profile"]` | same (verify wording + entry) | med | From "Update SG Arrival Card", confirm a profile-selection step titled "Select Profile". |
| SGAC-SEL-PROFILE-BACK-BUTTON | `//android.widget.Button[@content-desc="Back"]` | same | high | Generic Back. |
| SGAC-SEL-PROFILE-CARD-BUTTON | `//android.view.ViewGroup[@resource-id="card"]` | same | med | Generic `card` testID; confirm profile cards still use `resource-id="card"`. |
| SGAC-SEL-PROFILE-CARD-RIGHT-ICON | `//android.widget.Button[@content-desc="select profile card right icon"]` | same (verify) | med | Descriptive content-desc (not a SNAKE_CASE testID); confirm it persists. |
| SGAC-SEL-PROFILE-ADD-PROFILE-BUTTON | `//android.widget.Button[@resource-id="ProfileAddProfile"]` | `//android.widget.Button[@resource-id="ProfileADD_PROFILE"]` | med | Same testID as screen 2; try SNAKE_CASE, then spaced `"Add Profile"`, then label. |
| SGAC-SEL-PROFILE-ADD-PROFILE-LABEL | `//android.widget.TextView[@text="ADD PROFILE"]` | same | med | Confirm label unchanged. |
| SGAC-SEL-PROFILE-FOOTER-BACK-BUTTON | `//android.view.ViewGroup[@resource-id="back"]` | same | med | Generic footer `back` testID. |
| SGAC-SEL-PROFILE-FOOTER-BACK-LABEL | `//android.widget.TextView[@text="BACK"]` | same | high | Footer BACK label. |
| SGAC-SEL-PROFILE-FOOTER-NEXT-BUTTON | `//android.view.ViewGroup[@resource-id="next"]` | same | med | Generic footer `next` testID. |
| SGAC-SEL-PROFILE-FOOTER-NEXT-LABEL | `//android.widget.TextView[@text="NEXT"]` | same | high | Footer NEXT label. |

Note: the commented-out `SGAC-SEL-PROFILE-CARD-LABEL` (placeholder text "TEST") is not counted.

Classification: unchanged = 9 · renamed-SNAKE_CASE = 1.

## 4. `declaration_page.yaml` — generic submit step, largely UNCHANGED

**Screen verdict:** a generic declaration/consent step expected to persist near-verbatim in 2.0's
submit flow. All text/class/generic-testID; no SNAKE_CASE candidates. Watch only for reworded
copy or an added consent sub-step under the profile-centric flow.

| key | sgac1 locator | proposed sgac2 locator | confidence | on-device check step |
| --- | --- | --- | --- | --- |
| SGAC-DECLARATION-HEADER | `//android.widget.TextView[@text="Declaration"]` | same | med | Reach the declaration step; confirm title "Declaration". |
| SGAC-DECLARATION-BACK-BUTTON | `//android.widget.Button[@content-desc="Back"]` | same | high | Generic Back. |
| SGAC-DECLARATION-TEXT | `//android.widget.TextView[contains(@text,"I hereby confirm")]` | same | med | Confirm declaration body still contains "I hereby confirm". |
| SGAC-DECLARATION-CONSENT-TEXT | `//android.widget.TextView[contains(@text,"Consent to data sharing")]` | same | med | Confirm consent section text unchanged. |
| SGAC-DECLARATION-CHECKBOX | `//android.view.ViewGroup[contains(@content-desc,"I have read and agreed to the declaration")]` | same | med | Confirm unchecked checkbox content-desc contains the phrase. |
| SGAC-DECLARATION-CHECKBOX-LABEL | `//android.widget.TextView[@text="I have read and agreed to the declaration."]` | same | med | Confirm label text unchanged. |
| SGAC-DECLARATION-CHECKBOX-CHECKED | `//android.view.ViewGroup[@content-desc="checkedI have read and agreed to the declaration."]` | same | med | Tap the checkbox; confirm the checked state still prefixes `checked` to the label in content-desc. |
| SGAC-DECLARATION-FOOTER-BACK-BUTTON | `//android.view.ViewGroup[@resource-id="back"]` | same | med | Generic footer `back` testID. |
| SGAC-DECLARATION-FOOTER-BACK-LABEL | `//android.widget.TextView[@text="BACK"]` | same | high | Footer BACK label. |
| SGAC-DECLARATION-PROGRESS-BAR | `//android.view.View[@resource-id="progress-bar"]` | same | med | Structural `progress-bar` id; confirm present. |
| SGAC-DECLARATION-FOOTER-SUBMIT-BUTTON | `//android.view.ViewGroup[@resource-id="save"]` | same | med | Generic `save` testID drives Submit; confirm unchanged. |
| SGAC-DECLARATION-FOOTER-SUBMIT-LABEL | `//android.widget.TextView[@text="SUBMIT"]` | same | high | Footer SUBMIT label. |

Classification: unchanged = 12.

## 5. `sub_success_page.yaml` — generic terminal step, largely UNCHANGED, 1 SNAKE_CASE candidate

**Screen verdict:** the submission-success terminal screen; expected to persist. All text except
two testIDs; only `GoToSgac` is a rename candidate. The Back locator is a brittle structural
xpath (ViewGroup + SvgView) — verify carefully.

| key | sgac1 locator | proposed sgac2 locator | confidence | on-device check step |
| --- | --- | --- | --- | --- |
| SGAC-SUB-SUCCESS-HEADER | `//android.widget.TextView[@text="Submission Successful"]` | same | med | Complete a submit; confirm header "Submission Successful". |
| SGAC-SUB-SUCCESS-BACK-BUTTON | `//android.view.ViewGroup[@clickable="true" and .//com.horcrux.svg.SvgView]` | same (verify structure) | low | Brittle structural xpath; confirm an SVG-icon clickable ViewGroup still serves as Back. |
| SGAC-SUB-SUCCESS-CARD | `//android.view.ViewGroup[@resource-id="card-container"]` | same | med | Structural `card-container` id; confirm present. |
| SGAC-SUB-SUCCESS-TITLE | `//android.widget.TextView[@text="SUBMISSION SUCCESSFUL"]` | same | med | Confirm title text unchanged. |
| SGAC-SUB-SUCCESS-MSG | `//android.widget.TextView[contains(@text,"Your submission is successful")]` | same | med | Confirm success message text. |
| SGAC-SUB-SUCCESS-DRUGS-WARNING | `//android.widget.TextView[contains(@text,"Drug trafficking is an offence")]` | same | med | Confirm drugs warning text present. |
| SGAC-SUB-SUCCESS-HEALTH-WARNING | `//android.widget.TextView[contains(@text,"Providing false health declarations")]` | same | med | Confirm health warning text present. |
| SGAC-SUB-SUCCESS-REMINDER | `//android.widget.TextView[contains(@text,"You are reminded to update and resubmit")]` | same | med | Confirm reminder text present. |
| SGAC-SUB-SUCCESS-INFO-LINK | `//android.widget.TextView[contains(@text,"Please tap here for information")]` | same | med | Confirm info link text present. |
| SGAC-SUB-SUCCESS-OTHER-DECLARATIONS-TITLE | `//android.widget.TextView[@text="OTHER DECLARATIONS"]` | same | med | Confirm "OTHER DECLARATIONS" section title. |
| SGAC-SUB-SUCCESS-CBNI-TITLE | `//android.widget.TextView[contains(@text,"Cash (CBNI) Declaration")]` | same | med | Confirm CBNI declaration card title. |
| SGAC-SUB-SUCCESS-CBNI-DESC | `//android.widget.TextView[contains(@text,"Physical Currency and Bearer Negotiable Instruments")]` | same | med | Confirm CBNI description text. |
| SGAC-SUB-SUCCESS-CUSTOMS-TITLE | `//android.widget.TextView[contains(@text,"Customs Declaration")]` | same | med | Confirm Customs declaration card title. |
| SGAC-SUB-SUCCESS-GO-TO-SGAC-BUTTON | `//android.view.ViewGroup[@resource-id="GoToSgac"]` | `//android.view.ViewGroup[@resource-id="GO_TO_SGAC"]` | low | No clear namespace prefix, so SNAKE_CASE form is uncertain; try `GO_TO_SGAC`, then original `GoToSgac`, then spaced `"Go To Sgac"`, then the label fallback (text "GO TO SG ARRIVAL CARD"). |
| SGAC-SUB-SUCCESS-GO-TO-SGAC-LABEL | `//android.widget.TextView[@text="GO TO SG ARRIVAL CARD"]` | same | med | Confirm button label unchanged. |

Classification: unchanged = 14 · renamed-SNAKE_CASE = 1.

---

## Summary

| Screen | keys | unchanged | renamed-SNAKE_CASE | flow-diverged | removed | screen verdict |
| --- | --- | --- | --- | --- | --- | --- |
| individual_submission_page.yaml | 9 | 0 | 0 | 5 | 4 | **FULL flow divergence (T33)** |
| indv_profile_list_page.yaml | 7 | 5 | 2 | 0 | 0 | role elevated (survives) |
| sel_profile_submission_page.yaml | 10 | 9 | 1 | 0 | 0 | partial flow divergence (entry changed) |
| declaration_page.yaml | 12 | 12 | 0 | 0 | 0 | unchanged (generic step) |
| sub_success_page.yaml | 15 | 14 | 1 | 0 | 0 | unchanged (generic step) |
| **Total** | **53** | **40** | **4** | **5** | **4** | |

**For T33:** `individual_submission_page.yaml` is a full flow divergence (Individual/Group model
removed — no 2.0 equivalent as-is). `sel_profile_submission_page.yaml` is a partial divergence
(same locators, new entry via "Update SG Arrival Card"). `indv_profile_list_page.yaml` survives
with an elevated role (entered via "Manage Profiles") and 2 renamed testIDs.

**Cross-reference:** consistent with `Data/sgac2/android/STATUS.md` — these 5 files are all still
`copied` (unverified) in the sgac2 tree; this report is the offline hypothesis set to accelerate
their live walk. Do not edit `Data/sgac2/android/**` from this task.
