*** Settings ***
Library     AppiumLibrary
Library     ../../../Resources/ios_appium_commands.py
Resource    ../../../Resources/commands.robot
Variables   ../../../Data/ios/landing_page.yaml
Variables   ../../../Data/ios/other_e_services/other_e_services_page.yaml
Variables    ../../../Data/ios/other_e_services/change_res_address_page.yaml
Test Setup       Open ios App on device 
Test Teardown    ios_appium_commands.Terminate App

*** Test Cases *** 
Navigating to change of address for ic holder page
    [Documentation]     report change of residential address
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-REPORT-CHANGE-RESIDENTIAL-ADDRESS}
    ### asserting that there should be 2 options
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    2
    Click on element        ${REPORT-CHANGE-RES-ADDRESS-IC-HOLDER-TAB}
    Expect Element    ${REPORT-CHANGE-RES-ADDRESS-HEADER-ELEM}    visible
    Close iOS Chrome Browser

Navigating to change of address for ltvp/stp holder page
    [Documentation]     report change of residential address
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-REPORT-CHANGE-RESIDENTIAL-ADDRESS}
    ### asserting that there should be 2 options
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    2
    Click on element        ${REPORT-CHANGE-RES-ADDRESS-LTVP-STP-HOLDER-TAB}
    Expect Element    ${REPORT-CHANGE-RES-ADDRESS-HEADER-ELEM}    visible
    Close iOS Chrome Browser