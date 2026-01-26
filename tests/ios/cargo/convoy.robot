*** Settings ***
Library     AppiumLibrary
Library     Collections
Library     String
Library    ../../../Data/test_data/manual_field_random.py
Library     ../../../Resources/ios_appium_commands.py
Resource    ../../../Resources/commands.robot
Variables    ../../../Data/ios/ios_common_selectors.yaml
Variables    ../../../Data/test_data/input_fields_test_data.yaml
Variables   ../../../Data/ios/landing_page.yaml
Variables    ../../../Data/ios/cargo/cargo_landing_page.yaml
Variables    ../../../Data/ios/cargo/cargo_convoy_page.yaml
Variables    ../../../Data/ios/cargo/cargo_convoy_form_page.yaml
Variables    ../../../Data/ios/cargo/cargo_permit_form_page.yaml
Variables    ../../../Data/ios/cargo/cargo_sub_res_page.yaml
Variables    ../../../Data/test_data/manual_field_random.py
Test Setup       Open ios App on device 
#Test Teardown    ios_appium_commands.Terminate App

*** Test Cases ***

User create convoy with 15 veh and 100 permits
    [Documentation]    user creates convoy with 100 permits
    Click on element    ${CARGO-CLEARANCE-FAV-BUTTON}
    Click on element    ${CARGO-CONVOY-SHORTCUT-BTN}
    Click on element    ${CARGO-CONVOY-ADD-SUBMISSION-BUTTON}
    ## generating a list of email vehicle number
    @{VEH-LIST}=     manual_field_random.Generate Listof Vehno        ${VEH-NUM}
    @{PERMIT-NO-LIST}=     manual_field_random.Generate Listof Permit   ${PERMIT-NUM} 
    #Log Many    @{PERMIT-NO-LIST}
    Type text           ${CARGO-CONVOY-FORM-EMAIL-INPUT}      ${EMAIL}
    FOR    ${NTH-VEH}    IN RANGE        ${VEH-NUM}
        Type text    ${CARGO-CONVOY-FORM-VEHICLE-NUMBER-INPUT}    ${VEH-LIST}[${NTH-VEH}]
        Click on element    ${CARGO-CONVOY-FORM-MOBILE-INPUT}
    END
    Click on element    ${KEYBOARD-DONE-BTN}
    Click on element    ${CARGO-CONVOY-FORM-NEXT-BUTTON}
    
    FOR    ${NTH-PERMIT}    IN RANGE        ${PERMIT-NUM}
        Click on element    ${CARGO-ADD-PERMIT-BTN}
        Click on element    ${MANUAL-INPUT-PERMIT-BTN}
        
        Type text    ${PERMIT-NO-INPUT-FIELD}    ${PERMIT-NO-LIST}[${NTH-PERMIT}]
        Click on element    ${KEYBOARD-DONE-BTN}

        Click on element    ${SAVE-PERMIT-BTN}
    END
    Click on element    ${SUBMIT-CARGO-CONVOY-BTN}
    Type text    ${CAPTCHA-INPUT-FIELD}    ${CAPTCHA-STR}
    Click on element    ${KEYBOARD-DONE-BTN}

    Click on element    ${CAPTCHA-VERIFY-BTN}
    Expect Element    xpath=${CARGO-SUCCESS-TEXT}    visible

