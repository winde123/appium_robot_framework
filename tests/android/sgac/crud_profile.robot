*** Settings ***
Variables    ../../../Resources/fork_config.py
Library     AppiumLibrary
Library     String
Library     ../../../Data/test_data/manual_field_random.py
Resource    ../../../Resources/commands.robot
Resource    ../../../Resources/android/SGACcommands.robot
Force Tags    fork:both
Test Setup       Open MyICA App on Android Emulator
Test Teardown    Close Application

*** Test Cases ***

User is able create resident profile
    [Documentation]   Straight-through manual creation of a resident profile on sgac1 and sgac2.
    ${PROFILE}=    manual_field_random.Generate Profile Record    country=SG
    Navigate to resident SGAC landing page
    Navigate to resident profile creation method page
    Fill resident profile form    ${PROFILE}
    Verify resident profile summary    ${PROFILE}
    Accept terms and save resident profile

