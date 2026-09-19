*** Settings ***
Documentation    SGAC2.0-only foreigner profile creation. SGAC1.0 Android has no
...    dedicated foreigner locator tree, so this suite is tagged fork:sgac2-only.
Variables    ../../../Resources/fork_config.py
Library     AppiumLibrary
Library     Collections
Library     ../../../Data/test_data/manual_field_random.py
Resource    ../../../Resources/commands.robot
Resource    ../../../Resources/android/SGACcommands.robot
Force Tags    fork:sgac2-only
Test Setup       Open MyICA App on Android Emulator
Test Teardown    Close Application

*** Test Cases ***

User is able to create foreigner profile
    [Documentation]    Straight-through manual creation of a foreigner profile on sgac2.
    ${PROFILE}=    manual_field_random.Generate Profile Record
    # Pin the country code to the Australian persona (+61 on the summary, as in the build-15 evidence)
    Set To Dictionary    ${PROFILE}    cty_code=${FOREIGNER-COUNTRY-CODE}
    Navigate to foreigner SGAC landing page
    Navigate to foreigner profile creation method page
    Fill foreigner profile form    ${PROFILE}
    Verify foreigner profile summary    ${PROFILE}
    Accept terms and save foreigner profile
