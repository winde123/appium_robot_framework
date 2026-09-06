*** Settings ***
Variables   ../../../Resources/fork_config.py
Library     AppiumLibrary
Library     ../../../Resources/ios_appium_commands.py
Resource    ../../../Resources/commands.robot
Resource    ../../../Resources/ios/eservices_commands.robot
Variables   ${FORK_DATA_DIR}/ios/landing_page.yaml
Variables   ${FORK_DATA_DIR}/ios/other_e_services/other_e_services_page.yaml
Variables    ${FORK_DATA_DIR}/ios/other_e_services/sc_pr_services_page.yaml
Force Tags       fork:both
Test Setup       Open MyICA App on iOS Device 
Test Teardown    ios_appium_commands.Terminate App
Test Template    Open E-Service Portal And Verify

*** Test Cases *** 

Navigating to apply for sc page
    [Documentation]     sc and pr services
    ${E-SERVICES-SC-PR}    3    ${SC-PR-APPLY-SINGAPORE-CITIZENSHIP-TAB}    ${SC-PR-APPLY-SINGAPORE-CITIZENSHIP-HEADER-ELEM}

Navigating to apply for pr page
    [Documentation]     sc and pr services
    ${E-SERVICES-SC-PR}    3    ${SC-PR-APPLY-PR-TAB}    ${SC-PR-APPLY-PR-HEADER-ELEM}

Navigating to apply for renewal/transfer re-entry permit page
    [Documentation]     sc and pr services
    ${E-SERVICES-SC-PR}    3    ${SC-PR-REENTRY-PERMIT-RENEWAL-TRANSFER-TAB}    ${SC-PR-REENTRY-PERMIT-RENEWAL-TRANSFER-HEADER-ELEM}
