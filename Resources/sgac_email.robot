*** Settings ***
Variables    fork_config.py
Variables    ../Data/test_data/submission_email.yaml
Library      MailinatorDE.py    WITH NAME    SGACEmail

*** Keywords ***
Prepare Foreigner SGAC Email Capture
    [Documentation]    Call immediately before the submission action with the actual submitted email.
    [Arguments]    ${submission_key}    ${email_address}    ${expected_text}    ${domain}=${NONE}
    Set Test Variable    ${SGAC_DE_NUMBER}    ${NONE}
    SGACEmail.Start SGAC Email Capture    ${submission_key}    ${email_address}    ${expected_text}    ${domain}

Capture Foreigner SGAC DE Number
    [Documentation]    Call after the successful receipt. Returns DE and sets the test-scoped update variable.
    [Arguments]    ${submission_key}    ${store_path}=${NONE}    ${timeout}=120    ${poll_interval}=5
    ...    ${subject_contains}=SG Arrival Card    ${sender}=${NONE}
    Set Test Variable    ${SGAC_DE_NUMBER}    ${NONE}
    ${de}=    SGACEmail.Wait For SGAC DE Number    ${submission_key}
    ...    timeout=${timeout}    poll_interval=${poll_interval}    subject_contains=${subject_contains}
    ...    sender=${sender}    store_path=${store_path}
    Set Test Variable    ${SGAC_DE_NUMBER}    ${de}
    RETURN    ${de}

Get Foreigner SGAC DE Number For Update
    [Documentation]    Use the same submission key; optionally load its saved JSON in a new run.
    [Arguments]    ${submission_key}    ${store_path}=${NONE}
    Set Test Variable    ${SGAC_DE_NUMBER}    ${NONE}
    IF    $store_path is not None
        ${de}=    SGACEmail.Load SGAC DE Number    ${submission_key}    ${store_path}
    ELSE
        ${de}=    SGACEmail.Get Stored SGAC DE Number    ${submission_key}
    END
    Set Test Variable    ${SGAC_DE_NUMBER}    ${de}
    RETURN    ${de}
