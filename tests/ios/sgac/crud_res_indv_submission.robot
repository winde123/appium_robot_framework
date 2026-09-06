*** Settings ***
Variables    ../../../Resources/fork_config.py
Library     AppiumLibrary
Library     String
Library     ../../../Resources/helper_func.py
Library     ../../../Resources/ios_appium_commands.py
Resource    ../../../Resources/commands.robot
Resource    ../../../Resources/ios/SGACcommands.robot
Variables    ${FORK_DATA_DIR}/ios/ios_common_selectors.yaml
Variables    ../../../Data/test_data/input_fields_test_data.yaml
Variables    ${FORK_DATA_DIR}/ios/sgac/sel_indv_profile_list_page.yaml
Variables    ${FORK_DATA_DIR}/ios/sgac/resident/res_submission_form_page.yaml
Variables    ${FORK_DATA_DIR}/ios/sgac/resident/res_declaration_summary.yaml
Variables    ${FORK_DATA_DIR}/ios/sgac/declaration_page.yaml
Variables    ${FORK_DATA_DIR}/ios/sgac/sub_success_page.yaml
Variables    ${FORK_DATA_DIR}/ios/other_e_services/e727_services_page.yaml
Variables    ${FORK_DATA_DIR}/ios/other_e_services/customs_dec_services_page.yaml
Force Tags       fork:both
Test Setup       Open MyICA App on iOS Device 
Test Teardown    ios_appium_commands.Terminate App

*** Test Cases ***

Create a resident submission and navigate to the e727 website
    [Documentation]    create submission and navigate to the cbni submission on the declaration success page
    Navigate to resident SGAC landing page
    Navigate to individual submission creation page
    Create resident profile manually
    ## selecting the first profile 
    Click on element    xpath=${INDV-PROFILE-CARD-1}
    ## date of arrival
    Click on element    xpath=${RES-SUB-FORM-DATE-OPTION-1}
    Click on element    ${FOOTER-NEXT-BTN}
    ## health declaration
    Click on element    xpath=${RES-SUBMISSION-FORM-DECLARATION-Q1-NO}
    Click on element    xpath=${RES-SUBMISSION-FORM-DECLARATION-Q2-NO}
    Click on element    ${FOOTER-NEXT-BTN}
    ## confirmation page
    ###validating the date of the arrival field
    ${CUR-DATE} =    helper_func.Current Date Generator
    ${CUR-DATE} =    helper_func.Date Field Formatter   ${CUR-DATE}
    ${TRAVEL-DATE-SELECTOR}=    Format String    //XCUIElementTypeStaticText[@value="{}"]    ${CUR-DATE}
    Scroll down on the screen
    Expect Element    ${TRAVEL-DATE-SELECTOR}    visible
    Click on element    ${FOOTER-NEXT-BTN}
    Click on element    ${DECLARATION-CHECKBOX-UNCHECKED}
    Click on element    ${DECLARATION-FOOTER-SUBMIT}
    Type text    ${CAPTCHA-INPUT-FIELD}    ${CAPTCHA-STR}
    Click on element    ${KEYBOARD-DONE-BTN}
    Click on element    ${CAPTCHA-VERIFY-BTN}
    #${DUR}=     helper_func.Convert Int To Secs    30
    #Scroll down on the screen
    #Scroll Down    ${SUB-SUCCESS-CUSTOMS-BUTTON}    ${DUR}        
    Click on element    ${SUB-SUCCESS-CBNI-BUTTON}
    #Wait Until Element Is Visible    ${CBNI-WEB-HOME-ICON}
    Expect Element    ${CBNI-WEB-ELEM-HEADER}    visible
    Close iOS Chrome Browser

Create a resident submission and navigate to the customs website
    [Documentation]    create submission and navigate to the customs declaration on the declaration success page
    Navigate to resident SGAC landing page
    Navigate to individual submission creation page
    Create resident profile manually 
    ## selecting the first profile 
    Click on element    xpath=${INDV-PROFILE-CARD-1}
    ## date of arrival
    Click on element    xpath=${RES-SUB-FORM-DATE-OPTION-1}
    Click on element    ${FOOTER-NEXT-BTN}
    ## health declaration
    Click on element    xpath=${RES-SUBMISSION-FORM-DECLARATION-Q1-NO}
    Click on element    xpath=${RES-SUBMISSION-FORM-DECLARATION-Q2-NO}
    Click on element    ${FOOTER-NEXT-BTN}
    ## confirmation page
    ###validating the date of the arrival field
    ${CUR-DATE} =    helper_func.Current Date Generator
    ${CUR-DATE} =    helper_func.Date Field Formatter   ${CUR-DATE}
    ${TRAVEL-DATE-SELECTOR}=    Format String    //XCUIElementTypeStaticText[@value="{}"]    ${CUR-DATE}
    Scroll down on the screen
    Expect Element    ${TRAVEL-DATE-SELECTOR}    visible
    Click on element    ${FOOTER-NEXT-BTN}
    Click on element    ${DECLARATION-CHECKBOX-UNCHECKED}
    Click on element    ${DECLARATION-FOOTER-SUBMIT}
    Type text    ${CAPTCHA-INPUT-FIELD}    ${CAPTCHA-STR}
    Click on element    ${KEYBOARD-DONE-BTN}
    Click on element    ${CAPTCHA-VERIFY-BTN}
    #${DUR}=     helper_func.Convert Int To Secs    30
    #Scroll down on the screen
    #Scroll Down    ${CUSTOMS-BUTTON}    ${DUR}        
    Click on element    ${SUB-SUCCESS-CUSTOMS-BUTTON}
    #Wait Until Element Is Visible    ${CBNI-WEB-HOME-ICON}
    Expect Element    xpath=${CUSTOMS-WEB-ELEM-HEADER}    visible
    Close iOS Chrome Browser

    
