*** Settings ***
Library    AppiumLibrary
Library    Collections
Library    helper_func.py
#Library    RPA.Email.ImapSmtp
#Library    SeleniumLibrary
Variables   ../robotconfig.yaml
Variables   ../Data/landing_page.yaml
Variables   ../Data/yaml_tutorial_flow_pages/passport_qr_tutorial_flow.yaml 
Variables   getabspath.py

*** Variables ***



*** Keywords ***
Open Android App in emulator
    [Arguments]    ${appActivity}=${EMPTY}
    Open Application    http://127.0.0.1:4723   automationName=${ANDROID_AUTOMATION_NAME}    app=${ANDROID_APP}    platformName=${ANDROID_PLATFORM_NAME}    deviceName=${ANDROID_EMULATOR_NAME}  platformVersion=${ANDROID_PLATFORM_VERSION}     appPackage=${ANDROID_APP_PACKAGE}      appActivity=${appActivity}     

Open Android App in Android Phone
    [Arguments]    ${appActivity}=${EMPTY}
    Open Application    http://127.0.0.1:4723   automationName=${ANDROID_AUTOMATION_NAME}    platformName=${ANDROID_PLATFORM_NAME}    deviceName=${ANDROID_DEVICE_NAME}  platformVersion=${ANDROID_PLATFORM_VERSION}     appPackage=${ANDROID_APP_PACKAGE}      appActivity=${appActivity}  
Click on element
    [Arguments]    ${elementid}
    #${CLICK-ELEMENT-STATUS}    Set Variable    ${KEYWORD STATUS}
    Wait Until Keyword Succeeds    1min     5sec    AppiumLibrary.Wait Until Page Contains Element    locator=${elementid}    timeout=${10}
    Wait Until Keyword Succeeds    1min     5sec    AppiumLibrary.Click element  locator=${elementid}
    #[Teardown]    ${CLICK-ELEMENT-STATUS}    Set Variable    ${KEYWORD STATUS}  

Type text
    [Arguments]    ${elementid}    ${textstring}                      
    Wait Until Keyword Succeeds     1min     5sec     AppiumLibrary.Wait Until Page Contains Element    locator=${elementid}
    AppiumLibrary.Input Text    locator=${elementid}    text=${textstring}

Generate dynamic group qr checkbox element locator for n group members
    [Arguments]    @{list_of_names}    ${elementindex}
    @{GROUP-CHECKBOX-LOCATOR}    Set Variable     ${None}
    FOR  ${checkbox}  IN RANGE    ${elementindex}
        ${NTH-CHECKBOX-LOCATOR}=    Catenate    SEPARATOR=    //android.widget.TextView[@text='    ${list_of_names}[${0}][${checkbox}]    'and @enabled='true']
        Append To List     ${GROUP-CHECKBOX-LOCATOR}    ${NTH-CHECKBOX-LOCATOR}         
        
    END
    [Return]    @{GROUP-CHECKBOX-LOCATOR}

Scroll down on the screen
    Swipe By Percent    50    50    50    10    duration=${500}

Navigate to QR Code page without tutorial flow
    Click on element                ${QR-CODE-FAV-BUTTON}
    # Click on tutorial interface no option
    Click on element                ${NO-THANKS-OPTION}
 

     