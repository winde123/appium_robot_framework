# Walkthrough inventory and suite reconciliation

Last reviewed: 2026-09-07

This inventory reconciles the installed SGAC2 build's navigation with the repository's
eight Android suite files (24 test cases). It records manual screen coverage. No Robot
regression suite was executed, and captured UI XML does not by itself verify YAML locators.
The [package overview](README.md) and category manifests contain the screen evidence.

## Native navigation

| Area | Evidence and boundary |
| --- | --- |
| Home, drawer, Citizen and Resident, Foreign Visitor | [Home and navigation](01-home-and-navigation/README.md): home, both service hubs, favourite editor, About, Help and Settings. Service shortcuts overlap the SGAC, QR, cargo and e-Service routes below. |
| Resident SGAC | [Resident walkthrough](02-resident-profiles-and-arrival-cards/README.md): manual create/view/update, scanner and Singpass entries, retrieval and public web submission fields. Native arrival-card selection hit the repeated profile-update prompt. |
| Foreign visitor SGAC | [Visitor walkthrough](03-foreign-visitor-profiles-and-arrival-cards/README.md): Malaysian profile, conditional identity field, country/residence search, save/update and retrieval. Native submission hit the same update prompt. |
| Land-checkpoint QR | [QR walkthrough](04-qr-codes-at-land-checkpoints/README.md): tutorial, individual resident QR, all four vehicle group types, foreign-visitor SGAC reminder, group edit/delete. Groups used two people each. |
| Cargo and convoy | [Cargo walkthrough](05-cargo-clearance/README.md): vehicle create/edit, full/partial permits, two-vehicle convoy and review. No declaration submitted. |
| Other e-Services | [e-Service walkthrough](06-e-services/README.md): all ten categories and 32 entry links, plus empty/matching/no-match/cleared search states and navigation from a result. |

## E-Service catalogue

Counts come from the nine captured native service menus, plus the direct Customs entry.
Screens 003, 008, 013, 022, 025, 029, 034, 036 and 040 preserve those menus.

| Category | Entry links opened | Observed boundary |
| --- | ---: | --- |
| Passport and Identity Card | 4 | External entry pages; no applications or reports submitted. |
| SG Arrival Card, Entry Visa, e-Pass and Visit Pass | 4 | External entries and retrieval forms; no authenticated result. |
| Check Validity/Verify | 8 | Identity/pass and certificate entries; fixtures/access codes and any CAPTCHA remain required. |
| Residential address | 2 | Both address entries reached; second native label is `FOR_LTVP_STP_HOLDER`. |
| Citizenship and Permanent Residence | 3 | Citizenship, PR and Re-entry Permit entries loaded. |
| Long-Term Visit Pass and Student's Pass | 4 | LTVP, PMLA, SOLAR and SOLAR+ entries loaded. |
| Birth and Death | 1 | Birth/death extract entry loaded. |
| Others | 3 | APEC loaded; Trusted Traveller Programme reached ICA's 404 page; Race/Dialect reached a FormSG Singpass boundary. |
| Appointment | 2 | Staging appointment landing and identity/reference check-in form loaded. |
| Customs Declaration | 1 | Customs@SG information page loaded. |
| **Total** | **32** | Entry-link coverage, including the unavailable destination. |

The separate iOS e-Service suites provide a useful catalogue cross-check, especially
[Citizenship/PR](../../../tests/ios/other_e_services/sc_pr_services.robot),
[LTVP/Student's Pass](../../../tests/ios/other_e_services/ltvp_stu_pass_services.robot),
[Birth/Death](../../../tests/ios/other_e_services/birth_death_services.robot),
[Others](../../../tests/ios/other_e_services/other_services.robot) and
[Appointment](../../../tests/ios/other_e_services/appt_services.robot). They were read as
flow references; no iOS execution is claimed.

## Android suite mapping

| Suite | Cases | Relationship to the captured SGAC2 flow |
| --- | ---: | --- |
| [myica_landing.robot](../../../tests/android/myica_landing.robot) | 1 | Home scam-banner navigation. SGAC2 uses an image banner; the old text-header locator has no direct equivalent. |
| [other_e_services_landing.robot](../../../tests/android/other_e_services_landing.robot) | 4 | Catalogue, Customs and search captured. The supplied `Report` query gives two cards; `test` gives none. Search names/time estimates display raw translation keys. |
| [sgac_epass_services.robot](../../../tests/android/other_e_services/sgac_epass_services.robot) | 4 | All four corresponding catalogue entries opened. |
| [crud_profile.robot](../../../tests/android/sgac/crud_profile.robot) | 1 | Manual resident profile saved/updated. Current SGAC2 contact form is email-only; the suite still describes country-code/mobile input. |
| [crud_res_indv_submission.robot](../../../tests/android/sgac/crud_res_indv_submission.robot) | 2 | Native downstream submission and its success-page CBNI/Customs handoffs were not reached because of the profile-update loop. Opening Customs from the catalogue does not establish success-page coverage. |
| [QR_code_individual_profile_creation.robot](../../../tests/android/QR_code/QR_code_individual_profile_creation.robot) | 2 | Resident individual QR captured. A visitor SGAC profile and mixed group were captured, but the dedicated visitor individual-QR creation variant was not completed. |
| [passport_qr_code.robot](../../../tests/android/passport_qr_code.robot) | 4 | Car, motorcycle, lorry and bus groups generated with two members. Full car/lorry/bus capacity variants were not exercised. |
| [Add_Vehicle_Profile.robot](../../../tests/android/Add_Vehicle_Profile.robot) | 6 | Vehicle create/edit and convoy review captured. SGAC2 has Vehicle Number/Mobile/Email; the suite's NRIC/passport toggles are absent. Invalid-number, vehicle deletion, 15-vehicle and 100-permit variants were not completed in this package. |

## Remaining coverage limits

- **Observed blockers:** native SGAC profile-update loop; Trusted Traveller Programme destination unavailable. Search translation keys are a display issue despite matching/filtering working.
- **Inputs/equipment needed:** authenticated Singpass account, test passport/permit fixtures, matching submitted SGAC/cargo/certificate or appointment references, and physical checkpoint hardware.
- **No submitted transactions:** government applications, reports, travel/cargo declarations, appointment actions and payments remain outside the completed outcomes.
- **Unexercised variants:** first-install onboarding, exhaustive nationality/location/language combinations, profile and vehicle deletion variants, separate visitor individual QR, and maximum-capacity QR/convoy/permit cases. Language selector screens are documented; prior locale verification is recorded separately in [Android status](../../../Data/sgac2/android/STATUS.md).

These limits remain visible even when the screenshot-documentation task is complete.
