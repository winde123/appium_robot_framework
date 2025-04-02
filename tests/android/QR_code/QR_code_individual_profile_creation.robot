*** Settings ***
Library       AppiumLibrary
Library       ../../../Data/test_data/manual_field_random.py
Library       ../../../Resources/helper_func.py
Resource      ../../../Resources/commands.robot
Resource      ../../../Resources/QRcommands.robot
Variables     ../../../Data/yaml_QR_pages/passport_qr_code_page.yaml
Variables     ../../../Data/manual_creation_profile_form.yaml
Variables     ../../../Data/yaml_QR_pages/personal_qr_code_page.yaml
Variables     ../../../Data/yaml_QR_pages/create_group_qr_code_page.yaml
Variables     ../../../Data/yaml_QR_pages/all_profiles_page.yaml
Variables     ../../../Data/test_data/input_fields_test_data.yaml
Test Setup       Open Android App in emulator    appActivity=sg.gov.ica.mobile.app.MainActivity    
Test Teardown    Close Application
*** Test Cases ***

SG_BC_MHA_SGAC-773
    [Documentation]     Straight through case of creating personal passport qr code for sc manually and validate the values in the summary page
    #Open Android App in emulator                appActivity=sg.gov.ica.mobile.app.MainActivity
    #Sleep    5s
    ## checking for the presence of the favorite icon for passport qrcode and passport qr tab

    Navigate to QR Code page without tutorial flow
    Navigate to individual manual profile creation page
    
    #Click on element                ${QR-CODE-FAV-BUTTON}
    # Click on tutorial interface no option
    #Click on element                ${NO-THANKS-OPTION}
    #Sleep                           2s
    ## close the banner
    #Click on element                ${QR-CODE-BANNER}
    ## click on the QR individual card
    #Click on element                ${IND-QR-CODE-SHORTCUT}
    #${result}=    Set Variable    Page Should Contain element    ${IND-QR-CODE-SHORTCUT}    
    #${result} =    Run Keyword And Ignore Error    Page Should Contain element    ${IND-QR-CODE-SHORTCUT}
    #Run Keyword If        "${result}[0]" =="PASS"    Click on element    ${IND-QR-CODE-SHORTCUT}         
   
    #Click on element                ${ADD-PROFILE-BUTTON}                

    #Click on element                ${GENERATE-PERSONAL-QR-CODE-OPTION}
    #Click on element                ${FILL-MANUALLY-BUTTON}
    ## selecting nric option yes
    #Click on element                ${NRIC-DROPDOWN-BUTTON}
    Click on element                ${NRIC-FLAG-YES-OPTION}
    Type text                       ${FULL-NAME-TEXT-FIELD}    ${NAME}
    Hide Keyboard    
    ## date format dd/mm/yyyy
    Type text                       ${DOB-TEXT-FIELD}    ${DOB-TEST-DATA}
    Click on element                ${NAT-CITIZEN-DROPDOWN-BUTTON}
    ## select singaporean option
    Click on element                ${CITIZEN-SG-OPTION}
    #Scroll down on the screen
    Click on element                ${NRIC-TEXT-FIELD}
    #Type text                       ${NRIC-TEXT-FIELD}    ${NRIC}
    ## split the str in 3 chars and use adb shell to input
    @{split_nric_str} =     helper_func.String Splitter    ${NRIC}    ${3}
    FOR    ${split_str}    IN    @{split_nric_str}
        Execute Adb Shell    input text    ${split_str}
        Sleep    1s
        
    END

    #Execute Adb Shell    input text     '123'
    Hide Keyboard 
    #Press Keycode                   KEYCODE_ENTER
    Click on element                ${PASSPORT-NO-FIELD}
    Type text                       ${PASSPORT-NO-FIELD}   ${PPNUM}
    Hide Keyboard
    Scroll down on the screen
    Type text                       ${PASSPORT-DATE-EXPIRY-TEXT-FIELD}    ${PP-EXPIRY-DATE-TEST-DATA}
    Click on element                ${PROFILE-PAGE-NEXT-BUTTON}

    ## checking if the details entered is coherant to the passport detail page
    Wait Until Page Contains element   ${FULL-NAME-FIELD} 
    Element Should Contain Text     ${FULL-NAME-FIELD}    ${NAME}
    ## getting the text value of DOB and passport date expiry field
    ${DOB-FIELD-TEXT}    Get Text    ${DOB-FIELD}
    
    Scroll down on the screen  
    #Sleep     2s
    ${PP-EXP-DATE-TEXT}  Get Text    ${PASSPORT-DATE-EXPIRY-FIELD}
    #Log    ${PP-EXP-DATE-TEXT}   
    ### stripping the white space
    ${DOB-FIELD-TEXT}=     helper_func.remove_whitespaces    ${DOB-FIELD-TEXT}             
    ${PP-EXP-DATE-TEXT}=   helper_func.remove_whitespaces    ${PP-EXP-DATE-TEXT}
    Should Be Equal As Strings      ${DOB-FIELD-TEXT}    second=${DOB-TEST-DATA}
    Element Should Contain Text     ${NRIC-FIELD}    ${NRIC}         
    Element Should Contain Text     ${PASSPORT-NUMBER-FIELD}   ${PPNUM}
    Should Be Equal As Strings      ${PP-EXP-DATE-TEXT}    ${PP-EXPIRY-DATE-TEST-DATA}

    Click on element                ${TOC-PRIVACY-POLICY-CHECKBOX}

    ##Clicking on the save button on passport details and qr info modal popup
    Click on element    ${PASSPORT-DETAILS-SAVE-BUTTON}
    Click on element    ${ACCESS-QR-INFO-CONFIRM-BUTTON}
    ##checking for the presence of the qr code
    Wait Until Page Contains Element    ${QR-CODE-PERSONAL}

SG_BC_MHA_SGAC-775
    [Documentation]     This is the manual creation of foreign visitor profile and QR code and validate fields in summary page . Nationality is random.
    #Open Android App in emulator                appActivity=sg.gov.ica.mobile.app.MainActivity
    Navigate to QR Code page without tutorial flow
    Navigate to individual manual profile creation page
    Click on element    ${NRIC-FLAG-NO-OPTION}

    ## filling the manual input form
    Type text                       ${FULL-NAME-TEXT-FIELD}        ${NAME}
    Type text                       ${DOB-TEXT-FIELD}        ${DOB}
    Click on element                ${NAT-CITIZEN-DROPDOWN-BUTTON}

    ##gettting a random nationality selected.
    ${random_country_int} =     Evaluate    random.randint(2,13)
    #Log    ${random_country_int}
    ${random_country_selector} =     Catenate     //android.view.ViewGroup[@content-desc='searchable dropdown accessible label    ${random_country_int}'    and @focusable='true']
    #Log    ${random_country_selector}
    Click on element            ${random_country_selector}
    Click on element                ${PASSPORT-NO-FIELD}
    Type text        ${PASSPORT-NO-FIELD}        ${FOREIGNPPNUM}
    ${keyboard_flag}=            Is Keyboard Shown
    IF    ${keyboard_flag}
        Hide Keyboard
        
    END
    #Log    ${keyboard_flag}  
    #Hide Keyboard
    Type text                       ${PASSPORT-DATE-EXPIRY-TEXT-FIELD}    ${PP-EXPIRY-DATE-TEST-DATA}
    Click on element                ${PROFILE-PAGE-NEXT-BUTTON}

    ## validate field values in the confirmation page
    Wait Until Page Contains element       ${FULL-NAME-FIELD} 
    Element Should Contain Text            ${FULL-NAME-FIELD}    ${NAME}
    ## getting the text value of DOB and passport date expiry field
    ${DOB-FIELD-TEXT}    Get Text    ${DOB-FIELD}
    
    Scroll down on the screen  
    ${PP-EXP-DATE-TEXT}  Get Text    ${FORIEGNER-PASSPORT-DATE-EXPIRY-FIELD}   
    ### stripping the white space
    ${DOB-FIELD-TEXT}=     helper_func.remove_whitespaces    ${DOB-FIELD-TEXT}             
    ${PP-EXP-DATE-TEXT}=   helper_func.remove_whitespaces    ${PP-EXP-DATE-TEXT}

    ## checking for the correct data populated in the summary field
    Should Be Equal As Strings      ${DOB-FIELD-TEXT}    second=${DOB}         
    Element Should Contain Text     ${FOREIGNER-PASSPORT-NUMBER-FIELD}   ${FOREIGNPPNUM}
    Should Be Equal As Strings      ${PP-EXP-DATE-TEXT}    ${PP-EXPIRY-DATE-TEST-DATA}

    Click on element                ${TOC-PRIVACY-POLICY-CHECKBOX}

    Click on element                ${PASSPORT-DETAILS-SAVE-BUTTON}

