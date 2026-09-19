*** Settings ***
Variables   ../../../Resources/fork_config.py
Library     AppiumLibrary
Library     String
Library     ../../../Resources/ios_appium_commands.py
Library     ../../../Data/test_data/manual_field_random.py
Resource    ../../../Resources/commands.robot
Resource    ../../../Resources/ios/SGACcommands.robot
Force Tags       fork:both
Test Setup       Open MyICA App on iOS Device 
Test Teardown    ios_appium_commands.Terminate App

*** Test Cases ***

#User is able to create resident indv submssion with one trip successfully
User is able create resident profile
    [Documentation]   this tc is to do a straight through flow of indv user submssion
    ${PROFILE}=    manual_field_random.Generate Profile Record    country=SG
    Navigate to resident SGAC landing page
    Navigate to resident profile creation method page
    Fill resident profile form    ${PROFILE}
    Verify resident profile summary    ${PROFILE}
    Accept terms and save resident profile
