*** Settings ***
Documentation     Shared iOS e-services navigation keywords for the repeatable
...               “open category → count cards → open tab → assert header → close browser”
...               workflow used across tests/ios/other_e_services.
Variables         ../../Resources/fork_config.py
Resource          ../../Resources/commands.robot
Variables         ${FORK_DATA_DIR}/ios/landing_page.yaml
Variables         ${FORK_DATA_DIR}/ios/other_e_services/other_e_services_page.yaml

*** Keywords ***
Open E-Service Portal And Verify
    [Documentation]    Template body for a single e-service portal case.
    ...                Clicks the favourites e-services button, opens the requested
    ...                portal, asserts the number of option cards, opens the requested
    ...                tab and optionally asserts the expected portal header.
    [Arguments]        ${portal_locator}    ${card_count}    ${tab_locator}    ${header_locator}=${EMPTY}
    Click on element        ${OTHER-E-SERVICES-FAV-BUTTON}
    Click on element        ${portal_locator}
    ### asserting the expected number of option cards on the portal screen
    Xpath Should Match X Times    //XCUIElementTypeOther[@name="card"]    ${card_count}
    Click on element        ${tab_locator}
    Run Keyword If          $header_locator != ''    Expect Element    ${header_locator}    visible
    Close iOS Chrome Browser
