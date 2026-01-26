*** Settings ***
Library     AppiumLibrary
Library     ../../Resources/ios_appium_commands.py
Resource    ../../Resources/commands.robot
Variables   ../../Data/ios/landing_page.yaml
Test Setup       Open ios App on device 
Test Teardown    ios_appium_commands.Terminate App

*** Test Cases *** 

Verification of visibility of the scam banner and navigation via the banner
    [Documentation]    to verify visbiliy and functionality of scam banner
    Click on element    ${MYICA-SCAM-BANNER}
    Expect Element      ${MYICA-SCAM-BANNER-HEADER-ELEM}    visible
    Close iOS Chrome Browser
