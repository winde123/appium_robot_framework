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

User is able to create foreigner profile
    [Documentation]     this tests creation workflow for foreigner profile
    ${PROFILE}=    manual_field_random.Generate Profile Record
    # SGAC2.0 (build 2.0.0(17)) persona pins the country code to +61 (see the ${FOR-SGAC2-*}
    # persona block in Resources/ios/SGACcommands.robot). sgac1 keeps the generated record's
    # cty_code; uncomment the line below to force +61 for both forks:
    # Set To Dictionary    ${PROFILE}    cty_code=61
    Navigate to foreigner SGAC landing page
    Navigate to foreigner profile creation method page
    Fill foreigner profile form    ${PROFILE}
    Verify foreigner profile summary    ${PROFILE}
    Accept terms and save foreigner profile
