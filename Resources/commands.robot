*** Settings ***
Library    AppiumLibrary
Library    Collections
Library    Process
Library    OperatingSystem
Library    String
Library    helper_func.py
#Library    ../venv/lib/python3.13/site-packages/robot/libraries/String.py
#Library    RPA.Email.ImapSmtp
#Library    SeleniumLibrary
Variables   ../robotconfig.yaml
#Variables   ../Data/android/landing_page.yaml
#Variables   ../Data/ios/landing_page.yaml
#Variables   ../Data/android/yaml_tutorial_flow_pages/passport_qr_tutorial_flow.yaml
Variables   getabspath.py

*** Variables ***

#${ANDROID_PLATFORM_VERSION}       %{ANDROID_PLATFORM_VERSION=13}


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

#Generate dynamic group qr checkbox element locator for n group members
    #[Arguments]    @{list_of_names}    ${elementindex}
    #@{GROUP-CHECKBOX-LOCATOR}    Set Variable     ${None}
    #FOR  ${checkbox}  IN RANGE    ${elementindex}
        #${NTH-CHECKBOX-LOCATOR}=    Catenate    SEPARATOR=    //android.widget.TextView[@text='    ${list_of_names}[${0}][${checkbox}]    'and @enabled='true']
        #Append To List     ${GROUP-CHECKBOX-LOCATOR}    ${NTH-CHECKBOX-LOCATOR}         
        
    #END
    #[Return]    @{GROUP-CHECKBOX-LOCATOR}

Scroll down on the screen
    [Arguments]    ${duration}=${500}
    Swipe By Percent    50    50    50    10    duration=${duration}

Close Android Chrome Browser
    [Documentation]    Close Chrome by terminating the Android Chrome app.
    AppiumLibrary.Terminate Application    com.android.chrome





########################IOS##################################################################################################################
Start iOS Device Recording
    [Documentation]    Start per-suite screen recording on a real iOS device.
    ${safe_name}=    Replace String    ${SUITE NAME}    ${SPACE}    _
    ${outfile}=    Set Variable    ${OUTPUT DIR}/${safe_name}.mp4
    ${proc}=    Start Process    idevicescreenrecord    ${outfile}    stdout=NONE    stderr=NONE
    Set Suite Variable    ${REC_PROC}    ${proc}

Stop iOS Device Recording
    [Documentation]    Stop per-suite screen recording on a real iOS device.
    ${proc}=    Get Variable Value    ${REC_PROC}    ${NONE}
    Run Keyword If    '${proc}' != '${NONE}'    Terminate Process    ${proc}    kill=true

Open ios App on device
    #Open Application    http://127.0.0.1:4723    platformName=iOS    appium:platformVersion=18.4.1    appium:deviceName='Edwin's iPad'    appium:automationName=XCUITest    appium:udid=00008122-000A08312186801C    appium:noReset=${True}    appium:showXcodeLog=${True}    appium:app=${IOS_APP}    appium:xcodeOrgId=W6PMZD7K72    appium:includeSafariInWebviews=${True}    appium:newCommandTimeout=${3600}    appium:connectHardwareKeyboard=${True}
    Open Application    ${APPIUM_SERVER_URL}     platformName=${IOS_PLATFORM_NAME}    appium:platformVersion=${IOS_PLATFORM_VERSION}    appium:deviceName=${IOS_DEVICE_NAME}    appium:automationName=${IOS_AUTOMATION_NAME}    appium:udid=${IOS_DEVICE_UDID}    appium:noReset=${True}    appium:showXcodeLog=${True}    appium:app=${IOS_APP}    appium:xcodeOrgId=${IOS_XCODE_ORGID}    appium:includeSafariInWebviews=${True}    appium:newCommandTimeout=${3600}    appium:connectHardwareKeyboard=${True}


Close iOS Chrome Browser
    [Documentation]    Close Chrome by terminating the iOS Chrome app.
    AppiumLibrary.Terminate Application    com.google.chrome.ios
    
    
 

     
