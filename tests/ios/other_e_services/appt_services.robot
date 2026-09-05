*** Settings ***
Variables   ../../../Resources/fork_config.py
Library     AppiumLibrary
Library     ../../../Resources/ios_appium_commands.py
Resource    ../../../Resources/commands.robot
Variables   ${FORK_DATA_DIR}/ios/landing_page.yaml
Variables   ${FORK_DATA_DIR}/ios/citizen_res_page.yaml
Variables   ${FORK_DATA_DIR}/ios/other_e_services/other_e_services_page.yaml
Variables    ${FORK_DATA_DIR}/ios/other_e_services/appt_services_page.yaml
Force Tags       fork:both
Test Setup       Open MyICA App on iOS Device 
Test Teardown    ios_appium_commands.Terminate App

*** Test Cases *** 

Navigating to book change cancel appt page
    [Documentation]     appt services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-APPOINTMENT}
    ### asserting that there should be 2 options
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    2
    Click on element        ${APPT-BOOK-CHANGE-CANCEL-TAB}
    Expect Element    ${APPT-BOOK-CHANGE-CANCEL-TAB-HEADER-ELEM}    visible
    Close iOS Chrome Browser

Navigating to check in page
    [Documentation]     appt services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-APPOINTMENT}
    ### asserting that there should be 2 options
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    2
    Click on element        ${APPT-ONLINE-CHECK-IN-TAB}
    Expect Element    ${APPT-ONLINE-CHECK-IN-TAB-HEADER-ELEM}    visible
    Close iOS Chrome Browser

Navigate to the appointment page via the citizen and residents card
    [Documentation]    navigating to the appt page via the citizens and resident card 
    Click on element       xpath=${CITIZEN-RESIDENT-ESERVICE-BUTTON}
    Click on element       ${CITIZEN-RES-APPOINTMENT-CARD}
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    2
    Expect Element    ${APPT-BOOK-CHANGE-CANCEL-TAB}    visible
    Expect Element    ${APPT-ONLINE-CHECK-IN-TAB}    visible
