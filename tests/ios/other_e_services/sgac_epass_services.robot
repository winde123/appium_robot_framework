*** Settings ***
Variables   ../../../Resources/fork_config.py
Library     AppiumLibrary
Library     ../../../Resources/ios_appium_commands.py
Resource    ../../../Resources/commands.robot
Variables   ${FORK_DATA_DIR}/ios/landing_page.yaml
Variables   ${FORK_DATA_DIR}/ios/other_e_services/other_e_services_page.yaml
Variables    ${FORK_DATA_DIR}/ios/other_e_services/sgac_epass_enquiry.yaml
Force Tags       fork:both
Test Setup       Open MyICA App on iOS Device 
Test Teardown    ios_appium_commands.Terminate App

*** Test Cases *** 

Navigating to SGAC and epass enquiry page
    [Documentation]     sgac epass e services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-SGAC-ENTRY-VISA-EPASS-ENQUIRY-PORTAL}
    ### asserting that there should be 4 options
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    4
    Click on element              ${SUBMIT-SG-ARRIVAL-CARD-TAB}
    Expect Element    ${SUBMIT-SG-ARRIVAL-CARD-HEADER-ELEM}    visible
    Close iOS Chrome Browser

Navigating to apply to entry visa page
    [Documentation]     sgac epass e services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-SGAC-ENTRY-VISA-EPASS-ENQUIRY-PORTAL}
    ### asserting that there should be 4 options
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    4
    Click on element              ${APPLY-ENTRY-VISA-TAB}
    Expect Element    ${APPLY-ENTRY-VISA-CARD-HEADER-ELEM}    visible
    Close iOS Chrome Browser

Navigating to epass enquiry portal page
    [Documentation]     sgac epass e services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-SGAC-ENTRY-VISA-EPASS-ENQUIRY-PORTAL}
    ### asserting that there should be 4 options
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    4
    Click on element              ${RETRIEVE-E-PASS-RECORD-TAB}
    Expect Element    ${RETRIEVE-E-PASS-RECORD-HEADER-ELEM}    visible
    Close iOS Chrome Browser

Navigating to extension of visit pass portal page
    [Documentation]     sgac epass e services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-SGAC-ENTRY-VISA-EPASS-ENQUIRY-PORTAL}
    ### asserting that there should be 4 options
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    4
    Click on element              ${APPLY-EXTENSION-OF-VISIT-PASS-TAB}
    Expect Element    ${APPLY-EXTENSION-OF-VISIT-PASS-HEADER-ELEM}    visible
    Close iOS Chrome Browser