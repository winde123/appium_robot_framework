*** Settings ***
Variables   ../../Resources/fork_config.py
Library     AppiumLibrary
Library     ../../Resources/ios_appium_commands.py
Resource    ../../Resources/commands.robot
Variables   ${FORK_DATA_DIR}/ios/landing_page.yaml
Force Tags       fork:both
Test Setup       Open MyICA App on iOS Device 
Test Teardown    ios_appium_commands.Terminate App

*** Test Cases *** 

Verification of visibility of the scam banner and navigation via the banner
    [Documentation]    to verify visbiliy and functionality of scam banner
    Click on element    ${MYICA-SCAM-BANNER}
    Expect Element      ${MYICA-SCAM-BANNER-HEADER-ELEM}    visible
    Close iOS Chrome Browser
