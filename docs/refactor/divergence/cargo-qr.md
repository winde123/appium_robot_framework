# Divergence check — cargo + QR screens (Android)

SGAC1.0 → SGAC2.0 offline divergence analysis for the cargo-clearance and QR-code Android
screens. Task: `todo/done/divergence-check-cargo-qr.md`. Cross-reference:
`Data/sgac2/android/STATUS.md` (walk status + patterns) and
`todo/backlog/divergence-check-sgac-core.md` (shared method).

> **OFFLINE, UNVERIFIED.** None of these screens were walked on the live 2.0 build — in
> `STATUS.md` every file below is `copied` (an unverified sgac1 copy). Every "proposed sgac2
> locator" here is a **hypothesis** derived from the app-wide drift patterns, not a live capture.
> Confidence is honestly mostly medium/low. Do **not** edit `Data/sgac2/android/**` from this
> analysis — use the on-device check steps to confirm first, then let the live-walk task apply.

## Scope covered

11 screens, 88 keys (86 defined + 2 empty placeholders in sgac1):

| Area | File | Keys |
| --- | --- | --- |
| cargo | `cargo/cargo_clearance_home_page.yaml` | 10 (2 empty) |
| cargo | `cargo/cargo_clearance.yaml` | 9 |
| cargo | `cargo/add_vehicle_page.yaml` | 11 |
| cargo | `cargo/vehicle_profiles_page.yaml` | 10 |
| cargo | `cargo/add_permit_page.yaml` | 11 |
| cargo | `cargo/cargo_convoy_page.yaml` | 11 |
| QR | `yaml_QR_pages/all_profiles_page.yaml` | 1 |
| QR | `yaml_QR_pages/personal_qr_code_page.yaml` | 3 |
| QR | `yaml_QR_pages/passport_qr_code_page.yaml` | 4 |
| QR | `yaml_QR_pages/create_group_qr_code_page.yaml` | 17 |
| QR | `yaml_tutorial_flow_pages/passport_qr_tutorial_flow.yaml` | 1 |

## Classification & the SNAKE_CASE rule

Each key is classified:

- **renamed-SNAKE_CASE** — locator matches on a React-Native testID (surfaced as Android
  `resource-id`, often mirrored in `content-desc`) whose value is a concatenated PascalCase/label
  identifier. The dominant 2.0 pattern converts the label portion to a SNAKE_CASE constant.
- **unchanged** — text (`@text=`) / visible-label (`@content-desc="Human Text"`) / widget-class /
  structural-positional / platform-framework-id (`back`, `next`, `android:id/*`,
  `com.android.permissioncontroller:*`) locators. The pattern leaves these alone (but see caveats).
- **flow-diverged** — the screen's role or gating changed in 2.0, not just a locator string.
- **removed** — element gone in 2.0 (none confirmed here; one flagged as *possibly* removed).
- **undefined (sgac1)** — key exists in the sgac1 YAML with an empty value (never a real locator).

### The conversion rule (from VERIFIED 2.0 captures)

Ground truth from the two already-verified screens (`Data/sgac2/android/landing_page.yaml`,
`Data/sgac2/android/eservices_landing_page.yaml`): keep the **prefix**, convert the **label suffix**
to `UPPER_SNAKE_CASE` (split PascalCase into words, spaces/`-`/`/` → `_`, drop `,`; `and` → `AND`).

| sgac1 testID | sgac2 testID | note |
| --- | --- | --- |
| `HomeQR Code at Land Checkpoints` | `HomeQR_CODE_AT_LAND_CHECKPOINTS` | spaces → `_` |
| `HomeCargo Clearance` | `HomeCARGO_CLEARANCE` | spaces → `_` |
| `HomeCitizen & Resident - SG Arrival Card` | `HomeCITIZEN_RESIDENT_SG_ARRIVAL_CARD` | `&`, ` - ` dropped |
| `EServicesPassportandIdentityCard` | `EServicesPASSPORT_AND_IDENTITY_CARD` | `and` → `AND` |
| `EServicesCheckValidity/Verify` | `EServicesCHECK_VALIDITY_VERIFY` | `/` → `_` |
| `EServicesReportChangeofResidentialAddress` | `EServicesREPORT_CHANGE_RESIDENTIAL_ADDRESS` | **`of` dropped** |
| `EServicesSGArrivalCard,EntryVisa,e-PassEnquiryPortalandExtensionofVisitPass` | `EServicesSG_ARRIVAL_CARD_ENTRY_VISA_E_PASS_EXTENSION` | **hand-abbreviated** |

**Why confidence is mostly low/medium, not high:** the rule is not purely mechanical. Small words
(`of`) get dropped and long labels get hand-abbreviated to a shorter constant (the SGAC entry-visa
card is the clearest example). So single/two-word cargo labels are the most trustworthy proposals;
multi-word ones are guesses that the on-device dump must confirm.

**Notation:** in tables below the sgac1/proposed columns give the **matching attribute + value**
(the surrounding `//android.*[@attr="…"]` wrapper is unchanged unless noted). For a renamed key,
also verify whether the attribute flipped `content-desc`↔`resource-id` — on the landing page several
1.0 `content-desc` favourites became `resource-id` in 2.0 (`content-desc` = the same constant).

### Two app-wide caveats that touch these screens

1. **Back button (`resource-id="back"`) is at risk.** The verified 2.0 e-services page changed its
   back button from `//android.widget.Button[@resource-id="back"]` to
   `//android.widget.Button[@content-desc="Back"]`. Every `resource-id="back"` key below is
   therefore classified *unchanged* but flagged **low** confidence with `content-desc="Back"` as the
   fallback to try. (`add_permit_page` already carries both conventions — `BACK_BUTTON`
   `content-desc="Back"` and `BACK_ARROW` `content-desc="back"` — so the app is internally mixed.)
2. **Structural / positional / SvgView xpaths** (deep index chains, `com.horcrux.svg.SvgView`,
   `@index=`) are fragile across any RN re-render and cannot be pattern-predicted — they are
   *unchanged* hypotheses at **low** confidence and must be re-captured on device regardless.

---

## FLAG — QR "NEW" badge on the home QR favourite (possible 2.0 addition)

The home "QR Code at Land Checkpoints" favourite reportedly shows a **"NEW" badge** on the 2.0 home
screen. This lives on `landing_page.yaml` (out of scope to edit here; the favourite's navigation
node is already verified as `//android.view.ViewGroup[@resource-id="HomeQR_CODE_AT_LAND_CHECKPOINTS"]`).
The badge is a **possible 2.0-only addition** to verify:

- **Check:** dump the home page source; look for a child badge node under
  `HomeQR_CODE_AT_LAND_CHECKPOINTS` — a `content-desc`/`@text` of `NEW` (or a testID such as
  `HomeQR_CODE_AT_LAND_CHECKPOINTS_NEW` / `..._BADGE` / a generic `NewBadge`).
- **Decide:** if it is a distinct element, does it need its own locator key (e.g. a
  `QR-CODE-FAV-NEW-BADGE`), and does the badge overlay change the tappable bounds of the favourite
  (i.e. can the existing favourite tap still land)? If it is a pure visual (image/no a11y node),
  record "cosmetic, no locator" so its absence is intentional.
- Not a sgac1 key — this is a net-new element to confirm, owned by the landing/live-walk task; noted
  here per task instruction.

---

## Cargo screens

Entry: Home → scroll down → tap **Cargo Clearance** favourite (`HomeCARGO_CLEARANCE`) → Cargo
Clearance home. Generic capture step for every row: `adb shell uiautomator dump` (or Appium page
source) on the named screen, then grep the proposed `resource-id`/`content-desc`; if it misses, grep
the SNAKE_CASE fallback, then the attribute-flipped form.

### `cargo/cargo_clearance_home_page.yaml`

| key | sgac1 locator | proposed sgac2 locator | class | confidence | on-device check |
| --- | --- | --- | --- | --- | --- |
| VEHICLES_PROFILE_ICON | `resource-id="CargoClearanceVehicleProfiles"` | `resource-id="CargoClearanceVEHICLE_PROFILES"` | renamed-SNAKE_CASE | medium | Cargo home; grep rid on the Vehicle Profiles tile |
| CARGO_CLEARANCE_ICON | `content-desc="CargoClearanceCargoClearance"` | `content-desc="CargoClearanceCARGO_CLEARANCE"` (may be rid) | renamed-SNAKE_CASE | medium | Cargo home; grep cd/rid on the Cargo Clearance tile |
| CARGO_CONVOY_ICON | `content-desc="CargoClearanceCargoConvoys"` | `content-desc="CargoClearanceCARGO_CONVOYS"` (may be rid) | renamed-SNAKE_CASE | medium | Cargo home; grep cd/rid on the Cargo Convoys tile |
| VIEW_ALL_CARGO_CLEARANCE_SUBMISSION_BUTTON | `resource-id="CargoClearanceViewAllCargoClearanceSubmissions"` | `resource-id="CargoClearanceVIEW_ALL_CARGO_CLEARANCE_SUBMISSIONS"` | renamed-SNAKE_CASE | low-medium | long label — confirm exact constant, watch for hand-abbreviation |
| CARGO_CLEARANCE_PLUS_SIGN_BUTTON | `//android.widget.Button[android.view.ViewGroup/android.view.ViewGroup/@displayed='true']` | unchanged (re-capture) | unchanged (structural) | low | structural; re-dump the FAB, prefer a stable cd/rid if 2.0 exposes one |
| PLUS_ADD_VEHICLE_PROFILE_BUTTON | `content-desc="Add Vehicle Profile"` | unchanged | unchanged (text) | medium | open (+) menu; confirm label text unchanged |
| PLUS_CARGO_SUBMISSION_BUTTON | *(empty in sgac1)* | needs device — never defined | undefined (sgac1) | n/a | capture the "Cargo Submission" (+) item testID/label on device |
| PLUS_NEW_CONVOY_SUBMISSION_BUTTON | `content-desc="New Convoy Submission"` | unchanged | unchanged (text) | medium | open (+) menu; confirm label text unchanged |
| PLUS_LOOKUP_SUBMISSION_BUTTON | `content-desc="Lookup Submission"` | unchanged | unchanged (text) | medium | open (+) menu; confirm label text unchanged |
| CROSS_BUTTON | *(empty in sgac1)* | needs device — never defined | undefined (sgac1) | n/a | capture the (+) menu close/X control on device |

### `cargo/cargo_clearance.yaml`

Screen: Cargo Clearance submissions list (All/Submitted/Draft tabs). Reach via VIEW_ALL tile.

| key | sgac1 locator | proposed sgac2 locator | class | confidence | on-device check |
| --- | --- | --- | --- | --- | --- |
| CARGO_CLEARANCE_ALL_TAB | `content-desc="All"` | unchanged | unchanged (text) | medium | list screen; confirm tab label |
| CARGO_CLEARANCE_SUBMITTED_TAB | `content-desc="Submitted"` | unchanged | unchanged (text) | medium | list screen; confirm tab label |
| CARGO_CLEARANCE_DRAFT_TAB | `content-desc="Draft"` | unchanged | unchanged (text) | medium | list screen; confirm tab label |
| CARGO_CLEARANCE_ADD_SUBMISSION_BUTTON | `content-desc="ADD SUBMISSION"` | unchanged | unchanged (text) | medium | confirm button caption (casing) unchanged |
| CARGO_CLEARANCE_VIEW_EDIT_SUBMISSION_BUTTON | `content-desc="View / Edit"` | unchanged | unchanged (text) | medium | open a submission row; confirm label |
| CARGO_CLEARANCE_DELETE_SUBMISSION_BUTTON | `content-desc="Delete Submission"` | unchanged | unchanged (text) | medium | open row menu; confirm label |
| CARGO_CLEARANCE_BACK_BUTTON | `resource-id="back"` | unchanged; **fallback** `content-desc="Back"` | unchanged (at-risk) | low | e-services precedent flipped back → `content-desc="Back"`; try both |
| CARGO_CLEARANCE_SEARCH_BUTTON | deep absolute positional xpath (`…/ViewGroup[9]/…`) | unchanged (re-capture) | unchanged (structural) | very low | almost certainly broken; re-capture the search entry on device |
| CARGO_CLEARANCE_APPLICATION_REFERENCE_TEXT_FIELD | `resource-id="SearchCargoClearanceApplicationReference"` | `resource-id="SearchCARGO_CLEARANCE_APPLICATION_REFERENCE"` | renamed-SNAKE_CASE | low | prefix/label split uncertain; confirm on device |

### `cargo/add_vehicle_page.yaml`

Screen: Add Vehicle Profile form. Reach: Cargo home → (+) → Add Vehicle Profile.

| key | sgac1 locator | proposed sgac2 locator | class | confidence | on-device check |
| --- | --- | --- | --- | --- | --- |
| ADD_VEHICLE_NUMBER_TEXT_FIELD | `resource-id="AddVehicleVehicleNumber"` | `resource-id="AddVehicleVEHICLE_NUMBER"` | renamed-SNAKE_CASE | low-medium | form; grep rid on vehicle-number input |
| ADD_VEHICLE_NRIC_TEXT_FIELD | `resource-id="AddVehicleNricFin"` | `resource-id="AddVehicleNRIC_FIN"` | renamed-SNAKE_CASE | low | "NricFin" split guess; confirm (may be `NRICFIN`) |
| ADD_VEHICLE_EMAIL_ADDRESS_TEXT_FIELD | `resource-id="InfoAndVehiclesAddEmail"` | `resource-id="InfoAndVehiclesADD_EMAIL"` | renamed-SNAKE_CASE | low-medium | shared `InfoAndVehicles` prefix (also in convoy form) |
| ADD_VEHICLE_USE_PASSPORT_NUMBER_OPTION | `resource-id="AddVehicleUsePassportNumber"` | `resource-id="AddVehicleUSE_PASSPORT_NUMBER"` | renamed-SNAKE_CASE | low-medium | toggle; grep rid |
| ADD_VEHICLE_USE_NRIC_OPTION | `resource-id="AddVehicleUseNricFin"` | `resource-id="AddVehicleUSE_NRIC_FIN"` | renamed-SNAKE_CASE | low | toggle; confirm NricFin split |
| ADD_VEHICLE_PASSPORT_NUMBER_TEXT_FIELD | `resource-id="AddVehiclePassportNumber"` | `resource-id="AddVehiclePASSPORT_NUMBER"` | renamed-SNAKE_CASE | low-medium | form; grep rid |
| ADD_VEHICLE_SAVE_VEHICLE_PROFILE_BUTTON | `resource-id="AddVehicleSaveVehicleProfile"` | `resource-id="AddVehicleSAVE_VEHICLE_PROFILE"` | renamed-SNAKE_CASE | low-medium | footer; grep rid |
| ADD_VEHICLE_BACK_BUTTON | `resource-id="back"` | unchanged; **fallback** `content-desc="Back"` | unchanged (at-risk) | low | try both back forms |
| ADD_VEHICLE_NEXT_BUTTON | `resource-id="next"` | unchanged | unchanged (platform id) | medium | shared `next` id; confirm not also flipped to cd |
| INVALID-VEHICLE-NUMBER-POPUP-MESSAGE | `//android.widget.ScrollView/android.view.ViewGroup/android.view.ViewGroup[2]` | unchanged (re-capture) | unchanged (structural) | very low | trigger invalid-vehicle popup; re-capture message node/text |
| assert-passport-number-field | `//android.widget.TextView[@text="${test-data-passport-no}"]` | unchanged | unchanged (dynamic text) | medium | dynamic assertion; unaffected by testID renames |

### `cargo/vehicle_profiles_page.yaml`

Screen: Vehicle Profiles list. Reach: Cargo home → Vehicle Profiles tile.

| key | sgac1 locator | proposed sgac2 locator | class | confidence | on-device check |
| --- | --- | --- | --- | --- | --- |
| VEHICLE_PROFILES_PAGE_BACK_ARROW | `resource-id="back"` | unchanged; **fallback** `content-desc="Back"` | unchanged (at-risk) | low | try both back forms |
| ADD_VEHICLE | `content-desc="VehicleProfilesAddVehicle"` | `content-desc="VehicleProfilesADD_VEHICLE"` (may be rid) | renamed-SNAKE_CASE | low-medium | grep cd/rid on the add-vehicle control |
| VEHICLE_PROFILES_HEADER | `@text="Vehicle Profiles"` | unchanged | unchanged (text) | medium | confirm header text (language-dependent) |
| KEBAB_MENU | `content-desc="${test-data}"/android.view.ViewGroup` | unchanged (dynamic) | unchanged (dynamic) | medium | runtime-substituted cd; structure unchanged but re-verify child depth |
| EDIT_BUTTON | `content-desc="Edit"` | unchanged | unchanged (text) | medium | open kebab; confirm label |
| DELETE_PROFILE | `//android.view.ViewGroup[com.horcrux.svg.SvgView and @index='1']` | unchanged (re-capture) | unchanged (structural) | low | SvgView/index icon; fragile — re-capture |
| EDIT_PROFILE | `content-desc="Edit"` | unchanged | unchanged (text) | medium | duplicate of EDIT_BUTTON |
| INVALIDATE_VEHICLES_TEXT_FIELD | `@text="VEHICLE COULD NOT BE VALIDATED"` | unchanged | unchanged (text) | medium | confirm validation copy unchanged |
| NO_VEHICLE_PROFILES_TEXT_FIELD | `content-desc="No vehicle profiles"` | unchanged | unchanged (text) | medium | empty-state; confirm label |
| DELETE_PROFILE_BUTTON | `resource-id="android:id/button1"` | unchanged | unchanged (platform id) | high | native Android dialog positive button |

### `cargo/add_permit_page.yaml`

Screen: Add Permit (within convoy flow). Reach: convoy form → Next → Add Permit.

| key | sgac1 locator | proposed sgac2 locator | class | confidence | on-device check |
| --- | --- | --- | --- | --- | --- |
| ADD_PERMIT_BUTTON | `resource-id="PermitsAddPermit"` | `resource-id="PermitsADD_PERMIT"` | renamed-SNAKE_CASE | low-medium | permits screen; grep rid |
| SUBMIT_CARGO_CONVOY_BUTTON | `resource-id="PermitsSubmitCargoConvoy"` | `resource-id="PermitsSUBMIT_CARGO_CONVOY"` | renamed-SNAKE_CASE | low | footer; grep rid |
| BACK_BUTTON | `content-desc="Back"` | unchanged | unchanged (label) | medium-high | already the 2.0-style back form |
| BACK_ARROW | `content-desc="back"` | unchanged | unchanged (label) | medium | lowercase `back` cd; confirm still present |
| ENTER_PERMIT_NUMBER_MANUALLY_BUTTON | `resource-id="AddPermitEnterPermitNoManually"` | `resource-id="AddPermitENTER_PERMIT_NO_MANUALLY"` | renamed-SNAKE_CASE | low | multi-word; confirm exact constant |
| ADD_PERMIT_NUMBER_TEXT_FIELD | `content-desc="AddPermitPermitNumber"` | `content-desc="AddPermitPERMIT_NUMBER"` (may be rid) | renamed-SNAKE_CASE | low-medium | grep cd/rid on permit-number input |
| SCAN_PERMIT_WITH_CAMERA_BUTTON | `resource-id="AddPermitScanPermitWithCamera"` | `resource-id="AddPermitSCAN_PERMIT_WITH_CAMERA"` | renamed-SNAKE_CASE | low-medium | grep rid |
| SAVE_PERMIT_BUTTON | `content-desc="SAVE PERMIT"` | unchanged | unchanged (text) | medium | confirm caption unchanged |
| ALLOW_CAMERA_BUTTON | `resource-id="com.android.permissioncontroller:id/permission_allow_foreground_only_button"` | unchanged | unchanged (OS id) | high | OS permission dialog; fork-independent |
| IFRAME | `//android.widget.ScrollView/android.view.ViewGroup/android.view.ViewGroup[1]/android.widget.FrameLayout` | unchanged (re-capture) | unchanged (structural) | low | scan-permit webview host; re-capture |
| CAPTCHA_INPUT | `content-desc="CaptchaModalCodeInput"` | `content-desc="CaptchaModalCODE_INPUT"` (may be rid) | renamed-SNAKE_CASE | low | captcha modal; confirm constant |

### `cargo/cargo_convoy_page.yaml`

Screen: Cargo Convoy submission form/list. Reach: Cargo home → (+) → New Convoy Submission.

| key | sgac1 locator | proposed sgac2 locator | class | confidence | on-device check |
| --- | --- | --- | --- | --- | --- |
| CARGO_CONVOY_ALL_TAB | `content-desc="All"` | unchanged | unchanged (text) | medium | confirm tab label |
| CARGO_CONVOY_SUBMITTED_TAB | `content-desc="Submitted"` | unchanged | unchanged (text) | medium | confirm tab label |
| CARGO_CONVOY_DRAFT_TAB | `content-desc="Draft"` | unchanged | unchanged (text) | medium | confirm tab label |
| ADD_CARGO_CONVOY_BUTTON | `content-desc="ADD CARGO CONVOY"` | unchanged | unchanged (text) | medium | confirm caption unchanged |
| CARGO_CONVOY_NRIC_TEXT_FIELD | `content-desc="InfoAndVehiclesNricFin"` | `content-desc="InfoAndVehiclesNRIC_FIN"` (may be rid) | renamed-SNAKE_CASE | low | shared `InfoAndVehicles` prefix; confirm NricFin split |
| CARGO_CONVOY_EMAIL_TEXT_FIELD | `content-desc="InfoAndVehiclesAddEmail"` | `content-desc="InfoAndVehiclesADD_EMAIL"` (may be rid) | renamed-SNAKE_CASE | low-medium | matches add_vehicle EMAIL key |
| CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD | `resource-id="InfoAndVehiclesVehicleNumber"` | `resource-id="InfoAndVehiclesVEHICLE_NUMBER"` | renamed-SNAKE_CASE | low-medium | grep rid |
| CARGO_CONVOY_VIEW_EDIT_BUTTON | `content-desc="View / Edit"` | unchanged | unchanged (text) | medium | confirm label |
| CARGO_CONVOY_DELETE_SUBMISSION_BUTTON | `@text="Delete Submission"` | unchanged | unchanged (text) | medium | confirm label |
| CARGO_CONVOY_NEXT_BUTTON | `resource-id="next"` | unchanged | unchanged (platform id) | medium | shared `next` id |
| CARGO_CONVOY_VEHICLE_PLUS_BUTTON | `//android.widget.ScrollView/android.view.ViewGroup/android.view.ViewGroup[1]/android.view.ViewGroup[5]` | unchanged (re-capture) | unchanged (structural) | low | positional add-vehicle-row control; re-capture |

---

## QR screens

Entry: Home → tap **QR Code at Land Checkpoints** favourite (`HomeQR_CODE_AT_LAND_CHECKPOINTS`).
See the **NEW badge** flag above. In sgac1 a "Welcome to MyICA"/tutorial modal gate appears first
(`Navigate to QR Code page without tutorial flow` taps `NO, THANKS`) — 2.0 may have removed this
gate (see `passport_qr_tutorial_flow.yaml`).

### `yaml_QR_pages/all_profiles_page.yaml`

| key | sgac1 locator | proposed sgac2 locator | class | confidence | on-device check |
| --- | --- | --- | --- | --- | --- |
| ADD-PROFILE-BUTTON | `resource-id="ProfileAddProfile"` | `resource-id="ProfileADD_PROFILE"` | renamed-SNAKE_CASE | low-medium | profiles list; grep rid on Add Profile |

### `yaml_QR_pages/personal_qr_code_page.yaml`

| key | sgac1 locator | proposed sgac2 locator | class | confidence | on-device check |
| --- | --- | --- | --- | --- | --- |
| ACCESS-QR-INFO-CONFIRM-BUTTON | `resource-id="android:id/button2"` | unchanged | unchanged (platform id) | high | native dialog button (note: button2 = negative slot) |
| QR-CODE-PERSONAL | `//com.horcrux.svg.SvgView[@enabled='true']` | unchanged (re-capture) | unchanged (class) | medium | QR renders as SvgView; confirm it is still the only enabled SvgView |
| PERSONAL-QR-CODE-BACK-BUTTON | `resource-id="back"` | unchanged; **fallback** `content-desc="Back"` | unchanged (at-risk) | low | try both back forms |

### `yaml_QR_pages/passport_qr_code_page.yaml`

| key | sgac1 locator | proposed sgac2 locator | class | confidence | on-device check |
| --- | --- | --- | --- | --- | --- |
| GENERATE-PERSONAL-QR-CODE-OPTION | `content-desc="Create a personal profile to generate My QR code"` | unchanged | unchanged (text) | medium | long label; confirm exact wording unchanged |
| IND-QR-CODE-SHORTCUT | `resource-id="QrIndividualQrCode" and content-desc="QrIndividualQrCode"` | `resource-id="QrINDIVIDUAL_QR_CODE"` (cd likely mirrors) | renamed-SNAKE_CASE | low-medium | QR landing shortcut; grep rid/cd |
| GENERATE-GROUP-QR-CODE-OPTION | `content-desc="Create a group QR code"` | unchanged | unchanged (text) | medium | confirm wording unchanged |
| QR-CODE-BANNER | `content-desc="close banner"` | unchanged | unchanged (label) | medium | confirm the dismissable banner still exists |

### `yaml_QR_pages/create_group_qr_code_page.yaml`

Screen: Group QR creation form + summary. (Commented `#PROFILE-CONFIRMATION-MSG-WIDGET` left as-is,
not counted.)

| key | sgac1 locator | proposed sgac2 locator | class | confidence | on-device check |
| --- | --- | --- | --- | --- | --- |
| GROUP-NAME-TEXT-INPUT-FIELD | `resource-id="passportGroupQrName"` | `resource-id="passportGroupQrNAME"` (or unchanged) | renamed-SNAKE_CASE | low | camelCase prefix — conversion uncertain; confirm |
| VECHICLE-TYPE-DROPDOWN-BUTTON | `resource-id="passportGroupQrVehicleType"` | `resource-id="passportGroupQrVEHICLE_TYPE"` (or unchanged) | renamed-SNAKE_CASE | low | camelCase prefix; confirm |
| VECHICLE-TYPE-DROPDOWN-CAR-OPTION | `content-desc="Car"` | unchanged | unchanged (text) | medium | dropdown option label |
| VECHICLE-TYPE-DROPDOWN-MC-OPTION | `content-desc="Motorcycle" and resource-id="menu-item"` | unchanged | unchanged (text+generic id) | medium | option label; `menu-item` is generic |
| VECHICLE-TYPE-DROPDOWN-LORRY-OPTION | `content-desc="Lorry" and resource-id="menu-item"` | unchanged | unchanged (text+generic id) | medium | option label |
| VEHICLE-TYPE-DROPDOWN-BUS-OPTION | `content-desc="Bus" and resource-id="menu-item"` | unchanged | unchanged (text+generic id) | medium | option label |
| CAR-OPTION-RES-MSG | `@text="(Minimum 2, Maximum 10)"` | unchanged | unchanged (text) | medium | **confirm limits unchanged** (2.0 could re-tune) |
| MC-OPTION-RES-MSG | `@text="(Maximum 2)"` | unchanged | unchanged (text) | medium | confirm limit unchanged |
| LORRY-OPTION-RES-MSG | `@text="(Minimum 2, Maximum 4)"` | unchanged | unchanged (text) | medium | confirm limits unchanged |
| BUS-OPTION-RES-MSG | `@text="(Minimum 2, Maximum 4)"` | unchanged | unchanged (text) | medium | confirm limits unchanged |
| ADD-PROFILE-GROUP-BUTTON | `resource-id="passportGroupQrAddProfile" and @clickable="true"` | `resource-id="passportGroupQrADD_PROFILE"` (or unchanged) | renamed-SNAKE_CASE | low | camelCase prefix; confirm |
| GENERATE-GROUP-QR-CODE-BUTTON | `resource-id="GenerateQrCode" and @clickable="true"` | `resource-id="GENERATE_QR_CODE"` (or unchanged) | renamed-SNAKE_CASE | low | single-token testID; confirm |
| NEXT-BUTTON | `@text="NEXT"` | unchanged | unchanged (text) | medium | confirm caption |
| PAX-FIELD-LABEL | `@text="No. of Pax:"` | unchanged | unchanged (text) | medium | summary label |
| PAX-FIELD | `//android.widget.TextView[@index='3' and @enabled='true']` | unchanged (re-capture) | unchanged (structural) | low | index-based; fragile — re-capture |
| GROUP-QR-CODE | `//com.horcrux.svg.SvgView[@enabled='true']` | unchanged (re-capture) | unchanged (class) | medium | group QR SvgView; confirm |
| GROUP-NAME-TEXT-LABEL | `resource-id="card"//TextView[@index='0']` | unchanged (re-capture) | unchanged (structural) | low | generic `card` rid + index; fragile |

### `yaml_tutorial_flow_pages/passport_qr_tutorial_flow.yaml`

| key | sgac1 locator | proposed sgac2 locator | class | confidence | on-device check |
| --- | --- | --- | --- | --- | --- |
| NO-THANKS-OPTION | `content-desc="NO, THANKS"` | unchanged **if** modal survives; else **removed** | flow-diverged | low | STATUS shows the SGAC tutorial gate removed in 2.0 — confirm whether the QR "Welcome to MyICA" modal still appears; if gone, delete key + update `Navigate to QR Code page without tutorial flow` |

---

## Category summary

| Category | Count |
| --- | --- |
| renamed-SNAKE_CASE | 28 |
| unchanged | 57 |
| flow-diverged | 1 |
| removed | 0 |
| undefined (empty in sgac1) | 2 |
| **Total keys** | **88** |
| + net-new to verify (QR "NEW" badge) | 1 (not a sgac1 key) |

**`unchanged` breakdown (57):** text/visible-label 37 · platform/OS id 5 (`next`×2, `android:id/button1`,
`android:id/button2`, permissioncontroller allow) · at-risk `resource-id="back"` 4 (low confidence —
try `content-desc="Back"` fallback) · structural/positional/SvgView 11 (low confidence — re-capture).

**Highest-value on-device checks (do first):**
1. The **QR "NEW" badge** — is it a distinct element/testID, and does it move the favourite's tap bounds?
2. The 4 `resource-id="back"` keys — did 2.0 flip them to `content-desc="Back"` (as e-services did)?
3. Whether `next` (`resource-id="next"`) survived unchanged or also flipped attribute.
4. Whether the QR **tutorial/welcome modal** (`NO-THANKS-OPTION`) still gates the QR entry in 2.0.
5. The 11 structural xpaths (FABs, search entry, SvgView, index/`card` nodes) — assume broken until re-captured.
6. Confirm the group-QR **pax limit** copy (`*-OPTION-RES-MSG`) hasn't been re-tuned in 2.0.

**Trust ordering for the SNAKE_CASE proposals:** cargo-home nav tiles (mirror verified Home/EServices
pattern) > single/two-word field ids > multi-word ids (`ViewAll…`, `Enter…Manually`, SGAC-style) which
risk hand-abbreviation. `passportGroupQr*` and `GenerateQrCode` are camelCase/single-token testIDs whose
conversion is the least certain — they may be left unchanged in 2.0.
