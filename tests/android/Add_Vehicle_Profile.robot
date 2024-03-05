*** Settings ***
Library     AppiumLibrary
Resource    ../../Resources/commands.robot
Variables   ../../Data/landing_page.yaml
Variables    ../../Data/yaml_Cargo_pages/cargo_clearance_home_page.yaml
Variables    ../../Data/yaml_Cargo_pages/add_vehicle_page.yaml
Variables    ../../Data/yaml_Cargo_pages/vehicle_profiles_page.yaml
Test Teardown    Close Application
#Test Setup        Open Android App In Emulator    appActivity=sg.gov.ica.mobile.app.MainActivity

*** Variables ***
${test-val}        nric
*** Keywords ***
create test case with arg
    [Documentation]     Creating vehicle profile in favorites-Cargo Clearance page(PASSPORT)
    Open Android App in emulator                appActivity=sg.gov.ica.mobile.app.MainActivity
    Sleep        3s
    Click On Element    ${CARGO-CLEARANCE-FAV-BUTTON}
    Click On Element    ${CARGO_CLEARANCE_PLUS_SIGN_BUTTON}
    Click On Element    ${PLUS_ADD_VEHICLE_PROFILE_BUTTON}
    #Edit text VehicleNo, passport, email
    Type Text        ${ADD_VEHICLE_VEHICLE_NUMBER_TEXT_FIELD}     ${test-data-vehicleNo.}
    # Evalutes if passport test case / nric test case needs to be created
    IF    "${test-val}" == "passport"
        Log To Console    "here passport"
        Click On Element    ${ADD_VEHICLE_USE_PASSPORT_NUMBER_OPTION}
        Type Text      ${ADD_VEHICLE_PASSPORT_NUMBER_TEXT_FIELD}        ${test-data-passport-no}
        Type Text        ${ADD_VEHICLE_EMAIL_ADDRESS_TEXT_FIELD}       ${test-data-email}
        Click On Element    ${ADD_VEHICLE_SAVE_VEHICLE_PROFILE_BUTTON}
    ELSE IF    "${test-val}" == "nric"
        Log To Console    "here to nric"
        Type Text        ${ADD_VEHICLE_VEHICLE_NUMBER_TEXT_FIELD}     ${test-data-vehicleNo.}
        Type Text        ${ADD_VEHICLE_NRIC_TEXT_FIELD}               ${test-data-nric}
        Type Text        ${ADD_VEHICLE_EMAIL_ADDRESS_TEXT_FIELD}       ${test-data-email}
        Click On Element    ${ADD_VEHICLE_SAVE_VEHICLE_PROFILE_BUTTON}
    END

create test case using passport
    [Documentation]     Creating vehicle profile in favorites-Cargo Clearance page(PASSPORT)
    Open Android App in emulator                appActivity=sg.gov.ica.mobile.app.MainActivity
    Sleep        3s
    Click On Element    ${CARGO-CLEARANCE-FAV-BUTTON}
    Click On Element    ${CARGO_CLEARANCE_PLUS_SIGN_BUTTON}
    Click On Element    ${PLUS_ADD_VEHICLE_PROFILE_BUTTON}
    #Edit text VehicleNo, passport, email
    Type Text        ${ADD_VEHICLE_VEHICLE_NUMBER_TEXT_FIELD}     ${test-data-vehicleNo.}
    Click On Element    ${ADD_VEHICLE_USE_PASSPORT_NUMBER_OPTION}
    Type Text      ${ADD_VEHICLE_PASSPORT_NUMBER_TEXT_FIELD}        ${test-data-passport-no}
    Type Text        ${ADD_VEHICLE_EMAIL_ADDRESS_TEXT_FIELD}       ${test-data-email}
    Click On Element    ${ADD_VEHICLE_SAVE_VEHICLE_PROFILE_BUTTON}
    
create test case using nric
    [Documentation]     Creating vehicle profile in favorites-Cargo Clearance page(NRIC)
    Open Android App in emulator                appActivity=sg.gov.ica.mobile.app.MainActivity
    Sleep        3s
    Click On Element    ${CARGO-CLEARANCE-FAV-BUTTON}
    Click On Element    ${CARGO_CLEARANCE_PLUS_SIGN_BUTTON}
    Click On Element    ${PLUS_ADD_VEHICLE_PROFILE_BUTTON}
    #Edit text VehicleNo, NRIC, email
    Type Text        ${ADD_VEHICLE_VEHICLE_NUMBER_TEXT_FIELD}     ${test-data-vehicleNo.}
    Type Text        ${ADD_VEHICLE_NRIC_TEXT_FIELD}               ${test-data-nric}
    Type Text        ${ADD_VEHICLE_EMAIL_ADDRESS_TEXT_FIELD}       ${test-data-email}
    Click On Element    ${ADD_VEHICLE_SAVE_VEHICLE_PROFILE_BUTTON}

*** Test Cases ***
test case 1        #SG_BC_MHA_SGAC-414
    [Documentation]     Creating vehicle profile in favorites-Cargo Clearance page(NRIC)
    Set Local Variable    ${test-val}        nric
    create test case with arg

test case 2        #SG_BC_MHA_SGAC-419
    [Documentation]    Editing vehicle profile in favorites- Cargo clearance page -passport Number
    Set Local Variable    ${test-val}        nric
    Log To Console    test value is ${test-val}
    create test case with arg
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
    Set Local Variable        ${test-val}        passport
    create test case with arg
    Click On Element    ${VEHICLES_PROFILE_ICON}
    Click On Element    //android.view.ViewGroup[@content-desc="${test-data1}"]/android.view.ViewGroup
    Click On Element    ${EDIT_BUTTON}
    Click On Element    ${ADD_VEHICLE_USE_NRIC_OPTION}
    Type Text        ${ADD_VEHICLE_NRIC_TEXT_FIELD}               ${test-data-nric}
    Click On Element    ${ADD_VEHICLE_SAVE_VEHICLE_PROFILE_BUTTON}
#Assert
    Wait Until Page Contains Element    //android.widget.TextView[@text="*****773A"]  timeout=10s
    Element Should Contain Text    //android.widget.TextView[@text="*****773A"]    *****773A


    
    

        
          