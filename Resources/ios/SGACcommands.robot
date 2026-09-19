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
Variables    ${FORK_DATA_DIR}/ios/sgac/profile_list_page.yaml
Variables    ${FORK_DATA_DIR}/ios/sgac/resident/res_profile_form_page.yaml
Variables    ${FORK_DATA_DIR}/ios/sgac/resident/res_profile_summary.yaml

*** Keywords ***
Navigate to resident SGAC landing page
    Run Keyword    Navigate to resident SGAC landing page for ${APP_FORK}

Navigate to resident SGAC landing page for sgac1
    Click on element    xpath=${CITIZEN-RESIDENT-ESERVICE-BUTTON}
    Click on element    xpath=${CITIZEN-RES-SG-ARRIVAL-CARD}

Navigate to resident SGAC landing page for sgac2
    Click on element    ${CITIZEN&RESIDENT-SGARRIVAL-CARD-FAV-BUTTON}
    Wait Until Element Is Visible    ${SGAC-LANDING-CREATE-NEW-PROFILE}    ${INTERACTION_WAIT_TIMEOUT}

Navigate to foreigner SGAC landing page
    Click on element    xpath=${FORIEGN-VISITOR-ESERVICE-BUTTON}
    Click on element    xpath=${FOREIGN-VIS-SGAC-CARD}
    

Navigate to individual submission creation page
    [Documentation]    sgac1-only: the native Individual Submission -> declaration -> captcha
    ...                flow does not exist in SGAC2.0 (submission is web-based there).
    Click on element    ${SGAC-LANDING-INDIVIDUAL-SUBMISSION}
    Click on element    ${INDV-SUBMISSION-ADD-SUBMISSION}

Navigate to profile list page
    Run Keyword    Navigate to profile list page for ${APP_FORK}

Navigate to profile list page for sgac1
    Click on element    ${SGAC-LANDING-VIEW-PROFILE}

Navigate to profile list page for sgac2
    Click on element    ${SGAC-LANDING-MANAGE-PROFILES}
    Wait Until Element Is Visible    ${RES-PROFILE-LIST-HEADER}    ${INTERACTION_WAIT_TIMEOUT}

Navigate to resident profile creation method page
    Run Keyword    Navigate to resident profile creation method page for ${APP_FORK}

Navigate to resident profile creation method page for sgac1
    Navigate to profile list page
    Click on element    ${ADD-PROFILE-BTN}
    Wait Until Element Is Visible    ${PROFILE-CREATION-METHOD-FILL-MANUALLY}    ${INTERACTION_WAIT_TIMEOUT}

Navigate to resident profile creation method page for sgac2
    Click on element    ${SGAC-LANDING-CREATE-NEW-PROFILE}
    Wait Until Element Is Visible    ${PROFILE-CREATION-METHOD-FILL-MANUALLY}    ${INTERACTION_WAIT_TIMEOUT}

Fill resident profile form
    [Arguments]    ${profile}
    Run Keyword    Fill resident profile form for ${APP_FORK}    ${profile}

Fill resident profile form for sgac1
    [Arguments]    ${profile}
    Click on element    ${PROFILE-CREATION-METHOD-FILL-MANUALLY}
    Type text    ${RES-FORM-NAME-INPUT}    ${profile}[name]
    Type text    ${RES-FORM-NRIC-INPUT}    ${profile}[nric]
    Type text    ${RES-FORM-DOB-INPUT}    ${profile}[dob]
    Click on element    ${KEYBOARD-DONE-BTN}
    Click on element    ${FOOTER-NEXT-BTN}
    Type text    ${RES-FORM-CTY-CODE-INPUT}    ${profile}[cty_code]
    Type text    ${RES-FORM-MOBILE-NUMBER-INPUT}    ${profile}[phno]
    Type text    ${RES-FORM-EMAIL-INPUT}    ${profile}[email]
    Click on element    ${KEYBOARD-DONE-BTN}
    Click on element    ${FOOTER-NEXT-BTN}

Fill resident profile form for sgac2
    [Arguments]    ${profile}
    Click on element    ${PROFILE-CREATION-METHOD-FILL-MANUALLY}
    Type text    ${RES-FORM-NAME-INPUT}    ${profile}[name]
    Type text    ${RES-FORM-DOB-INPUT}    ${profile}[dob]
    Type text    ${RES-FORM-NRIC-INPUT}    ${profile}[nric]
    Click on element    ${RES-FORM-NATIONALITY-DROPDOWN}
    Type text    ${RES-FORM-NATIONALITY-SEARCH}    SINGAPOREAN
    ${NATIONALITY-OPTION}=    Format String    ${RES-FORM-NATIONALITY-OPTION-TEMPLATE}    SINGAPOREAN
    Click on element    ${NATIONALITY-OPTION}
    Type text    ${RES-FORM-PASSPORT-NUMBER-INPUT}    ${profile}[pp_num]
    Type text    ${RES-FORM-PASSPORT-EXPIRY-INPUT}    ${profile}[pp_expiry]
    Click on element    ${KEYBOARD-DONE-BTN}
    Click on element    ${FOOTER-NEXT-BTN}
    Type text    ${RES-FORM-CTY-CODE-INPUT}    ${profile}[cty_code]
    Type text    ${RES-FORM-MOBILE-NUMBER-INPUT}    ${profile}[phno]
    Type text    ${RES-FORM-EMAIL-INPUT}    ${profile}[email]
    Click on element    ${KEYBOARD-DONE-BTN}
    Click on element    ${FOOTER-NEXT-BTN}

Verify resident profile summary
    [Arguments]    ${profile}
    Run Keyword    Verify resident profile summary for ${APP_FORK}    ${profile}

Verify resident profile summary for sgac1
    [Arguments]    ${profile}
    ${NAME-FIELD-SEL}=    Format String    //XCUIElementTypeStaticText[@value="{}"]    ${profile}[name]
    ${DOB}=    helper_func.Date Field Formatter    ${profile}[dob]
    ${DOB-FIELD-SEL}=    Format String    //XCUIElementTypeStaticText[@value="{}"]    ${DOB}
    ${NRIC-FIELD-SEL}=    Format String    //XCUIElementTypeStaticText[@value="{}"]    ${profile}[nric]
    ${PHNO}=    helper_func.Add Space Between String    ${profile}[phno]
    ${PHNO-FIELD-SEL}=    Format String    //XCUIElementTypeStaticText[@value="{}"]    ${PHNO}
    ${EMAIL}=    Convert To Upper Case    ${profile}[email]
    ${EMAIL-FIELD-SEL}=    Format String    //XCUIElementTypeStaticText[@value="{}"]    ${EMAIL}
    Expect Element    ${NAME-FIELD-SEL}    visible
    Expect Element    ${DOB-FIELD-SEL}    visible
    Expect Element    ${NRIC-FIELD-SEL}    visible
    Expect Element    ${PHNO-FIELD-SEL}    visible
    Expect Element    ${EMAIL-FIELD-SEL}    visible

Verify resident profile summary for sgac2
    [Arguments]    ${profile}
    ${NAME-FIELD-SEL}=    Format String    //XCUIElementTypeStaticText[@value="{}"]    ${profile}[name]
    ${DOB}=    helper_func.Date Field Formatter    ${profile}[dob]
    ${DOB-FIELD-SEL}=    Format String    //XCUIElementTypeStaticText[@value="{}"]    ${DOB}
    ${NRIC-FIELD-SEL}=    Format String    //XCUIElementTypeStaticText[@value="{}"]    ${profile}[nric]
    ${NATIONALITY-FIELD-SEL}=    Format String    //XCUIElementTypeStaticText[@value="{}"]    SINGAPOREAN
    ${PP-NUM-FIELD-SEL}=    Format String    //XCUIElementTypeStaticText[@value="{}"]    ${profile}[pp_num]
    ${PP-EXPIRY}=    helper_func.Date Field Formatter    ${profile}[pp_expiry]
    ${PP-EXPIRY-FIELD-SEL}=    Format String    //XCUIElementTypeStaticText[@value="{}"]    ${PP-EXPIRY}
    ${PHNO}=    helper_func.Add Space Between String    ${profile}[phno]
    ${PHNO-FIELD-SEL}=    Format String    //XCUIElementTypeStaticText[@value="{}"]    ${PHNO}
    ${EMAIL}=    Convert To Upper Case    ${profile}[email]
    ${EMAIL-FIELD-SEL}=    Format String    //XCUIElementTypeStaticText[@value="{}"]    ${EMAIL}
    Expect Element    ${NAME-FIELD-SEL}    visible
    Expect Element    ${DOB-FIELD-SEL}    visible
    Expect Element    ${NRIC-FIELD-SEL}    visible
    Expect Element    ${NATIONALITY-FIELD-SEL}    visible
    Expect Element    ${PP-NUM-FIELD-SEL}    visible
    Expect Element    ${PP-EXPIRY-FIELD-SEL}    visible
    Expect Element    ${PHNO-FIELD-SEL}    visible
    Expect Element    ${EMAIL-FIELD-SEL}    visible

Accept terms and save resident profile
    Click on element    ${RES-DECL-SUMMARY-TERMS-CHECKBOX-UNCHECKED}
    Click on element    ${RES-DECL-SUMMARY-FOOTER-SAVE}

Create resident profile manually
    [Arguments]    ${profile}=${NONE}
    IF    $profile is None
        ${profile}=    manual_field_random.Generate Profile Record    country=SG
    END
    Run Keyword    Create resident profile manually for ${APP_FORK}    ${profile}
    RETURN    ${profile}

Create resident profile manually for sgac1
    [Arguments]    ${profile}
    Click on element    ${INDV-PROFILE-LIST-ADD-PROFILE}
    Fill resident profile form    ${profile}
    Accept terms and save resident profile

Create resident profile manually for sgac2
    [Arguments]    ${profile}
    Navigate to resident profile creation method page
    Fill resident profile form    ${profile}
    Accept terms and save resident profile
