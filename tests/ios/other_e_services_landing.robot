*** Settings ***
Library     AppiumLibrary
Library     ../../Resources/ios_appium_commands.py
Resource    ../../Resources/commands.robot
Variables   ../../Data/ios/landing_page.yaml
Variables   ../../Data/ios/other_e_services/other_e_services_page.yaml
Variables    ../../Data/ios/other_e_services/passport_IC_page.yaml
Variables    ../../Data/ios/other_e_services/sgac_epass_enquiry.yaml
Test Setup       Open ios App on device 
Test Teardown    ios_appium_commands.Terminate App

*** Test Cases *** 
Navigating to e-services page
    [Documentation]     Navigate on other e-services via the other e-services fav icon
    #Open ios App on device    
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    10

