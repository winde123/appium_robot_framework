*** Settings ***
Variables    ../fork_config.py
Library    AppiumLibrary
Library    Collections
Library    ../../Data/test_data/manual_field_random.py
Resource    ../commands.robot
Variables    ../../Data/test_data/input_fields_test_data.yaml
Variables    ${FORK_DATA_DIR}/android/landing_page.yaml
Variables    ${FORK_DATA_DIR}/android/citizen_and_res_page.yaml
Variables    ${FORK_DATA_DIR}/android/sgac/sgac_landing_page.yaml
Variables    ${FORK_DATA_DIR}/android/sgac/individual_submission_page.yaml
Variables    ${FORK_DATA_DIR}/android/sgac/indv_profile_list_page.yaml
Variables    ${FORK_DATA_DIR}/android/profile_creation_method_page.yaml
Variables    ${FORK_DATA_DIR}/android/sgac/resident/resident_profile_creation_form_page.yaml
Variables    ${FORK_DATA_DIR}/android/sgac/resident/resident_confirmation_profile_page.yaml

*** Keywords ***
Navigate to resident SGAC landing page
    Click on element    ${CITIZEN-RESIDENT-ESERVICE-BUTTON}
    Click on element    ${CITIZEN-RES-SGAC}
    Click on element    ${SGAC-TUTORIAL-NAV-SGAC-BTN}

Navigate to individual submission creation page
    Click on element    ${SGAC-INDIVIDUAL-SUBMISSION-BUTTON}
    Click on element    ${SGAC-INDIVIDUAL-ADD-SUBMISSION-BUTTON}

Navigate to resident profile list page
    Click on element    ${SGAC-VIEW-PROFILE-BUTTON}

Create resident profile manually
    [Arguments]    ${profile}=${NONE}
    IF    $profile is None
        ${profile}=    manual_field_random.Generate Profile Record    country=SG
    END
    Click on element    ${SGAC-ADD-PROFILE-BUTTON}
    Click on element    ${PROFILE-CREATION-FILL-MANUALLY-BUTTON}
    Type text    ${RES-PROFILE-NAME-INPUT}    ${profile}[name]
    Input NRIC into input field for android device    ${RES-PROFILE-NRIC-FIN-INPUT}    ${profile}[nric]
    Type text    ${RES-PROFILE-DOB-INPUT}    ${profile}[dob]
    Click on element    ${RES-PROFILE-FOOTER-NEXT-BUTTON}
    Type text    ${RES-PROFILE-CONTACT-COUNTRY-CODE-INPUT}    ${profile}[cty_code]
    Type text    ${RES-PROFILE-CONTACT-MOBILE-NUMBER-INPUT}    ${profile}[phno]
    Type text    ${RES-PROFILE-CONTACT-EMAIL-INPUT}    ${profile}[email]
    Click on element    ${RES-PROFILE-FOOTER-NEXT-BUTTON}
    Click on element    ${RES-CONFIRM-PROFILE-TERMS-CHECKBOX}
    Click on element    ${RES-FOOTER-SAVE-BUTTON}
    RETURN    ${profile}
    
