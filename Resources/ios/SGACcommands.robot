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
Variables    ${FORK_DATA_DIR}/ios/sgac/foreigner/for_profile_form.yaml
Variables    ${FORK_DATA_DIR}/ios/sgac/foreigner/for_form_cty_page.yaml
Variables    ${FORK_DATA_DIR}/ios/sgac/foreigner/for_form_nationality_page.yaml
Variables    ${FORK_DATA_DIR}/ios/sgac/foreigner/for_form_residence_page.yaml
Variables    ${FORK_DATA_DIR}/ios/sgac/foreigner/for_profile_summary.yaml

*** Variables ***
# SGAC2.0 foreigner persona (matches build 2.0.0(17) evidence, Output/evidence/
# myica-build17-regression-2026-09-16/ios 065/066/068/069). sgac1 ignores these and keeps
# its first-option / generated-cty_code behaviour.
${FOR-SGAC2-SEX}    FEMALE
${FOR-SGAC2-SEX-LETTER}    F
${FOR-SGAC2-COUNTRY-BIRTH}    AUSTRALIA
${FOR-SGAC2-NATIONALITY}    AUSTRALIAN
${FOR-SGAC2-RESIDENCE-SEARCH}    SYDNEY
${FOR-SGAC2-RESIDENCE-OPTION}    AUSTRALIA, NEW SOUTH WALES, SYDNEY (AUSTRALIA)
${FOR-SGAC2-CTY-CODE}    61

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
    Run Keyword    Navigate to foreigner SGAC landing page for ${APP_FORK}

Navigate to foreigner SGAC landing page for sgac1
    Click on element    xpath=${FORIEGN-VISITOR-ESERVICE-BUTTON}
    Click on element    xpath=${FOREIGN-VIS-SGAC-CARD}

Navigate to foreigner SGAC landing page for sgac2
    Click on element    ${FORIEGNVISITOR-SGARRIVAL-CARD-FAV-BUTTON}
    Wait Until Element Is Visible    ${SGAC-LANDING-CREATE-NEW-PROFILE}    ${INTERACTION_WAIT_TIMEOUT}

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

Navigate to foreigner profile creation method page
    Run Keyword    Navigate to foreigner profile creation method page for ${APP_FORK}

Navigate to foreigner profile creation method page for sgac1
    Navigate to profile list page
    Click on element    ${ADD-PROFILE-BTN}
    Wait Until Element Is Visible    ${PROFILE-CREATION-METHOD-FILL-MANUALLY}    ${INTERACTION_WAIT_TIMEOUT}

Navigate to foreigner profile creation method page for sgac2
    Click on element    ${SGAC-LANDING-CREATE-NEW-PROFILE}
    Wait Until Element Is Visible    ${PROFILE-CREATION-METHOD-FILL-MANUALLY}    ${INTERACTION_WAIT_TIMEOUT}

Select foreigner modal option
    [Arguments]    ${list_locator}    ${search_locator}    ${option_template}    ${search_text}    ${option_text}
    Click on element    ${list_locator}
    Type text    ${search_locator}    ${search_text}
    ${option}=    Format String    ${option_template}    ${option_text}
    Click on element    ${option}

Fill foreigner profile form
    [Arguments]    ${profile}
    Run Keyword    Fill foreigner profile form for ${APP_FORK}    ${profile}

Fill foreigner profile form for sgac1
    [Arguments]    ${profile}
    Click on element    ${PROFILE-CREATION-METHOD-FILL-MANUALLY}
    Type text    ${FOR-PROFILE-FORM-NAME-INPUT}    ${profile}[name]
    Click on element    ${KEYBOARD-DONE-BTN}
    Click on element    ${FOR-PROFILE-FORM-GENDER-DROPDOWN}
    Click on element    ${FEMALE-DROPDOWN-OPTION}
    Type text    ${FOR-PROFILE-FORM-DOB-INPUT}    ${profile}[dob]
    Click on element    ${KEYBOARD-DONE-BTN}
    Click on element    ${FOR-PROFILE-FORM-CTY-BIRTH-LIST}
    Click on element    xpath=${FOR-CTY-OPTION-1}
    Click on element    ${FOR-PROFILE-FORM-NAT-LIST}
    Click on element    xpath=${FOR-NATIONALITY-OPTION-1}
    Type text    ${FOR-PROFILE-FORM-PASSPORT-NO-INPUT}    ${profile}[foreign_pp_num]
    Click on element    ${KEYBOARD-DONE-BTN}
    Type text    ${FOR-PROFILE-FORM-PASSPORT-EXPIRY-INPUT}    ${profile}[pp_expiry]
    Click on element    ${KEYBOARD-DONE-BTN}
    Click on element    ${FOOTER-NEXT-BTN}
    Click on element    ${FOR-PROFILE-FORM-CITY-RES-INPUT}
    Click on element    xpath=${FOR-RESIDENCE-OPTION-1}
    Type text    ${FOR-PROFILE-FORM-COUNTRY-CODE-INPUT}    ${profile}[cty_code]
    Click on element    ${KEYBOARD-DONE-BTN}
    Type text    ${FOR-PROFILE-FORM-MOBILE-NO-INPUT}    ${profile}[phno]
    Type text    ${FOR-PROFILE-FORM-EMAIL-INPUT}    ${profile}[email]
    Click on element    ${KEYBOARD-DONE-BTN}
    Click on element    ${FOOTER-NEXT-BTN}

Fill foreigner profile form for sgac2
    [Arguments]    ${profile}
    Click on element    ${PROFILE-CREATION-METHOD-FILL-MANUALLY}
    Type text    ${FOR-PROFILE-FORM-NAME-INPUT}    ${profile}[name]
    Click on element    ${KEYBOARD-DONE-BTN}
    Click on element    ${FOR-PROFILE-FORM-GENDER-DROPDOWN}
    Click on element    ${FEMALE-DROPDOWN-OPTION}
    Type text    ${FOR-PROFILE-FORM-DOB-INPUT}    ${profile}[dob]
    Click on element    ${KEYBOARD-DONE-BTN}
    Select foreigner modal option    ${FOR-PROFILE-FORM-CTY-BIRTH-LIST}    ${FOR-CTY-SEARCH-INPUT}    ${FOR-CTY-OPTION-BY-NAME-TEMPLATE}    ${FOR-SGAC2-COUNTRY-BIRTH}    ${FOR-SGAC2-COUNTRY-BIRTH}
    Select foreigner modal option    ${FOR-PROFILE-FORM-NAT-LIST}    ${FOR-NATIONALITY-SEARCH-INPUT}    ${FOR-NATIONALITY-OPTION-BY-NAME-TEMPLATE}    ${FOR-SGAC2-NATIONALITY}    ${FOR-SGAC2-NATIONALITY}
    Type text    ${FOR-PROFILE-FORM-PASSPORT-NO-INPUT}    ${profile}[foreign_pp_num]
    Click on element    ${KEYBOARD-DONE-BTN}
    Type text    ${FOR-PROFILE-FORM-PASSPORT-EXPIRY-INPUT}    ${profile}[pp_expiry]
    Click on element    ${KEYBOARD-DONE-BTN}
    Click on element    ${FOOTER-NEXT-BTN}
    Select foreigner modal option    ${FOR-PROFILE-FORM-CITY-RES-INPUT}    ${FOR-RESIDENCE-SEARCH-INPUT}    ${FOR-RESIDENCE-OPTION-BY-NAME-TEMPLATE}    ${FOR-SGAC2-RESIDENCE-SEARCH}    ${FOR-SGAC2-RESIDENCE-OPTION}
    Type text    ${FOR-PROFILE-FORM-COUNTRY-CODE-INPUT}    ${FOR-SGAC2-CTY-CODE}
    Click on element    ${KEYBOARD-DONE-BTN}
    Type text    ${FOR-PROFILE-FORM-MOBILE-NO-INPUT}    ${profile}[phno]
    Type text    ${FOR-PROFILE-FORM-EMAIL-INPUT}    ${profile}[email]
    Click on element    ${KEYBOARD-DONE-BTN}
    Click on element    ${FOOTER-NEXT-BTN}

Verify foreigner profile summary
    [Arguments]    ${profile}
    Run Keyword    Verify foreigner profile summary for ${APP_FORK}    ${profile}

Verify foreigner profile summary for sgac1
    [Arguments]    ${profile}
    ${NAME-FIELD-SEL}=    Format String    //XCUIElementTypeStaticText[@value="{}"]    ${profile}[name]
    ${DOB}=    helper_func.Date Field Formatter    ${profile}[dob]
    ${DOB-FIELD-SEL}=    Format String    //XCUIElementTypeStaticText[@value="{}"]    ${DOB}
    ${TDNO-FIELD-SEL}=    Format String    //XCUIElementTypeStaticText[@value="{}"]    ${profile}[foreign_pp_num]
    ${PPEXPDT}=    helper_func.Date Field Formatter    ${profile}[pp_expiry]
    ${PPEXPDT-FIELD-SEL}=    Format String    //XCUIElementTypeStaticText[@value="{}"]    ${PPEXPDT}
    ${PHNO}=    helper_func.Add Space Between String    ${profile}[phno]
    ${PHNO-FIELD-SEL}=    Format String    //XCUIElementTypeStaticText[@value="{}"]    ${PHNO}
    ${EMAIL}=    Convert To Upper Case    ${profile}[email]
    ${EMAIL-FIELD-SEL}=    Format String    //XCUIElementTypeStaticText[@value="{}"]    ${EMAIL}
    Expect Element    ${NAME-FIELD-SEL}    visible
    Expect Element    ${DOB-FIELD-SEL}    visible
    Expect Element    ${TDNO-FIELD-SEL}    visible
    Expect Element    ${PPEXPDT-FIELD-SEL}    visible
    Expect Element    ${PHNO-FIELD-SEL}    visible
    Expect Element    ${EMAIL-FIELD-SEL}    visible

Verify foreigner profile summary for sgac2
    [Arguments]    ${profile}
    ${NAME-FIELD-SEL}=    Format String    //XCUIElementTypeStaticText[@value="{}"]    ${profile}[name]
    ${DOB}=    helper_func.Date Field Formatter    ${profile}[dob]
    ${DOB-FIELD-SEL}=    Format String    //XCUIElementTypeStaticText[@value="{}"]    ${DOB}
    ${TDNO-FIELD-SEL}=    Format String    //XCUIElementTypeStaticText[@value="{}"]    ${profile}[foreign_pp_num]
    ${PPEXPDT}=    helper_func.Date Field Formatter    ${profile}[pp_expiry]
    ${PPEXPDT-FIELD-SEL}=    Format String    //XCUIElementTypeStaticText[@value="{}"]    ${PPEXPDT}
    ${SEX-FIELD-SEL}=    Format String    //XCUIElementTypeStaticText[@value="{}"]    ${FOR-SGAC2-SEX-LETTER}
    ${BIRTH-FIELD-SEL}=    Format String    //XCUIElementTypeStaticText[@value="{}"]    ${FOR-SGAC2-COUNTRY-BIRTH}
    ${NATIONALITY-FIELD-SEL}=    Format String    //XCUIElementTypeStaticText[@value="{}"]    ${FOR-SGAC2-NATIONALITY}
    ${RESIDENCE-FIELD-SEL}=    Format String    //XCUIElementTypeStaticText[@value="{}"]    ${FOR-SGAC2-RESIDENCE-OPTION}
    ${CODE-FIELD-SEL}=    Format String    //XCUIElementTypeStaticText[@value="{}"]    +${FOR-SGAC2-CTY-CODE}
    ${PHNO}=    helper_func.Add Space Between String    ${profile}[phno]
    ${PHNO-FIELD-SEL}=    Format String    //XCUIElementTypeStaticText[@value="{}"]    ${PHNO}
    ${EMAIL}=    Convert To Upper Case    ${profile}[email]
    ${EMAIL-FIELD-SEL}=    Format String    //XCUIElementTypeStaticText[@value="{}"]    ${EMAIL}
    Expect Element    ${NAME-FIELD-SEL}    visible
    Expect Element    ${DOB-FIELD-SEL}    visible
    Expect Element    ${TDNO-FIELD-SEL}    visible
    Expect Element    ${PPEXPDT-FIELD-SEL}    visible
    Expect Element    ${SEX-FIELD-SEL}    visible
    Expect Element    ${BIRTH-FIELD-SEL}    visible
    Expect Element    ${NATIONALITY-FIELD-SEL}    visible
    Expect Element    ${RESIDENCE-FIELD-SEL}    visible
    Expect Element    ${CODE-FIELD-SEL}    visible
    Expect Element    ${PHNO-FIELD-SEL}    visible
    Expect Element    ${EMAIL-FIELD-SEL}    visible

Accept terms and save foreigner profile
    Click on element    ${FOR-PROFILE-SUMMARY-TERMS-CHECKBOX}
    Click on element    ${FOR-PROFILE-SUMMARY-FOOTER-SAVE}

Create foreigner profile manually
    [Arguments]    ${profile}=${NONE}
    IF    $profile is None
        ${profile}=    manual_field_random.Generate Profile Record
    END
    Run Keyword    Create foreigner profile manually for ${APP_FORK}    ${profile}
    RETURN    ${profile}

Create foreigner profile manually for sgac1
    [Arguments]    ${profile}
    Navigate to foreigner profile creation method page
    Fill foreigner profile form    ${profile}
    Accept terms and save foreigner profile

Create foreigner profile manually for sgac2
    [Arguments]    ${profile}
    Navigate to foreigner profile creation method page
    Fill foreigner profile form    ${profile}
    Accept terms and save foreigner profile
