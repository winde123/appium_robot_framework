# Foreign visitor profiles and SG Arrival Cards

Last reviewed: 2026-09-07

The foreign visitor manual-entry journey, including conditional Malaysian identity details, searchable location lists, residence and email, confirmation, profile update and arrival-card retrieval.

[Word walkthrough](03-foreign-visitor-profiles-and-arrival-cards.docx)

| Flow | Observed outcome |
| --- | --- |
| Create visitor profile manually | Completed: WALKTHROUGH VISITOR saved with synthetic Malaysian identity, passport, residence and contact details. |
| Sex, birthplace and nationality | Selection screens and a country search captured. Malaysian nationality reveals an additional identity-card field. |
| Conditional identity field | The required Malaysian identity-card field was supplied before continuing. |
| Residence and contact | A searchable Malaysian city of residence and email were accepted; both sections appear in the confirmation. |
| Profile update | Update saved successfully, but selecting the profile for an arrival card repeats Profile update required. |
| Native arrival-card submission | Blocked by the repeated profile-update prompt. Arrival, trip, accommodation, declaration and success screens beyond that point were not reached. |
| Update existing arrival card | Web retrieval form opened. It requests DE number, nationality, date of birth, passport number and passport expiry. No submitted record was supplied. |
| Passport scan | Creation method is visible. The shared scanner is documented in the resident walkthrough; passport extraction requires a test fixture. |

## Screens

| Step | Screen | Action | Outcome |
| --- | --- | --- | --- |
| 001 | [Foreign visitor SG Arrival Card landing](screenshots/001-foreign-visitor-sg-arrival-card-landing.png) | Choose Foreign Visitor SG Arrival Card from Home. | Captured |
| 002 | [Foreign visitor creation methods](screenshots/002-foreign-visitor-creation-methods.png) | Choose Create New Profile. | Captured |
| 003 | [Foreign visitor profile details](screenshots/003-foreign-visitor-profile-details.png) | Choose Fill Manually. | Captured |
| 004 | [Foreign visitor sex selection](screenshots/004-foreign-visitor-sex-selection.png) | Open the Sex dropdown. | Captured |
| 005 | [Country or place of birth picker](screenshots/005-country-or-place-of-birth-picker.png) | Open the searchable Country or Place of Birth picker. | Captured |
| 006 | [Search country or place of birth](screenshots/006-search-country-or-place-of-birth.png) | Open Nationality or Citizenship. | Searching MALAYSIA narrows the birthplace list. This is a country picker, before selecting nationality. |
| 007 | [Foreign visitor nationality list](screenshots/007-foreign-visitor-nationality-list.png) | Open the Nationality or Citizenship options. | Captured |
| 008 | [Malaysian identity field revealed](screenshots/008-malaysian-identity-field-revealed.png) | Complete the synthetic Malaysian visitor identity and passport details. | Selecting MALAYSIAN adds Identity Card Number (For Malaysians Only). The field has not yet been filled in this capture. |
| 009 | [Malaysian identity field required](screenshots/009-malaysian-identity-field-required.png) | Continue to Contact Details. | Next remains on Profile Details while the required Malaysian identity-card field is empty. |
| 010 | [Malaysian identity card detail](screenshots/010-malaysian-identity-card-detail.png) | Provide the additional synthetic identity number required for Malaysian nationality. | Captured |
| 011 | [Visitor residence and email form](screenshots/011-visitor-residence-and-email-form.png) | Continue to Contact Details. | Captured |
| 012 | [Place of residence picker](screenshots/012-place-of-residence-picker.png) | Open Place of Residence. | Captured |
| 013 | [Visitor residence and contact details completed](screenshots/013-visitor-residence-and-contact-details-completed.png) | Choose Kuala Lumpur and enter the synthetic email address. | Captured |
| 014 | [Visitor profile confirmation upper section](screenshots/014-visitor-profile-confirmation-upper-section.png) | Review the visitor Passport Details card. | Captured |
| 015 | [Visitor profile confirmation contact section](screenshots/015-visitor-profile-confirmation-contact-section.png) | Scroll to Contact Details and the profile terms. | Captured |
| 016 | [Foreign visitor profile saved](screenshots/016-foreign-visitor-profile-saved.png) | Accept the profile terms and save. | The app reports that WALKTHROUGH VISITOR was created successfully. |
| 017 | [Visitor profile update required](screenshots/017-visitor-profile-update-required.png) | Return to the dashboard and select the saved visitor. | Selecting the saved visitor profile for an arrival card opens the update-required alert. |
| 018 | [Visitor profile update requested](screenshots/018-visitor-profile-update-requested.png) | Open the required update after selecting the saved profile. | Captured |
| 019 | [Visitor profile update saved](screenshots/019-visitor-profile-update-saved.png) | Save the requested visitor profile update. | The app reports a successful update before the same alert recurs on selection. |
| 020 | [Visitor arrival card update loop](screenshots/020-visitor-arrival-card-update-loop.png) | Select the visitor again after the successful update. | Profile update required repeats after saving; this prevents advancing to the native arrival-card form. |
| 021 | [Visitor arrival-card retrieval form](screenshots/021-visitor-arrival-card-retrieval-form.png) | Scroll to the existing-arrival-card retrieval fields. | The update form requests DE number, nationality, date of birth, passport number and passport expiry. No matching submitted record was available. |
