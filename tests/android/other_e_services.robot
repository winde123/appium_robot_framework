*** Settings ***
Library     AppiumLibrary
Resource    ../../Resources/commands.robot
Test Teardown    Close Application

*** Variables ***
${OTHER-ESERVICE-BUTTON}    //android.view.ViewGroup[@resource-id='HomeOther e-Services']

*** Test Cases *** 
[Documentation]Open ICA application test and click on other e-services button
    Open Android App    sg.gov.ica.mobile.app.MainActivity
    Click on element    ${OTHER-ESERVICE-BUTTON} 
    