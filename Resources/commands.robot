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
Variables   fork_config.py
Variables   ../robotconfig.yaml
#Variables   ../Data/android/landing_page.yaml
#Variables   ../Data/ios/landing_page.yaml
#Variables   ../Data/android/yaml_tutorial_flow_pages/passport_qr_tutorial_flow.yaml

*** Variables ***

#${ANDROID_PLATFORM_VERSION}       %{ANDROID_PLATFORM_VERSION=13}
${REMOTE_PLATFORM_NAME}            %{DEVICEFARM_DEVICE_PLATFORM_NAME}
${REMOTE_DEVICE_NAME}              %{DEVICEFARM_DEVICE_NAME}
${REMOTE_APP}                      %{DEVICEFARM_APP_PATH}


*** Keywords ***
Open MyICA App Remotely
    [Documentation]    Fork-agnostic Device Farm app open: device/app come from the DEVICEFARM_* env vars (${REMOTE_*}), package/activity from fork_config.py for the active ${APP_FORK}.
    Open Application    remote_url=${APPIUM_SERVER_URL}   automationName=${ANDROID_AUTOMATION_NAME}    app=${REMOTE_APP}    platformName=${REMOTE_PLATFORM_NAME}   deviceName=${REMOTE_DEVICE_NAME}    appPackage=${ANDROID_APP_PACKAGE}      appActivity=${ANDROID_APP_ACTIVITY}

Open MyICA App on Android Emulator
    [Documentation]    Fork-agnostic app open on the Android emulator: binary/package/activity come from fork_config.py for the active ${APP_FORK}. Both forks share one package ID and UiAutomator2 skips downgrades, so when switching forks run once with ENFORCE_APP_INSTALL=True to force the selected apk onto the device.
    Open Application    remote_url=${APPIUM_SERVER_URL}   automationName=${ANDROID_AUTOMATION_NAME}    app=${ANDROID_APP}    platformName=${ANDROID_PLATFORM_NAME}    deviceName=${ANDROID_EMULATOR_NAME}  platformVersion=${ANDROID_PLATFORM_VERSION}     appPackage=${ANDROID_APP_PACKAGE}      appActivity=${ANDROID_APP_ACTIVITY}    enforceAppInstall=${ENFORCE_APP_INSTALL}

Open MyICA App on Android Phone
    [Documentation]    Fork-agnostic app open on the physical Android device: binary/package/activity come from fork_config.py for the active ${APP_FORK}. app= is passed so the selected fork gets installed/upgraded; when switching forks run once with ENFORCE_APP_INSTALL=True (downgrades are skipped otherwise).
    Open Application    ${APPIUM_SERVER_URL}   automationName=${ANDROID_AUTOMATION_NAME}    app=${ANDROID_APP}    platformName=${ANDROID_PLATFORM_NAME}    deviceName=${ANDROID_DEVICE_NAME}  platformVersion=${ANDROID_PLATFORM_VERSION}     appPackage=${ANDROID_APP_PACKAGE}      appActivity=${ANDROID_APP_ACTIVITY}    enforceAppInstall=${ENFORCE_APP_INSTALL}

Open Android App remotely
    [Documentation]    *DEPRECATED* Use `Open MyICA App Remotely` instead. The ${appActivity} argument is ignored — the active fork's ${ANDROID_APP_ACTIVITY} from fork_config.py is authoritative.
    [Arguments]    ${appActivity}=${EMPTY}
    Open MyICA App Remotely

Open Android App in emulator
    [Documentation]    *DEPRECATED* Use `Open MyICA App on Android Emulator` instead. The ${appActivity} argument is ignored — the active fork's ${ANDROID_APP_ACTIVITY} from fork_config.py is authoritative.
    [Arguments]    ${appActivity}=${EMPTY}
    Open MyICA App on Android Emulator

Open Android App in Android Phone
    [Documentation]    *DEPRECATED* Use `Open MyICA App on Android Phone` instead. The ${appActivity} argument is ignored — the active fork's ${ANDROID_APP_ACTIVITY} from fork_config.py is authoritative.
    [Arguments]    ${appActivity}=${EMPTY}
    Open MyICA App on Android Phone
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
    [Arguments]    ${duration}=${1}
    ${DUR}=    helper_func.Convert Int To Secs    ${duration}
    Swipe By Percent    50    50    50    10    duration=${DUR}


Close Android Chrome Browser
    [Documentation]    Close Chrome by terminating the Android Chrome app.
    AppiumLibrary.Terminate Application    com.android.chrome

Input NRIC into input field for android device
    [Documentation]    this is for inputting  nric field into secure fields. Need to enable insecure adb shell
    [Arguments]    ${nric_field_locator}    ${textstring}
    Click on element        ${nric_field_locator}
    @{split_nric_str} =     helper_func.String Splitter    ${textstring}    ${2}
    FOR    ${split_str}    IN    @{split_nric_str}
        Execute Adb Shell    input text    ${split_str}
        Sleep    1s
            
    END





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

Open MyICA App on iOS Device
    [Documentation]    Fork-agnostic app open on the real iOS device: launches the TestFlight-installed build by ${IOS_BUNDLE_ID} from fork_config.py (nothing is installed; noReset keeps device state).
    Open Application    ${APPIUM_SERVER_URL}     platformName=${IOS_PLATFORM_NAME}    appium:platformVersion=${IOS_PLATFORM_VERSION}    appium:deviceName=${IOS_DEVICE_NAME}    appium:automationName=${IOS_AUTOMATION_NAME}    appium:udid=${IOS_DEVICE_UDID}    appium:noReset=${True}    appium:showXcodeLog=${True}    appium:bundleId=${IOS_BUNDLE_ID}    appium:xcodeOrgId=${IOS_XCODE_ORGID}    appium:includeSafariInWebviews=${True}    appium:newCommandTimeout=${3600}    appium:connectHardwareKeyboard=${True}

Open ios App on device
    [Documentation]    *DEPRECATED* Use `Open MyICA App on iOS Device` instead — it launches the TestFlight-installed build by the active fork's ${IOS_BUNDLE_ID}.
    Open MyICA App on iOS Device


Close iOS Chrome Browser
    [Documentation]    Close Chrome by terminating the iOS Chrome app.
    AppiumLibrary.Terminate Application    com.google.chrome.ios
    
    
 

     
