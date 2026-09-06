*** Settings ***
Variables   ../../../Resources/fork_config.py
Library     AppiumLibrary
Library     ../../../Resources/ios_appium_commands.py
Resource    ../../../Resources/commands.robot
Resource    ../../../Resources/ios/eservices_commands.robot
Variables   ${FORK_DATA_DIR}/ios/landing_page.yaml
Variables   ${FORK_DATA_DIR}/ios/other_e_services/other_e_services_page.yaml
Variables    ${FORK_DATA_DIR}/ios/other_e_services/others_services_page.yaml
Force Tags       fork:both
Test Setup       Open MyICA App on iOS Device 
Test Teardown    ios_appium_commands.Terminate App
Test Template    Open E-Service Portal And Verify

*** Test Cases *** 

Navigating to apply for apec business travel card page
    [Documentation]     other services
    ${E-SERVICES-OTHERS}    3    ${OTHERS-APEC-BUSINESS-TRAVEL-CARD-TAB}    ${OTHERS-APEC-BUSINESS-TRAVEL-HEADER-ELEM}

Navigating to apply for usa trusted traveller program page
    [Documentation]     other services
    ${E-SERVICES-OTHERS}    3    ${OTHERS-US-TRUSTED-TRAVELLER-PROGRAMME-TAB}    ${EMPTY}

Navigating to apply for change race / dialect page
    [Documentation]     other services
    ${E-SERVICES-OTHERS}    3    ${OTHERS-CHANGE-RACE-DIALECT-TAB}    ${OTHERS-CHANGE-RACE-DIALECT-HEADER-ELEM}
