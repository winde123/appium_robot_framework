# Resident profiles and SG Arrival Cards

Last reviewed: 2026-09-07

Resident profile creation, validation, management, Singpass and passport-scanner entry points, plus the reached arrival-card web screens. Native arrival-card progression is blocked by a repeatable profile-update loop.

[Word walkthrough](02-resident-profiles-and-arrival-cards.docx)

| Flow | Observed outcome |
| --- | --- |
| Create profile manually | Completed: WALKTHROUGH RESIDENT saved with synthetic identity and contact details. |
| Required fields and dates | Empty-form validation and an invalid date format captured; corrected DD/MM/YYYY input accepted. |
| View and update profile | Profile details opened and an update reported success. |
| Select profile for arrival card | Blocked: Profile update required repeats after updating and saving. Native arrival date, health declaration and submission confirmation were not reached. |
| Retrieve through Singpass | Staging Singpass login reached. No authenticated retrieval without supplied test credentials. |
| Scan passport | Tutorial, permission denial, permission request, full-screen hint and landscape MRZ scanner captured. A passport fixture is needed to verify extraction. |
| Update existing arrival card | Resident web retrieval instructions and NRIC/FIN plus arrival-date fields opened. No matching submitted record was available. |
| New web submission link | Arrival-date, personal-information, contact and health fields opened. No arrival declaration was submitted. |

## Screens

| Step | Screen | Action | Outcome |
| --- | --- | --- | --- |
| 001 | [Resident SG Arrival Card landing](screenshots/001-resident-sg-arrival-card-landing.png) | Choose Citizen and Resident SG Arrival Card from Home. | Captured |
| 002 | [Resident profile creation methods](screenshots/002-resident-profile-creation-methods.png) | Choose Create New Profile. | Captured |
| 003 | [Singpass profile retrieval handoff](screenshots/003-singpass-profile-retrieval-handoff.png) | Choose Retrieve Myinfo with Singpass. | Retrieval requires a Singpass session; no credentials were supplied. |
| 004 | [Passport scan entry](screenshots/004-passport-scan-entry.png) | Choose Scan Passport. | Captured |
| 005 | [Camera permission denied](screenshots/005-camera-permission-denied.png) | Starting the passport scanner requests camera access. | The first scanner attempt reported that camera usage was denied. The scanner was reopened and permission granted in the following steps. |
| 006 | [Passport camera permission dialog](screenshots/006-passport-camera-permission-dialog.png) | Start Scan Passport and wait for the Android permission dialog. | Captured |
| 007 | [Android full-screen camera hint](screenshots/007-android-full-screen-camera-hint.png) | Allow camera access for this session. | Android shows its full-screen navigation hint before the landscape scanner. |
| 008 | [Passport MRZ scanner in landscape](screenshots/008-passport-mrz-scanner-in-landscape.png) | Dismiss the Android full-screen hint. | The camera viewfinder opened after permission was granted. No passport fixture was supplied to complete extraction. |
| 009 | [Resident profile details empty form](screenshots/009-resident-profile-details-empty-form.png) | Choose Fill Manually. | Captured |
| 010 | [Resident required field validation](screenshots/010-resident-required-field-validation.png) | Choose Next with the profile form empty. | Captured |
| 011 | [Resident date format validation](screenshots/011-resident-date-format-validation.png) | Enter synthetic full name, NRIC and date of birth. | Input without slashes produced Invalid date format (DD/MM/YYYY). The identity fields were corrected before saving. |
| 012 | [Resident nationality picker](screenshots/012-resident-nationality-picker.png) | Open Nationality or Citizenship. | Captured |
| 013 | [Resident profile completed details](screenshots/013-resident-profile-completed-details.png) | Complete the identity and passport fields with synthetic test data. | Captured |
| 014 | [Resident contact details](screenshots/014-resident-contact-details.png) | Continue to Contact Details. | Captured |
| 015 | [Resident contact details completed](screenshots/015-resident-contact-details-completed.png) | Enter the synthetic example.com email address. | Captured |
| 016 | [Resident profile confirmation](screenshots/016-resident-profile-confirmation.png) | Review Passport Details and Contact Details before saving. | Captured |
| 017 | [Resident profile saved](screenshots/017-resident-profile-saved.png) | Accept the profile terms and choose Save. | The app reports that WALKTHROUGH RESIDENT was created successfully. |
| 018 | [Resident profile management menu](screenshots/018-resident-profile-management-menu.png) | Select the new walkthrough profile. | Selecting the saved profile opens View / Edit and Delete actions. |
| 019 | [Resident profile view and edit](screenshots/019-resident-profile-view-and-edit.png) | Open the saved profile menu and choose View / Edit. | Captured |
| 020 | [Resident profile update required](screenshots/020-resident-profile-update-required.png) | Return to the dashboard and select WALKTHROUGH RESIDENT. | Selecting the saved profile on the arrival-card dashboard opens an update-required alert. |
| 021 | [Resident contact update form](screenshots/021-resident-contact-update-form.png) | Choose Update Profile when the arrival dashboard requests additional details. | UPDATE PROFILE opens Contact Details with the previously saved email. |
| 022 | [Resident update confirmation](screenshots/022-resident-update-confirmation.png) | Continue through the requested profile update. | The update summary lists the saved identity and contact information and requires accepting the terms before SAVE. |
| 023 | [Resident profile update saved](screenshots/023-resident-profile-update-saved.png) | Save the requested profile update. | The app reports the profile was updated successfully. |
| 024 | [Resident update loop blocks arrival card](screenshots/024-resident-update-loop-blocks-arrival-card.png) | Select the profile again after saving the required update. | The app repeats Profile update required after reporting a successful update; arrival-date and declaration screens cannot be reached with this new profile. |
| 025 | [Resident arrival-card retrieval instructions](screenshots/025-resident-arrival-card-retrieval-instructions.png) | Wait for the in-app update portal to load. | The update portal explains which fields cannot be amended and requests NRIC/FIN and arrival date to retrieve a submission. |
| 026 | [Resident retrieval arrival-date choices](screenshots/026-resident-retrieval-arrival-date-choices.png) | Scroll to the NRIC, arrival date and email retrieval form. | The lower part of the retrieval form offers arrival dates and Next. This belongs to the update portal, before following the new-submission link. |
| 027 | [Resident web new-submission arrival date](screenshots/027-resident-web-new-submission-arrival-date.png) | Wait for the web submission form to load. | The separate new-submission link opens resident arrival-date choices. |
| 028 | [Resident web personal information](screenshots/028-resident-web-personal-information.png) | Scroll through the web form. | The web form requests full name, NRIC/FIN, date of birth and email. No declaration was sent. |
| 029 | [Resident web contact and health information](screenshots/029-resident-web-contact-and-health-information.png) | Scroll through the remaining web fields. | The lower form contains contact and health information, Add Traveller and Next. Later submission screens were not exercised. |
