*** Settings ***
Variables   ../../../Resources/fork_config.py
Library     AppiumLibrary
Library     ../../../Resources/ios_appium_commands.py
Resource    ../../../Resources/commands.robot
Variables   ${FORK_DATA_DIR}/ios/landing_page.yaml
Variables   ${FORK_DATA_DIR}/ios/other_e_services/other_e_services_page.yaml
Variables    ${FORK_DATA_DIR}/ios/other_e_services/birth_death_services_page.yaml
Force Tags       fork:both
Test Setup       Open MyICA App on iOS Device 
Test Teardown    ios_appium_commands.Terminate App

*** Test Cases *** 

Navigating to apply for birth/death extract page
    [Documentation]     birth and death services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-BIRTH-DEATH}
    ### asserting that there should be 1 option
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    1
    Click on element        ${BIRTH-DEATH-APPLY-EXTRACT-TAB}
    Expect Element    ${BIRTH-DEATH-APPLY-EXTRACT-HEADER-ELEM}    visible
    Close iOS Chrome Browser

