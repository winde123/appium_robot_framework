*** Settings ***
Library    AppiumLibrary
Library    Collections
Library    ../Data/test_data/manual_field_random.py
Variables    ../Data/yaml_QR_pages/passport_qr_code_page.yaml
Variables    ../Data/yaml_QR_pages/all_profiles_page.yaml
Variables    ../Data/manual_creation_profile_form.yaml
Variables    ../Data/yaml_QR_pages/create_group_qr_code_page.yaml
Variables    ../Data/test_data/manual_field_random.py
Variables    ../Data/test_data/input_fields_test_data.yaml
Resource    commands.robot

*** Keywords ***

Navigate to individual manual profile creation page
    Click on element          ${QR-CODE-BANNER}
    Click on element          ${IND-QR-CODE-SHORTCUT}
    Click on element          ${ADD-PROFILE-BUTTON}
    Click on element          ${FILL-MANUALLY-BUTTON}

Navigate to group QR creation page
    Click on element          ${QR-CODE-BANNER}
    Click on element          ${GENERATE-GROUP-QR-CODE-OPTION}

Create resident manual profile n times

    [Arguments]    ${n_times}
    ### generating the attributes for residents n times and forming a list
    @{DOB-LIST}=     manual_field_random.generatelistofDOBS        ${n_times}
    @{NAME-LIST}=    manual_field_random.generatelistofNames       ${n_times}
    Log Many    @{NAME-LIST} 
    @{NRIC-LIST}=    manual_field_random.generatelistofNRIC        ${n_times}
    @{PPNUM-LIST}=   manual_field_random.generateListofPPNum       ${n_times}
    
    FOR    ${NTH-MEMBER}    IN RANGE        ${n_times}    
        ##Creating personal profile first
        Click on element          ${ADD-PROFILE-GROUP-BUTTON}
        Click on element          ${FILL-MANUALLY-BUTTON}
        Click on element          ${NRIC-FLAG-YES-OPTION}
        Type text                 ${FULL-NAME-TEXT-FIELD}        ${NAME-LIST}[${NTH-MEMBER}]
        Type text                 ${DOB-TEXT-FIELD}              ${DOB-LIST}[${NTH-MEMBER}]
        Click on element          ${NAT-CITIZEN-DROPDOWN-BUTTON}
        ## select singaporean option
        Click on element          ${CITIZEN-SG-OPTION}
        ## input nric characters using adb shell
        Click on element          ${NRIC-TEXT-FIELD}
        @{split_nric_str} =     helper_func.String Splitter    ${NRIC-LIST}[${NTH-MEMBER}]    ${2}
        FOR    ${split_str}    IN    @{split_nric_str}
            Execute Adb Shell    input text    ${split_str}
            Sleep    1s
            
        END
        Hide Keyboard
        Click on element                ${PASSPORT-NO-FIELD}                
        Type text                       ${PASSPORT-NO-FIELD}   ${PPNUM-LIST}[${NTH-MEMBER}]
        ${keyboard_flag}=            Is Keyboard Shown
        IF    ${keyboard_flag}
            Hide Keyboard
        
        END
        Scroll down on the screen
        Type text                       ${PASSPORT-DATE-EXPIRY-TEXT-FIELD}    ${PP-EXPIRY-DATE-TEST-DATA}

        Click on element                ${PROFILE-PAGE-NEXT-BUTTON}
        Click on element                ${TOC-PRIVACY-POLICY-CHECKBOX}

        Click on element                ${PASSPORT-DETAILS-SAVE-BUTTON}

    END

    #[Return]    ${NAME} ${arg}
    [Return]    @{NAME-LIST}

Generate dynamic group qr checkbox element locator for n group members
    [Arguments]    @{list_of_names}    ${elementindex}
    @{GROUP-CHECKBOX-LOCATOR}        Create List
    FOR  ${checkbox}  IN RANGE    ${elementindex}
        #${NTH-CHECKBOX-LOCATOR}=    Catenate    SEPARATOR=    //android.widget.TextView[@text='    ${list_of_names}[${0}][${checkbox}]    'and @enabled='true']
        ${NTH-CHECKBOX-LOCATOR}=    Catenate    SEPARATOR=    //android.view.ViewGroup[@content-desc='    group qr member list card ${checkbox}${SPACE}    Passport Expiry: 01 January 2029']
        Append To List     ${GROUP-CHECKBOX-LOCATOR}    ${NTH-CHECKBOX-LOCATOR}         
        
    END
    [Return]    @{GROUP-CHECKBOX-LOCATOR}

Click on n checkboxes on the profiles on the QR group page
    [Arguments]    @{dynamic_locators}    ${n_members}
    FOR  ${NTH-GROUP-MEMBER}  IN RANGE    ${n_members}
        IF      ${NTH-GROUP-MEMBER} < ${3}
            #Swipe By Percent    50    90    50    10    duration=${500}
            Click on element                    ${dynamic_locators}[${NTH-GROUP-MEMBER}]
        ELSE IF    ${NTH-GROUP-MEMBER} >= ${3}
            Scroll down on the screen    duration=${250}
            Click on element                    ${dynamic_locators}[${NTH-GROUP-MEMBER}]    
            
        END
             
    END
    
Navigate to QR Code page without tutorial flow
    Click on element                ${QR-CODE-FAV-BUTTON}
    # Click on tutorial interface no option
    Click on element                ${NO-THANKS-OPTION}