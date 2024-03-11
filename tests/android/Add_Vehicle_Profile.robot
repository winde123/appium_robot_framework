*** Settings ***
Library     AppiumLibrary
Library     String
Library    ../../Data/test_data/manual_field_random.py
Library    ../../Resources/helper_func.py
Resource    ../../Resources/commands.robot
Variables    ../../Data/test_data/input_fields_test_data.yaml
Variables   ../../Data/landing_page.yaml
Variables    ../../Data/yaml_Cargo_pages/cargo_clearance_home_page.yaml
Variables    ../../Data/yaml_Cargo_pages/add_vehicle_page.yaml
Variables    ../../Data/yaml_Cargo_pages/vehicle_profiles_page.yaml
Test Teardown    Close Application

*** Variables ***
${xpath-kebab-menu-display-text}       //android.widget.TextView[@text="
${xpath-kebab-menu}    //android.view.ViewGroup[@content-desc="
${xpath-kebab-menu-2}    /android.view.ViewGroup

*** Keywords ***

Create vehicle profile with arg

    [Arguments]    ${field-val}
    [Documentation]     Creating vehicle profile in favorites-Cargo Clearance page(PASSPORT)
    Click On Element    ${CARGO-CLEARANCE-FAV-BUTTON}
    Click On Element    ${CARGO_CLEARANCE_PLUS_SIGN_BUTTON}
    Click On Element    ${PLUS_ADD_VEHICLE_PROFILE_BUTTON}
    #Edit text VehicleNo, passport, email
    Type Text        ${ADD_VEHICLE_NUMBER_TEXT_FIELD}     ${VEHICLENO-TEST-DATA}

    # Evalutes if passport test case / nric test case needs to be created
    IF    "${field-val}" == "passport"
        Log To Console  "Creating vehicle profile using passport No."
        Click On Element    ${ADD_VEHICLE_USE_PASSPORT_NUMBER_OPTION}
        ${passport-testdata}=   manual_field_random.generaterandomPPNumber
        Type Text      ${ADD_VEHICLE_PASSPORT_NUMBER_TEXT_FIELD}        ${passport-testdata}
        Type Text        ${ADD_VEHICLE_EMAIL_ADDRESS_TEXT_FIELD}       ${EMAIL-TEST-DATA}
        Click On Element    ${ADD_VEHICLE_SAVE_VEHICLE_PROFILE_BUTTON}
        RETURN     ${passport-testdata}

    ELSE IF    "${field-val}" == "nric"
        Log To Console  "Creating vehicle profile using NRIC"
        ${nric-testdata}=   manual_field_random.generaterandomNRIC
        Type Text        ${ADD_VEHICLE_NRIC_TEXT_FIELD}               ${nric-testdata}
        Type Text        ${ADD_VEHICLE_EMAIL_ADDRESS_TEXT_FIELD}       ${EMAIL-TEST-DATA}
        Click On Element    ${ADD_VEHICLE_SAVE_VEHICLE_PROFILE_BUTTON}
        RETURN    ${nric-testdata}
    END

*** Test Cases ***
test case 1        #SG_BC_MHA_SGAC-414
    
    [Documentation]     Creating vehicle profile in favorites-Cargo Clearance page(NRIC)
    Open Android App in emulator                appActivity=sg.gov.ica.mobile.app.MainActivity
    Sleep    3s
    Create Vehicle Profile With arg    nric

test case 2        #SG_BC_MHA_SGAC-419

    [Documentation]    Editing vehicle profile in favorites- Cargo clearance page -passport Number
    #Creating test case with NRIC field
    Open Android App in emulator                appActivity=sg.gov.ica.mobile.app.MainActivity
    Sleep        3s
    ${nric-testdata}=     Create Vehicle Profile With Arg        nric
    ${masked-nric}=    helper_func.masking_string    ${nric-testdata}
    Click On Element    ${VEHICLES_PROFILE_ICON}
    ${xpath-kebabmenu}=    Catenate    SEPARATOR=    ${xpath-kebab-menu}   ${VEHICLENO-TEST-DATA}  ,    ${SPACE}  ${masked-nric}   "]    ${xpath-kebab-menu-2}
    Click On Element     ${xpath-kebabmenu}
    Click On Element    ${EDIT_BUTTON}
    Click On Element    ${ADD_VEHICLE_USE_PASSPORT_NUMBER_OPTION}
    #Add passport number
    ${passport-testdata}=  manual_field_random.generaterandomPPNumber
    Type Text      ${ADD_VEHICLE_PASSPORT_NUMBER_TEXT_FIELD}        ${passport-testdata}
    Click On Element    ${ADD_VEHICLE_SAVE_VEHICLE_PROFILE_BUTTON}
    ${passport-kebab-menu}=       Catenate    SEPARATOR=    ${xpath-kebab-menu-display-text}    ${passport-testdata}    "]
    Wait Until Page Contains Element    ${passport-kebab-menu}    timeout=5s
    ${passport-kebab-menu-display-text}=    Catenate    SEPARATOR=    ${xpath-kebab-menu-display-text}    ${passport-testdata}  "]
    Element Should Contain Text     ${passport-kebab-menu-display-text}      ${passport-testdata}
    

test case 3    #SG_BC_MHA_SGAC-417
    [Documentation]    Editing vehicle profile in favorites- Cargo clearance page - nric No.
    Open Android App in emulator                appActivity=sg.gov.ica.mobile.app.MainActivity
    Sleep        3s
    #Creating test case with passport field
    ${passport-testdata}=    Create Vehicle Profile With Arg    passport
    Click On Element    ${VEHICLES_PROFILE_ICON}
    ${xpath-kebabmenu-passport}=    Catenate    SEPARATOR=    ${xpath-kebab-menu}    ${VEHICLENO-TEST-DATA}     ,    ${SPACE}     ${passport-testdata}   "]    ${xpath-kebab-menu-2}
    Click On Element    ${xpath-kebabmenu-passport}
    Click On Element    ${EDIT_BUTTON}
    Click On Element    ${ADD_VEHICLE_USE_NRIC_OPTION}
    ${nric-testdata}=   manual_field_random.generaterandomNRIC
    Type Text        ${ADD_VEHICLE_NRIC_TEXT_FIELD}               ${nric-testdata}
    ${masked-nric}=    helper_func.masking_string    ${nric-testdata}
    ${VEHICLENO-JOIN-NRIC}=    Catenate    SEPARATOR=    ${VEHICLENO-TEST-DATA}    ,    ${SPACE}    ${masked-nric}
    ${xpath-kebabmenu-nric}=    Catenate    SEPARATOR=    ${xpath-kebab-menu}       ${VEHICLENO-JOIN-NRIC}    "]
    Click On Element    ${ADD_VEHICLE_SAVE_VEHICLE_PROFILE_BUTTON}
#Assert
    Wait Until Page Contains Element      ${xpath-kebabmenu-nric}  timeout=10s
    Element Attribute Should Match    ${xpath-kebabmenu-nric}    content-desc    ${VEHICLENO-JOIN-NRIC}


test case 4
    [Documentation]    testing with invalid vehicle number

    Open Android App in emulator                appActivity=sg.gov.ica.mobile.app.MainActivity
    Sleep        3s
    Click On Element    ${CARGO-CLEARANCE-FAV-BUTTON}
    Click On Element    ${CARGO_CLEARANCE_PLUS_SIGN_BUTTON}
    Click On Element    ${PLUS_ADD_VEHICLE_PROFILE_BUTTON}
    Click On Element    ${ADD_VEHICLE_NUMBER_TEXT_FIELD}
    Type Text        ${ADD_VEHICLE_NUMBER_TEXT_FIELD}      ${INVALID-VEHICLENO-TEST-DATA}
    Press Keycode       42
    Click On Element     ${ADD_VEHICLE_NUMBER_TEXT_FIELD}
    Click On Element    ${ADD_VEHICLE_NRIC_TEXT_FIELD}
    ${nric-testdata}=   manual_field_random.generaterandomNRIC
    Type Text        ${ADD_VEHICLE_NRIC_TEXT_FIELD}               ${nric-testdata}
    Click On Element     ${ADD_VEHICLE_EMAIL_ADDRESS_TEXT_FIELD}
    Type Text         ${ADD_VEHICLE_EMAIL_ADDRESS_TEXT_FIELD}    ${EMAIL-TEST-DATA}
    Wait Until Page Contains Element    ${INVALIDATE_VEHICLES_TEXTFIELD}    timeout=3s
    Element Attribute Should Match    ${INVALIDATE_VEHICLES_TEXT_FIELD}    text  VEHICLE COULD NOT BE VALIDATED
    Hide Keyboard    key_name=none
    Click On Element    ${ADD_VEHICLE_SAVE_VEHICLE_PROFILE_BUTTON}

test case 5
    [Documentation]    Deleting vehicle profile
    #Creating vehicle profile with NRIC
    Open Android App in emulator                appActivity=sg.gov.ica.mobile.app.MainActivity
    Sleep        3s
    ${nric-testdata}=     create vehicle profile with arg     nric
    ${masked-nric}=    helper_func.masking_string    ${nric-testdata}
    Click On Element    ${VEHICLES_PROFILE_ICON}
    ${xpath-kebabmenu}=    Catenate    SEPARATOR=    ${xpath-kebab-menu}    ${VEHICLENO-TEST-DATA}    ,    ${SPACE}    ${masked-nric}    "]    ${xpath-kebab-menu-2}
    Wait Until Page Contains Element      ${xpath-kebabmenu}
    Click On Element     ${xpath-kebabmenu}
    Click On Element    ${DELETE_PROFILE}
    Click On Element    ${DELETE_PROFILE_BUTTON}
    Wait Until Page Contains Element    ${NO_VEHICLE_PROFILES_TEXT_FIELD}
    Element Attribute Should Match      ${NO_VEHICLE_PROFILES_TEXT_FIELD}   content-desc        No vehicle profiles