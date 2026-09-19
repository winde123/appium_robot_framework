*** Settings ***
Variables    ../fork_config.py
Library    AppiumLibrary
Library    Collections
Library    String
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

# Foreigner profile persona (SGAC2.0 evidence: Australian visitor, build 2.0.0(15)).
${FOREIGNER-COUNTRY-OF-BIRTH}    AUSTRALIA
${FOREIGNER-NATIONALITY}         AUSTRALIAN
${FOREIGNER-RESIDENCE-SEARCH}    SYDNEY
${FOREIGNER-RESIDENCE-OPTION}    AUSTRALIA, NEW SOUTH WALES, SYDNEY (AUSTRALIA)
${FOREIGNER-SEX}                 FEMALE
${FOREIGNER-COUNTRY-CODE}        61

*** Keywords ***
Navigate to resident SGAC landing page
    Run Keyword    Navigate to resident SGAC landing page for ${APP_FORK}

Navigate to resident SGAC landing page for sgac1
    Click on element    ${CITIZEN-RESIDENT-ESERVICE-BUTTON}
    Click on element    ${CITIZEN-RES-SGAC}
    Click on element    ${SGAC-TUTORIAL-NAV-SGAC-BTN}

Navigate to resident SGAC landing page for sgac2
    Click on element    ${CITIZEN&RESIDENT-SGARRIVAL-CARD-FAV-BUTTON}
    Wait Until Element Is Visible    ${SGAC-CREATE-NEW-PROFILE-BUTTON}    ${INTERACTION_WAIT_TIMEOUT}

Navigate to resident profile list page
    Run Keyword    Navigate to resident profile list page for ${APP_FORK}

Navigate to resident profile list page for sgac1
    Click on element    ${SGAC-VIEW-PROFILE-BUTTON}

Navigate to resident profile list page for sgac2
    [Documentation]    The Manage Profiles list itself was not captured in the build-15
    ...    evidence set; this keyword only performs the tap and does not assert the list.
    Click on element    ${SGAC-MANAGE-PROFILES-BUTTON}

Navigate to resident profile creation method page
    [Documentation]    Precondition: the SGAC landing page is open. Ends on the
    ...    "Choose profile creation method" page with the "fill manually" option visible.
    Run Keyword    Navigate to resident profile creation method page for ${APP_FORK}

Navigate to resident profile creation method page for sgac1
    Navigate to resident profile list page
    Click on element    ${SGAC-ADD-PROFILE-BUTTON}
    Wait Until Element Is Visible    ${PROFILE-CREATION-FILL-MANUALLY-BUTTON}    ${INTERACTION_WAIT_TIMEOUT}

Navigate to resident profile creation method page for sgac2
    Click on element    ${SGAC-CREATE-NEW-PROFILE-BUTTON}
    Wait Until Element Is Visible    ${PROFILE-CREATION-FILL-MANUALLY-BUTTON}    ${INTERACTION_WAIT_TIMEOUT}

Fill resident profile form
    [Documentation]    Precondition: the profile creation method page is open.
    ...    Fills page 1 (profile details), the contact page, and ends on the summary page.
    [Arguments]    ${profile}
    Click on element    ${PROFILE-CREATION-FILL-MANUALLY-BUTTON}
    Run Keyword    Fill resident profile page 1 for ${APP_FORK}    ${profile}
    Click on element    ${RES-PROFILE-FOOTER-NEXT-BUTTON}
    Fill resident profile contact details    ${profile}
    Click on element    ${RES-PROFILE-FOOTER-NEXT-BUTTON}

Fill resident profile page 1 for sgac1
    [Arguments]    ${profile}
    Type text    ${RES-PROFILE-NAME-INPUT}    ${profile}[name]
    Input NRIC into input field for android device    ${RES-PROFILE-NRIC-FIN-INPUT}    ${profile}[nric]
    Type text    ${RES-PROFILE-DOB-INPUT}    ${profile}[dob]

Fill resident profile page 1 for sgac2
    [Arguments]    ${profile}
    Type text    ${RES-PROFILE-NAME-INPUT}    ${profile}[name]
    Type text    ${RES-PROFILE-DOB-INPUT}    ${profile}[dob]
    Input NRIC into input field for android device    ${RES-PROFILE-NRIC-FIN-INPUT}    ${profile}[nric]
    Select resident nationality    SINGAPOREAN
    Type text    ${RES-PROFILE-PASSPORT-NUMBER-INPUT}    ${profile}[pp_num]
    Type text    ${RES-PROFILE-PASSPORT-EXPIRY-INPUT}    ${profile}[pp_expiry]

Select resident nationality
    [Documentation]    Open the nationality modal, search, and select the matching option.
    [Arguments]    ${nationality}
    Click on element    ${RES-PROFILE-NATIONALITY-DROPDOWN}
    Wait Until Element Is Visible    ${RES-PROFILE-NATIONALITY-MODAL-SEARCH}    ${INTERACTION_WAIT_TIMEOUT}
    Type text    ${RES-PROFILE-NATIONALITY-MODAL-SEARCH}    ${nationality}
    ${option}=    Format String    ${RES-PROFILE-NATIONALITY-OPTION-BY-NAME-TEMPLATE}    ${nationality}
    Click on element    ${option}

Fill resident profile contact details
    [Documentation]    Fill the shared contact page (country code, mobile, email).
    [Arguments]    ${profile}
    Type text    ${RES-PROFILE-CONTACT-COUNTRY-CODE-INPUT}    ${profile}[cty_code]
    Type text    ${RES-PROFILE-CONTACT-MOBILE-NUMBER-INPUT}    ${profile}[phno]
    Type text    ${RES-PROFILE-CONTACT-EMAIL-INPUT}    ${profile}[email]

Verify resident profile summary
    [Documentation]    Assert that the summary page displays the values from ${profile}.
    [Arguments]    ${profile}
    ${name_sel}=    Format String    //android.widget.TextView[@text="{}"]    ${profile}[name]
    ${dob}=    helper_func.Date Field Formatter    ${profile}[dob]
    ${dob_sel}=    Format String    //android.widget.TextView[contains(@text,"{}")]    ${dob}
    ${nric_sel}=    Format String    //android.widget.TextView[@text="{}"]    ${profile}[nric]
    ${cty_code}=    Set Variable    +${profile}[cty_code]
    ${cty_sel}=    Format String    //android.widget.TextView[@text="{}"]    ${cty_code}
    ${phno}=    Convert To String    ${profile}[phno]
    ${phno_sel}=    Format String    //android.widget.TextView[@text="{}"]    ${phno}
    ${email_sel}=    Format String    //android.widget.TextView[@text="{}"]    ${profile}[email]
    Expect Element    ${name_sel}    visible
    Expect Element    ${dob_sel}    visible
    Expect Element    ${nric_sel}    visible
    Expect Element    ${cty_sel}    visible
    Expect Element    ${phno_sel}    visible
    Expect Element    ${email_sel}    visible
    Run Keyword    Verify resident profile summary extras for ${APP_FORK}    ${profile}

Verify resident profile summary extras for sgac1
    [Arguments]    ${profile}
    No Operation

Verify resident profile summary extras for sgac2
    [Arguments]    ${profile}
    ${nat_sel}=    Format String    //android.widget.TextView[@text="{}"]    SINGAPOREAN
    ${pp_num_sel}=    Format String    //android.widget.TextView[@text="{}"]    ${profile}[pp_num]
    ${pp_expiry}=    helper_func.Date Field Formatter    ${profile}[pp_expiry]
    ${pp_expiry_sel}=    Format String    //android.widget.TextView[contains(@text,"{}")]    ${pp_expiry}
    Expect Element    ${nat_sel}    visible
    Expect Element    ${pp_num_sel}    visible
    Expect Element    ${pp_expiry_sel}    visible

Accept terms and save resident profile
    Click on element    ${RES-CONFIRM-PROFILE-TERMS-CHECKBOX}
    Click on element    ${RES-FOOTER-SAVE-BUTTON}

Create resident profile manually
    [Arguments]    ${profile}=${NONE}
    IF    $profile is None
        ${profile}=    manual_field_random.Generate Profile Record    country=SG
    END
    Run Keyword    Create resident profile manually for ${APP_FORK}    ${profile}
    RETURN    ${profile}

Create resident profile manually for sgac1
    [Documentation]    Precondition: a screen showing the ADD PROFILE button is open
    ...    (the individual profile list in the sgac1 flow). Composed from the shared
    ...    fill/save steps so the sgac1 click/type sequence has a single source of truth.
    [Arguments]    ${profile}
    Click on element    ${SGAC-ADD-PROFILE-BUTTON}
    Fill resident profile form    ${profile}
    Accept terms and save resident profile

Create resident profile manually for sgac2
    [Documentation]    Precondition: the SGAC landing page is open.
    [Arguments]    ${profile}
    Navigate to resident profile creation method page
    Fill resident profile form    ${profile}
    Accept terms and save resident profile

Navigate to individual submission creation page
    [Documentation]    *sgac1-only*: the native Individual Submission flow does not exist in
    ...    SGAC2.0 (replaced by an in-app webview submission flow).
    Click on element    ${SGAC-INDIVIDUAL-SUBMISSION-BUTTON}
    Click on element    ${SGAC-INDIVIDUAL-ADD-SUBMISSION-BUTTON}

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

# --- Foreigner profile CRUD (SGAC2.0 only) ---
# SGAC1.0 Android has no dedicated foreigner locator tree; the sgac1 implementations
# fail fast so a later implementation can add the tree.

Import foreigner locator files
    [Documentation]    Load the sgac2 foreigner YAMLs at runtime. They cannot be
    ...    imported in Settings because Data/sgac1/android/sgac/foreigner/ does not exist.
    Import Variables    ${FORK_DATA_DIR}/android/sgac/foreigner/for_profile_form.yaml
    Import Variables    ${FORK_DATA_DIR}/android/sgac/foreigner/for_profile_summary.yaml
    Import Variables    ${FORK_DATA_DIR}/android/sgac/foreigner/for_form_cty_page.yaml
    Import Variables    ${FORK_DATA_DIR}/android/sgac/foreigner/for_form_nationality_page.yaml
    Import Variables    ${FORK_DATA_DIR}/android/sgac/foreigner/for_form_residence_page.yaml

Navigate to foreigner SGAC landing page
    Run Keyword    Navigate to foreigner SGAC landing page for ${APP_FORK}

Navigate to foreigner SGAC landing page for sgac1
    Fail    Foreigner SGAC profile flow is not implemented for sgac1 on Android (no sgac1 foreigner locator tree); run with APP_FORK=sgac2

Navigate to foreigner SGAC landing page for sgac2
    Click on element    ${FORIEGNVISITOR-SGARRIVAL-CARD-FAV-BUTTON}
    Wait Until Element Is Visible    ${SGAC-CREATE-NEW-PROFILE-BUTTON}    ${INTERACTION_WAIT_TIMEOUT}

Navigate to foreigner profile creation method page
    [Documentation]    Precondition: the SGAC foreigner landing page is open.
    Run Keyword    Navigate to foreigner profile creation method page for ${APP_FORK}

Navigate to foreigner profile creation method page for sgac1
    Fail    Foreigner SGAC profile flow is not implemented for sgac1 on Android (no sgac1 foreigner locator tree); run with APP_FORK=sgac2

Navigate to foreigner profile creation method page for sgac2
    Click on element    ${SGAC-CREATE-NEW-PROFILE-BUTTON}
    Wait Until Element Is Visible    ${PROFILE-CREATION-FILL-MANUALLY-BUTTON}    ${INTERACTION_WAIT_TIMEOUT}

Fill foreigner profile form
    [Documentation]    Precondition: the profile creation method page is open.
    ...    Fills page 1 (passport details), page 2 (contact details), and ends on the summary.
    [Arguments]    ${profile}
    Run Keyword    Fill foreigner profile form for ${APP_FORK}    ${profile}

Fill foreigner profile form for sgac1
    [Arguments]    ${profile}
    Fail    Foreigner SGAC profile flow is not implemented for sgac1 on Android (no sgac1 foreigner locator tree); run with APP_FORK=sgac2

Fill foreigner profile form for sgac2
    [Arguments]    ${profile}
    Import foreigner locator files
    Click on element    ${PROFILE-CREATION-FILL-MANUALLY-BUTTON}
    Type text    ${FOR-PROFILE-FORM-FULL-NAME-INPUT}    ${profile}[name]
    Select foreigner sex    ${FOREIGNER-SEX}
    Type text    ${FOR-PROFILE-FORM-DOB-INPUT}    ${profile}[dob]
    Select foreigner searchable option
    ...    ${FOR-PROFILE-FORM-CTY-BIRTH-LIST}
    ...    ${FOR-CTY-SEARCH-INPUT}
    ...    ${FOR-CTY-OPTION-BY-NAME-TEMPLATE}
    ...    ${FOREIGNER-COUNTRY-OF-BIRTH}
    ...    ${FOREIGNER-COUNTRY-OF-BIRTH}
    Select foreigner searchable option
    ...    ${FOR-PROFILE-FORM-NATIONALITY-LIST}
    ...    ${FOR-NATIONALITY-SEARCH-INPUT}
    ...    ${FOR-NATIONALITY-OPTION-BY-NAME-TEMPLATE}
    ...    ${FOREIGNER-NATIONALITY}
    ...    ${FOREIGNER-NATIONALITY}
    Type text    ${FOR-PROFILE-FORM-PASSPORT-NO-INPUT}    ${profile}[foreign_pp_num]
    Type text    ${FOR-PROFILE-FORM-PASSPORT-EXPIRY-INPUT}    ${profile}[pp_expiry]
    Click on element    ${FOR-PROFILE-FORM-FOOTER-NEXT-BUTTON}
    Select foreigner searchable option
    ...    ${FOR-PROFILE-FORM-RESIDENCE-LIST}
    ...    ${FOR-RESIDENCE-SEARCH-INPUT}
    ...    ${FOR-RESIDENCE-OPTION-BY-NAME-TEMPLATE}
    ...    ${FOREIGNER-RESIDENCE-SEARCH}
    ...    ${FOREIGNER-RESIDENCE-OPTION}
    Type text    ${FOR-PROFILE-FORM-COUNTRY-CODE-INPUT}    ${profile}[cty_code]
    Type text    ${FOR-PROFILE-FORM-MOBILE-NUMBER-INPUT}    ${profile}[phno]
    Type text    ${FOR-PROFILE-FORM-EMAIL-INPUT}    ${profile}[email]
    Click on element    ${FOR-PROFILE-FORM-CONTACT-NEXT-BUTTON}

Select foreigner sex
    [Documentation]    Open the Sex dropdown and tap the named option.
    [Arguments]    ${sex}
    Click on element    ${FOR-PROFILE-FORM-SEX-DROPDOWN-EXPAND}
    Wait Until Element Is Visible    ${FOR-PROFILE-FORM-SEX-OPTION-${sex}}    ${INTERACTION_WAIT_TIMEOUT}
    Click on element    ${FOR-PROFILE-FORM-SEX-OPTION-${sex}}

Select foreigner searchable option
    [Documentation]    Open a searchable modal, type the search text, and tap the option.
    [Arguments]
    ...    ${list_locator}
    ...    ${search_locator}
    ...    ${option_template}
    ...    ${search_text}
    ...    ${option_text}
    Click on element    ${list_locator}
    Wait Until Element Is Visible    ${search_locator}    ${INTERACTION_WAIT_TIMEOUT}
    Type text    ${search_locator}    ${search_text}
    ${option}=    Format String    ${option_template}    ${option_text}
    Click on element    ${option}

Verify foreigner profile summary
    [Documentation]    Assert that the summary page displays the values from ${profile}.
    [Arguments]    ${profile}
    Run Keyword    Verify foreigner profile summary for ${APP_FORK}    ${profile}

Verify foreigner profile summary for sgac1
    [Arguments]    ${profile}
    Fail    Foreigner SGAC profile flow is not implemented for sgac1 on Android (no sgac1 foreigner locator tree); run with APP_FORK=sgac2

Verify foreigner profile summary for sgac2
    [Arguments]    ${profile}
    Import foreigner locator files
    ${sex_letter}=    Get Substring    ${FOREIGNER-SEX}    0    1
    ${name_sel}=    Format String    //android.widget.TextView[@text="{}"]    ${profile}[name]
    ${sex_sel}=    Format String    //android.widget.TextView[@text="{}"]    ${sex_letter}
    ${dob}=    helper_func.Date Field Formatter    ${profile}[dob]
    ${dob_sel}=    Format String    //android.widget.TextView[contains(@text,"{}")]    ${dob}
    ${cty_birth_sel}=    Format String    //android.widget.TextView[@text="{}"]    ${FOREIGNER-COUNTRY-OF-BIRTH}
    ${nationality_sel}=    Format String    //android.widget.TextView[@text="{}"]    ${FOREIGNER-NATIONALITY}
    ${pp_num_sel}=    Format String    //android.widget.TextView[@text="{}"]    ${profile}[foreign_pp_num]
    ${pp_expiry}=    helper_func.Date Field Formatter    ${profile}[pp_expiry]
    ${pp_expiry_sel}=    Format String    //android.widget.TextView[contains(@text,"{}")]    ${pp_expiry}
    ${residence_sel}=    Format String    //android.widget.TextView[@text="{}"]    ${FOREIGNER-RESIDENCE-OPTION}
    ${cty_code}=    Set Variable    +${profile}[cty_code]
    ${cty_code_sel}=    Format String    //android.widget.TextView[@text="{}"]    ${cty_code}
    ${phno}=    Convert To String    ${profile}[phno]
    ${phno_sel}=    Format String    //android.widget.TextView[@text="{}"]    ${phno}
    ${email_sel}=    Format String    //android.widget.TextView[@text="{}"]    ${profile}[email]
    Expect Element    ${name_sel}    visible
    Expect Element    ${sex_sel}    visible
    Expect Element    ${dob_sel}    visible
    Expect Element    ${cty_birth_sel}    visible
    Expect Element    ${nationality_sel}    visible
    Expect Element    ${pp_num_sel}    visible
    Expect Element    ${pp_expiry_sel}    visible
    Expect Element    ${residence_sel}    visible
    Expect Element    ${cty_code_sel}    visible
    Expect Element    ${phno_sel}    visible
    Expect Element    ${email_sel}    visible

Accept terms and save foreigner profile
    Run Keyword    Accept terms and save foreigner profile for ${APP_FORK}

Accept terms and save foreigner profile for sgac1
    Fail    Foreigner SGAC profile flow is not implemented for sgac1 on Android (no sgac1 foreigner locator tree); run with APP_FORK=sgac2

Accept terms and save foreigner profile for sgac2
    Import foreigner locator files
    Click on element    ${FOR-PROFILE-SUMMARY-TERMS-CHECKBOX-UNCHECKED}
    Click on element    ${FOR-PROFILE-SUMMARY-SAVE-BUTTON}

Create foreigner profile manually
    [Documentation]    Precondition: the SGAC foreigner landing page is open.
    ...    Generates a record when none is supplied and returns it.
    [Arguments]    ${profile}=${NONE}
    IF    $profile is None
        ${profile}=    manual_field_random.Generate Profile Record
    END
    Set To Dictionary    ${profile}    cty_code=${FOREIGNER-COUNTRY-CODE}
    Run Keyword    Create foreigner profile manually for ${APP_FORK}    ${profile}
    RETURN    ${profile}

Create foreigner profile manually for sgac1
    [Arguments]    ${profile}
    Fail    Foreigner SGAC profile flow is not implemented for sgac1 on Android (no sgac1 foreigner locator tree); run with APP_FORK=sgac2

Create foreigner profile manually for sgac2
    [Arguments]    ${profile}
    Navigate to foreigner profile creation method page
    Fill foreigner profile form    ${profile}
    Accept terms and save foreigner profile

