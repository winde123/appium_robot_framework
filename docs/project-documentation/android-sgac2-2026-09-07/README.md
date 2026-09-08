# MyICA Android walkthrough — 7 September 2026

Last reviewed: 2026-09-07

**The walkthrough resumed from Citizenship and Permanent Residence and added 36 captures.** All 32 e-Service entry links, service search, the remaining Help/About destinations and home external links are now documented. The emulator was returned to **MyICA Home**. See the [task record](../../../todo/done/emulator-flow-documentation.md) and [flow inventory](flow-inventory.md) for the remaining blocked or unexercised branches.

This package contains **200 documented screens in six illustrated Word documents**. Seven earlier loading transitions or repeated views remain in `_capture-archive/`, bringing the original capture count to **207**. The documentation covers the reached screens and records its limits; it does not establish complete application or automated regression coverage.

- [Download all six Word documents](myica-flow-documents.zip)
- [Browse the screenshot gallery](index.html)
- [Environment and synthetic data](environment.json)
- [Artifact validation](validation.json)
- [Integrity and repository-check results](checks.json)
- [Raw-to-document count reconciliation](curation.json)
- [Flow inventory and Android suite reconciliation](flow-inventory.md)

## Documents and observed coverage

| Category | Screens | Word document | Reached outcome |
| --- | ---: | --- | --- |
| Home and navigation | 27 | [Word](01-home-and-navigation/01-home-and-navigation.docx) | Home, hubs, drawer, settings, all Help destination entries, ICA website, loaded privacy/terms pages and home advisory/feedback links. |
| Resident profiles and arrival cards | 29 | [Word](02-resident-profiles-and-arrival-cards/02-resident-profiles-and-arrival-cards.docx) | Manual profile saved and updated; scanner and Singpass entries; arrival-card selection blocked by repeated update prompt. |
| Foreign visitor profiles and arrival cards | 21 | [Word](03-foreign-visitor-profiles-and-arrival-cards/03-foreign-visitor-profiles-and-arrival-cards.docx) | Malaysian visitor profile saved and updated; conditional identity and residence fields; same arrival-card selection blocker. |
| QR codes at land checkpoints | 41 | [Word](04-qr-codes-at-land-checkpoints/04-qr-codes-at-land-checkpoints.docx) | Tutorial, individual resident QR, all four vehicle group types, group edit and deletion. |
| Cargo and convoy | 33 | [Word](05-cargo-clearance/05-cargo-clearance.docx) | Vehicle created/edited; full and partial permits; cargo and two-vehicle convoy reached review. |
| Other e-Services | 49 | [Word](06-e-services/06-e-services.docx) | All ten categories and 32 entry links, including the Trusted Traveller Programme 404 destination; search matches, no matches, clearing and result navigation. |

Each category's README provides a screen-by-screen action index. Original PNGs and matching UI XML are under that category's `screenshots/` and `sources/`. Word images retain the original resolution; open the PNG or use the gallery for detailed zooming.

## Continuation findings and retained state

The continuation opened the remaining 14 catalogue links and checked service search using
the repository's `Report` and `test` fixtures. `Report` returned two services, its passport
result opened, `test` returned no cards, and clearing the input restored the list.

- **Unavailable destination:** the [Trusted Traveller Programme link](06-e-services/screenshots/038-apply-for-singapore-united-states-of-america-trusted-traveller-programme-entry.png) reached `eservices.ica.gov.sg/404.html` and displayed that the requested page cannot be found.
- **Search display issue:** [matching results](06-e-services/screenshots/046-service-search-report-matches.png) show raw translation keys, including `REPORT_LOST_PASSPORT` and `MINUTES_5_TO_10`.
- **Mixed external environments:** Appointment loaded on `eservices-stg.ica.gov.sg`; Race/Dialect redirected to FormSG and requires Singpass. Customs opened its information page. Other destinations include public ICA, AskGov, GovTech and ScamShield pages.
- **Support and policies:** Contact Us, Feedback, FAQ, Report Vulnerability and ICA website loaded. Privacy overview text and the expanded Terms General section were captured. The translation-feedback shortcut opened Contact Us.

No profiles, groups, vehicles or declarations were created during the continuation. The
existing synthetic records were retained, and the emulator was left running at Home.
Check the device/session before future work. The earlier pause point remains as historical
screen 025 in the e-Service document; it is no longer the next action.

## Blocked or uncompleted branches

- **Native SGAC profile-update loop:** Both newly created resident and visitor profiles save successfully. Selecting either for an arrival card opens “Profile update required”. Updating Contact Details, reviewing, accepting terms and saving reports success, but selecting the profile again repeats the alert. Native arrival, trip and declaration screens beyond that point remain unverified.
- **Singpass:** The resident retrieval branch reaches staging login. No test credentials were supplied; authenticated profile retrieval is pending.
- **Passport and permit scanning:** The passport permission and landscape MRZ viewfinder were reached. Extraction needs a test passport fixture. Permit barcode scanning was not completed.
- **Existing submissions:** Resident/visitor arrival-card and cargo retrieval forms were opened. Matching submitted records or a cargo ARN are needed to continue.
- **Submission and verification results:** Cargo and convoy stopped at review before Submit. External e-Service entries use several public/staging domains; no application, report, identity verification or declaration was sent. Certificate verification requires a certificate/access-code fixture and user completion of any CAPTCHA. Appointment actions need a suitable identity/application reference.
- **Physical clearance:** QR presentation screens were generated; no checkpoint hardware or immigration/cargo clearance was exercised.
- **Unexercised variants:** first-install onboarding, separate visitor individual QR, profile/vehicle deletion variants, exhaustive languages/nationalities and maximum-capacity group/convoy/permit cases remain outside this package. The [suite reconciliation](flow-inventory.md) maps these limits to all 24 Android test cases. Earlier native SGAC blockers were retained as evidence and were not retried in this continuation.

## Environment and retained state

Pixel_7_Pro emulator, Android 16, `emulator-5554`, MyICA package `sg.gov.ica.mobile.app`, versionName `2.0.0`, versionCode `420`. About MyICA displays `Current Version: 2.0.0(13) (STAGING)`. The existing staging tunnel was already active. The staging app label does not establish the environment of every external link.

Synthetic resident, visitor and QR profiles, the cargo vehicle, and car/motorcycle/lorry QR groups remain on the emulator for continuation. Only the bus group created for this walkthrough was deleted during its management flow. Previously present unrelated records were preserved. All entered walkthrough details are listed in `environment.json`; no real travel declaration was submitted.

## Validation

All 207 original PNGs passed hash/decoding checks and their source XML parsed. All six
DOCX files passed ZIP integrity, drawing-count, embedded-original-image hash and native
macOS text-import checks; all 200 screen titles were found. The six-document download
bundle passed integrity/hash checks. Fork parity reported **0 errors, 0 warnings** with
238 intentional divergences suppressed. Results are recorded in `checks.json`. Word page
layout was not rendered in Microsoft Word.

These artifact checks confirm the documentation package, not successful execution of unwalked application flows. No production code or Robot test flow was changed. See the [tooling and rebuild instructions](../README.md) to regenerate the files from their manifests.
