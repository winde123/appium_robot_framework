*** Settings ***
Variables   ../../../Resources/fork_config.py
Library     AppiumLibrary
Library     ../../../Resources/ios_appium_commands.py
Resource    ../../../Resources/commands.robot
Variables   ${FORK_DATA_DIR}/ios/landing_page.yaml
Variables   ${FORK_DATA_DIR}/ios/other_e_services/other_e_services_page.yaml
Variables    ${FORK_DATA_DIR}/ios/other_e_services/others_services_page.yaml
Force Tags       fork:both
Test Setup       Open MyICA App on iOS Device 
Test Teardown    ios_appium_commands.Terminate App

*** Test Cases *** 

Navigating to apply for apec business travel card page
    [Documentation]     other services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-OTHERS}
    ### asserting that there should be 3 options
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    3
    Click on element        ${OTHERS-APEC-BUSINESS-TRAVEL-CARD-TAB}
    Expect Element    ${OTHERS-APEC-BUSINESS-TRAVEL-HEADER-ELEM}    visible
    Close iOS Chrome Browser

Navigating to apply for usa trusted traveller program page
    [Documentation]     other services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-OTHERS}
    ### asserting that there should be 3 options
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    3
    Click on element        ${OTHERS-US-TRUSTED-TRAVELLER-PROGRAMME-TAB}
    Close iOS Chrome Browser

Navigating to apply for change race / dialect page
    [Documentation]     other services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-OTHERS}
    ### asserting that there should be 3 options
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    3
    Click on element        ${OTHERS-CHANGE-RACE-DIALECT-TAB}
    Expect Element    ${OTHERS-CHANGE-RACE-DIALECT-HEADER-ELEM}    visible
    Close iOS Chrome Browser