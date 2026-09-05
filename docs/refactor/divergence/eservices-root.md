# Divergence check — Other-e-Services detail screens + root/common (Android)

SGAC1.0 → SGAC2.0 per-screen locator divergence, **offline / pattern-based**. Proposed 2.0
locators are hypotheses except where marked live-verified; every row carries an on-device check.

- Source tree: `Data/sgac1/android/**` (the current `Data/sgac2/android/**` copies are byte-identical to sgac1 — status `copied` in STATUS.md).
- Cross-reference: `Data/sgac2/android/STATUS.md` (live walk vs build 2.0.0 / versionCode 420, `Pixel_7_Pro`), `docs/refactor/sgac-fork-refactor-tasks.md`.
- Do **not** edit `Data/sgac2/android/**` from this task — the live walk (T31) owns that tree.

## Patterns applied (and their limits)

1. **SNAKE_CASE testIDs — confirmed only on NAVIGATION CARDS.** React-Native testIDs
   (Android `resource-id`, often mirrored in `content-desc`) on card-container navigation tiles
   were converted from concatenated-label form to SNAKE_CASE constants:
   `EServicesPassportandIdentityCard` → `EServicesPASSPORT_AND_IDENTITY_CARD`,
   `HomeCitizen…` → `HomeCITIZEN_RESIDENT_SG_ARRIVAL_CARD`. The constant is **hand-curated from
   the label**, not a mechanical transform (e.g. the long SGAC card →
   `EServicesSG_ARRIVAL_CARD_ENTRY_VISA_E_PASS_EXTENSION`), so any card-tile proposal below is a
   spelling guess until dumped on device.
2. **Component / form testIDs — verified UNCHANGED.** This is the important counter-signal to a
   blanket "app-wide SNAKE_CASE" reading. `Data/sgac1/android/sgac/resident/resident_profile_creation_form_page.yaml`
   reuses the exact `PassportDetailsFullName` / `PassportDetailsNricFin` / `PassportDetailsDateOfBirth`
   testIDs and the `next` / `back` footer ids, and STATUS.md marks that page **verified — page-1
   fields resolve as-is** on live 2.0. So `PassportDetails*`, `next`, `save`, `card`, `modal`,
   `CaptchaModal*` (all component/form testIDs, *not* nav cards) are treated as **unchanged**.
   The `-label-inactive` / `-text` suffix convention is likewise verified on the resident form.
3. **Text / class locators — usually unchanged** (STATUS pattern; `citizen_and_res_page` verified
   10/10 as-is).
4. **e-Services detail screens are Chrome web views.** The suites tear down with
   `Close Android Chrome Browser` / `Close iOS Chrome Browser` after opening Customs, CBNI and each
   e-Pass enquiry tab (see `tests/android/other_e_services_landing.robot`,
   `tests/android/other_e_services/sgac_epass_services.robot`). Their `*-WEB-*` / `*-HEADER-ELEM`
   text locators are **external government web content**, outside the RN app's testID refactor — so
   the fork change does not touch them (they can still drift on their own web release cadence).

### Confidence legend

- **High** — corroborated by live 2.0 (STATUS walk) or by an identical testID verified on a sibling screen.
- **Med-High** — external web content unaffected by the fork, or a verified id-suffix convention, or same verified testID family.
- **Medium** — consistent with the "text/class stays" pattern but not individually verified.
- **Low** — hypothesis; dominant pattern points one way but the locator form is ambiguous → must dump page source.

### Classes

`unchanged` · `renamed-SNAKE_CASE` (testID nav-card conversion) · `flow-diverged` (screen role / layout changed) · `removed`.

---

## 1. `other_e_services/customs_declaration_service.yaml` — Customs@SG (Chrome web view)

Reached via the **Customs Declaration** card (`E-SERVICES-CUSTOMS-DECLARATION`, SNAKE_CASE-verified in 2.0) → opens Customs@SG in Chrome.

| Key | Class | sgac1 locator | Proposed sgac2 locator | Conf | On-device check |
| --- | --- | --- | --- | --- | --- |
| CUSTOMS-BUTTON | unchanged | `//android.widget.Button[@content-desc="SUBMIT CUSTOMS DECLARATION"]` | same | Medium | Reach the native intro (if still present in the 2.0 path); confirm the button's `content-desc`. Watch for a newly-added SNAKE_CASE `resource-id` — prefer it if present. |
| CUSTOMS-BUTTON-LABEL | unchanged | `//android.widget.TextView[@text="SUBMIT CUSTOMS DECLARATION"]` | same | Medium | Same screen; confirm visible button text unchanged. |
| CUSTOMS-WEB-ELEM-HEADER | unchanged | `//android.widget.TextView[@text="Customs@SG Web Application"]` | same | Med-High | Tap through to Chrome; confirm header text. External web — may drift on Customs@SG's own release, not the fork. |

---

## 2. `other_e_services/e727_service.yaml` — Cash/CBNI declaration (Chrome web view)

**Entry-point flag:** the verified 2.0 landing lists 10 cards with no dedicated CBNI/e727 tile — the
CBNI declaration is likely reached from inside Customs@SG rather than a top-level card. Verify the
route on device; the locators below still hold if the screen is reachable.

| Key | Class | sgac1 locator | Proposed sgac2 locator | Conf | On-device check |
| --- | --- | --- | --- | --- | --- |
| CBNI-DECL-BUTTON | unchanged | `//android.widget.Button[@content-desc="SUBMIT CASH (CBNI) DECLARATION"]` | same | Medium | Reach the CBNI intro; confirm `content-desc`; prefer any new SNAKE_CASE `resource-id`. |
| CBNI-BUTTON-LABEL | unchanged | `//android.widget.TextView[@text="SUBMIT CASH (CBNI) DECLARATION"]` | same | Medium | Confirm visible button text. |
| CBNI-WEB-HOME-ICON | unchanged | `//android.widget.TextView[@text="HOME"]` | same | Medium | Web content. `"HOME"` is generic — confirm it resolves to exactly one node; scope it (e.g. add an ancestor) if the 2.0 web page has multiple `HOME` labels. |
| CBNI-WEB-ELEM-HEADER | unchanged | `//android.widget.TextView[@text="Physical Currency and Bearer Negotiable Instruments (CBNI) Report (Traveller)"]` | same | Med-High | External web header; confirm exact text. |

---

## 3. `other_e_services/sgac_epass_enquiry.yaml` — SGAC/e-Pass Enquiry Portal

Reached via the **SG Arrival Card, Entry Visa, e-Pass…** card
(`E-SERVICES-SGAC-ENTRY-VISA-EPASS-ENQUIRY-PORTAL` → 2.0 `EServicesSG_ARRIVAL_CARD_ENTRY_VISA_E_PASS_EXTENSION`,
verified). The portal shows **4 native `card-container` tabs** (same family as the e-Services
landing cards); tapping a tab opens the destination in **Chrome**.

The `*-TAB` keys currently match on `content-desc="service list <Label>"` — a spaced
**accessibility label**, not a testID. Because these are card-container tiles (the exact element
class that got SNAKE_CASE'd on the landing), the `resource-id` most likely became a SNAKE_CASE
constant in 2.0; but the descriptive `content-desc` may equally have survived untouched. Genuinely
ambiguous → **Low** until dumped. The `*-HEADER-ELEM` keys are Chrome web-page headers (external).

| Key | Class | sgac1 locator | Proposed sgac2 locator | Conf | On-device check |
| --- | --- | --- | --- | --- | --- |
| SUBMIT-SG-ARRIVAL-CARD-TAB | renamed-SNAKE_CASE | `//android.view.ViewGroup[contains(@content-desc,"service list Submit SG Arrival Card")]` | Prefer a SNAKE_CASE `resource-id` on the card-container child (prefix TBD, e.g. `…SUBMIT_SG_ARRIVAL_CARD`); **fallback** = keep the `contains(@content-desc,"service list Submit SG Arrival Card")` form if the label persisted | Low | Open the portal, dump page source, read the 4 `card-container` children's `resource-id` **and** `content-desc`; record the real prefix and pick resource-id if present. |
| APPLY-ENTRY-VISA-TAB | renamed-SNAKE_CASE | `//android.view.ViewGroup[contains(@content-desc,"service list Apply for Entry Visa")]` | SNAKE_CASE `resource-id` (`…APPLY_FOR_ENTRY_VISA`?) / fallback content-desc contains | Low | Same dump — read child 2. |
| RETRIEVE-E-PASS-RECORD-TAB | renamed-SNAKE_CASE | `//android.view.ViewGroup[contains(@content-desc,"service list Retrieve e-Pass Record")]` | SNAKE_CASE `resource-id` (`…RETRIEVE_E_PASS_RECORD`?) / fallback content-desc contains | Low | Same dump — read child 3. |
| APPLY-EXTENSION-OF-VISIT-PASS-TAB | renamed-SNAKE_CASE | `//android.view.ViewGroup[contains(@content-desc,"service list Apply for Extension of Visit Pass")]` | SNAKE_CASE `resource-id` (`…APPLY_FOR_EXTENSION_OF_VISIT_PASS`?) / fallback content-desc contains | Low | Same dump — read child 4. |
| SUBMIT-SG-ARRIVAL-CARD-HEADER-ELEM | unchanged | `//android.view.View[@text="Singapore Arrival Card (SGAC) and Electronic Pass (e-Pass) Enquiry Portal"]` | same | Medium | Web header after tapping the tab; confirm text (external web). |
| APPLY-ENTRY-VISA-CARD-HEADER-ELEM | unchanged | `//android.view.View[@text="Apply for Entry Visa"]` | same | Medium | Web header; confirm text. |
| RETRIEVE-E-PASS-RECORD-HEADER-ELEM | unchanged | `//android.view.View[@text="Retrieval of Electronic Pass (e-Pass)"]` | same | Medium | Web header; confirm text. |
| APPLY-EXTENSION-OF-VISIT-PASS-HEADER-ELEM | unchanged | `//android.view.View[@text="Apply for Extension of Short-Term Visit Pass"]` | same | Medium | Web header; confirm text. |

---

## 4. `manual_creation_profile_form.yaml` — manual profile creation + confirm page

Flow context (STATUS.md): 2.0 restructured SGAC into a profile-centric model and **adds required
Nationality / Passport No. / Passport Expiry to the resident form**. The input testIDs here are the
`PassportDetails*` family **verified unchanged** on the resident form, so the field keys are High/Med-High
`unchanged`. The confirm-page keys are **positional** (`resource-id='card'//TextView[@index='N']`); the
added fields shift the summary layout, so every index-based key is `flow-diverged` and must be
re-derived — replace with text/label-anchored locators.

| Key | Class | sgac1 locator | Proposed sgac2 locator | Conf | On-device check |
| --- | --- | --- | --- | --- | --- |
| FILL-MANUALLY-BUTTON | unchanged | `//android.widget.Button[@resource-id='ProfileAddProfile' and @content-desc='fill manually']` | `//android.widget.Button[@content-desc="fill manually"]` (drop the `ProfileAddProfile` conjunct — the verified `profile_creation_method_page.PROFILE-CREATION-FILL-MANUALLY-BUTTON` matches on content-desc only) | Med-High | Confirm `content-desc="fill manually"` resolves; check whether `resource-id='ProfileAddProfile'` still exists (it is dropped in the verified method-page locator). Effectively a duplicate of `PROFILE-CREATION-FILL-MANUALLY-BUTTON`. |
| NRIC-FLAG-YES-OPTION | unchanged | `//android.widget.Button[@content-desc='yes']` | same | Medium | Reach the NRIC-flag prompt in the 2.0 profile flow; confirm content-desc. |
| NRIC-FLAG-NO-OPTION | unchanged | `//android.widget.Button[@content-desc='no']` | same | Medium | Same prompt; confirm content-desc. |
| FULL-NAME-TEXT-FIELD | unchanged | `//android.widget.EditText[@resource-id='PassportDetailsFullName']` | same | High | Verified as-is on resident form (`RES-PROFILE-NAME-INPUT`, STATUS page-1). Spot-confirm on the manual form. |
| DOB-TEXT-FIELD | unchanged | `//android.widget.EditText[@resource-id='PassportDetailsDateOfBirth']` | same | High | Verified as-is on resident form (`RES-PROFILE-DOB-INPUT`). |
| NAT-CITIZEN-DROPDOWN-BUTTON | unchanged | `//android.widget.TextView[@resource-id='PassportDetailsNationality']` | same | Med-High | Same `PassportDetails*` family; 2.0 adds Nationality (required) to the resident form, so this testID should exist unchanged. Confirm the node class (`TextView`) still applies. |
| CITIZEN-SG-OPTION | unchanged | `//android.view.ViewGroup[@content-desc='searchable dropdown accessible label 0' and @focusable='true']` | same | Medium | Open the nationality dropdown; confirm the indexed accessible-label pattern still applies to option 0. |
| NRIC-TEXT-FIELD | unchanged | `//android.widget.EditText[@resource-id='PassportDetailsNricFin']` | same | High | Verified as-is on resident form (`RES-PROFILE-NRIC-FIN-INPUT`). |
| PASSPORT-NO-FIELD | unchanged | `//android.widget.EditText[@resource-id='PassportDetailsPassportNumber']` | same | Med-High | `PassportDetails*` family; 2.0 adds Passport No. to the resident form. Confirm. |
| PASSPORT-DATE-EXPIRY-TEXT-FIELD | unchanged | `//android.widget.EditText[@resource-id='PassportDetailsDatePassportExpiry']` | same | Med-High | `PassportDetails*` family; 2.0 adds Passport Expiry to the resident form. Confirm. |
| PROFILE-PAGE-NEXT-BUTTON | unchanged | `//android.view.ViewGroup[@resource-id='next']` | same | High | Footer `next` verified as-is on resident form (`RES-PROFILE-FOOTER-NEXT-BUTTON`). |
| FULL-NAME-FIELD | flow-diverged | `//android.view.ViewGroup[@resource-id='card']//android.widget.TextView[@index='4']` | Re-derive: anchor to a stable label instead of `@index` (added required fields shift the summary card). `card` container id likely unchanged. | Med-High | On the 2.0 confirm/summary card, dump source and map the value TextViews; the index-4 assumption is broken by the new fields. |
| DOB-FIELD | flow-diverged | `//android.view.ViewGroup[@resource-id='card']//android.widget.TextView[@index='7']` | Re-derive (see above) | Med-High | Re-map index on 2.0 summary. |
| NRIC-FIELD | flow-diverged | `//android.view.ViewGroup[@resource-id='card']//android.widget.TextView[@index='13']` | Re-derive | Med-High | Re-map index on 2.0 summary. |
| PASSPORT-NUMBER-FIELD | flow-diverged | `//android.view.ViewGroup[@resource-id='card']//android.widget.TextView[@index='16']` | Re-derive | Med-High | Re-map index on 2.0 summary. |
| PASSPORT-DATE-EXPIRY-HEADER | flow-diverged | `//android.view.ViewGroup[@resource-id='card']//android.widget.TextView[@index='18']` | Re-derive | Med-High | Re-map index on 2.0 summary. |
| PASSPORT-DATE-EXPIRY-FIELD | flow-diverged | `//android.view.ViewGroup[@resource-id='card']//android.widget.TextView[@index='19']` | Re-derive | Med-High | Re-map index on 2.0 summary. |
| PASSPORT-DETAILS-SAVE-BUTTON | unchanged | `//android.view.ViewGroup[@resource-id='save']` | same | Med-High | Generic testID (like the verified `next`); confirm `save` resolves on the 2.0 confirm page. |
| TOC-PRIVACY-POLICY-CHECKBOX | unchanged | `//android.view.ViewGroup[@content-desc='QR code term and condition' and @enabled='true']` | same | Medium | Confirm the T&C checkbox content-desc on the 2.0 confirm page. |
| FOREIGNER-PASSPORT-NUMBER-FIELD | flow-diverged | `//android.view.ViewGroup[@resource-id='card']//android.widget.TextView[@index='13']` | Re-derive (foreigner summary layout) | Med-High | Re-map index on 2.0 foreigner summary. |
| FOREIGNER-PASSPORT-DATE-EXPIRY-HEADER | flow-diverged | `//android.view.ViewGroup[@resource-id='card']//android.widget.TextView[@index='15']` | Re-derive | Med-High | Re-map index on 2.0 foreigner summary. |
| FORIEGNER-PASSPORT-DATE-EXPIRY-FIELD | flow-diverged | `//android.view.ViewGroup[@resource-id='card']//android.widget.TextView[@index='16']` | Re-derive | Med-High | Re-map index on 2.0 foreigner summary. (Note: key keeps the sgac1 `FORIEGNER` typo.) |

---

## 5. `android_common_selectors.yaml` — SGAC declaration CAPTCHA modal

All `CaptchaModal*` ids are **component testIDs** (same category as the verified `PassportDetails*`
family), not nav cards → treated `unchanged`. The `-label-inactive` / `-text` id suffixes match the
verified resident-form convention. This is the highest-value on-device check: if any `CaptchaModal*`
id turns out SNAKE_CASE, it would contradict the component-testID-stable finding and warrant a re-sweep.

| Key | Class | sgac1 locator | Proposed sgac2 locator | Conf | On-device check |
| --- | --- | --- | --- | --- | --- |
| SGAC-DECLARATION-CAPTCHA-MODAL | unchanged | `//android.view.ViewGroup[@resource-id="modal"]` | same | Medium | Trigger the captcha modal in the 2.0 declaration flow; confirm `resource-id="modal"`. |
| SGAC-DECLARATION-CAPTCHA-CLOSE | unchanged | `//android.widget.Button[@content-desc="Close modal"]` | same | Medium | Confirm close-button content-desc. |
| SGAC-DECLARATION-CAPTCHA-TITLE | unchanged | `//android.widget.TextView[@text="Enter the captcha shown below:"]` | same | Medium | Confirm title text. |
| SGAC-DECLARATION-CAPTCHA-IMAGE | unchanged | `//android.view.ViewGroup[contains(@content-desc,"captcha volume button")]/android.widget.ImageView` | same | Medium | Confirm the captcha-image container content-desc. |
| SGAC-DECLARATION-CAPTCHA-REFRESH | unchanged | `//android.view.ViewGroup[@resource-id="CaptchaModalRefresh"]` | same (if broken, try SNAKE_CASE `CaptchaModalREFRESH`) | Medium | **Key check** — confirm the `CaptchaModal*` ids are still PascalCase, not SNAKE_CASE. |
| SGAC-DECLARATION-CAPTCHA-VOLUME | unchanged | `//android.view.ViewGroup[@resource-id="CaptchaModalVolumeUp"]` | same (fallback `CaptchaModalVOLUME_UP`) | Medium | Confirm id. |
| SGAC-DECLARATION-CAPTCHA-INPUT | unchanged | `//android.widget.EditText[@resource-id="CaptchaModalCodeInput"]` | same (fallback `CaptchaModalCODE_INPUT`) | Medium | Confirm id. |
| SGAC-DECLARATION-CAPTCHA-INPUT-LABEL | unchanged | `//android.widget.TextView[@resource-id="CaptchaModalCodeInput-label-inactive"]` | same | Med-High | `-label-inactive` suffix convention verified on resident form. |
| SGAC-DECLARATION-CAPTCHA-VERIFY-BUTTON | unchanged | `//android.widget.Button[@resource-id="CaptchaModalConfirm"]` | same (fallback `CaptchaModalCONFIRM`) | Medium | Confirm id. |
| SGAC-DECLARATION-CAPTCHA-VERIFY-LABEL | unchanged | `//android.widget.TextView[@resource-id="CaptchaModalConfirm-text"]` | same | Med-High | `-text` suffix convention consistent with verified id-suffix pattern. |

---

## 6. `eservices_landing_page.yaml` — 4 unverified search-flow keys

These 4 keys were NOT exercised in the read-only landing walk (they need the search interaction /
Chrome open); the other 13 landing keys are already verified in `Data/sgac2/android/eservices_landing_page.yaml`.
Search flow (`tests/android/other_e_services_landing.robot`): tap `E-SERVICES-SEARCH-ICON` (verified) →
type `${CORRECT-E-SERVICES-INPUT}` = **"Report"** → asserts `card-container` ×2 → both Report-Lost
results visible. All 4 are text-based → `unchanged` per pattern.

| Key | Class | sgac1 locator | Proposed sgac2 locator | Conf | On-device check |
| --- | --- | --- | --- | --- | --- |
| E-SERVICES-SEARCH-INPUT | unchanged | `//android.widget.EditText[@text="Search for an e-Service"]` | same | Medium | Tap `E-SERVICES-SEARCH-ICON`, dump source; confirm the EditText placeholder text. If a `resource-id` now exists on the search field, prefer it. |
| E-SERVICES-CUSTOMS-DECLARATION-HEADER-ELEM | unchanged | `//android.widget.TextView[@text="Customs@SG"]` | same | Med-High | Tap `E-SERVICES-CUSTOMS-DECLARATION` (verified 2.0 card) → Chrome opens; confirm the `Customs@SG` header. External web. |
| E-SERVICES-REPORT-LOST-PASSPORT-SEARCH-RES | unchanged | `//android.widget.TextView[@text="Report Lost Passport"]` | same | Medium | Search "Report"; assert `//android.view.ViewGroup[@resource-id="card-container"]` ×2; confirm this result text. |
| E-SERVICES-REPORT-LOST-IC-SEARCH-RES | unchanged | `//android.widget.TextView[@text="Report Lost Identity Card"]` | same | Medium | Same search; confirm the second result text. |

---

## Summary

Screens analysed: **6** (`customs_declaration_service`, `e727_service`, `sgac_epass_enquiry`,
`manual_creation_profile_form`, `android_common_selectors`, + the 4 `eservices_landing_page`
search-flow keys). Keys classified: **51**.

| Class | Count |
| --- | --- |
| unchanged | 38 |
| renamed-SNAKE_CASE (hypothesis) | 4 |
| flow-diverged | 9 |
| removed | 0 |
| **Total** | **51** |

**Headlines**
- No confirmed nav-card SNAKE_CASE conversions in this scope; the only SNAKE_CASE candidates are
  the 4 e-Pass enquiry-portal `card-container` tabs (Low confidence — dump the portal source).
- The 9 `flow-diverged` keys are all the positional `card`/`@index` summary locators in
  `manual_creation_profile_form`; the added required resident fields shift indices — re-anchor to labels.
- The `manual_creation_profile_form` **input** testIDs (`PassportDetails*`, `next`) are the
  strongest `unchanged` calls (High) — verified via the sibling resident form in STATUS.md.
- The e-Services detail screens (Customs, CBNI, enquiry-portal destinations) are Chrome web views;
  their headers are external content, unaffected by the fork refactor.
- Watch item: `CaptchaModal*` and `PassportDetails*` are treated `unchanged` on the
  component-testID-stable finding. If a live check shows either is SNAKE_CASE, re-sweep all
  component testIDs — the "SNAKE_CASE is nav-card-only" boundary would be wrong.
