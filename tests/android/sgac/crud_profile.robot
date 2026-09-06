*** Settings ***
Variables    ../../../Resources/fork_config.py
Library     AppiumLibrary
Library     String
Library     ../../../Data/test_data/manual_field_random.py
Resource    ../../../Resources/commands.robot
Resource    ../../../Resources/android/SGACcommands.robot
Variables    ${FORK_DATA_DIR}/android/sgac/indv_profile_list_page.yaml
Variables    ${FORK_DATA_DIR}/android/profile_creation_method_page.yaml
Variables    ${FORK_DATA_DIR}/android/sgac/resident/resident_profile_creation_form_page.yaml
Variables    ${FORK_DATA_DIR}/android/sgac/resident/resident_confirmation_profile_page.yaml
Force Tags    fork:both
Test Setup       Open MyICA App on Android Emulator
Test Teardown    Close Application

*** Test Cases ***

#User is able to create resident indv submssion with one trip successfully
User is able create resident profile
    [Documentation]   this tc is to do a straight through flow of indv user submssion
    ${PROFILE}=    manual_field_random.Generate Profile Record
    Set Test Variable    ${NAME}    ${PROFILE}[name]
    Set Test Variable    ${NRIC}    ${PROFILE}[nric]
    Set Test Variable    ${DOB}    ${PROFILE}[dob]
    Set Test Variable    ${PHNO}    ${PROFILE}[phno]
    Set Test Variable    ${EMAIL}    ${PROFILE}[email]
    Navigate to resident SGAC landing page
    Navigate to resident profile list page
    ## create profile via the manual input button
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
    ### validating the values on the confirmation page
    ${NAME-FIELD-SEL}=  Format String  //android.widget.TextView[@text="{}"]   ${NAME}
    ${DOB} =     helper_func.Date Field Formatter    ${DOB}
    ${DOB-FIELD-SEL}=  Format String    //android.widget.TextView[contains(@text,"{}")]    ${DOB}
    ${NRIC-FIELD-SEL}=  Format String    //android.widget.TextView[@text="{}"]    ${NRIC}
    ${PHNO-FIELD-SEL}=  Format String    //android.widget.TextView[@text="{}"]    ${PHNO}
    ${EMAIL-FIELD-SEL}=  Format String    //android.widget.TextView[@text="{}"]    ${EMAIL}


    Expect Element    ${NAME-FIELD-SEL}    visible
    Expect Element    ${DOB-FIELD-SEL}    visible
    Expect Element    ${NRIC-FIELD-SEL}    visible
    Expect Element    ${PHNO-FIELD-SEL}    visible
    Expect Element    ${EMAIL-FIELD-SEL}    visible

    ### clicking on the save button
    Click on element    ${RES-CONFIRM-PROFILE-TERMS-CHECKBOX}
    Click on element    ${RES-FOOTER-SAVE-BUTTON}



