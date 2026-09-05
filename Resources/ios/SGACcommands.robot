*** Settings ***
Variables    ../fork_config.py
Library    AppiumLibrary
Library    Collections
Library    ../../Data/test_data/manual_field_random.py
Resource    ../commands.robot
#Variables    ../../Data/test_data/manual_field_random.py
Variables    ../../Data/test_data/input_fields_test_data.yaml
Variables    ${FORK_DATA_DIR}/ios/ios_common_selectors.yaml
Variables    ${FORK_DATA_DIR}/ios/landing_page.yaml
Variables    ${FORK_DATA_DIR}/ios/citizen_res_page.yaml
Variables    ${FORK_DATA_DIR}/ios/foreign_vis_page.yaml
Variables    ${FORK_DATA_DIR}/ios/sgac/sgac_landing_page.yaml
Variables    ${FORK_DATA_DIR}/ios/sgac/indv_submission_page.yaml
Variables    ${FORK_DATA_DIR}/ios/sgac/sel_indv_profile_list_page.yaml
Variables    ${FORK_DATA_DIR}/ios/sgac/profile_creation_method_page.yaml
Variables   ${FORK_DATA_DIR}/ios/sgac/resident/res_profile_form_page.yaml
Variables    ${FORK_DATA_DIR}/ios/sgac/resident/res_profile_summary.yaml

*** Keywords ***
Navigate to resident SGAC landing page
    Click on element    xpath=${CITIZEN-RESIDENT-ESERVICE-BUTTON}
    Click on element    xpath=${CITIZEN-RES-SG-ARRIVAL-CARD}
    #Click on element    xpath=${SGAC-TUTORIAL-NAV-SGAC-BTN}

Navigate to foreigner SGAC landing page
    Click on element    xpath=${FORIEGN-VISITOR-ESERVICE-BUTTON}
    Click on element    xpath=${FOREIGN-VIS-SGAC-CARD}
    

Navigate to individual submission creation page
    Click on element    ${SGAC-LANDING-INDIVIDUAL-SUBMISSION}
    Click on element    ${INDV-SUBMISSION-ADD-SUBMISSION}

Navigate to profile list page
    Click on element    ${SGAC-LANDING-VIEW-PROFILE}

Create resident profile manually 
    Click on element    ${INDV-PROFILE-LIST-ADD-PROFILE}
    Click on element    ${PROFILE-CREATION-METHOD-FILL-MANUALLY}
    ${NAME} =    manual_field_random.Generate Random Name
    Type text    ${RES-FORM-NAME-INPUT}    ${NAME}
    ${NRIC} =    manual_field_random.Generaterandom NRIC
    Type text    ${RES-FORM-NRIC-INPUT}    ${NRIC}
    ${DOB}=      manual_field_random.Generaterandom DOB
    Type text    ${RES-FORM-DOB-INPUT}    ${DOB}
    Click on element    ${KEYBOARD-DONE-BTN}
    Click on element    ${FOOTER-NEXT-BTN}
    ${CTY-CODE}=    manual_field_random.Generate Random Cty Code    SG 
    Type text    ${RES-FORM-CTY-CODE-INPUT}    ${CTY-CODE}
    ${PHNO}=     manual_field_random.Generate Random Ph No
    Type text    ${RES-FORM-MOBILE-NUMBER-INPUT}    ${PHNO}
    ${EMAIL}=    manual_field_random.Generate Random Email
    Type text    ${RES-FORM-EMAIL-INPUT}    ${EMAIL}
    Click on element    ${KEYBOARD-DONE-BTN}
    Click on element    ${FOOTER-NEXT-BTN}
    Click on element    ${RES-DECL-SUMMARY-TERMS-CHECKBOX-UNCHECKED}
    Click on element    ${RES-DECL-SUMMARY-FOOTER-SAVE}