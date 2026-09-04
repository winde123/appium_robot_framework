*** Settings ***
Library     AppiumLibrary
Library     ../../Resources/helper_func.py
Resource    ../../Resources/commands.robot
Variables   ../../Data/android/landing_page.yaml
Test Setup       Open Android App in emulator    appActivity=sg.gov.ica.mobile.app.MainActivity  
Test Teardown    Close Application

*** Test Cases *** 

Verification of visibility of the scam banner and navigation via the banner
    [Documentation]    to verify visbiliy and functionality of scam banner
    #Click on element    	//android.widget.TextView[@text="Citizen and Resident"]
    #Click on element   //android.widget.Button[@content-desc="Back"]
    ${DUR}=     helper_func.Convert Int To Secs    30
    #Scroll down on the screen
    Scroll Down    ${MYICA-SCAM-BANNER}    ${DUR}        
    
    Click on element    ${MYICA-SCAM-BANNER}
    Expect Element      ${MYICA-SCAM-BANNER-HEADER-ELEM}    visible
    Close Android Chrome Browser