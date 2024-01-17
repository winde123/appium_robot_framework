*** Settings ***
Library     AppiumLibrary
Library    ../../Resources/helper_func.py
Library    ../../Data/test_data/manual_field_random.py    
Resource    ../../Resources/commands.robot
Variables   ../../Data/landing_page.yaml
Variables    ../../Data/test_data/manual_field_random.py
Test Teardown    Close Application

*** Variables ***

*** Test Cases ***
test case 1
    [Documentation]     Straight through case of creating personal passport qr code manually
    Open Android App in emulator                appActivity=sg.gov.ica.mobile.app.MainActivity