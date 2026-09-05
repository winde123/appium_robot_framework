*** Settings ***
Variables   ../../../Resources/fork_config.py
Library     AppiumLibrary
Library     ../../../Resources/ios_appium_commands.py
Resource    ../../../Resources/commands.robot
Variables   ${FORK_DATA_DIR}/ios/landing_page.yaml
Variables   ${FORK_DATA_DIR}/ios/other_e_services/other_e_services_page.yaml
Variables    ${FORK_DATA_DIR}/ios/other_e_services/passport_IC_page.yaml
Force Tags       fork:both
Test Setup       Open MyICA App on iOS Device 
Test Teardown    ios_appium_commands.Terminate App

*** Test Cases *** 

Navigating to the passport and ic page
    [Documentation]     passport IC e services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-PASSPORT-IDENTITY-CARD}
    ### asserting that there should be 4 options
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    4
    Click on element        ${APPLY-TRAVEL-DOC-TAB}
    Expect Element    ${APPLY-TRAVEL-WEBPAGE-HEADER-ELEM}    visible
    Close iOS Chrome Browser

Navigating to report lost passport page
    [Documentation]     passport IC e services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-PASSPORT-IDENTITY-CARD}
    ### asserting that there should be 4 options
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    4
    Click on element              ${REPORT-LOST-PASSPORT-TAB}
    Expect Element    ${LOST-PASSPORT-WEBPAGE-HEADER-ELEM}    visible
    Close iOS Chrome Browser

Navigating to register IC page
    [Documentation]     passport IC e services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-PASSPORT-IDENTITY-CARD}
    ### asserting that there should be 4 options
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    4
    Click on element              ${REGISTER-REPLACE-IDENTITY-CARD-TAB}
    Expect Element    ${REGISTER-REPLACE-IDENTITY-WEBPAGE-HEADER-ELEM}    visible
    Close iOS Chrome Browser

Navigating to report lost IC page
    [Documentation]     passport IC e services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-PASSPORT-IDENTITY-CARD}
    ### asserting that there should be 4 options
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    4
    Click on element              ${REPORT-LOST-IDENTITY-CARD-TAB}
    Expect Element    ${REGISTER-REPLACE-IDENTITY-WEBPAGE-HEADER-ELEM}    visible
    Close iOS Chrome Browser

