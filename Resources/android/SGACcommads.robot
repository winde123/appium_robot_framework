*** Settings ***
Library    AppiumLibrary
Library    Collections
Library    ../../Data/test_data/manual_field_random.py
Resource    ../commands.robot
Variables    ../../Data/test_data/manual_field_random.py
Variables    ../../Data/test_data/input_fields_test_data.yaml
Variables    ../../Data/android/landing_page.yaml
Variables    ../../Data/android/citizen_and_res_page.yaml
Variables    ../../Data/android/sgac/sgac_landing_page.yaml
Variables    ../../Data/android/sgac/individual_submission_page.yaml
Variables    ../../Data/android/sgac/indv_profile_list_page.yaml
Variables    ../../Data/android/profile_creation_method_page.yaml
Variables   ../../../../Data/android/sgac/resident/resident_profile_creation_form_page.yaml
Variables    ../../../../Data/android/sgac/resident/resident_confirmation_profile_page.yaml

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
    Click on element    ${SGAC-ADD-PROFILE-BUTTON}
    Click on element    ${PROFILE-CREATION-FILL-MANUALLY-BUTTON}
    Type text    ${RES-PROFILE-NAME-INPUT}    ${NAME}
    Input NRIC into input field for android device    ${RES-PROFILE-NRIC-FIN-INPUT}    ${NRIC}
    Type text    ${RES-PROFILE-DOB-INPUT}    ${DOB}
    Click on element    ${RES-PROFILE-FOOTER-NEXT-BUTTON}
    ${CTY-CODE}=    manual_field_random.Generate Random Cty Code    SG 
    Type text    ${RES-PROFILE-CONTACT-COUNTRY-CODE-INPUT}    ${CTY-CODE}
    Type text    ${RES-PROFILE-CONTACT-MOBILE-NUMBER-INPUT}    ${PHNO}
    Type text    ${RES-PROFILE-CONTACT-EMAIL-INPUT}    ${EMAIL}
    Click on element    ${RES-PROFILE-FOOTER-NEXT-BUTTON}
    Click on element    ${RES-CONFIRM-PROFILE-TERMS-CHECKBOX}
    Click on element    ${RES-FOOTER-SAVE-BUTTON}
    
