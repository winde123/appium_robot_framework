*** Settings ***
Variables   ../../../Resources/fork_config.py
Library     AppiumLibrary
Library     ../../../Resources/ios_appium_commands.py
Resource    ../../../Resources/commands.robot
Resource    ../../../Resources/ios/eservices_commands.robot
Variables   ${FORK_DATA_DIR}/ios/landing_page.yaml
Variables   ${FORK_DATA_DIR}/ios/other_e_services/other_e_services_page.yaml
Variables    ${FORK_DATA_DIR}/ios/other_e_services/ltvp_student_pass_services_page.yaml
Force Tags       fork:both
Test Setup       Open MyICA App on iOS Device 
Test Teardown    ios_appium_commands.Terminate App
Test Template    Open E-Service Portal And Verify

*** Test Cases *** 

Navigating to apply/renew ltvp page
    [Documentation]     ltvp and student pass services
    ${E-SERVICES-LTVP-STUDENTS-PASS}    4    ${LTVP-APPLY-RENEW-LTVP-TAB}    ${LTVP-APPLY-RENEW-LTVP-HEADER-ELEM}

Navigating to apply for PMLA page
    [Documentation]     ltvp and student pass services
    ${E-SERVICES-LTVP-STUDENTS-PASS}    4    ${LTVP-APPLY-PMLA-TAB}    ${LTVP-APPLY-PMLA-HEADER-ELEM}

Navigating to apply/renew student pass page
    [Documentation]     ltvp and student pass services
    ${E-SERVICES-LTVP-STUDENTS-PASS}    4    ${LTVP-APPLY-RENEW-STUDENT-PASS-IHL-TAB}    ${LTVP-APPLY-RENEW-STUDENT-PASS-IHL-HEADER-ELEM}

Navigating to apply/renew student pass for other schools page
    [Documentation]     ltvp and student pass services
    ${E-SERVICES-LTVP-STUDENTS-PASS}    4    ${LTVP-APPLY-RENEW-STUDENT-PASS-OTHER-SCHOOLS-TAB}    ${LTVP-APPLY-RENEW-STUDENT-PASS-IHL-HEADER-ELEM}
