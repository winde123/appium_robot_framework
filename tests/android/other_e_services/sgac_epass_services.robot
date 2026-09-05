*** Settings ***
Variables    ../../../Resources/fork_config.py
Library     AppiumLibrary
Resource    ../../../Resources/commands.robot
Variables   ${FORK_DATA_DIR}/android/landing_page.yaml
Variables   ${FORK_DATA_DIR}/android/eservices_landing_page.yaml
Variables    ${FORK_DATA_DIR}/android/other_e_services/sgac_epass_enquiry.yaml
Force Tags    fork:both
Test Setup       Open MyICA App Remotely
Test Teardown    Close Application

*** Test Cases *** 

Navigating to SGAC and epass enquiry page
    [Documentation]     sgac epass e services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-SGAC-ENTRY-VISA-EPASS-ENQUIRY-PORTAL}
    ### asserting that there should be 4 options
    Wait Until Element Is Visible  ${SUBMIT-SG-ARRIVAL-CARD-TAB}
    Xpath Should Match X Times    //android.view.ViewGroup[@resource-id="card-container"]    4
    Click on element              ${SUBMIT-SG-ARRIVAL-CARD-TAB}
    Expect Element    ${SUBMIT-SG-ARRIVAL-CARD-HEADER-ELEM}    visible
    Close iOS Chrome Browser

Navigating to apply to entry visa page
    [Documentation]     sgac epass e services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-SGAC-ENTRY-VISA-EPASS-ENQUIRY-PORTAL}
    Wait Until Element Is Visible  ${SUBMIT-SG-ARRIVAL-CARD-TAB}
    ### asserting that there should be 4 options
    Xpath Should Match X Times    //android.view.ViewGroup[@resource-id="card-container"]    4
    Click on element              ${APPLY-ENTRY-VISA-TAB}
    Expect Element    ${APPLY-ENTRY-VISA-CARD-HEADER-ELEM}    visible
    Close Android Chrome Browser

Navigating to epass enquiry portal page
    [Documentation]     sgac epass e services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-SGAC-ENTRY-VISA-EPASS-ENQUIRY-PORTAL}
    Wait Until Element Is Visible  ${SUBMIT-SG-ARRIVAL-CARD-TAB}
    ### asserting that there should be 4 options
    Xpath Should Match X Times    //android.view.ViewGroup[@resource-id="card-container"]    4
    Click on element              ${RETRIEVE-E-PASS-RECORD-TAB}
    Expect Element    ${RETRIEVE-E-PASS-RECORD-HEADER-ELEM}    visible
    Close Android Chrome Browser

Navigating to extension of visit pass portal page
    [Documentation]     sgac epass e services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-SGAC-ENTRY-VISA-EPASS-ENQUIRY-PORTAL}
    Wait Until Element Is Visible  ${SUBMIT-SG-ARRIVAL-CARD-TAB}
    ### asserting that there should be 4 options
    Xpath Should Match X Times    //android.view.ViewGroup[@resource-id="card-container"]    4
    Click on element              ${APPLY-EXTENSION-OF-VISIT-PASS-TAB}
    Expect Element    ${APPLY-EXTENSION-OF-VISIT-PASS-HEADER-ELEM}    visible
    Close Android Chrome Browser
