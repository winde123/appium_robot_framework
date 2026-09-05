*** Settings ***
Variables    ../../Resources/fork_config.py
Library       AppiumLibrary
Resource      ../../Resources/commands.robot
Variables     ../../Data/test_data/input_fields_test_data.yaml
Variables     ${FORK_DATA_DIR}/android/landing_page.yaml
Variables     ${FORK_DATA_DIR}/android/eservices_landing_page.yaml
Force Tags    fork:both
Test Setup       Open MyICA App on Android Emulator
Test Teardown    Close Application
*** Test Cases ***

Navigating to e-services page via the favorite icons
    [Documentation]     Navigate on other e-services via the other e-services fav icon
    #Open ios App on device 
    #Start Screen Recording   
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Wait Until Element Is Visible  ${E-SERVICES-PASSPORT-IDENTITY-CARD}
    Xpath Should Match X Times    //android.view.ViewGroup[@resource-id="card-container"]    10
    #Stop Screen Recording

Navigating to customs@SG page
    [Documentation]     appt services
    #Start Screen Recording
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Scroll down on the screen
    Click on element        ${E-SERVICES-CUSTOMS-DECLARATION}
    #Wait Until Element Is Visible    //android.widget.TextView[@text="Customs@SG"]    
    Expect Element    ${E-SERVICES-CUSTOMS-DECLARATION-HEADER-ELEM}    visible
    Close Android Chrome Browser

User is able to successfully search for a e-service
    [Documentation]     User is able to search for an e-service successfully
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-SEARCH-ICON}
    Type text               ${E-SERVICES-SEARCH-INPUT}    ${CORRECT-E-SERVICES-INPUT}
    ## two options should be shown 
    Xpath Should Match X Times    //android.view.ViewGroup[@resource-id="card-container"]   2
    Expect Element    ${E-SERVICES-REPORT-LOST-PASSPORT-SEARCH-RES}    visible
    Expect Element    ${E-SERVICES-REPORT-LOST-IC-SEARCH-RES}    visible

User is able to unsuccessfully search for a e-service
    [Documentation]     User is unable to search for an e-service when using a string that dont match any of the e-services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-SEARCH-ICON}
    Type text               ${E-SERVICES-SEARCH-INPUT}    ${WRONG-E-SERVICES-INPUT}
    ## two options should be shown 
    Xpath Should Match X Times    //android.view.ViewGroup[@resource-id="card-container"]    0
