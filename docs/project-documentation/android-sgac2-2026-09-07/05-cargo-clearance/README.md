# Cargo and convoy clearance

Last reviewed: 2026-09-07

Vehicle-profile creation and editing, full and partial clearance permits, cargo review, existing-submission retrieval, and a two-vehicle convoy through review.

[Word walkthrough](05-cargo-clearance.docx)

| Flow | Observed outcome |
| --- | --- |
| Create vehicle profile | Completed: SBA1234G saved with synthetic contact details after required-field validation. |
| Edit vehicle profile | Completed: email updated and the new value carried into the cargo submission form. |
| Cargo with full clearance | Synthetic permit IG2BB990001 saved and displayed in review. |
| Cargo with partial clearance | Synthetic permit IG2BB990002 with quantity 10 saved alongside the full-clearance permit and displayed in review. |
| Cargo submission | Review and Submit control reached. No declaration was sent and no application reference was generated. |
| Manage existing submission | ARN and vehicle-number retrieval form opened. A matching submitted reference is needed to continue. |
| Two-vehicle convoy | Two synthetic vehicles, contact details and permit IG2BB990003 accepted through review. No convoy declaration was sent. |
| Convoy low value goods | YES selected. Attempting Next without a permit showed Please fill in the field above; saving a permit allowed review. |
| Language | Cargo language selector opened. English retained. |

## Screens

| Step | Screen | Action | Outcome |
| --- | --- | --- | --- |
| 001 | [Cargo clearance dashboard](screenshots/001-cargo-clearance-dashboard.png) | Choose Cargo Clearance from Home. | Captured |
| 002 | [Cargo dashboard actions](screenshots/002-cargo-dashboard-actions.png) | Close the staging broadcast banner to view cargo actions. | Captured |
| 003 | [Vehicle profiles list](screenshots/003-vehicle-profiles-list.png) | Choose Create New Vehicle Profiles. | Captured |
| 004 | [Add vehicle profile form](screenshots/004-add-vehicle-profile-form.png) | Choose Add Vehicle. | Captured |
| 005 | [Vehicle profile required field validation](screenshots/005-vehicle-profile-required-field-validation.png) | Attempt to save an empty vehicle profile. | Captured |
| 006 | [Completed walkthrough vehicle profile](screenshots/006-completed-walkthrough-vehicle-profile.png) | Enter the synthetic walkthrough vehicle and contact details. | Captured |
| 007 | [Vehicle profile saved](screenshots/007-vehicle-profile-saved.png) | Save the new vehicle profile. | SBA1234G appears in the saved vehicle list. |
| 008 | [Vehicle profile management menu](screenshots/008-vehicle-profile-management-menu.png) | Open the saved walkthrough vehicle profile. | Captured |
| 009 | [Edit vehicle profile](screenshots/009-edit-vehicle-profile.png) | Choose Edit for the walkthrough vehicle. | Captured |
| 010 | [Vehicle profile update saved](screenshots/010-vehicle-profile-update-saved.png) | Save the updated synthetic email address. | The edited vehicle profile was saved; the updated email appears in the subsequent cargo form. |
| 011 | [Vehicle selected for cargo submission](screenshots/011-vehicle-selected-for-cargo-submission.png) | Select the walkthrough vehicle on the cargo dashboard. | Captured |
| 012 | [Cargo submission details loaded](screenshots/012-cargo-submission-details-loaded.png) | Wait for the cargo submission web form. | Captured |
| 013 | [Cargo submission additional fields](screenshots/013-cargo-submission-additional-fields.png) | Scroll through the cargo submission form. | Captured |
| 014 | [Cargo permit entry step](screenshots/014-cargo-permit-entry-step.png) | Choose No for Low Value Goods and continue. | Captured |
| 015 | [Full-clearance permit fields](screenshots/015-full-clearance-permit-fields.png) | Choose Full Clearance. | Captured |
| 016 | [Full-clearance permit saved](screenshots/016-full-clearance-permit-saved.png) | Add permit IG2BB990001 from the repository test fixture. | Captured |
| 017 | [Partial-clearance permit fields](screenshots/017-partial-clearance-permit-fields.png) | Add a Partial Clearance section. | Captured |
| 018 | [Partial-clearance permit and quantity](screenshots/018-partial-clearance-permit-and-quantity.png) | Scroll to the partial-clearance entry fields. | Captured |
| 019 | [Partial-clearance permit saved](screenshots/019-partial-clearance-permit-saved.png) | Add test permit IG2BB990002 with quantity 10. | Captured |
| 020 | [Cargo review contact details](screenshots/020-cargo-review-contact-details.png) | Continue after adding full and partial clearance permits. | The review page shows the contact details copied from the selected vehicle profile. |
| 021 | [Cargo review permit details](screenshots/021-cargo-review-permit-details.png) | Scroll through the review page. | Review the entered synthetic vehicle, contact and permit details before any submission. |
| 022 | [Cargo submission boundary](screenshots/022-cargo-submission-boundary.png) | Scroll to the bottom of the review page. | The walkthrough stops before sending a cargo declaration; no cargo submission was made. |
| 023 | [Retrieve an existing cargo submission](screenshots/023-retrieve-an-existing-cargo-submission.png) | Cargo Clearance → Manage Cargo Submission. | Retrieval needs an existing cargo submission reference and matching vehicle details. No submitted reference was available. |
| 024 | [Convoy contact information](screenshots/024-convoy-contact-information.png) | Cargo Clearance → Convoy. | The convoy portal opens inside the app and starts with contact information. |
| 025 | [Convoy goods and vehicle options](screenshots/025-convoy-goods-and-vehicle-options.png) | Enter synthetic contact details and scroll. | Convoy submission requires more than one vehicle. |
| 026 | [Convoy with two vehicles and low value goods](screenshots/026-convoy-with-two-vehicles-and-low-value-goods.png) | Select YES for low value goods and enter two synthetic vehicle numbers. | The page offers Add Vehicle and displays a maximum of 15 vehicles. Only the two-vehicle case was exercised. |
| 027 | [Convoy full-clearance permit form](screenshots/027-convoy-full-clearance-permit-form.png) | Continue the two-vehicle low value goods scenario. | Despite selecting YES for low value goods, the next step displays a full-clearance permit form. |
| 028 | [Convoy permit required validation](screenshots/028-convoy-permit-required-validation.png) | Attempt to continue without a permit. | Trying Next without a permit displays Please fill in the field above. |
| 029 | [Convoy permit saved](screenshots/029-convoy-permit-saved.png) | Save synthetic permit IG2BB990003. | The convoy required a permit even with low value goods set to YES. |
| 030 | [Convoy review](screenshots/030-convoy-review.png) | Continue after saving the convoy permit. | Captured |
| 031 | [Convoy review vehicles and permit](screenshots/031-convoy-review-vehicles-and-permit.png) | Scroll through the convoy review. | The review includes the two synthetic vehicle numbers and saved permit. |
| 032 | [Convoy submission boundary](screenshots/032-convoy-submission-boundary.png) | Scroll to the end of the convoy review. | No convoy declaration was submitted. |
| 033 | [Cargo language selection](screenshots/033-cargo-language-selection.png) | Open the cargo language control. | Language options are documented without changing the English walkthrough setting. |
