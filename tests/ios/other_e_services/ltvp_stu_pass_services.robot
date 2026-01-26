*** Settings ***
Library     AppiumLibrary
Library     ../../../Resources/ios_appium_commands.py
Resource    ../../../Resources/commands.robot
Variables   ../../../Data/ios/landing_page.yaml
Variables   ../../../Data/ios/other_e_services/other_e_services_page.yaml
Variables    ../../../Data/ios/other_e_services/ltvp_student_pass_services_page.yaml
Test Setup       Open ios App on device 
Test Teardown    ios_appium_commands.Terminate App

*** Test Cases *** 

Navigating to apply/renew ltvp page
    [Documentation]     ltvp and student pass services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-LTVP-STUDENTS-PASS}
    ### asserting that there should be 4 options
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    4
    Click on element        ${LTVP-APPLY-RENEW-LTVP-TAB}
    Expect Element    ${LTVP-APPLY-RENEW-LTVP-HEADER-ELEM}    visible
    Close iOS Chrome Browser

Navigating to apply for PMLA page
    [Documentation]     ltvp and student pass services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-LTVP-STUDENTS-PASS}
    ### asserting that there should be 4 options
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    4
    Click on element        ${LTVP-APPLY-PMLA-TAB}
    Expect Element    ${LTVP-APPLY-PMLA-HEADER-ELEM}    visible
    Close iOS Chrome Browser

Navigating to apply/renew student pass page
    [Documentation]     ltvp and student pass services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-LTVP-STUDENTS-PASS}
    ### asserting that there should be 4 options
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    4
    Click on element        ${LTVP-APPLY-RENEW-STUDENT-PASS-IHL-TAB}
    Expect Element    ${LTVP-APPLY-RENEW-STUDENT-PASS-IHL-HEADER-ELEM}    visible
    Close iOS Chrome Browser

Navigating to apply/renew student pass for other schools page
    [Documentation]     ltvp and student pass services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-LTVP-STUDENTS-PASS}
    ### asserting that there should be 4 options
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    4
    Click on element        ${LTVP-APPLY-RENEW-STUDENT-PASS-OTHER-SCHOOLS-TAB}
    Expect Element    ${LTVP-APPLY-RENEW-STUDENT-PASS-IHL-HEADER-ELEM}    visible
    Close iOS Chrome Browser