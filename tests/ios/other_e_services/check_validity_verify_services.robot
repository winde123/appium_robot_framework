*** Settings ***
Variables   ../../../Resources/fork_config.py
Library     AppiumLibrary
Library     ../../../Resources/ios_appium_commands.py
Resource    ../../../Resources/commands.robot
Resource    ../../../Resources/ios/eservices_commands.robot
Variables   ${FORK_DATA_DIR}/ios/landing_page.yaml
Variables   ${FORK_DATA_DIR}/ios/other_e_services/other_e_services_page.yaml
Variables    ${FORK_DATA_DIR}/ios/other_e_services/check_validity_verify_page.yaml
Force Tags       fork:both
Test Setup       Open MyICA App on iOS Device 
Test Teardown    ios_appium_commands.Terminate App
Test Template    Open E-Service Portal And Verify

*** Test Cases *** 
Navigating to verify validity of IC page
    [Documentation]     check validity / verify  e services
    ${E-SERVICES-CHECK-VALIDITY-VERIFY}    8    ${VERIFY-VALIDITY-IC-TAB}    ${VERIFY-VALIDITY-IC-HEADER-ELEM}

Navigating to verify validity of immigration pass page
    [Documentation]     check validity / verify  e services
    ${E-SERVICES-CHECK-VALIDITY-VERIFY}    8    ${IMMIGRATION-PASS-LTVP-STUDENT-PASS-TAB}    ${IMMIGRATION-PASS-LTVP-STUDENT-PASS-HEADER-ELEM}

Navigating to verify validity of digital birth page
    [Documentation]     check validity / verify  e services
    ${E-SERVICES-CHECK-VALIDITY-VERIFY}    8    ${DIGITAL-BIRTH-CERTIFICATE-TAB}    ${DIGITAL-BIRTH-CERTIFICATE-HEADER-ELEM}

Navigating to verify validity of digital birth extract page
    [Documentation]     check validity / verify  e services
    ${E-SERVICES-CHECK-VALIDITY-VERIFY}    8    ${DIGITAL-BIRTH-EXTRACT-TAB}    ${DIGITAL-BIRTH-EXTRACT-HEADER-ELEM}

Navigating to verify validity of digital death cert page
    [Documentation]     check validity / verify  e services
    ${E-SERVICES-CHECK-VALIDITY-VERIFY}    8    ${DIGITAL-DEATH-CERTIFICATE-TAB}    ${DIGITAL-DEATH-CERTIFICATE-HEADER-ELEM}

Navigating to verify validity of digital death extract page
    [Documentation]     check validity / verify  e services
    ${E-SERVICES-CHECK-VALIDITY-VERIFY}    8    ${DIGITAL-DEATH-EXTRACT-TAB}    ${DIGITAL-DEATH-EXTRACT-HEADER-ELEM}

Navigating to verify validity of digital stillbirth cert page
    [Documentation]     check validity / verify  e services
    ${E-SERVICES-CHECK-VALIDITY-VERIFY}    8    ${DIGITAL-STILLBIRTH-CERTIFICATE-TAB}    ${DIGITAL-STILLBIRTH-CERTIFICATE-HEADER-ELEM}

Navigating to verify validity of digital stillbirth extract cert page
    [Documentation]     check validity / verify  e services
    ${E-SERVICES-CHECK-VALIDITY-VERIFY}    8    ${DIGITAL-STILLBIRTH-EXTRACT-TAB}    ${DIGITAL-STILLBIRTH-EXTRACT-HEADER-ELEM}
