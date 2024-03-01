*** Settings ***
Library     AppiumLibrary
Resource    ../../Resources/commands.robot
Variables   ../../Data/landing_page.yaml
Variables    ../../Data/yaml_Cargo_pages/cargo_clearance_home_page.yaml
Variables    ../../Data/yaml_Cargo_pages/add_vehicle_page.yaml
Variables    ../../Data/yaml_Cargo_pages/vehicle_profiles_page.yaml
Test Teardown    Close Application
Test Setup        Open Android App In Emulator    appActivity=sg.gov.ica.mobile.app.MainActivity

*** Keywords ***
test case 1_key
    [Documentation]     Adding vehicle profile in favorites-Cargo Clearance page
    #Open Android App in emulator                appActivity=sg.gov.ica.mobile.app.MainActivity
    Sleep        3s

    Click On Element    ${CARGO-CLEARANCE-FAV-BUTTON}
    Click On Element    ${CARGO_CLEARANCE_PLUS_SIGN_BUTTON}
    Click On Element    ${PLUS_ADD_VEHICLE_PROFILE_BUTTON}

    #Edit text VehicleNo, NRIC, email
    Type Text        ${ADD_VEHICLE_VEHICLE_NUMBER_TEXT_FIELD}     ${test-data-vehicleNo.}
    Type Text        ${ADD_VEHICLE_NRIC_TEXT_FIELD}               ${test-data-nric}
    Type Text        ${ADD_VEHICLE_EMAIL_ADDRESS_TEXT_FIELD}       ${test-data-email}
    Click On Element    ${ADD_VEHICLE_SAVE_VEHICLE_PROFILE_BUTTON}
    Sleep        3s
*** Test Cases ***
test case 1
    Test Case 1_key


test case 2
    [Documentation]    Editing vehicle profile in favorites- Cargo clearance page using passport Number
    #Open Android App in emulator                appActivity=sg.gov.ica.mobile.app.MainActivity
    Test Case 1_key
    Sleep     3s
    #Click On Element    ${CARGO-CLEARANCE-FAV-BUTTON}
    Click On Element    ${VEHICLES_PROFILE_ICON}
    Click On Element    //android.view.ViewGroup[@content-desc="${test-data}"]/android.view.ViewGroup
    Click On Element    ${EDIT_BUTTON}


        
          