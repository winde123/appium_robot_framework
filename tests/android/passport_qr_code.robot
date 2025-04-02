*** Settings ***
Library     AppiumLibrary
Library    ../../Resources/helper_func.py
Library    ../../Data/test_data/manual_field_random.py    
#Library    RPA.Robocorp.WorkItems
#Library    RPA.Excel.Files
Resource    ../../Resources/commands.robot
Resource    ../../Resources/QRcommands.robot
#Variables   ../../Data/landing_page.yaml
#Variables   ../../Data/yaml_QR_pages/passport_qr_code_page.yaml
#Variables    ../../Data/manual_creation_profile_form.yaml
#Variables    ../../Data/yaml_QR_pages/personal_qr_code_page.yaml
#Variables    ../../Data/yaml_QR_pages/create_group_qr_code_page.yaml
#Variables    ../../Data/yaml_QR_pages/all_profiles_page.yaml
#Variables    ../../Data/yaml_tutorial_flow_pages/passport_qr_tutorial_flow.yaml
#Variables    ../../Data/test_data/input_fields_test_data.yaml
#Variables    ../../Data/test_data/manual_field_random.py
Test Setup     Open Android App in emulator    appActivity=sg.gov.ica.mobile.app.MainActivity    
Test Teardown    Close Application

*** Variables ***
#${TOTAL-GROUP-MEMBERS}        ${${N-GROUP-MEMBERS}+${1}}



*** Test Cases ***
SG_BC_MHA_SGAC-836
...    [Documentation]    Straight through case of creating group qr code for car for 10pax
    #Open Android App in emulator                appActivity=sg.gov.ica.mobile.app.MainActivity
    #Sleep    3s
    #Click on element                ${HOME-ANNOUCEMENT-BANNER}
    #Page Should Contain Element     ${QR-CODE-FAV-BUTTON}
    #Page Should Contain Element     ${PASSPORT-QR-CODE-TAB} 
    #Click on element                ${QR-CODE-FAV-BUTTON}
    Navigate to QR Code page without tutorial flow
    Navigate to group QR creation page
    ## close the banner
    #Click on element                ${QR-CODE-BANNER}
    #Sleep     2s
    #Scroll down on the screen
    #Click on element                ${GENERATE-GROUP-QR-CODE-OPTION}
    Type text                       ${GROUP-NAME-TEXT-INPUT-FIELD}    ${GROUP-QR-GROUP-NAME}
    ## selecting the car option
    Click on element    ${VECHICLE-TYPE-DROPDOWN-BUTTON}
    Click on element    ${VECHICLE-TYPE-DROPDOWN-CAR-OPTION}
    ## Validating the text string restriction
    Wait Until Page Contains Element   ${CAR-OPTION-RES-MSG}
    ${CAR-RES-MSG}    Get Text         ${CAR-OPTION-RES-MSG} 
    Element Should Contain Text        ${CAR-OPTION-RES-MSG}    ${CAR-RES-MSG}

    @{GROUP-NAME-LIST}=    Create resident manual profile n times    ${N-MEMBERS-CAR}
    @{QR-MEMBERS-LOCATORS}=    Generate dynamic group qr checkbox element locator for n group members    ${GROUP-NAME-LIST}        elementindex=${N-MEMBERS-CAR}
    Click on n checkboxes on the profiles on the QR group page    @{QR-MEMBERS-LOCATORS}     n_members=${N-MEMBERS-CAR}




    #Click on element                   ${ADD-PROFILE-GROUP-BUTTON}
    
    ##Creating personal profile first
    #Click on element                ${FILL-MANUALLY-BUTTON}
    #Click on element                ${NRIC-FLAG-YES-OPTION}
    #Type text                       ${FULL-NAME-TEXT-FIELD}    ${NAME}
    #Type text                       ${DOB-TEXT-FIELD}    ${DOB}
    #Click on element                ${NAT-CITIZEN-DROPDOWN-BUTTON}
    ## select singaporean option
    #Click on element                ${CITIZEN-SG-OPTION}
    #Click on element                ${NRIC-TEXT-FIELD}
    ## input nric characters using adb shell
    #@{split_nric_str} =     helper_func.String Splitter    ${NRIC}    ${3}
    #FOR    ${split_str}    IN    @{split_nric_str}
        #Execute Adb Shell    input text    ${split_str}
        #Sleep    2s
        
    #END
    #Type text                       ${NRIC-TEXT-FIELD}    ${NRIC}
    #Hide Keyboard
    #Click on element                ${PASSPORT-NO-FIELD}                
    #Type text                       ${PASSPORT-NO-FIELD}   ${PPNUM}
    #Hide Keyboard
    #Scroll down on the screen
    #Swipe By Percent    50    90    50    10    duration=${500}
    #Type text                       ${PASSPORT-DATE-EXPIRY-TEXT-FIELD}    ${PP-EXPIRY-DATE-TEST-DATA}
    #Click on element                ${PROFILE-PAGE-NEXT-BUTTON}
    #Click on element                ${TOC-PRIVACY-POLICY-CHECKBOX}

    #Click on element                ${PASSPORT-DETAILS-SAVE-BUTTON}
    #Click on element                ${ACCESS-QR-INFO-CONFIRM-BUTTON}
    #Click on element                ${PERSONAL-QR-CODE-BACK-BUTTON}
    
    ## instantiating list of names,DOBs,NRIC and PPnums
    #@{DOB-LIST}=     manual_field_random.generatelistofDOBS        ${N-GROUP-MEMBERS-CAR}
    #@{NAME-LIST}=    manual_field_random.generatelistofNames       ${N-GROUP-MEMBERS-CAR}
    #@{NRIC-LIST}=    manual_field_random.generatelistofNRIC        ${N-GROUP-MEMBERS-CAR}
    #@{PPNUM-LIST}=   manual_field_random.generateListofPPNum       ${N-GROUP-MEMBERS-CAR} 



    ## looping the profile creation n times 
    #FOR  ${index}  IN RANGE    ${N-GROUP-MEMBERS-CAR}
       
        #Sleep    5s
        #Scroll down on the screen
        #Click on element                ${ADD-PROFILE-GROUP-BUTTON}
        #Click on element                ${FILL-MANUALLY-BUTTON}
        #Click on element                ${NRIC-DROPDOWN-BUTTON}
        #Click on element                ${NRIC-FLAG-YES-OPTION}
        #Type text                       ${FULL-NAME-TEXT-FIELD}    ${NAME-LIST}[${index}]
        #Type text                       ${DOB-TEXT-FIELD}     ${DOB-LIST}[${index}]
        #Click on element                ${NAT-CITIZEN-DROPDOWN-BUTTON}
        ## select singaporean option
        #Click on element                ${CITIZEN-SG-OPTION}
        #Click on element                ${NRIC-TEXT-FIELD}
        #@{split_nric_str} =     helper_func.String Splitter    ${NRIC-LIST}[${index}]    ${3}
        #FOR    ${split_str}    IN    @{split_nric_str}
            #Execute Adb Shell    input text    ${split_str}
            #Sleep    2s
        
        #END

        #Type text                       ${NRIC-TEXT-FIELD}    ${NRIC-LIST}[${index}]
        #Hide Keyboard
        #Click on element                ${PASSPORT-NO-FIELD}
        #Type text                       ${PASSPORT-NO-FIELD}  ${PPNUM-LIST}[${index}]
        #Hide Keyboard
        #Swipe By Percent    50    90    50    10    duration=${500}
        #Scroll down on the screen
        #Type text                       ${PASSPORT-DATE-EXPIRY-TEXT-FIELD}    ${PP-EXPIRY-DATE-TEST-DATA}
        #Click on element                ${PROFILE-PAGE-NEXT-BUTTON}
        #Click on element                ${TOC-PRIVACY-POLICY-CHECKBOX}
        #Click on element                ${PASSPORT-DETAILS-SAVE-BUTTON}
        
    
    #END
    ## selecting main owner checkbox
    #${OWNER-CHECKBOX-GROUP-QR}=    Catenate    SEPARATOR=    //android.widget.TextView[@text='    ${NAME}    'and @enabled='true']    
    #Click on element                    ${OWNER-CHECKBOX-GROUP-QR}

    ## reversing the elements on the list

    #${NAME-LIST-REVERSED}=    helper_func.Reverse List Elements    ${NAME-LIST}
    #Log Many    @{NAME-LIST-REVERSED}    
    #@{NRIC-LIST-REVERSED}=    helper_func.Reverse List Elements    ${NRIC-LIST}
    
    ## generating element selectors for group members
    #@{RESULTS}=    Generate dynamic group qr checkbox element locator for n group members    ${NAME-LIST-REVERSED}        elementindex=${N-GROUP-MEMBERS-CAR}         
    #Log Many    @{RESULTS}
    
      
    #FOR  ${NTH-GROUP-MEMBER}  IN RANGE    ${N-GROUP-MEMBERS-CAR}
        #IF      ${NTH-GROUP-MEMBER} < ${3}
            #Swipe By Percent    50    90    50    10    duration=${500}
            #Click on element                    ${RESULTS}[${NTH-GROUP-MEMBER}]
        #ELSE IF    ${NTH-GROUP-MEMBER} >= ${3}
            #Swipe By Percent    50    90    50    50    duration=${250}
            #Click on element                    ${RESULTS}[${NTH-GROUP-MEMBER}]    
            
        #END
             
    #END
    
    Click on element                    ${NEXT-BUTTON}

    ### validating number of pax
    ## adding two scalar variables together
    #${INDV-PROFILE-COUNT}    Set Variable    ${1}
    #${x}=    Convert To Integer   ${x}
    #${N-GROUP-MEMBERS}=    Convert To Integer    ${N-GROUP-MEMBERS}    
    #${TOTAL-GROUP-MEMBERS} =     Evaluate    sum(${1},${1})
    #${TOTAL-GROUP-MEMBERS} =     Evaluate     ${N-GROUP-MEMBERS-CAR}+${INDV-PROFILE-COUNT}
    #Log    ${TOTAL-GROUP-MEMBERS}
    ## converting it to string

    ${N-MEMBERS-CAR}=     Convert To String    ${N-MEMBERS-CAR} 
    Wait Until Page Contains Element    ${PAX-FIELD-LABEL}
    Element Should Contain Text        ${PAX-FIELD}        ${N-MEMBERS-CAR}
    Click on element                    ${GENERATE-GROUP-QR-CODE-BUTTON}
    #### validate qr code and group name
    Wait Until Page Contains Element    ${GROUP-QR-CODE}
    Wait Until Page Contains Element   ${GROUP-NAME-TEXT-LABEL}
    ## making group name into uppercase
    ${GROUP-QR-GROUP-NAME}=     Evaluate     '${GROUP-QR-GROUP-NAME}'.upper()
    Element Should Contain Text        ${GROUP-NAME-TEXT-LABEL}    ${GROUP-QR-GROUP-NAME}


SG_BC_MHA_SGAC-1012
    [Documentation]   Creation of motorcycle qr code with resident profile
    Navigate to QR Code page without tutorial flow
    Navigate to group QR creation page
    Type text                       ${GROUP-NAME-TEXT-INPUT-FIELD}    ${GROUP-QR-GROUP-NAME}
    ## selecting the Motorcycle option
    Click on element    ${VECHICLE-TYPE-DROPDOWN-BUTTON}
    Click on element    ${VECHICLE-TYPE-DROPDOWN-MC-OPTION}
    ## Validate the maximum message
    Wait Until Page Contains Element    ${MC-OPTION-RES-MSG}
    ${MC-RES-MSG}    Get Text    ${MC-OPTION-RES-MSG}
    Element Should Contain Text    ${MC-OPTION-RES-MSG}    ${MC-RES-MSG}    
    
    ##Generating list of members
    #@{MEMBER-LIST}=    Create List
    #FOR    ${MEMBER-COUNT}    IN RANGE    ${N-MEMBERS-MC}    
        #${resident_name}     Set Variable       resident
        #${resident_name} =    Catenate            ${resident_name}         ${MEMBER-COUNT}
        #Append To List    ${MEMBER-LIST}    ${resident_name}
        
    #END
    @{GROUP-NAME-LIST}=    Create resident manual profile n times    ${N-MEMBERS-MC}    
    #add 2 resident profile for mc group qr
    #FOR    ${NTH-MEMBER}    IN RANGE   ${N-MEMBERS-MC}
        #${resident_name}     Set Variable       resident
        #${resident_name} =    Catenate            ${resident_name}         ${NTH-MEMBER}
        #Log    ${resident_name} 
        #${NTH-MEMBER-NAME} =    Run Keyword       Create resident manual profile    ${NTH-MEMBER}
        #Set Test Variable    ${MEMBER-${NTH-MEMBER}}    ${NTH-MEMBER}
        #Set Test Variable       ${MEMBER-NAME}        MEMBER-${NTH-MEMBER}
        #${MEMBER-NAME} =     Catenate    SEPARATOR=_    member    ${NTH-MEMBER}
        #${NAME}=    Run Keyword     Create resident manual profile    
        #Set Test Variable    ${${MEMBER-NAME}}    ${NTH-MEMBER}
        #${MEMBER-NAME}=  Repeat Keyword    2     Create resident manual profile
        #Log    ${MEMBER-NAME}    
        #${MEMBER-NAME} =   Create resident manual profile
        #IF    ${NTH-MEMBER} > 0
             #${MEMBER-NAME}=    Create resident manual profile    
            
        #END
        #Set Test Variable    ${MEMBER-${NTH-MEMBER}}    ${MEMBER-NAME} 
        #${MEMBER-NAME}=     Create resident manual profile      
        #Append To List    ${GROUP-NAME-LIST}     ${NAME}   
        
    #END

    #Log Many    @{GROUP-NAME-LIST}
    @{QR-MEMBERS-LOCATORS}=    Generate dynamic group qr checkbox element locator for n group members    ${GROUP-NAME-LIST}        elementindex=${N-MEMBERS-MC}
    #Log Many    @{QR-MEMBERS-LOCATORS}

    ## Verify visibility and functionality of profiles
    #Click on element    ${QR-MEMBERS-LOCATORS}[0]
    #Click on element    ${QR-MEMBERS-LOCATORS}[1]
    Click on n checkboxes on the profiles on the QR group page    @{QR-MEMBERS-LOCATORS}    n_members=${N-MEMBERS-MC}   

    Click on element                    ${NEXT-BUTTON}
    Wait Until Page Contains Element    ${PAX-FIELD-LABEL}
    ${N-MEMBERS-MC} =     Convert To String    ${N-MEMBERS-MC}
    Element Should Contain Text         ${PAX-FIELD}        ${N-MEMBERS-MC}

    Click on element                    ${GENERATE-GROUP-QR-CODE-BUTTON}
    #### validate qr code and group name
    Wait Until Page Contains Element    ${GROUP-QR-CODE}
    Wait Until Page Contains Element   ${GROUP-NAME-TEXT-LABEL}
    ## making group name into uppercase
    ${GROUP-QR-GROUP-NAME}=     Evaluate     '${GROUP-QR-GROUP-NAME}'.upper()
    Element Should Contain Text        ${GROUP-NAME-TEXT-LABEL}    ${GROUP-QR-GROUP-NAME}


    #${resident_name_1}=    Create resident manual profile
    #Log    ${resident_name_1}
    #${resident_name_2}=    Create resident manual profile

SG_BC_MHA_SGAC-1056
    [Documentation]    Creating group qr code for lorry group with residents profiles
    Navigate to QR Code page without tutorial flow
    Navigate to group QR creation page
    Type text                       ${GROUP-NAME-TEXT-INPUT-FIELD}    ${GROUP-QR-GROUP-NAME}
    ## selecting the Motorcycle option
    Click on element    ${VECHICLE-TYPE-DROPDOWN-BUTTON}
    Click on element    ${VECHICLE-TYPE-DROPDOWN-LORRY-OPTION}

    ## Validate the maximum message
    Wait Until Page Contains Element    ${LORRY-OPTION-RES-MSG}
    ${LORRY-RES-MSG}    Get Text    ${LORRY-OPTION-RES-MSG}
    Element Should Contain Text    ${LORRY-OPTION-RES-MSG}    ${LORRY-RES-MSG}
    @{GROUP-NAME-LIST}=    Create resident manual profile n times    ${N-MEMBERS-LORRY}

    @{QR-MEMBERS-LOCATORS}=    Generate dynamic group qr checkbox element locator for n group members    ${GROUP-NAME-LIST}        elementindex=${N-MEMBERS-LORRY}
    #Log Many     @{QR-MEMBERS-LOCATORS}
    Click on n checkboxes on the profiles on the QR group page    @{QR-MEMBERS-LOCATORS}    n_members=${N-MEMBERS-LORRY}
       

    #FOR    ${NTH-MEMBER}    IN RANGE    ${N-MEMBERS-LORRY}    
        #Click on element    ${QR-MEMBERS-LOCATORS}[${NTH-MEMBER}]
        
    #END
    
    Click on element                    ${NEXT-BUTTON}
    Wait Until Page Contains Element    ${PAX-FIELD-LABEL}
    ${N-MEMBERS-LORRY} =     Convert To String    ${N-MEMBERS-LORRY}
    Element Should Contain Text         ${PAX-FIELD}        ${N-MEMBERS-LORRY}

    Click on element                    ${GENERATE-GROUP-QR-CODE-BUTTON}
    #### validate qr code and group name
    Wait Until Page Contains Element    ${GROUP-QR-CODE}
    Wait Until Page Contains Element    ${GROUP-NAME-TEXT-LABEL}
    ## making group name into uppercase
    ${GROUP-QR-GROUP-NAME}=     Evaluate     '${GROUP-QR-GROUP-NAME}'.upper()
    Element Should Contain Text        ${GROUP-NAME-TEXT-LABEL}    ${GROUP-QR-GROUP-NAME}

SG_BC_MHA_SGAC-1110
    [Documentation]     Creation of bus QR code with resident profile
    Navigate to QR Code page without tutorial flow
    Navigate to group QR creation page
    Type text                       ${GROUP-NAME-TEXT-INPUT-FIELD}    ${GROUP-QR-GROUP-NAME}
    ## selecting the Motorcycle option
    Click on element                ${VECHICLE-TYPE-DROPDOWN-BUTTON}
    Click on element                ${VEHICLE-TYPE-DROPDOWN-BUS-OPTION}

     ## Validate the maximum message
    Wait Until Page Contains Element    ${BUS-OPTION-RES-MSG}
    ${BUS-RES-MSG}    Get Text          ${BUS-OPTION-RES-MSG}
    Element Should Contain Text         ${BUS-OPTION-RES-MSG}    ${BUS-RES-MSG}
    @{GROUP-NAME-LIST}=    Create resident manual profile n times    ${N-MEMBERS-BUS}

    @{QR-MEMBERS-LOCATORS}=    Generate dynamic group qr checkbox element locator for n group members    ${GROUP-NAME-LIST}        elementindex=${N-MEMBERS-BUS}

    Click on n checkboxes on the profiles on the QR group page    @{QR-MEMBERS-LOCATORS}     n_members=${N-MEMBERS-BUS}

    Click on element                    ${NEXT-BUTTON}
    Wait Until Page Contains Element    ${PAX-FIELD-LABEL}
    ${N-MEMBERS-BUS} =     Convert To String    ${N-MEMBERS-BUS}
    Element Should Contain Text         ${PAX-FIELD}        ${N-MEMBERS-BUS}

    Click on element                    ${GENERATE-GROUP-QR-CODE-BUTTON}
    #### validate qr code and group name
    Wait Until Page Contains Element    ${GROUP-QR-CODE}
    Wait Until Page Contains Element    ${GROUP-NAME-TEXT-LABEL}
    ## making group name into uppercase
    ${GROUP-QR-GROUP-NAME}=     Evaluate     '${GROUP-QR-GROUP-NAME}'.upper()
    Element Should Contain Text        ${GROUP-NAME-TEXT-LABEL}    ${GROUP-QR-GROUP-NAME}        
    










    
    












    
    
                 
    
