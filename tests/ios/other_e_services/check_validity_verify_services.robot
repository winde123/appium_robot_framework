*** Settings ***
Library     AppiumLibrary
Library     ../../../Resources/ios_appium_commands.py
Resource    ../../../Resources/commands.robot
Variables   ../../../Data/ios/landing_page.yaml
Variables   ../../../Data/ios/other_e_services/other_e_services_page.yaml
Variables    ../../../Data/ios/other_e_services/check_validity_verify_page.yaml
Test Setup       Open ios App on device 
Test Teardown    ios_appium_commands.Terminate App

*** Test Cases *** 
Navigating to verify validity of IC page
    [Documentation]     check validity / verify  e services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-CHECK-VALIDITY-VERIFY}
    ### asserting that there should be 4 options
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    8
    Click on element        ${VERIFY-VALIDITY-IC-TAB}
    Expect Element    ${VERIFY-VALIDITY-IC-HEADER-ELEM}    visible