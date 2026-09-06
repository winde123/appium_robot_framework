*** Settings ***
Variables   ../../../Resources/fork_config.py
Library     AppiumLibrary
Library     ../../../Resources/ios_appium_commands.py
Resource    ../../../Resources/commands.robot
Resource    ../../../Resources/ios/eservices_commands.robot
Variables   ${FORK_DATA_DIR}/ios/landing_page.yaml
Variables   ${FORK_DATA_DIR}/ios/other_e_services/other_e_services_page.yaml
Variables    ${FORK_DATA_DIR}/ios/other_e_services/sgac_epass_enquiry.yaml
Force Tags       fork:both
Test Setup       Open MyICA App on iOS Device 
Test Teardown    ios_appium_commands.Terminate App
Test Template    Open E-Service Portal And Verify

*** Test Cases *** 

Navigating to SGAC and epass enquiry page
    [Documentation]     sgac epass e services
    ${E-SERVICES-SGAC-ENTRY-VISA-EPASS-ENQUIRY-PORTAL}    4    ${SUBMIT-SG-ARRIVAL-CARD-TAB}    ${SUBMIT-SG-ARRIVAL-CARD-HEADER-ELEM}

Navigating to apply to entry visa page
    [Documentation]     sgac epass e services
    ${E-SERVICES-SGAC-ENTRY-VISA-EPASS-ENQUIRY-PORTAL}    4    ${APPLY-ENTRY-VISA-TAB}    ${APPLY-ENTRY-VISA-CARD-HEADER-ELEM}

Navigating to epass enquiry portal page
    [Documentation]     sgac epass e services
    ${E-SERVICES-SGAC-ENTRY-VISA-EPASS-ENQUIRY-PORTAL}    4    ${RETRIEVE-E-PASS-RECORD-TAB}    ${RETRIEVE-E-PASS-RECORD-HEADER-ELEM}

Navigating to extension of visit pass portal page
    [Documentation]     sgac epass e services
    ${E-SERVICES-SGAC-ENTRY-VISA-EPASS-ENQUIRY-PORTAL}    4    ${APPLY-EXTENSION-OF-VISIT-PASS-TAB}    ${APPLY-EXTENSION-OF-VISIT-PASS-HEADER-ELEM}
