*** Settings ***
Variables    ../fork_config.py
Library    AppiumLibrary
Library    Collections
Library    ../../Data/test_data/manual_field_random.py
Resource    ../commands.robot
Variables    ../../Data/test_data/input_fields_test_data.yaml
Variables    ${FORK_DATA_DIR}/android/landing_page.yaml
Variables    ${FORK_DATA_DIR}/android/citizen_and_res_page.yaml
Variables    ${FORK_DATA_DIR}/android/sgac/sgac_landing_page.yaml
Variables    ${FORK_DATA_DIR}/android/sgac/individual_submission_page.yaml
Variables    ${FORK_DATA_DIR}/android/sgac/indv_profile_list_page.yaml
Variables    ${FORK_DATA_DIR}/android/profile_creation_method_page.yaml
Variables    ${FORK_DATA_DIR}/android/sgac/resident/resident_profile_creation_form_page.yaml
Variables    ${FORK_DATA_DIR}/android/sgac/resident/resident_confirmation_profile_page.yaml
Variables    ${FORK_DATA_DIR}/android/sgac/singpass_login_page.yaml

*** Variables ***
# Singpass runs on external staging infrastructure and is slower to settle than the app.
${SINGPASS-PAGE-TIMEOUT}      40s
${SINGPASS-SCROLL-ATTEMPTS}   ${4}

*** Keywords ***
Navigate to resident SGAC landing page
    Click on element    ${CITIZEN-RESIDENT-ESERVICE-BUTTON}
    Click on element    ${CITIZEN-RES-SGAC}
    Click on element    ${SGAC-TUTORIAL-NAV-SGAC-BTN}

Navigate to individual submission creation page
    Click on element    ${SGAC-INDIVIDUAL-SUBMISSION-BUTTON}
    Click on element    ${SGAC-INDIVIDUAL-ADD-SUBMISSION-BUTTON}

Navigate to resident profile list page
    Click on element    ${SGAC-VIEW-PROFILE-BUTTON}

Create resident profile manually
    [Arguments]    ${profile}=${NONE}
    IF    $profile is None
        ${profile}=    manual_field_random.Generate Profile Record    country=SG
    END
    Click on element    ${SGAC-ADD-PROFILE-BUTTON}
    Click on element    ${PROFILE-CREATION-FILL-MANUALLY-BUTTON}
    Type text    ${RES-PROFILE-NAME-INPUT}    ${profile}[name]
    Input NRIC into input field for android device    ${RES-PROFILE-NRIC-FIN-INPUT}    ${profile}[nric]
    Type text    ${RES-PROFILE-DOB-INPUT}    ${profile}[dob]
    Click on element    ${RES-PROFILE-FOOTER-NEXT-BUTTON}
    Type text    ${RES-PROFILE-CONTACT-COUNTRY-CODE-INPUT}    ${profile}[cty_code]
    Type text    ${RES-PROFILE-CONTACT-MOBILE-NUMBER-INPUT}    ${profile}[phno]
    Type text    ${RES-PROFILE-CONTACT-EMAIL-INPUT}    ${profile}[email]
    Click on element    ${RES-PROFILE-FOOTER-NEXT-BUTTON}
    Click on element    ${RES-CONFIRM-PROFILE-TERMS-CHECKBOX}
    Click on element    ${RES-FOOTER-SAVE-BUTTON}
    RETURN    ${profile}

Navigate to SGAC2 resident profile creation method page
    [Documentation]    SGAC2.0 path from MyICA Home to "Choose profile creation method":
    ...    the Citizen & Resident SG Arrival Card favourite lands directly on the
    ...    profile-centric SGAC screen (2.0 removed the tutorial gate), where Create New
    ...    Profile opens the creation-method choices. sgac1 uses a different flow
    ...    (`Navigate to resident SGAC landing page`), so this keyword is SGAC2.0-only.
    Click on element    ${CITIZEN&RESIDENT-SGARRIVAL-CARD-FAV-BUTTON}
    Click on element    ${SGAC-CREATE-NEW-PROFILE-BUTTON}
    Wait Until Element Is Visible    ${PROFILE-CREATION-SINGPASS-BUTTON}

Log in to Singpass with password
    [Documentation]    Complete the Singpass password login that "Retrieve Myinfo with Singpass"
    ...    opens in Chrome. Handles both page states: a fresh login (Singpass ID + password)
    ...    and the remembered-browser state (password only), which Singpass enters after any
    ...    successful login on this device. The login-method buttons render below the fold and
    ...    Chrome only exposes on-screen nodes, so the page is scrolled before they are addressed.
    [Arguments]    ${nric}    ${password}
    Wait Until Element Is Visible    ${SINGPASS-LOGIN-WEBVIEW}    ${SINGPASS-PAGE-TIMEOUT}
    Scroll To Singpass Login Method Buttons
    Click on element    ${SINGPASS-PASSWORD-AUTH-BUTTON}
    Wait Until Element Is Visible    ${SINGPASS-PASSWORD-INPUT}    ${SINGPASS-PAGE-TIMEOUT}
    ${fresh_login}=    Run Keyword And Return Status
    ...    Page Should Contain Element    ${SINGPASS-USERNAME-INPUT}
    IF    ${fresh_login}
        Type text    ${SINGPASS-USERNAME-INPUT}    ${nric}
    END
    Type text    ${SINGPASS-PASSWORD-INPUT}    ${password}
    Click on element    ${SINGPASS-LOGIN-SUBMIT-BUTTON}

Scroll To Singpass Login Method Buttons
    [Documentation]    Bring the Singpass login-method buttons into view. Chrome renders only
    ...    visible content, so an off-screen button is genuinely absent from the page source.
    ...    Returns once the password-authentication button is present.
    ${on_screen}=    Run Keyword And Return Status
    ...    Page Should Contain Element    ${SINGPASS-PASSWORD-AUTH-BUTTON}
    IF    not ${on_screen}
        FOR    ${attempt}    IN RANGE    ${SINGPASS-SCROLL-ATTEMPTS}
            Swipe By Percent    50    80    50    25
            ${on_screen}=    Run Keyword And Return Status
            ...    Page Should Contain Element    ${SINGPASS-PASSWORD-AUTH-BUTTON}
            Exit For Loop If    ${on_screen}
        END
    END
    Page Should Contain Element    ${SINGPASS-PASSWORD-AUTH-BUTTON}
    
