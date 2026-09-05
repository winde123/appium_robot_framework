# Divergence check — SGAC resident screens (Android)

SGAC1.0 → SGAC2.0 offline divergence report for the resident SGAC screens under
`Data/sgac1/android/sgac/resident/`. Produced offline (no device) from the sgac1 locator
YAMLs plus the live-verified findings and drift patterns in
[`Data/sgac2/android/STATUS.md`](../../../Data/sgac2/android/STATUS.md). Task:
`todo/done/divergence-check-sgac-resident.md`.

- Platform: Android only (iOS resident is a separate effort — not covered here).
- Method mirrors the sibling
  [`divergence-check-sgac-core`](../../../todo/backlog/divergence-check-sgac-core.md) task:
  classify each key, propose the 2.0 locator, give confidence + an on-device check step.
  **No edits were made to `Data/sgac2/android/**`** — this is analysis only.

## Classification

| Class | Meaning |
| --- | --- |
| `unchanged` | Expected to resolve as-is on 2.0 (text/class/generic-id based, or a form-field testID whose sibling was live-verified as-is). |
| `renamed-SNAKE_CASE` | testID (resource-id / content-desc) likely converted from concatenated-label form to a SNAKE_CASE constant — propose the 2.0 id. |
| `flow-diverged` | The key's screen role or entry path changed in 2.0's profile-centric flow, or the locator depends on layout/section ordering that 2.0 shifts. |
| `new (added in 2.0)` | Field/row that does not exist in sgac1; 2.0 adds it (the required-fields divergence). |
| `removed` | Element gone in 2.0. |

Confidence: **High** = strong offline prediction (text/class or verified analog) · **Medium** =
plausible but genuinely uncertain (concatenated-label content-desc, index/sibling-dependent, or
content that could be reworded) · **Low** = hypothesis only, exact string needs device.

## Drift patterns applied (from STATUS.md)

1. **App-wide SNAKE_CASE testIDs** — testIDs (resource-id, often mirrored in content-desc) were
   converted from concatenated-label to SNAKE_CASE constants. **Confirmed only on navigation
   cards/tiles** (home favourites `Home<CONSTANT>`, e-services `EServices<CONSTANT>`).
2. **Form-field testIDs are the exception — unchanged.** On the resident profile creation form
   **page 1**, `PassportDetailsFullName`, `PassportDetailsNricFin`, `PassportDetailsDateOfBirth`
   (and their `-label-inactive` labels) were **live-verified to resolve as-is on 2.0**. So
   `<Section><Field>` PascalCase form-field ids did NOT get SNAKE_CASE'd. This is the basis for
   the page-2 `ContactDetails*` prediction below.
3. **Text/class-based locators mostly unchanged.**
4. **Concatenated-label content-descs** that read like state+role tokens (e.g.
   `uncheckterms of use checkbox`, `unselected radio selection`, `declaration question answer no`)
   are the real SNAKE_CASE candidates on these screens — flag for device.
5. **SGAC arrival-card flow restructured** — Individual/Group Submission model replaced by a
   profile-centric model (Manage Profiles / Create New Profile / Update SG Arrival Card); tutorial
   gate removed. This is a **flow divergence (T33)**. Every resident submission/declaration/summary
   screen below is now *reached via a different entry path* even where its internal locators are
   intact.

---

## HEADLINE DIVERGENCE — new REQUIRED fields on the resident profile form (for T33)

**Live-verified this session (page 1 of `resident_profile_creation_form_page.yaml`):** SGAC2.0
**adds three REQUIRED fields** to the resident profile creation form that do **not** exist in
sgac1's YAML:

- **Nationality / Citizenship**
- **Passport Number**
- **Date of Passport Expiry**

Consequences:

1. **Blocker:** these new required fields sit on **page 1** and must be filled before the
   **NEXT** button advances to **page 2 (Contact Details)** — which is why page 2 was not reached
   on device this session. Any on-device verification of the page-2 keys below must fill them
   first.
2. **New keys needed in the sgac2 YAML** (not present in sgac1). Following the verified
   form-field convention (`PassportDetails<Field>` PascalCase, unchanged), the likely 2.0 testIDs
   are hypotheses only (widget type also unconfirmed — Nationality may be a picker/dropdown, not
   an EditText):

| Proposed sgac2 key | Proposed sgac2 locator (hypothesis) | Confidence | On-device check |
| --- | --- | --- | --- |
| RES-PROFILE-NATIONALITY-INPUT | `//*[@resource-id="PassportDetailsNationality"]` (or `...Citizenship`; may be a dropdown/picker, not `EditText`) | Low | Dump page 1 source; find the Nationality/Citizenship field, capture real resource-id + widget class |
| RES-PROFILE-NATIONALITY-LABEL | `//android.widget.TextView[@resource-id="PassportDetailsNationality-label-inactive"]` | Low | Confirm `-label-inactive` suffix holds for the new field |
| RES-PROFILE-PASSPORT-NUMBER-INPUT | `//android.widget.EditText[@resource-id="PassportDetailsPassportNumber"]` (or `...PassportNo`) | Low | Capture real resource-id from page-1 source |
| RES-PROFILE-PASSPORT-NUMBER-LABEL | `//android.widget.TextView[@resource-id="PassportDetailsPassportNumber-label-inactive"]` | Low | Confirm suffix |
| RES-PROFILE-PASSPORT-EXPIRY-INPUT | `//android.widget.EditText[@resource-id="PassportDetailsDateOfPassportExpiry"]` (or `...PassportExpiryDate`) | Low | Capture real resource-id; check for a calendar `right-icon-adornment` like DOB |
| RES-PROFILE-PASSPORT-EXPIRY-LABEL | `//android.widget.TextView[@resource-id="PassportDetailsDateOfPassportExpiry-label-inactive"]` | Low | Confirm suffix |
| RES-PROFILE-*-REQUIRED (each) | `//android.widget.TextView[@resource-id="errorMessage" and @text="Required"]` | Medium | Same generic error pattern as existing page-1 fields |

3. **Downstream ripple:** the new Passport Details fields will most likely surface as **new
   label/value rows** on the confirmation page (Screen 2) and the declaration summary (Screen 4),
   and may add/reorder sections — which shifts the index-based `EDIT`-button locators there
   (flagged per-screen below).

---

## Screen 1 — `resident_profile_creation_form_page.yaml` (page-2 Contact Details only)

Per task scope, only the **page-2 Contact Details** keys are analysed here (page-1 fields were
already live-verified as-is; do not re-edit that file). Contact Details is the second page of the
resident profile creation form, reached via **NEXT** after page 1.

**Prediction basis:** the page-1 sibling form fields (`PassportDetails*` + `-label-inactive`)
were verified as-is on 2.0, and these page-2 fields use the identical `ContactDetails<Field>`
convention — so **unchanged** is the primary hypothesis. Fallback if a key misses on device: the
SNAKE_CASE constant form (shown in the proposed column), by pattern 1.

**On-device reach step (all rows):** open the app → Create New Profile → resident/Singpass path →
fill page 1 **including the new required Nationality / Passport Number / Passport Expiry** → tap
**NEXT** → dump page source of the Contact Details page.

| Key | sgac1 locator | Proposed sgac2 locator | Class | Conf. | On-device check |
| --- | --- | --- | --- | --- | --- |
| RES-PROFILE-CONTACT-SECTION-TITLE | `//android.widget.TextView[@text="Contact Details"]` | same (unchanged) | unchanged | High | Section title text present on page 2 |
| RES-PROFILE-CONTACT-COUNTRY-CODE-INPUT | `//android.widget.EditText[@resource-id="ContactDetailsCountryCode"]` | same; fallback `ContactDetailsCOUNTRY_CODE` | unchanged (fallback renamed-SNAKE_CASE) | Medium | Resolve as-is first; if miss, try SNAKE_CASE constant |
| RES-PROFILE-CONTACT-COUNTRY-CODE-LABEL | `//android.widget.TextView[@resource-id="ContactDetailsCountryCode-label-inactive"]` | same; fallback `ContactDetailsCOUNTRY_CODE-label-inactive` | unchanged (fallback renamed) | Medium | Confirm `-label-inactive` suffix holds |
| RES-PROFILE-CONTACT-COUNTRY-CODE-REQUIRED | `//android.widget.TextView[@resource-id="errorMessage" and @text="Required"]` | same (unchanged) | unchanged | Medium | Generic error id — same as page-1 fields |
| RES-PROFILE-CONTACT-MOBILE-NUMBER-INPUT | `//android.widget.EditText[@resource-id="ContactDetailsMobileNumber"]` | same; fallback `ContactDetailsMOBILE_NUMBER` | unchanged (fallback renamed) | Medium | Resolve as-is; SNAKE_CASE fallback |
| RES-PROFILE-CONTACT-MOBILE-NUMBER-LABEL | `//android.widget.TextView[@resource-id="ContactDetailsMobileNumber-label-inactive"]` | same; fallback SNAKE_CASE | unchanged (fallback renamed) | Medium | Confirm suffix |
| RES-PROFILE-CONTACT-MOBILE-NUMBER-REQUIRED | `//android.widget.TextView[@resource-id="errorMessage" and @text="Required"]` | same (unchanged) | unchanged | Medium | Generic error id |
| RES-PROFILE-CONTACT-EMAIL-INPUT | `//android.widget.EditText[@resource-id="ContactDetailsEmailAddress"]` | same; fallback `ContactDetailsEMAIL_ADDRESS` | unchanged (fallback renamed) | Medium | Resolve as-is; SNAKE_CASE fallback |
| RES-PROFILE-CONTACT-EMAIL-LABEL | `//android.widget.TextView[@resource-id="ContactDetailsEmailAddress-label-inactive"]` | same; fallback SNAKE_CASE | unchanged (fallback renamed) | Medium | Confirm suffix |
| RES-PROFILE-CONTACT-EMAIL-REQUIRED | `//android.widget.TextView[@resource-id="errorMessage" and @text="Required"]` | same (unchanged) | unchanged | Medium | Generic error id |

**Note:** all rows carry a flow caveat — page 2 is gated behind the new page-1 required fields
(headline divergence), so it is unreachable on device until those are filled.

---

## Screen 2 — `resident_confirmation_profile_page.yaml`

Read-only confirmation of the created profile (Passport Details + Contact Details) with per-section
EDIT buttons, a Terms-of-Use checkbox, and a footer SAVE. **Flow-entry note:** reached via the
profile-centric Create-New-Profile flow in 2.0 (not the removed Individual-Submission path).

**Expected 2.0 divergence (from the headline required-fields change):** the **Passport Details**
section will most likely gain **new label/value rows** for Nationality/Citizenship, Passport
Number and Passport Expiry (mirroring the new required fields). Those are *new keys to add* in the
sgac2 YAML, not changes to the rows below.

| Key | sgac1 locator | Proposed sgac2 locator | Class | Conf. | On-device check |
| --- | --- | --- | --- | --- | --- |
| RES-CONFIRM-PROFILE-HEADER | `//android.widget.TextView[@text="Add Profile"]` | same | unchanged | High | Header text present |
| RES-CONFIRM-PROFILE-BACK-BUTTON | `//android.widget.Button[@content-desc="Back"]` | same | unchanged | High | Standard nav Back |
| RES-CONFIRM-PROFILE-PASSPORT-SECTION-TITLE | `//android.widget.TextView[@text="Passport Details"]` | same | unchanged | High | Section title present |
| RES-CONFIRM-PROFILE-NAME-LABEL | `//android.widget.TextView[@text="Name"]` | same | unchanged | High | Label text present |
| RES-CONFIRM-PROFILE-DOB-LABEL | `//android.widget.TextView[@text="Date of Birth"]` | same | unchanged | High | Label text present |
| RES-CONFIRM-PROFILE-NRIC-LABEL | `//android.widget.TextView[@text="NRIC/FIN"]` | same | unchanged | High | Label text present |
| RES-CONFIRM-PROFILE-PASSPORT-EDIT-BUTTON | `//android.view.ViewGroup[@content-desc="EDIT"]` | same | unchanged | Medium | `EDIT` content-desc; verify it is still the first EDIT if section order changes |
| RES-CONFIRM-PROFILE-PASSPORT-EDIT-LABEL | `//android.widget.TextView[@text="EDIT"]` | same | unchanged | High | Label text present |
| RES-CONFIRM-PROFILE-CONTACT-SECTION-TITLE | `//android.widget.TextView[@text="Contact Details"]` | same | unchanged | High | Section title present |
| RES-CONFIRM-PROFILE-COUNTRY-CODE-LABEL | `//android.widget.TextView[@text="Country/Region Code"]` | same | unchanged | High | Label text present |
| RES-CONFIRM-PROFILE-MOBILE-NUMBER-LABEL | `//android.widget.TextView[@text="Mobile Number"]` | same | unchanged | High | Label text present |
| RES-CONFIRM-PROFILE-EMAIL-LABEL | `//android.widget.TextView[@text="Email Address"]` | same | unchanged | High | Label text present |
| RES-CONFIRM-PROFILE-CONTACT-EDIT-BUTTON | `//android.view.ViewGroup[@content-desc="EDIT"]` | same | unchanged | Medium | Non-indexed `EDIT` content-desc (matches multiple) — confirm scoping still works |
| RES-CONFIRM-PROFILE-CONTACT-EDIT-LABEL | `//android.widget.TextView[@text="EDIT"]` | same | unchanged | High | Label text present |
| RES-CONFIRM-PROFILE-TERMS-CHECKBOX | `//android.view.ViewGroup[@content-desc="uncheckterms of use checkbox"]` | as-is first; likely SNAKE_CASE constant (e.g. `TERMS_OF_USE_CHECKBOX` / `uncheckTERMS_OF_USE_CHECKBOX`) | renamed-SNAKE_CASE (candidate) | Medium | Concatenated-label content-desc — dump source, capture the real content-desc/resource-id |
| RES-CONFIRM-PROFILE-TERMS-TEXT | `//android.view.ViewGroup[@content-desc="I have read and accepted the Terms of Use and Privacy Policy"]` | same (sentence a11y text) | unchanged | Medium | Sentence content-desc; verify exact wording unchanged |
| RES-CONFIRM-PROFILE-TERMS-LINK | `//android.view.ViewGroup[@content-desc="Terms of Use and Privacy Policy"]` | same | unchanged | Medium | Verify link content-desc unchanged |
| RES-CONFIRM-PROFILE-FOOTER-BACK-BUTTON | `//android.view.ViewGroup[@resource-id="back"]` | same | unchanged | High | Generic footer id `back` (verified analog on page-1 footer) |
| RES-CONFIRM-PROFILE-FOOTER-BACK-LABEL | `//android.widget.TextView[@text="BACK"]` | same | unchanged | High | Label text present |
| RES-FOOTER-SAVE-BUTTON | `//android.view.ViewGroup[@resource-id="save"]` | same | unchanged | Medium | Generic footer id `save` — confirm it is `save` (not `next`) on this step |
| RES-FOOTER-SAVE-LABEL | `//android.widget.TextView[@text="SAVE"]` | same | unchanged | High | Label text present |

---

## Screen 3 — `res_indv_submission_form_page.yaml`

Two sub-screens of the resident arrival-card submission: **Date of Arrival** and **Declaration**.
**Flow-entry divergence (T33):** in 2.0 this is reached through **Update SG Arrival Card** on the
profile-centric landing, not the removed **Individual Submission** entry — the screen filename and
`INDV`/`SUBMISSION` key prefixes reflect the sgac1 flow name. Internal locators are mostly
text/class/generic-id based and expected to survive; the two content-desc radio/answer tokens are
SNAKE_CASE candidates, and the health-declaration **question wording** is a plausible content
divergence.

**On-device reach step:** profile-centric landing → Update SG Arrival Card for a resident profile
→ Date of Arrival step (then NEXT → Declaration step); dump source at each.

### Date of Arrival sub-screen

| Key | sgac1 locator | Proposed sgac2 locator | Class | Conf. | On-device check |
| --- | --- | --- | --- | --- | --- |
| RES-INDV-SUBMISSION-HEADER | `//android.widget.TextView[@text="Date of Arrival (DD/MM/YYYY)"]` | same | unchanged | High | Header text present |
| RES-INDV-SUBMISSION-BACK-BUTTON | `//android.widget.Button[@content-desc="Back"]` | same | unchanged | High | Standard nav Back |
| RES-INDV-SUBMISSION-SAVE-BUTTON | `//android.view.ViewGroup[@content-desc="save"]` | same | unchanged | Medium | Generic `save` content-desc |
| RES-INDV-SUBMISSION-TRIP-TITLE | `//android.widget.TextView[@text="Trip 1"]` | same | unchanged | High | Trip title present |
| RES-INDV-SUBMISSION-INFO | `//android.widget.TextView[contains(@text,"Declaration can only be done within 3 days prior")]` | same | unchanged | Medium | Info-banner wording (the "3 days" rule) may be reworded — verify text |
| RES-INDV-SUBMISSION-INFO-CLOSE | `//android.view.ViewGroup[@clickable="true" and .//com.horcrux.svg.SvgView]` | same | unchanged | Medium | Class/SVG-based close; confirm structure |
| RES-INDV-SUBMISSION-DATE-ARRIVAL-LABEL | `//android.widget.TextView[@text="Date of Arrival (DD/MM/YYYY)"]` | same | unchanged | High | Label text present |
| RES-INDV-SUBMISSION-DATE-OPTION | `//android.view.ViewGroup[contains(@content-desc,"unselected radio selection")]` | as-is first; possible SNAKE_CASE token (e.g. `UNSELECTED_RADIO_SELECTION`) | renamed-SNAKE_CASE (candidate) | Medium | Concatenated-label content-desc — capture real radio content-desc |
| RES-INDV-SUBMISSION-DATE-OPTION-1 | `(//android.view.ViewGroup[@resource-id="card"])[1]` | same | unchanged | Medium | Generic `card` id, index-based |
| RES-INDV-SUBMISSION-REQUIRED | `//android.widget.TextView[@text="Required"]` | same | unchanged | High | Error text present |
| RES-INDV-SUBMISSION-FOOTER-BACK-BUTTON | `//android.view.ViewGroup[@resource-id="back"]` | same | unchanged | High | Generic footer id |
| RES-INDV-SUBMISSION-FOOTER-BACK-LABEL | `//android.widget.TextView[@text="BACK"]` | same | unchanged | High | Label text present |
| RES-INDV-SUBMISSION-PROGRESS-BAR | `//android.view.View[@resource-id="progress-bar"]` | same | unchanged | Medium | Generic `progress-bar` id |
| RES-INDV-SUBMISSION-FOOTER-NEXT-BUTTON | `//android.view.ViewGroup[@resource-id="next"]` | same | unchanged | High | Generic footer id |
| RES-INDV-SUBMISSION-FOOTER-NEXT-LABEL | `//android.widget.TextView[@text="NEXT"]` | same | unchanged | High | Label text present |

### Declaration sub-screen

| Key | sgac1 locator | Proposed sgac2 locator | Class | Conf. | On-device check |
| --- | --- | --- | --- | --- | --- |
| RES-INDV-DECLARATION-HEADER | `//android.widget.TextView[@text="Declaration"]` | same | unchanged | High | Header text present |
| RES-INDV-DECLARATION-BACK-BUTTON | `//android.widget.Button[@content-desc="Back"]` | same | unchanged | High | Standard nav Back |
| RES-INDV-DECLARATION-SAVE-BUTTON | `//android.view.ViewGroup[@content-desc="save"]` | same | unchanged | Medium | Generic `save` content-desc |
| RES-INDV-DECLARATION-TRIP-TITLE | `//android.widget.TextView[@text="Trip 1"]` | same | unchanged | High | Trip title present |
| RES-INDV-DECLARATION-TRIP-DATE | `//android.widget.TextView[@text="29 January 2026"]` | same (data-bound literal) | unchanged (fragile) | Low | Hardcoded date — fragile in BOTH forks; should be built from test data, not a fixed string |
| RES-INDV-DECLARATION-QUESTION | `//android.widget.TextView[contains(@text,"Do you currently have fever")]` | same | unchanged | Medium | Health-declaration wording may change between app versions — verify text |
| RES-INDV-DECLARATION-ANSWER-YES | `(//android.view.ViewGroup[@resource-id="card"])[1]` | same | unchanged | Medium | Generic `card` id, index-based |
| RES-INDV-DECLARATION-ANSWER-NO | `//android.view.ViewGroup[@content-desc="declaration question answer no"]` | as-is first; possible SNAKE_CASE token | renamed-SNAKE_CASE (candidate) | Medium | Concatenated-label content-desc — capture real content-desc |
| RES-INDV-DECLARATION-QUESTION-ME-AFR-LA | `//android.widget.TextView[contains(@text,"Middle East") and contains(@text,"Latin America") and contains(@text,"21 days")]` | same | unchanged | Medium | Screening-question wording/day-count may change — verify text |
| RES-INDV-DECLARATION-QUESTION-ME-AFR-LA-ANSWER-YES | `(//android.view.ViewGroup[@resource-id="card"])[3]` | same | unchanged | Medium | Index-based; confirm card ordering unchanged |
| RES-INDV-DECLARATION-QUESTION-ME-AFR-LA-ANSWER-NO | `(//android.view.ViewGroup[@resource-id="card"])[4]` | same | unchanged | Medium | Index-based |
| RES-INDV-DECLARATION-QUESTION-YF | `//android.widget.TextView[contains(@text,"listed countries") and contains(@text,"yellow fever")]` | same | unchanged | Medium | Screening-question wording may change — verify text |
| RES-INDV-DECLARATION-QUESTION-YF-ANSWER-YES | `(//android.view.ViewGroup[@resource-id="card"])[3]` | same | unchanged | Medium | Index-based |
| RES-INDV-DECLARATION-QUESTION-YF-ANSWER-NO | `(//android.view.ViewGroup[@resource-id="card"])[4]` | same | unchanged | Medium | Index-based |
| RES-INDV-DECLARATION-FOOTER-BACK-BUTTON | `//android.view.ViewGroup[@resource-id="back"]` | same | unchanged | High | Generic footer id |
| RES-INDV-DECLARATION-FOOTER-BACK-LABEL | `//android.widget.TextView[@text="BACK"]` | same | unchanged | High | Label text present |
| RES-INDV-DECLARATION-PROGRESS-BAR | `//android.view.View[@resource-id="progress-bar"]` | same | unchanged | Medium | Generic `progress-bar` id |
| RES-INDV-DECLARATION-FOOTER-NEXT-BUTTON | `//android.view.ViewGroup[@resource-id="next"]` | same | unchanged | High | Generic footer id |
| RES-INDV-DECLARATION-FOOTER-NEXT-LABEL | `//android.widget.TextView[@text="NEXT"]` | same | unchanged | High | Label text present |

---

## Screen 4 — `res_declaration_summmary_page.yaml`

Read-only declaration summary: Personal Details, Contact Details, Date of Arrival and Declaration
sections, each with an indexed `content-desc="EDIT"` button, plus following-sibling value
extraction and a footer. **Flow-entry note:** reached via the restructured 2.0 flow (T33).

**Key divergence risk — indexed EDIT buttons.** The four `EDIT` buttons are addressed by position
`[1]`–`[4]` in section order (Personal → Contact → Arrival → Declaration). If 2.0's new required
fields add a **separate Passport Details section** or otherwise reorder/insert sections, these
indices shift and the EDIT (and following-sibling value) locators break. The Personal Details
section may also gain **new Nationality/Passport-No/Passport-Expiry value rows** (new keys).

| Key | sgac1 locator | Proposed sgac2 locator | Class | Conf. | On-device check |
| --- | --- | --- | --- | --- | --- |
| RES-DECL-SUMMARY-HEADER | `//android.widget.TextView[@text="Declaration Summary"]` | same | unchanged | High | Header text present |
| RES-DECL-SUMMARY-BACK-BUTTON | `//android.widget.Button[@content-desc="Back"]` | same | unchanged | High | Standard nav Back |
| RES-DECL-SUMMARY-TRIP-TITLE | `//android.widget.TextView[@text="Trip 1"]` | same | unchanged | High | Trip title present |
| RES-DECL-SUMMARY-TRIP-DATE | `(//android.widget.TextView[@text="Trip 1"]/following::android.widget.TextView)[1]` | same | unchanged | Medium | Following-sibling; confirm first sibling is still the date |
| RES-DECL-SUMMARY-PERSONAL-SECTION | `//android.widget.TextView[@text="Personal Details"]` | same | unchanged | High | Section title present |
| RES-DECL-SUMMARY-NAME-LABEL | `//android.widget.TextView[@text="Name"]` | same | unchanged | High | Label text present |
| RES-DECL-SUMMARY-NAME-VALUE | `(//android.widget.TextView[@text="Name"]/following::android.widget.TextView)[1]` | same | unchanged | Medium | Following-sibling value |
| RES-DECL-SUMMARY-NRIC-LABEL | `//android.widget.TextView[@text="NRIC/FIN"]` | same | unchanged | High | Label text present |
| RES-DECL-SUMMARY-NRIC-VALUE | `(//android.widget.TextView[@text="NRIC/FIN"]/following::android.widget.TextView)[1]` | same | unchanged | Medium | Following-sibling value |
| RES-DECL-SUMMARY-DOB-LABEL | `//android.widget.TextView[@text="Date of Birth"]` | same | unchanged | High | Label text present |
| RES-DECL-SUMMARY-DOB-VALUE | `(//android.widget.TextView[@text="Date of Birth"]/following::android.widget.TextView)[1]` | same | unchanged | Medium | Following-sibling value |
| RES-DECL-SUMMARY-PERSONAL-EDIT-BUTTON | `(//android.view.ViewGroup[@content-desc="EDIT"])[1]` | same | flow-diverged (index-dependent) | Medium | Index `[1]` assumes Personal is first section — reconfirm if new sections added |
| RES-DECL-SUMMARY-PERSONAL-EDIT-LABEL | `(//android.view.ViewGroup[@content-desc="EDIT"]//android.widget.TextView[@text="EDIT"])[1]` | same | flow-diverged (index-dependent) | Medium | Same index caveat |
| RES-DECL-SUMMARY-CONTACT-SECTION | `//android.widget.TextView[@text="Contact Details"]` | same | unchanged | High | Section title present |
| RES-DECL-SUMMARY-COUNTRY-CODE-LABEL | `//android.widget.TextView[@text="Country/Region Code"]` | same | unchanged | High | Label text present |
| RES-DECL-SUMMARY-COUNTRY-CODE-VALUE | `(//android.widget.TextView[@text="Country/Region Code"]/following::android.widget.TextView)[1]` | same | unchanged | Medium | Following-sibling value |
| RES-DECL-SUMMARY-MOBILE-LABEL | `//android.widget.TextView[@text="Mobile Number"]` | same | unchanged | High | Label text present |
| RES-DECL-SUMMARY-MOBILE-VALUE | `(//android.widget.TextView[@text="Mobile Number"]/following::android.widget.TextView)[1]` | same | unchanged | Medium | Following-sibling value |
| RES-DECL-SUMMARY-EMAIL-LABEL | `//android.widget.TextView[@text="Email Address"]` | same | unchanged | High | Label text present |
| RES-DECL-SUMMARY-EMAIL-VALUE | `(//android.widget.TextView[@text="Email Address"]/following::android.widget.TextView)[1]` | same | unchanged | Medium | Following-sibling value |
| RES-DECL-SUMMARY-CONTACT-EDIT-BUTTON | `(//android.view.ViewGroup[@content-desc="EDIT"])[2]` | same | flow-diverged (index-dependent) | Medium | Index `[2]` shifts if a Passport Details section is inserted before Contact |
| RES-DECL-SUMMARY-CONTACT-EDIT-LABEL | `(//android.view.ViewGroup[@content-desc="EDIT"]//android.widget.TextView[@text="EDIT"])[2]` | same | flow-diverged (index-dependent) | Medium | Same index caveat |
| RES-DECL-SUMMARY-ARRIVAL-SECTION | `//android.widget.TextView[@text="Date of Arrival (DD/MM/YYYY)"]` | same | unchanged | High | Section title present |
| RES-DECL-SUMMARY-ARRIVAL-VALUE | `(//android.widget.TextView[@text="Date of Arrival (DD/MM/YYYY)"]/following::android.widget.TextView)[1]` | same | unchanged | Medium | Following-sibling value |
| RES-DECL-SUMMARY-ARRIVAL-EDIT-BUTTON | `(//android.view.ViewGroup[@content-desc="EDIT"])[3]` | same | flow-diverged (index-dependent) | Medium | Index `[3]` shifts if sections change |
| RES-DECL-SUMMARY-ARRIVAL-EDIT-LABEL | `(//android.view.ViewGroup[@content-desc="EDIT"]//android.widget.TextView[@text="EDIT"])[3]` | same | flow-diverged (index-dependent) | Medium | Same index caveat |
| RES-DECL-SUMMARY-DECLARATION-SECTION | `//android.widget.TextView[@text="Declaration"]` | same | unchanged | High | Section title present |
| RES-DECL-SUMMARY-DECLARATION-Q1 | `//android.widget.TextView[contains(@text,"fever, cough, shortness of breath")]` | same | unchanged | Medium | Health-question wording may change — verify text |
| RES-DECL-SUMMARY-DECLARATION-Q1-ANSWER | `(//android.widget.TextView[contains(@text,"fever, cough, shortness of breath")]/following::android.widget.TextView)[1]` | same | unchanged | Medium | Following-sibling; tied to Q1 wording |
| RES-DECL-SUMMARY-DECLARATION-Q2 | `//android.widget.TextView[contains(@text,"Middle East") and contains(@text,"Latin America")]` | same | unchanged | Medium | Screening-question wording may change — verify text |
| RES-DECL-SUMMARY-DECLARATION-Q2-ANSWER | `(//android.widget.TextView[contains(@text,"Middle East") and contains(@text,"Latin America")]/following::android.widget.TextView)[1]` | same | unchanged | Medium | Following-sibling; tied to Q2 wording |
| RES-DECL-SUMMARY-DECLARATION-EDIT-BUTTON | `(//android.view.ViewGroup[@content-desc="EDIT"])[4]` | same | flow-diverged (index-dependent) | Medium | Index `[4]` shifts if sections change |
| RES-DECL-SUMMARY-DECLARATION-EDIT-LABEL | `(//android.view.ViewGroup[@content-desc="EDIT"]//android.widget.TextView[@text="EDIT"])[4]` | same | flow-diverged (index-dependent) | Medium | Same index caveat |
| RES-DECL-SUMMARY-FOOTER-BACK-BUTTON | `//android.view.ViewGroup[@resource-id="back"]` | same | unchanged | High | Generic footer id |
| RES-DECL-SUMMARY-FOOTER-BACK-LABEL | `//android.widget.TextView[@text="BACK"]` | same | unchanged | High | Label text present |
| RES-DECL-SUMMARY-PROGRESS-BAR | `//android.view.View[@resource-id="progress-bar"]` | same | unchanged | Medium | Generic `progress-bar` id |
| RES-DECL-SUMMARY-FOOTER-NEXT-BUTTON | `//android.view.ViewGroup[@resource-id="next"]` | same | unchanged | High | Generic footer id |
| RES-DECL-SUMMARY-FOOTER-NEXT-LABEL | `//android.widget.TextView[@text="NEXT"]` | same | unchanged | High | Label text present |

---

## Summary

| Screen | Keys analysed | unchanged | renamed-SNAKE_CASE (candidate) | flow-diverged (index-dependent) | new (added in 2.0) |
| --- | --- | --- | --- | --- | --- |
| resident_profile_creation_form_page (page-2 Contact Details only) | 10 | 10¹ | (6 fallback²) | 0 | — |
| resident_confirmation_profile_page | 21 | 20 | 1 | 0 | (Passport Details rows expected³) |
| res_indv_submission_form_page | 34 | 32 | 2 | 0 | — |
| res_declaration_summmary_page | 38 | 30 | 0 | 8 | (Personal Details rows expected³) |
| **Total (existing keys)** | **103** | **92** | **3 firm + 6 fallback** | **8** | — |
| New required fields on the resident form (headline divergence) | 3 field groups | — | — | — | 3 (Nationality/Citizenship, Passport Number, Passport Expiry) |

¹ Contact Details page-2 fields are classified `unchanged` as the **primary** hypothesis
(verified page-1 `PassportDetails*` sibling analog), each with a SNAKE_CASE **fallback**.
² The 6 fallbacks are the 3 `ContactDetails*` inputs + their 3 `-label-inactive` labels — retry
as SNAKE_CASE constants only if the as-is id misses on device.
³ New value rows expected on the confirmation and summary Passport/Personal sections as a
downstream ripple of the new required fields — these are *new keys to add* in the sgac2 YAML, not
reclassifications of the rows above.

**For T33 (flow divergence):**
- The whole resident submission → declaration → summary chain is reached via the profile-centric
  2.0 flow (Update SG Arrival Card), not the removed Individual-Submission entry.
- **The resident profile form gains three REQUIRED fields** (Nationality/Citizenship, Passport
  Number, Date of Passport Expiry) on page 1, which **block page-2 Contact Details** until filled
  and ripple new rows onto the confirmation/summary screens and shift the summary's index-based
  EDIT locators.

Cross-references: [`Data/sgac2/android/STATUS.md`](../../../Data/sgac2/android/STATUS.md) ·
`sgac-core.md` (sibling divergence report — produced by the
[`divergence-check-sgac-core`](../../../todo/backlog/divergence-check-sgac-core.md) task) ·
[`fork-conventions.md`](../fork-conventions.md).
