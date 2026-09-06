*** Settings ***
Variables   ../../../Resources/fork_config.py
Library     AppiumLibrary
Library     String
Library     ../../../Resources/ios_appium_commands.py
Library     ../../../Data/test_data/manual_field_random.py
Resource    ../../../Resources/commands.robot
Resource    ../../../Resources/ios/SGACcommands.robot
Variables   ${FORK_DATA_DIR}/ios/ios_common_selectors.yaml
Variables   ${FORK_DATA_DIR}/ios/sgac/profile_list_page.yaml
Variables   ${FORK_DATA_DIR}/ios/sgac/profile_creation_method_page.yaml
Variables   ${FORK_DATA_DIR}/ios/sgac/foreigner/for_profile_form.yaml
Variables    ${FORK_DATA_DIR}/ios/sgac/foreigner/for_form_cty_page.yaml
Variables    ${FORK_DATA_DIR}/ios/sgac/foreigner/for_form_nationality_page.yaml
Variables    ${FORK_DATA_DIR}/ios/sgac/foreigner/for_form_residence_page.yaml
Variables    ${FORK_DATA_DIR}/ios/sgac/foreigner/for_profile_summary.yaml
Force Tags       fork:both
Test Setup       Open MyICA App on iOS Device 
Test Teardown    ios_appium_commands.Terminate App

*** Test Cases ***

User is able to create foreigner profile
    [Documentation]     this tests creation workflow for foreigner profile
    ${PROFILE}=    manual_field_random.Generate Profile Record
    Set Test Variable    ${NAME}    ${PROFILE}[name]
    Set Test Variable    ${DOB}    ${PROFILE}[dob]
    Set Test Variable    ${FOREIGNPPNUM}    ${PROFILE}[foreign_pp_num]
    Set Test Variable    ${PPEXPDT}    ${PROFILE}[pp_expiry]
    Set Test Variable    ${CTYCODE}    ${PROFILE}[cty_code]
    Set Test Variable    ${PHNO}    ${PROFILE}[phno]
    Set Test Variable    ${EMAIL}    ${PROFILE}[email]
    Navigate to foreigner SGAC landing page
    Navigate to profile list page
    Click on element    ${ADD-PROFILE-BTN}
    Click on element    ${PROFILE-CREATION-METHOD-FILL-MANUALLY}
    Type text    ${FOR-PROFILE-FORM-NAME-INPUT}    ${NAME}
    Click on element    ${KEYBOARD-DONE-BTN}
    ## select gender
    Click on element    ${FOR-PROFILE-FORM-GENDER-DROPDOWN}
    Click on element    ${FEMALE-DROPDOWN-OPTION}
    Type text    ${FOR-PROFILE-FORM-DOB-INPUT}    ${DOB}
    Click on element    ${KEYBOARD-DONE-BTN}
    Click on element    ${FOR-PROFILE-FORM-CTY-BIRTH-LIST}
    Click on element    xpath=${FOR-CTY-OPTION-1}
    Click on element    ${FOR-PROFILE-FORM-NAT-LIST}
    Click on element    xpath=${FOR-NATIONALITY-OPTION-1}
    Type text    ${FOR-PROFILE-FORM-PASSPORT-NO-INPUT}    ${FOREIGNPPNUM}
    Click on element    ${KEYBOARD-DONE-BTN}
    Type text    ${FOR-PROFILE-FORM-PASSPORT-EXPIRY-INPUT}    ${PPEXPDT}
    Click on element    ${KEYBOARD-DONE-BTN}
    Click on element    ${FOOTER-NEXT-BTN}
    Click on element    ${FOR-PROFILE-FORM-CITY-RES-INPUT}
    Click on element    xpath=${FOR-RESIDENCE-OPTION-1}
    Type text    ${FOR-PROFILE-FORM-COUNTRY-CODE-INPUT}    ${CTYCODE}
    Click on element    ${KEYBOARD-DONE-BTN}
    Type text    ${FOR-PROFILE-FORM-MOBILE-NO-INPUT}    ${PHNO}
    Type text    ${FOR-PROFILE-FORM-EMAIL-INPUT}    ${EMAIL}
    Click on element    ${KEYBOARD-DONE-BTN}
    Click on element    ${FOOTER-NEXT-BTN}
    ### verifying the fields in the profile
    ${NAME-FIELD-SEL}=  Format String  //XCUIElementTypeStaticText[@value="{}"]   ${NAME}
    ${DOB} =     helper_func.Date Field Formatter    ${DOB}
    ${DOB-FIELD-SEL}=  Format String    //XCUIElementTypeStaticText[@value="{}"]    ${DOB}
    ${TDNO-FIELD-SEL}=  Format String    //XCUIElementTypeStaticText[@value="{}"]    ${FOREIGNPPNUM}
    ${PPEXPDT}=    helper_func.Date Field Formatter    ${PPEXPDT}
    ${PPEXPDT-FIELD-SEL}=    Format String    //XCUIElementTypeStaticText[@value="{}"]    ${PPEXPDT}
    ${PHNO}=        helper_func.Add Space Between String    ${PHNO}
    ${PHNO-FIELD-SEL}=  Format String    //XCUIElementTypeStaticText[@value="{}"]    ${PHNO}
    ${EMAIL}=    Convert To Upper Case    ${EMAIL}
    ${EMAIL-FIELD-SEL}=  Format String    //XCUIElementTypeStaticText[@value="{}"]    ${EMAIL}

    Expect Element    ${NAME-FIELD-SEL}    visible
    Expect Element    ${DOB-FIELD-SEL}    visible
    Expect Element    ${TDNO-FIELD-SEL}    visible
    Expect Element    ${PPEXPDT-FIELD-SEL}    visible
    Expect Element    ${PHNO-FIELD-SEL}    visible
    Expect Element    ${EMAIL-FIELD-SEL}    visible

    Click on element    ${FOR-PROFILE-SUMMARY-TERMS-CHECKBOX}
    Click on element    ${FOR-PROFILE-SUMMARY-FOOTER-SAVE}


    
