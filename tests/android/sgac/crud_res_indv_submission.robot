*** Settings ***
Library     AppiumLibrary
Library     String
Library     ../../../../Resources/helper_func.py
Resource    ../../../../Resources/commands.robot
Resource    ../../../../Resources/android/SGACcommads.robot
Variables    ../../../../Data/test_data/manual_field_random.py
Variables    ../../../../Data/android/android_common_selectors.yaml
Variables    ../../../../Data/test_data/input_fields_test_data.yaml
Variables    ../../../../Data/android/sgac/sel_profile_submission_page.yaml
Variables    ../../../Data/android/sgac/resident/res_indv_submission_form_page.yaml
Variables    ../../../Data/android/sgac/resident/res_declaration_summmary_page.yaml
Variables    ../../../../Data/android/sgac/declaration_page.yaml
Variables    ../../../../Data/android/sgac/sub_success_page.yaml
Variables    ../../../../Data/android/other_e_services/e727_service.yaml
Variables    ../../../../Data/android/other_e_services/customs_declaration_service.yaml
Test Setup       Open Android App in emulator    appActivity=sg.gov.ica.mobile.app.MainActivity  
Test Teardown    Close Application

*** Test Cases ***

Create a resident submission and navigate to the e727 website
    [Documentation]    create submission and navigate to the cbni submission on the declaration success page
    Navigate to resident SGAC landing page
    Navigate to individual submission creation page
    Create resident profile manually 
    ## selecting the first profile 
    Click on element    ${SGAC-SEL-PROFILE-CARD-BUTTON}
    ## date of arrival
    Click on element    xpath=${RES-INDV-SUBMISSION-DATE-OPTION-1}
    Click on element    ${RES-INDV-SUBMISSION-FOOTER-NEXT-BUTTON}
    ## health declaration
    Click on element    xpath=${RES-INDV-DECLARATION-ANSWER-YES}
    Click on element    xpath=${RES-INDV-DECLARATION-QUESTION-ME-AFR-LA-ANSWER-YES}
    Click on element    ${RES-INDV-DECLARATION-FOOTER-NEXT-BUTTON}
    ## confirmation page
    ###validating the date of the arrival field
    ${CUR-DATE} =    helper_func.Current Date Generator
    ${CUR-DATE} =    helper_func.Date Field Formatter   ${CUR-DATE}
    ${TRAVEL-DATE-SELECTOR}=    Format String    //android.widget.TextView[@text="{}"]    ${CUR-DATE}
    Scroll down on the screen
    Expect Element    ${TRAVEL-DATE-SELECTOR}    visible
    Click on element    ${RES-DECL-SUMMARY-FOOTER-NEXT-BUTTON}
    Click on element    ${SGAC-DECLARATION-CHECKBOX}
    Click on element    ${SGAC-DECLARATION-FOOTER-SUBMIT-BUTTON}
    Type text    ${SGAC-DECLARATION-CAPTCHA-INPUT}    ${CAPTCHA-STR}
    Click on element    ${SGAC-DECLARATION-CAPTCHA-VERIFY-BUTTON}
    ${DUR}=     helper_func.Convert Int To Secs    30
    #Scroll down on the screen
    Scroll Down    ${CUSTOMS-BUTTON}    ${DUR}        
    Click on element    ${CBNI-DECL-BUTTON}
    Wait Until Element Is Visible    ${CBNI-WEB-HOME-ICON}
    Expect Element    ${CBNI-WEB-ELEM-HEADER}    visible
    Close Android Chrome Browser

Create a resident submission and navigate to the customs website
    [Documentation]    create submission and navigate to the customs declaration on the declaration success page
    Navigate to resident SGAC landing page
    Navigate to individual submission creation page
    Create resident profile manually 
    ## selecting the first profile 
    Click on element    ${SGAC-SEL-PROFILE-CARD-BUTTON}
    ## date of arrival
    Click on element    xpath=${RES-INDV-SUBMISSION-DATE-OPTION-1}
    Click on element    ${RES-INDV-SUBMISSION-FOOTER-NEXT-BUTTON}
    ## health declaration
    Click on element    xpath=${RES-INDV-DECLARATION-ANSWER-YES}
    Click on element    xpath=${RES-INDV-DECLARATION-QUESTION-ME-AFR-LA-ANSWER-YES}
    Click on element    ${RES-INDV-DECLARATION-FOOTER-NEXT-BUTTON}
    ## confirmation page
    ###validating the date of the arrival field
    ${CUR-DATE} =    helper_func.Current Date Generator
    ${CUR-DATE} =    helper_func.Date Field Formatter   ${CUR-DATE}
    ${TRAVEL-DATE-SELECTOR}=    Format String    //android.widget.TextView[@text="{}"]    ${CUR-DATE}
    Scroll down on the screen
    Expect Element    ${TRAVEL-DATE-SELECTOR}    visible
    Click on element    ${RES-DECL-SUMMARY-FOOTER-NEXT-BUTTON}
    Click on element    ${SGAC-DECLARATION-CHECKBOX}
    Click on element    ${SGAC-DECLARATION-FOOTER-SUBMIT-BUTTON}
    Type text    ${SGAC-DECLARATION-CAPTCHA-INPUT}    ${CAPTCHA-STR}
    Click on element    ${SGAC-DECLARATION-CAPTCHA-VERIFY-BUTTON}
    ${DUR}=     helper_func.Convert Int To Secs    30
    #Scroll down on the screen
    Scroll Down    ${CUSTOMS-BUTTON}    ${DUR}        
    Click on element    ${CUSTOMS-BUTTON}
    #Wait Until Element Is Visible    ${CBNI-WEB-HOME-ICON}
    Expect Element    ${CUSTOMS-WEB-ELEM-HEADER}    visible
    Close Android Chrome Browser

    
