*** Settings ***
Variables   ../../../Resources/fork_config.py
Library     AppiumLibrary
Library     String
Library     ../../../Resources/ios_appium_commands.py
Library     ../../../Data/test_data/manual_field_random.py
Resource    ../../../Resources/commands.robot
Resource    ../../../Resources/ios/SGACcommands.robot
Variables   ${FORK_DATA_DIR}/ios/ios_common_selectors.yaml
Variables   ../../../Data/test_data/manual_field_random.py
Variables   ${FORK_DATA_DIR}/ios/sgac/profile_list_page.yaml
Variables   ${FORK_DATA_DIR}/ios/sgac/profile_creation_method_page.yaml
Variables   ${FORK_DATA_DIR}/ios/sgac/resident/res_profile_form_page.yaml
Variables    ${FORK_DATA_DIR}/ios/sgac/resident/res_profile_summary.yaml
Force Tags       fork:both
Test Setup       Open MyICA App on iOS Device 
Test Teardown    ios_appium_commands.Terminate App

*** Test Cases ***

#User is able to create resident indv submssion with one trip successfully
User is able create resident profile
    [Documentation]   this tc is to do a straight through flow of indv user submssion
    Navigate to resident SGAC landing page
    Navigate to profile list page
    ## create profile via the manual input button
    Click on element    ${ADD-PROFILE-BTN}
    Click on element    ${PROFILE-CREATION-METHOD-FILL-MANUALLY}
    Type text    ${RES-FORM-NAME-INPUT}    ${NAME}
    Type text    ${RES-FORM-NRIC-INPUT}    ${NRIC}
    Type text    ${RES-FORM-DOB-INPUT}    ${DOB}
    Click on element    ${KEYBOARD-DONE-BTN}
    Click on element    ${FOOTER-NEXT-BTN}
    ${CTY-CODE}=    manual_field_random.Generate Random Cty Code    SG 
    Type text    ${RES-FORM-CTY-CODE-INPUT}    ${CTY-CODE}
    Type text    ${RES-FORM-MOBILE-NUMBER-INPUT}    ${PHNO}
    Type text    ${RES-FORM-EMAIL-INPUT}    ${EMAIL}
    Click on element    ${KEYBOARD-DONE-BTN}
    Click on element    ${FOOTER-NEXT-BTN}
    ### validating the values on the confirmation page
    ${NAME-FIELD-SEL}=  Format String  //XCUIElementTypeStaticText[@value="{}"]   ${NAME}
    ${DOB} =     helper_func.Date Field Formatter    ${DOB}
    ${DOB-FIELD-SEL}=  Format String    //XCUIElementTypeStaticText[@value="{}"]    ${DOB}
    ${NRIC-FIELD-SEL}=  Format String    //XCUIElementTypeStaticText[@value="{}"]    ${NRIC}
    ${PHNO}=        helper_func.Add Space Between String    ${PHNO}
    ${PHNO-FIELD-SEL}=  Format String    //XCUIElementTypeStaticText[@value="{}"]    ${PHNO}
    ${EMAIL}=    Convert To Upper Case    ${EMAIL}
    ${EMAIL-FIELD-SEL}=  Format String    //XCUIElementTypeStaticText[@value="{}"]    ${EMAIL}


    Expect Element    ${NAME-FIELD-SEL}    visible
    Expect Element    ${DOB-FIELD-SEL}    visible
    Expect Element    ${NRIC-FIELD-SEL}    visible
    Expect Element    ${PHNO-FIELD-SEL}    visible
    Expect Element    ${EMAIL-FIELD-SEL}    visible

    ### clicking on the save button
    Click on element    ${RES-DECL-SUMMARY-TERMS-CHECKBOX-UNCHECKED}
    Click on element    ${RES-DECL-SUMMARY-FOOTER-SAVE}




