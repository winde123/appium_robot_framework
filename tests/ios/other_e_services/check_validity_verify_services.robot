*** Settings ***
Variables   ../../../Resources/fork_config.py
Library     AppiumLibrary
Library     ../../../Resources/ios_appium_commands.py
Resource    ../../../Resources/commands.robot
Variables   ${FORK_DATA_DIR}/ios/landing_page.yaml
Variables   ${FORK_DATA_DIR}/ios/other_e_services/other_e_services_page.yaml
Variables    ${FORK_DATA_DIR}/ios/other_e_services/check_validity_verify_page.yaml
Force Tags       fork:both
Test Setup       Open MyICA App on iOS Device 
Test Teardown    ios_appium_commands.Terminate App

*** Test Cases *** 
Navigating to verify validity of IC page
    [Documentation]     check validity / verify  e services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-CHECK-VALIDITY-VERIFY}
    ### asserting that there should be 8 options
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    8
    Click on element        ${VERIFY-VALIDITY-IC-TAB}
    Expect Element    ${VERIFY-VALIDITY-IC-HEADER-ELEM}    visible
    Close iOS Chrome Browser

Navigating to verify validity of immigration pass page
    [Documentation]     check validity / verify  e services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-CHECK-VALIDITY-VERIFY}
    ### asserting that there should be 8 options
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    8
    Click on element        ${IMMIGRATION-PASS-LTVP-STUDENT-PASS-TAB}
    Expect Element    ${IMMIGRATION-PASS-LTVP-STUDENT-PASS-HEADER-ELEM}    visible
    Close iOS Chrome Browser

Navigating to verify validity of digital birth page
    [Documentation]     check validity / verify  e services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-CHECK-VALIDITY-VERIFY}
    ### asserting that there should be 8 options
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    8
    Click on element        ${DIGITAL-BIRTH-CERTIFICATE-TAB}
    Expect Element    ${DIGITAL-BIRTH-CERTIFICATE-HEADER-ELEM}    visible
    Close iOS Chrome Browser

Navigating to verify validity of digital birth extract page
    [Documentation]     check validity / verify  e services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-CHECK-VALIDITY-VERIFY}
    ### asserting that there should be 8 options
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    8
    Click on element        ${DIGITAL-BIRTH-EXTRACT-TAB}
    Expect Element    ${DIGITAL-BIRTH-EXTRACT-HEADER-ELEM}    visible
    Close iOS Chrome Browser

Navigating to verify validity of digital death cert page
    [Documentation]     check validity / verify  e services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-CHECK-VALIDITY-VERIFY}
    ### asserting that there should be 8 options
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    8
    Click on element        ${DIGITAL-DEATH-CERTIFICATE-TAB}
    Expect Element    ${DIGITAL-DEATH-CERTIFICATE-HEADER-ELEM}    visible
    Close iOS Chrome Browser

Navigating to verify validity of digital death extract page
    [Documentation]     check validity / verify  e services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-CHECK-VALIDITY-VERIFY}
    ### asserting that there should be 8 options
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    8
    Click on element        ${DIGITAL-DEATH-EXTRACT-TAB}
    Expect Element    ${DIGITAL-DEATH-EXTRACT-HEADER-ELEM}    visible
    Close iOS Chrome Browser

Navigating to verify validity of digital stillbirth cert page
    [Documentation]     check validity / verify  e services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-CHECK-VALIDITY-VERIFY}
    ### asserting that there should be 8 options
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    8
    Click on element        ${DIGITAL-STILLBIRTH-CERTIFICATE-TAB}
    Expect Element    ${DIGITAL-STILLBIRTH-CERTIFICATE-HEADER-ELEM}    visible
    Close iOS Chrome Browser

Navigating to verify validity of digital stillbirth extract cert page
    [Documentation]     check validity / verify  e services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-CHECK-VALIDITY-VERIFY}
    ### asserting that there should be 8 options
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    8
    Click on element        ${DIGITAL-STILLBIRTH-EXTRACT-TAB}
    Expect Element    ${DIGITAL-STILLBIRTH-EXTRACT-HEADER-ELEM}    visible
    Close iOS Chrome Browser
