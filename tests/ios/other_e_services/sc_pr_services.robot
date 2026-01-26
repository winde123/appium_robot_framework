*** Settings ***
Library     AppiumLibrary
Library     ../../../Resources/ios_appium_commands.py
Resource    ../../../Resources/commands.robot
Variables   ../../../Data/ios/landing_page.yaml
Variables   ../../../Data/ios/other_e_services/other_e_services_page.yaml
Variables    ../../../Data/ios/other_e_services/sc_pr_services_page.yaml
Test Setup       Open ios App on device 
Test Teardown    ios_appium_commands.Terminate App

*** Test Cases *** 

Navigating to apply for sc page
    [Documentation]     sc and pr services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-SC-PR}
    ### asserting that there should be 3 options
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    3
    Click on element        ${SC-PR-APPLY-SINGAPORE-CITIZENSHIP-TAB}
    Expect Element    ${SC-PR-APPLY-SINGAPORE-CITIZENSHIP-HEADER-ELEM}    visible
    Close iOS Chrome Browser

Navigating to apply for pr page
    [Documentation]     sc and pr services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-SC-PR}
    ### asserting that there should be 3 options
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    3
    Click on element        ${SC-PR-APPLY-PR-TAB}
    Expect Element    ${SC-PR-APPLY-PR-HEADER-ELEM}    visible
    Close iOS Chrome Browser

Navigating to apply for renewal/transfer re-entry permit page
    [Documentation]     sc and pr services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-SC-PR}
    ### asserting that there should be 3 options
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    3
    Click on element        ${SC-PR-REENTRY-PERMIT-RENEWAL-TRANSFER-TAB}
    Expect Element    ${SC-PR-REENTRY-PERMIT-RENEWAL-TRANSFER-HEADER-ELEM}    visible
    Close iOS Chrome Browser