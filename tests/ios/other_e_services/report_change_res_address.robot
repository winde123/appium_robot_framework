*** Settings ***
Variables   ../../../Resources/fork_config.py
Library     AppiumLibrary
Library     ../../../Resources/ios_appium_commands.py
Resource    ../../../Resources/commands.robot
Resource    ../../../Resources/ios/eservices_commands.robot
Variables   ${FORK_DATA_DIR}/ios/landing_page.yaml
Variables   ${FORK_DATA_DIR}/ios/other_e_services/other_e_services_page.yaml
Variables    ${FORK_DATA_DIR}/ios/other_e_services/change_res_address_page.yaml
Force Tags       fork:both
Test Setup       Open MyICA App on iOS Device 
Test Teardown    ios_appium_commands.Terminate App
Test Template    Open E-Service Portal And Verify

*** Test Cases *** 
Navigating to change of address for ic holder page
    [Documentation]     report change of residential address
    ${E-SERVICES-REPORT-CHANGE-RESIDENTIAL-ADDRESS}    2    ${REPORT-CHANGE-RES-ADDRESS-IC-HOLDER-TAB}    ${REPORT-CHANGE-RES-ADDRESS-HEADER-ELEM}

Navigating to change of address for ltvp/stp holder page
    [Documentation]     report change of residential address
    ${E-SERVICES-REPORT-CHANGE-RESIDENTIAL-ADDRESS}    2    ${REPORT-CHANGE-RES-ADDRESS-LTVP-STP-HOLDER-TAB}    ${REPORT-CHANGE-RES-ADDRESS-HEADER-ELEM}
