*** Settings ***
Library     AppiumLibrary
#Library     AutoRecorder    mode=suite
Library     ../../Resources/ios_appium_commands.py
Resource    ../../Resources/commands.robot
#Suite Setup     Start iOS Device Recording
#Suite Teardown    Stop iOS Device Recording
Variables   ../../Data/ios/landing_page.yaml
Variables   ../../Data/ios/other_e_services/other_e_services_page.yaml
Variables    ../../Data/ios/other_e_services/passport_IC_page.yaml
Variables    ../../Data/ios/other_e_services/sgac_epass_enquiry.yaml
Variables    ../../Data/test_data/input_fields_test_data.yaml
Test Setup       Open ios App on device 
Test Teardown    ios_appium_commands.Terminate App

*** Test Cases *** 
Navigating to e-services page via the favorite icons
    [Documentation]     Navigate on other e-services via the other e-services fav icon
    #Open ios App on device 
    #Start Screen Recording   
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    10
    #Stop Screen Recording

Navigating to customs@SG page
    [Documentation]     appt services
    #Start Screen Recording
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-CUSTOMS-DECLARATION}
    Expect Element    ${E-SERVICES-CUSTOMS-DECLARATION-HEADER-ELEM}    visible
    Close iOS Chrome Browser
    #Stop Screen Recording

User is able to successfully search for a e-service
    [Documentation]     User is able to search for an e-service successfully
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-SEARCH-ICON}
    Type text               ${E-SERVICES-SEARCH-INPUT}    ${CORRECT-E-SERVICES-INPUT}
    ## two options should be shown 
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    2
    Expect Element    ${E-SERVICES-REPORT-LOST-PASSPORT-SEARCH-RES}    visible
    Expect Element    ${E-SERVICES-REPORT-LOST-IC-SEARCH-RES}    visible

User is able to unsuccessfully search for a e-service
    [Documentation]     User is unable to search for an e-service when using a string that dont match any of the e-services
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${E-SERVICES-SEARCH-ICON}
    Type text               ${E-SERVICES-SEARCH-INPUT}    ${WRONG-E-SERVICES-INPUT}
    ## two options should be shown 
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    0




