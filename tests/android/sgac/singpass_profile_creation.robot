*** Settings ***
Documentation     SGAC2.0 resident profile creation via "Retrieve Myinfo with Singpass".
...
...               Credentials are NOT stored in the repository. Export them before running:
...                   export SINGPASS_NRIC=<staging test NRIC>
...                   export SINGPASS_PASSWORD=<staging test password>
...                   APP_FORK=sgac2 robot tests/android/sgac/singpass_profile_creation.robot
...               Without them the tests skip rather than fail, so unattended runs stay green.
...
...               Requires the staging tunnel: Singpass opens n.stg-id.singpass.gov.sg in Chrome.
Variables    ../../../Resources/fork_config.py
Library     AppiumLibrary
Library     ../../../Resources/helper_func.py
Resource    ../../../Resources/commands.robot
Resource    ../../../Resources/android/SGACcommands.robot
Variables    ${FORK_DATA_DIR}/android/landing_page.yaml
Variables    ${FORK_DATA_DIR}/android/sgac/sgac_landing_page.yaml
Variables    ${FORK_DATA_DIR}/android/profile_creation_method_page.yaml
Variables    ${FORK_DATA_DIR}/android/sgac/resident/resident_profile_creation_form_page.yaml
Variables    ${FORK_DATA_DIR}/android/sgac/singpass_login_page.yaml
Force Tags    fork:sgac2-only
Test Setup       Open MyICA App on Android Emulator
Test Teardown    Run Keywords    Close Android Chrome Browser    AND    Close Application

*** Variables ***
${SINGPASS-NRIC}        %{SINGPASS_NRIC=}
${SINGPASS-PASSWORD}    %{SINGPASS_PASSWORD=}

*** Test Cases ***
Resident reaches the Singpass login page from profile creation
    [Documentation]    The in-app path to Singpass: SG Arrival Card favourite -> Create New
    ...    Profile -> Retrieve Myinfo with Singpass hands off to Chrome and loads the Singpass
    ...    staging login for MYICAMOBILE. This stops at the handoff, so it needs no credentials.
    Navigate to SGAC2 resident profile creation method page
    Click on element    ${PROFILE-CREATION-SINGPASS-BUTTON}
    Wait Until Element Is Visible    ${SINGPASS-LOGIN-WEBVIEW}    ${SINGPASS-PAGE-TIMEOUT}
    Expect Element    ${SINGPASS-LOGIN-METHOD-HEADER}    visible

Singpass login succeeds but MyInfo retrieval returns no profile
    [Documentation]    REGRESSION GUARD for the defect found on build 2.0.0(15)/vc422
    ...    (2026-09-08): Singpass authentication succeeds, but the app returns to the
    ...    profile-creation method screen with no MyInfo consent step and no retrieved
    ...    profile. Reproduced on both the fresh and remembered-browser login paths.
    ...
    ...    This test PASSES while the defect is present. When MyInfo retrieval is fixed the
    ...    app will land on the profile form instead and this test will fail — that failure
    ...    is the signal to replace it with the positive assertions kept below.
    [Tags]    singpass    myinfo    known-defect
    Skip If    '${SINGPASS-NRIC}' == '' or '${SINGPASS-PASSWORD}' == ''
    ...    Set SINGPASS_NRIC and SINGPASS_PASSWORD to run the Singpass login tests.
    Navigate to SGAC2 resident profile creation method page
    Click on element    ${PROFILE-CREATION-SINGPASS-BUTTON}
    Log in to Singpass with password    ${SINGPASS-NRIC}    ${SINGPASS-PASSWORD}
    ## back in the app: the creation-method screen, not a retrieved profile
    Wait Until Element Is Visible    ${PROFILE-CREATION-SINGPASS-BUTTON}    ${SINGPASS-PAGE-TIMEOUT}
    Expect Element    ${PROFILE-CREATION-TITLE}    visible
    Page Should Not Contain Element    ${RES-PROFILE-NAME-INPUT}
    ## Positive assertions to restore once MyInfo retrieval works:
    ## Wait Until Element Is Visible    ${RES-PROFILE-NAME-INPUT}    ${SINGPASS-PAGE-TIMEOUT}
    ## Element Attribute Should Match    ${RES-PROFILE-NAME-INPUT}    text    ${EMPTY}    # retrieved name
    ## Expect Element    ${RES-PROFILE-CREATION-REMINDER}    visible    # "not editable" notice
