*** Settings ***
Library     AppiumLibrary
Library    ../../Resources/helper_func.py
Library    ../../Data/test_data/manual_field_random.py    
#Library    RPA.Excel.Files
Resource    ../../Resources/commands.robot
#Variables   ../../Data/landing_page.yaml
Variables   ../../Data/yaml_QR_pages/passport_qr_code_page.yaml
Variables    ../../Data/manual_creation_profile_form.yaml
Variables    ../../Data/yaml_QR_pages/personal_qr_code_page.yaml
Variables    ../../Data/yaml_QR_pages/create_group_qr_code_page.yaml
Variables    ../../Data/yaml_QR_pages/all_profiles_page.yaml
#Variables    ../../Data/yaml_tutorial_flow_pages/passport_qr_tutorial_flow.yaml
Variables    ../../Data/test_data/input_fields_test_data.yaml
Variables    ../../Data/test_data/manual_field_random.py
Test Teardown    Close Application

*** Variables ***



*** Test Cases ***

test case 1
    [Documentation]     Straight through case of creating personal passport qr code manually
    Open Android App in emulator                appActivity=sg.gov.ica.mobile.app.MainActivity
    #Sleep    5s
    ## checking for the presence of the favorite icon for passport qrcode and passport qr tab

    Navigate to QR Code page without tutorial flow
    
    #Click on element                ${QR-CODE-FAV-BUTTON}
    # Click on tutorial interface no option
    #Click on element                ${NO-THANKS-OPTION}
    #Sleep                           2s
    Click on element                ${IND-QR-CODE-SHORTCUT}
    #${result}=    Set Variable    Page Should Contain element    ${IND-QR-CODE-SHORTCUT}    
    #${result} =    Run Keyword And Ignore Error    Page Should Contain element    ${IND-QR-CODE-SHORTCUT}
    #Run Keyword If        "${result}[0]" =="PASS"    Click on element    ${IND-QR-CODE-SHORTCUT}         
   
    Click on element                ${ADD-PROFILE-BUTTON}                

    #Click on element                ${GENERATE-PERSONAL-QR-CODE-OPTION}
    Click on element                ${FILL-MANUALLY-BUTTON}
    ## selecting nric option yes
    #Click on element                ${NRIC-DROPDOWN-BUTTON}
    Click on element                ${NRIC-DROPDOWN-YES-OPTION}
    Type text                       ${FULL-NAME-TEXT-FIELD}    ${NAME}
    Hide Keyboard    
    ## date format dd/mm/yyyy
    Type text                       ${DOB-TEXT-FIELD}    ${DOB-TEST-DATA}
    Click on element                ${NAT-CITIZEN-DROPDOWN-BUTTON}
    ## select singaporean option
    Click on element                ${CITIZEN-SG-OPTION}
    #Scroll down on the screen
    Click on element                ${NRIC-TEXT-FIELD}
    Type text                       ${NRIC-TEXT-FIELD}    ${NRIC}
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
    Log    ${PP-EXP-DATE-TEXT}   
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

test case 2
...    [Documentation]    Straight through case of creating group qr code for car for 15pax
    Open Android App in emulator                appActivity=sg.gov.ica.mobile.app.MainActivity
    #Sleep    3s
    #Click on element                ${HOME-ANNOUCEMENT-BANNER}
    #Page Should Contain Element     ${QR-CODE-FAV-BUTTON}
    #Page Should Contain Element     ${PASSPORT-QR-CODE-TAB} 
    #Click on element                ${QR-CODE-FAV-BUTTON}
    Navigate to QR Code page without tutorial flow
    Sleep     2s
    Scroll down on the screen
    Click on element                ${GENERATE-GROUP-QR-CODE-OPTION}
    Type text                       ${GROUP-NAME-TEXT-FIELD}    testtesttestgroup
    ## selecting the car option
    Click on element    ${VECHICLE-TYPE-DROPDOWN-BUTTON}
    Click on element    ${VECHICLE-TYPE-DROPDOWN-CAR-OPTION}
    ## Validating the text string restriction
    Wait Until Page Contains Element   ${CAR-OPTION-RES-MSG}
    ${CAR-RES-MSG}    Get Text         ${CAR-OPTION-RES-MSG} 
    Element Should Contain Text        ${CAR-OPTION-RES-MSG}    ${CAR-RES-MSG}   
    Click on element                   ${ADD-PROFILE-GROUP-BUTTON}
    
    ##Creating personal profile first
    Click on element                ${FILL-MANUALLY-BUTTON}
    Click on element                ${NRIC-DROPDOWN-YES-OPTION}
    Type text                       ${FULL-NAME-TEXT-FIELD}    ${NAME}
    Type text                       ${DOB-TEXT-FIELD}    ${DOB}
    Click on element                ${NAT-CITIZEN-DROPDOWN-BUTTON}
    ## select singaporean option
    Click on element                ${CITIZEN-SG-OPTION}
    Click on element                ${NRIC-TEXT-FIELD}
    Type text                       ${NRIC-TEXT-FIELD}    ${NRIC}
    Hide Keyboard
    Click on element                ${PASSPORT-NO-FIELD}                
    Type text                       ${PASSPORT-NO-FIELD}   ${PPNUM}
    Hide Keyboard
    Scroll down on the screen
    #Swipe By Percent    50    90    50    10    duration=${500}
    Type text                       ${PASSPORT-DATE-EXPIRY-TEXT-FIELD}    ${PP-EXPIRY-DATE-TEST-DATA}
    Click on element                ${PROFILE-PAGE-NEXT-BUTTON}
    Click on element                ${TOC-PRIVACY-POLICY-CHECKBOX}

    Click on element                ${PASSPORT-DETAILS-SAVE-BUTTON}
    #Click on element                ${ACCESS-QR-INFO-CONFIRM-BUTTON}
    #Click on element                ${PERSONAL-QR-CODE-BACK-BUTTON}
    
    ## instantiating list of names,DOBs,NRIC and PPnums
    @{DOB-LIST}=     manual_field_random.generatelistofDOBS     ${N-GROUP-MEMBERS}
    @{NAME-LIST}=    manual_field_random.generatelistofNames    ${N-GROUP-MEMBERS}
    @{NRIC-LIST}=    manual_field_random.generatelistofNRIC     ${N-GROUP-MEMBERS}
    @{PPNUM-LIST}=   manual_field_random.generateListofPPNum    ${N-GROUP-MEMBERS} 



    ## looping the profile creation n times 
    FOR  ${index}  IN RANGE    ${N-GROUP-MEMBERS}
       
        #Sleep    5s
        #Scroll down on the screen
        Click on element                ${ADD-PROFILE-GROUP-BUTTON}
        Click on element                ${FILL-MANUALLY-BUTTON}
        #Click on element                ${NRIC-DROPDOWN-BUTTON}
        Click on element                ${NRIC-DROPDOWN-YES-OPTION}
        Type text                       ${FULL-NAME-TEXT-FIELD}    ${NAME-LIST}[${index}]
        Type text                       ${DOB-TEXT-FIELD}     ${DOB-LIST}[${index}]
        Click on element                ${NAT-CITIZEN-DROPDOWN-BUTTON}
        ## select singaporean option
        Click on element                ${CITIZEN-SG-OPTION}
        Click on element                ${NRIC-TEXT-FIELD}
        Type text                       ${NRIC-TEXT-FIELD}    ${NRIC-LIST}[${index}]
        Hide Keyboard
        Click on element                ${PASSPORT-NO-FIELD}
        Type text                       ${PASSPORT-NO-FIELD}  ${PPNUM-LIST}[${index}]
        Hide Keyboard
        #Swipe By Percent    50    90    50    10    duration=${500}
        Scroll down on the screen
        Type text                       ${PASSPORT-DATE-EXPIRY-TEXT-FIELD}    ${PP-EXPIRY-DATE-TEST-DATA}
        Click on element                ${PROFILE-PAGE-NEXT-BUTTON}
        Click on element                ${TOC-PRIVACY-POLICY-CHECKBOX}
        Click on element                ${PASSPORT-DETAILS-SAVE-BUTTON}
        
    
    END
    ## selecting main owner checkbox
    ${OWNER-CHECKBOX-GROUP-QR}=    Catenate    SEPARATOR=    //android.widget.TextView[@text='    ${NAME}    'and @enabled='true']    
    Click on element                    ${OWNER-CHECKBOX-GROUP-QR}

    ## reversing the elements on the list

    ${NAME-LIST-REVERSED}=    helper_func.Reverse List Elements    ${NAME-LIST}
    Log Many    @{NAME-LIST-REVERSED}    
    @{NRIC-LIST-REVERSED}=    helper_func.Reverse List Elements    ${NRIC-LIST}
    
    @{RESULTS}=    Generate dynamic group qr checkbox element locator for n group members    ${NAME-LIST-REVERSED}        elementindex=${N-GROUP-MEMBERS}         
    ##Log Many    @{RESULTS}
    
    
    FOR  ${NTH-GROUP-MEMBER}  IN RANGE    ${N-GROUP-MEMBERS}
        IF      ${NTH-GROUP-MEMBER} < ${3}
            #Swipe By Percent    50    90    50    10    duration=${500}
            Click on element                    ${RESULTS}[${NTH-GROUP-MEMBER}]
        ELSE IF    ${NTH-GROUP-MEMBER} >= ${3}
            Swipe By Percent    50    90    50    50    duration=${250}
            Click on element                    ${RESULTS}[${NTH-GROUP-MEMBER}]    
            
        END
             
    END
    
    Click on element                    ${NEXT-BUTTON}
    Click on element                    ${GENERATE-GROUP-QR-CODE-BUTTON}


    
    
                 
    
