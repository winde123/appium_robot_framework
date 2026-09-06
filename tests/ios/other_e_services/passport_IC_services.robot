*** Settings ***
Variables   ../../../Resources/fork_config.py
Library     AppiumLibrary
Library     ../../../Resources/ios_appium_commands.py
Resource    ../../../Resources/commands.robot
Resource    ../../../Resources/ios/eservices_commands.robot
Variables   ${FORK_DATA_DIR}/ios/landing_page.yaml
Variables   ${FORK_DATA_DIR}/ios/other_e_services/other_e_services_page.yaml
Variables    ${FORK_DATA_DIR}/ios/other_e_services/passport_IC_page.yaml
Force Tags       fork:both
Test Setup       Open MyICA App on iOS Device 
Test Teardown    ios_appium_commands.Terminate App
Test Template    Open E-Service Portal And Verify

*** Test Cases *** 

Navigating to the passport and ic page
    [Documentation]     passport IC e services
    ${E-SERVICES-PASSPORT-IDENTITY-CARD}    4    ${APPLY-TRAVEL-DOC-TAB}    ${APPLY-TRAVEL-WEBPAGE-HEADER-ELEM}

Navigating to report lost passport page
    [Documentation]     passport IC e services
    ${E-SERVICES-PASSPORT-IDENTITY-CARD}    4    ${REPORT-LOST-PASSPORT-TAB}    ${LOST-PASSPORT-WEBPAGE-HEADER-ELEM}

Navigating to register IC page
    [Documentation]     passport IC e services
    ${E-SERVICES-PASSPORT-IDENTITY-CARD}    4    ${REGISTER-REPLACE-IDENTITY-CARD-TAB}    ${REGISTER-REPLACE-IDENTITY-WEBPAGE-HEADER-ELEM}

Navigating to report lost IC page
    [Documentation]     passport IC e services
    ${E-SERVICES-PASSPORT-IDENTITY-CARD}    4    ${REPORT-LOST-IDENTITY-CARD-TAB}    ${REGISTER-REPLACE-IDENTITY-WEBPAGE-HEADER-ELEM}
