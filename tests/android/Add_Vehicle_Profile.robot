*** Settings ***
Library     AppiumLibrary
Resource    ../../Resources/commands.robot
Variables   ../../Data/landing_page.yaml
Variables    ../../Data/yaml_Cargo_pages/cargo_clearance_home_page.yaml
Variables    ../../Data/yaml_Cargo_pages/add_vehicle_page.yaml
Variables    ../../Data/yaml_Cargo_pages/vehicle_profiles_page.yaml
Test Teardown    Close Application

*** Variables ***


*** Keywords ***
create vehicle profile with arg
    [Documentation]     Creating vehicle profile in favorites-Cargo Clearance page(PASSPORT)
    Open Android App in emulator                appActivity=sg.gov.ica.mobile.app.MainActivity
    Sleep        3s
    Click On Element    ${CARGO-CLEARANCE-FAV-BUTTON}
    Click On Element    ${CARGO_CLEARANCE_PLUS_SIGN_BUTTON}
    Click On Element    ${PLUS_ADD_VEHICLE_PROFILE_BUTTON}
    #Edit text VehicleNo, passport, email
    Type Text        ${ADD_VEHICLE_VEHICLE_NUMBER_TEXT_FIELD}     ${test-data-vehicleNo.}
    Log            ${test-val-suite}

    # Evalutes if passport test case / nric test case needs to be created
    IF    "${test-val-suite}" == "passport"
        Log To Console  "Creating vehicle profile using passport No."
        Click On Element    ${ADD_VEHICLE_USE_PASSPORT_NUMBER_OPTION}
        Type Text      ${ADD_VEHICLE_PASSPORT_NUMBER_TEXT_FIELD}        ${test-data-passport-no}
        Type Text        ${ADD_VEHICLE_EMAIL_ADDRESS_TEXT_FIELD}       ${test-data-email}
        Click On Element    ${ADD_VEHICLE_SAVE_VEHICLE_PROFILE_BUTTON}

    ELSE IF    "${test-val-suite}" == "nric"
        Log To Console  "Creating vehicle profile using NRIC"
        Type Text        ${ADD_VEHICLE_NRIC_TEXT_FIELD}               ${test-data-nric}
        Type Text        ${ADD_VEHICLE_EMAIL_ADDRESS_TEXT_FIELD}       ${test-data-email}
        Click On Element    ${ADD_VEHICLE_SAVE_VEHICLE_PROFILE_BUTTON}
    END

#create test case using passport
#    [Documentation]     Creating vehicle profile in favorites-Cargo Clearance page(PASSPORT)
#    Open Android App in emulator                appActivity=sg.gov.ica.mobile.app.MainActivity
#    Sleep        3s
#    Click On Element    ${CARGO-CLEARANCE-FAV-BUTTON}
#    Click On Element    ${CARGO_CLEARANCE_PLUS_SIGN_BUTTON}
#    Click On Element    ${PLUS_ADD_VEHICLE_PROFILE_BUTTON}
#    #Edit text VehicleNo, passport, email
#    Type Text        ${ADD_VEHICLE_VEHICLE_NUMBER_TEXT_FIELD}     ${test-data-vehicleNo.}
#    Click On Element    ${ADD_VEHICLE_USE_PASSPORT_NUMBER_OPTION}
#    Type Text      ${ADD_VEHICLE_PASSPORT_NUMBER_TEXT_FIELD}        ${test-data-passport-no}
#    Type Text        ${ADD_VEHICLE_EMAIL_ADDRESS_TEXT_FIELD}       ${test-data-email}
#    Click On Element    ${ADD_VEHICLE_SAVE_VEHICLE_PROFILE_BUTTON}
#
#create test case using nric
#    [Documentation]     Creating vehicle profile in favorites-Cargo Clearance page(NRIC)
#    Open Android App in emulator                appActivity=sg.gov.ica.mobile.app.MainActivity
#    Sleep        3s
#    Click On Element    ${CARGO-CLEARANCE-FAV-BUTTON}
#    Click On Element    ${CARGO_CLEARANCE_PLUS_SIGN_BUTTON}
#    Click On Element    ${PLUS_ADD_VEHICLE_PROFILE_BUTTON}
#    #Edit text VehicleNo, NRIC, email
#    Type Text        ${ADD_VEHICLE_VEHICLE_NUMBER_TEXT_FIELD}     ${test-data-vehicleNo.}
#    Type Text        ${ADD_VEHICLE_NRIC_TEXT_FIELD}               ${test-data-nric}
#    Type Text        ${ADD_VEHICLE_EMAIL_ADDRESS_TEXT_FIELD}       ${test-data-email}
#    Click On Element    ${ADD_VEHICLE_SAVE_VEHICLE_PROFILE_BUTTON}

*** Test Cases ***
test case 1        #SG_BC_MHA_SGAC-414
    [Documentation]     Creating vehicle profile in favorites-Cargo Clearance page(NRIC)
    Set Suite Variable    ${test-val-suite}        nric
    Create Vehicle Profile With Arg

test case 2        #SG_BC_MHA_SGAC-419
    [Documentation]    Editing vehicle profile in favorites- Cargo clearance page -passport Number
    #Creating test case with NRIC field
    Create Vehicle Profile With Arg
    Click On Element    ${VEHICLES_PROFILE_ICON}
    Click On Element    //android.view.ViewGroup[@content-desc="${test-data}"]/android.view.ViewGroup
    Click On Element    ${EDIT_BUTTON}
    Click On Element    ${ADD_VEHICLE_USE_PASSPORT_NUMBER_OPTION}
    #Add passport number
    Type Text      ${ADD_VEHICLE_PASSPORT_NUMBER_TEXT_FIELD}        ${test-data-passport-no}
    Click On Element    ${ADD_VEHICLE_SAVE_VEHICLE_PROFILE_BUTTON}
    Wait Until Page Contains Element    //android.widget.TextView[@text="${test-data-passport-no}"]  timeout=10s
    Element Should Contain Text    //android.widget.TextView[@text="${test-data-passport-no}"]    ${test-data-passport-no}

test case 3    #SG_BC_MHA_SGAC-417
    [Documentation]    Editing vehicle profile in favorites- Cargo clearance page - nric No.
    #Creating test case with passport field
    Set Suite Variable    ${test-val-suite}        passport
    Create Vehicle Profile With Arg
    Click On Element    ${VEHICLES_PROFILE_ICON}
    Click On Element    //android.view.ViewGroup[@content-desc="${test-data1}"]/android.view.ViewGroup
    Click On Element    ${EDIT_BUTTON}
    Click On Element    ${ADD_VEHICLE_USE_NRIC_OPTION}
    Type Text        ${ADD_VEHICLE_NRIC_TEXT_FIELD}               ${test-data-nric}
    Click On Element    ${ADD_VEHICLE_SAVE_VEHICLE_PROFILE_BUTTON}
#Assert
    Wait Until Page Contains Element    //android.widget.TextView[@text="*****773A"]  timeout=10s
    Element Should Contain Text    //android.widget.TextView[@text="*****773A"]    *****773A

test case 4
    [Documentation]    Testing invalid vehicle number
    Open Android App in emulator                appActivity=sg.gov.ica.mobile.app.MainActivity
    Sleep        3s
    Click On Element    ${CARGO-CLEARANCE-FAV-BUTTON}
    Click On Element    ${CARGO_CLEARANCE_PLUS_SIGN_BUTTON}
    Click On Element    ${PLUS_ADD_VEHICLE_PROFILE_BUTTON}
    Click On Element    ${ADD_VEHICLE_VEHICLE_NUMBER_TEXT_FIELD}
    Type Text        ${ADD_VEHICLE_VEHICLE_NUMBER_TEXT_FIELD}      ${test-data-invalid-vehicleNo}
    Press Keycode       42
    Click On Element     ${ADD_VEHICLE_VEHICLE_NUMBER_TEXT_FIELD}
    Click On Element    ${ADD_VEHICLE_NRIC_TEXT_FIELD}
    Type Text        ${ADD_VEHICLE_NRIC_TEXT_FIELD}               ${test-data-nric}
    Click On Element     ${ADD_VEHICLE_EMAIL_ADDRESS_TEXT_FIELD}
    Type Text         ${ADD_VEHICLE_EMAIL_ADDRESS_TEXT_FIELD}    ${test-data-email}
    Wait Until Page Contains Element    //android.widget.TextView[@text="VEHICLE COULD NOT BE VALIDATED"]    timeout=3s
    Element Attribute Should Match    //android.widget.TextView[@text="VEHICLE COULD NOT BE VALIDATED"]    text  VEHICLE COULD NOT BE VALIDATED
    Hide Keyboard    key_name=none
    Click On Element    ${ADD_VEHICLE_SAVE_VEHICLE_PROFILE_BUTTON}

test case 5
    [Documentation]    Deleting vehicle profile
    #Creating vehicle profile with NRIC
    Set Suite Variable    ${test-val-suite}        nric
    create vehicle profile with arg
    Click On Element    ${VEHICLES_PROFILE_ICON}
    Wait Until Page Contains Element     //android.view.ViewGroup[@content-desc="${test-data}"]/android.view.ViewGroup
    Click On Element    //android.view.ViewGroup[@content-desc="${test-data}"]/android.view.ViewGroup
    Click On Element    ${DELETE_PROFILE}
    Click On Element    //android.widget.Button[@resource-id="android:id/button1"]
    Wait Until Page Contains Element    //android.view.ViewGroup[@content-desc="No vehicle profiles"]
    Element Attribute Should Match    //android.widget.TextView[@text="No vehicle profiles"]    text        No vehicle profiles