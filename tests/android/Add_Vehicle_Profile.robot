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
Variables    ../../Data/yaml_Cargo_pages/cargo_convoy_page.yaml
Variables    ../../Data/yaml_Cargo_pages/add_permit_page.yaml
Test Teardown    Close Application

*** Variables ***
${xpath-kebab-menu-display-text}       //android.widget.TextView[@text="
${xpath-kebab-menu}    //android.view.ViewGroup[@content-desc="
${xpath-kebab-menu-2}    /android.view.ViewGroup

*** Keywords ***
test_keyword       
    
    ${element_size}=    Get Element Size    ${ADD_PERMIT_BUTTON}
    ${element_location}=    Get Element Location    ${ADD_PERMIT_BUTTON}
    ${start_x}=         Evaluate      ${element_location['x']} + (${element_size['width']} * 0.5)
    ${start_y}=         Evaluate      ${element_location['y']} + (${element_size['height']} * 0.3)
    ${end_x}=           Evaluate      ${element_location['x']} + (${element_size['width']} * 0.5)
    ${end_y}=           Evaluate      ${element_location['y']} + (${element_size['height']} * 0.7)
    Log To Console     ${start_y}     ${end_y}
    Log To Console    ${start_x}    ${end_x}
    Swipe               ${start_x}    ${start_y}  ${end_x}  ${end_y}  500
    Sleep  1

Create vehicle profile with arg

    [Arguments]    ${field-val}
    [Documentation]     Creating vehicle profile in favorites-Cargo Clearance page(PASSPORT)
    Scroll Down On The Screen
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
    Scroll Down On The Screen
    Sleep    3s

    Click On Element    ${CARGO-CLEARANCE-FAV-BUTTON}
    Click On Element    ${CARGO_CLEARANCE_PLUS_SIGN_BUTTON}
    Click On Element    ${PLUS_ADD_VEHICLE_PROFILE_BUTTON}
    Click On Element    ${ADD_VEHICLE_NUMBER_TEXT_FIELD}
    Type Text        ${ADD_VEHICLE_NUMBER_TEXT_FIELD}      ${INVALID-VEHICLENO-TEST-DATA}
    Press Keycode       66
    #Click On Element     ${ADD_VEHICLE_NUMBER_TEXT_FIELD}
    Click On Element    ${ADD_VEHICLE_NRIC_TEXT_FIELD}
    ${nric-testdata}=   manual_field_random.generaterandomNRIC
    Type Text        ${ADD_VEHICLE_NRIC_TEXT_FIELD}               ${nric-testdata}
    Press Keycode    66
    #Hide Keyboard    key_name=none
    Click On Element     ${ADD_VEHICLE_EMAIL_ADDRESS_TEXT_FIELD}
    Type Text         ${ADD_VEHICLE_EMAIL_ADDRESS_TEXT_FIELD}    ${EMAIL-TEST-DATA}
    Press Keycode    66
    Wait Until Page Contains Element    ${INVALIDATE_VEHICLES_TEXTFIELD}    timeout=3s
    Element Attribute Should Match    ${INVALIDATE_VEHICLES_TEXT_FIELD}    text  VEHICLE COULD NOT BE VALIDATED
    #Hide Keyboard    key_name=none
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

test case 6
    Open Android App in emulator                appActivity=sg.gov.ica.mobile.app.MainActivity
    Sleep    3s
    Scroll Down On The Screen
    
    Wait Until Keyword Succeeds    1 minute    10     Click On Element    ${CARGO-CLEARANCE-FAV-BUTTON}
    Click On Element    ${CARGO_CLEARANCE_PLUS_SIGN_BUTTON}
    #Sleep     3s
    Click On Element    ${PLUS_NEW_CONVOY_SUBMISSION_BUTTON}
    ${nric-testdata}=   manual_field_random.generaterandomNRIC

    Click On Element     ${CARGO_CONVOY_NRIC_TEXT_FIELD}   
    Type Text    ${CARGO_CONVOY_NRIC_TEXT_FIELD}    ${nric-testdata}
    Press Keycode    66

    Click On Element    ${CARGO_CONVOY_EMAIL_TEXT_FIELD}
    Type Text    ${CARGO_CONVOY_EMAIL_TEXT_FIELD}     ${EMAIL-TEST-DATA}
    Press Keycode    66

    Click On Element   ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}
    Type Text        ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}    SK1000K
    Press Keycode    66

    Click On Element   ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}
    Type Text        ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}    SK999K
    Press Keycode    66
    
    Click On Element   ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}
    Type Text        ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}    SK998M
    Press Keycode    66
    
    Click On Element    ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}
    Type Text        ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}    SK997R
    Press Keycode    66
    
    Click On Element    ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}
    Type Text        ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}    SK996T
    Press Keycode    66
    
    Click On Element    ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}
    Type Text        ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}    SK995X
    Press Keycode    66

    Click On Element    ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}
    Type Text        ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}    SK994Z
    Press Keycode    66

    Click On Element    ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}
    Type Text        ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}    SK993B
    Press Keycode    66

    Click On Element    ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}
    Type Text        ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}    SK997R
    Press Keycode    66

    Click On Element    ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}
    Type Text        ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}    SK992D
    Press Keycode    66

    Click On Element    ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}
    Type Text        ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}    SK3861D
    Press Keycode    66

    Click On Element    ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}
     Type Text        ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}    SK991G
    Press Keycode    66

    Click On Element    ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}
     Type Text        ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}    SK990J
    Press Keycode    66

    Click On Element    ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}
     Type Text        ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}    SK989P
    Press Keycode    66

    Click On Element    ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}
     Type Text        ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}    SK988S
    Press Keycode    66
    Click On Element    ${ADD_VEHICLE_NEXT_BUTTON}

    Click On Element    ${ADD_PERMIT_BUTTON}
    Click On Element    ${ALLOW_CAMERA_BUTTON}
    Click On Element    ${ENTER_PERMIT_NUMBER_MANUALLY_BUTTON}
     Sleep    5s

Test case 6A
    Open Android App in emulator                appActivity=sg.gov.ica.mobile.app.MainActivity
    Sleep    3s
    Scroll Down On The Screen
    Wait Until Keyword Succeeds    1 minute    10     Click On Element    ${CARGO-CLEARANCE-FAV-BUTTON}
    Click On Element    ${CARGO_CLEARANCE_PLUS_SIGN_BUTTON}
    #Sleep     3s
    Click On Element    ${PLUS_NEW_CONVOY_SUBMISSION_BUTTON}
    ${nric-testdata}=   manual_field_random.generaterandomNRIC

    Click On Element     ${CARGO_CONVOY_NRIC_TEXT_FIELD}
    Type Text    ${CARGO_CONVOY_NRIC_TEXT_FIELD}    ${nric-testdata}
    Press Keycode    66

    Click On Element    ${CARGO_CONVOY_EMAIL_TEXT_FIELD}
    Type Text    ${CARGO_CONVOY_EMAIL_TEXT_FIELD}     ${EMAIL-TEST-DATA}
    Press Keycode    66

    Click On Element   ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}
    Type Text        ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}    SK1000K
    Press Keycode    66

    Click On Element   ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}
    Type Text        ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}    SK999K
    Press Keycode    66

    Click On Element   ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}
    Type Text        ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}    SK1P
    Press Keycode    66

    Click On Element   ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}
    Type Text        ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}    SK68Y
    Press Keycode    66

    Click On Element   ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}
    Type Text        ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}    SK3J
    Press Keycode    66

    Click On Element   ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}
    Type Text        ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}    SK4G
    Press Keycode    66

    Click On Element   ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}
    Type Text        ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}    SK5D
    Press Keycode    66

    Click On Element   ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}
    Type Text        ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}    SK6B
    Press Keycode    66

    Click On Element   ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}
    Type Text        ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}    SK7Z
    Press Keycode    66

    Click On Element   ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}
    Type Text        ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}    SK8X
    Press Keycode    66

    Click On Element   ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}
    Type Text        ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}    SK9T
    Press Keycode    66

    Click On Element   ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}
    Type Text        ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}    SK10M
    Press Keycode    66

    Click On Element   ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}
    Type Text        ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}    SK11k
    Press Keycode    66

    Click On Element   ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}
    Type Text        ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}    SK12H
    Press Keycode    66

    Click On Element   ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}
    Type Text        ${CARGO_CONVOY_VEHICLE_NUMBER_TEXT_FIELD}    SK13E
    Press Keycode    66

    Click On Element    ${ADD_VEHICLE_NEXT_BUTTON}


   ${lines}=   manual_field_random.readfromfile

    Click On Element    ${ADD_PERMIT_BUTTON}
    Click On Element    ${ALLOW_CAMERA_BUTTON}
    # check for iframe among the 70 permit inputs test case
    AppiumLibrary.Wait Until Page Contains Element    locator=${IFRAME}   timeout=${10}
    Click On Element    ${ENTER_PERMIT_NUMBER_MANUALLY_BUTTON}
    Wait Until Keyword Succeeds    1 minute    20     Click On Element     ${ADD_PERMIT_NUMBER_TEXT_FIELD}
   ${stripped}=    Strip String    ${lines}[0]
    Type Text        ${ADD_PERMIT_NUMBER_TEXT_FIELD}    ${stripped}
    Press Keycode    66
    Click On Element    ${SAVE_PERMIT_BUTTON}

      FOR    ${i}     IN RANGE    1    100
    Run Keyword If    ${i} >${10}    Swipe By Percent   50  75  50  10  duration=${2000}
    Run Keyword If    ${i} >${10}    Swipe By Percent   50  55  50  10  duration=${2000}
     Run Keyword If    ${i} >${15}    Swipe By Percent   50  75  50  10  duration=${2000}
     Run Keyword If    ${i} >${25}    Swipe By Percent   50  75  50  10  duration=${2000}
     Run Keyword If    ${i} >${29}    Swipe By Percent   50  75  50  10  duration=${3000}
     Run Keyword If    ${i} >${30}    Swipe By Percent   50  75  50  10  duration=${3000}
     Run Keyword If    ${i} >${60}    Swipe By Percent   50  75  50  10  duration=${3000}
     Run Keyword If    ${i} >${70}    Swipe By Percent   50  75  50  10  duration=${3000}
     Run Keyword If    ${i} >${79}    Swipe By Percent   50  75  50  10  duration=${4000}
     Run Keyword If    ${i} >${90}    Swipe By Percent   50  75  50  10  duration=${3000}
     Run Keyword If    ${i} >${95}    Swipe By Percent   50  75  50  10  duration=${3000}

   AppiumLibrary.Wait Until Page Contains Element        ${ADD_PERMIT_BUTTON}     timeout=${10}
    Click On Element    ${ADD_PERMIT_BUTTON}
   AppiumLibrary.Wait Until Page Contains Element    locator=${IFRAME}   timeout=${10}
    Click On Element    ${ENTER_PERMIT_NUMBER_MANUALLY_BUTTON}
    ${stripped}=    Strip String    ${lines}[${i}]
    Type Text        ${ADD_PERMIT_NUMBER_TEXT_FIELD}    ${stripped}
    Press Keycode    66
    Click On Element    ${SAVE_PERMIT_BUTTON}
    END

    #submit cargo convoy button click - wait untill button appears
    AppiumLibrary.Wait Until Page Contains Element    locator=${SUBMIT_CARGO_CONVOY_BUTTON}   timeout=${10}
    Click On Element        ${SUBMIT_CARGO_CONVOY_BUTTON}
    Sleep    10s


TEST CASE 7
    Open Android App in emulator     appActivity=sg.gov.ica.mobile.app.MainActivity
    sleep     3s
    Click On Element    ${CARGO-CLEARANCE-FAV-BUTTON}
    Click On Element    ${CARGO_CONVOY_ICON}
    Click On Element    ${CARGO_CONVOY_DRAFT_TAB}
    Sleep    5s






