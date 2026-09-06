from appium import webdriver
from appium.options.ios import XCUITestOptions
import yaml

import fork_config

_FORK_VARS = fork_config.get_variables()

### opening and reading robot config yaml file
with open('robotconfig.yaml','r') as robotconfigfile:
    robot_ios_config = yaml.safe_load(robotconfigfile)

#print(robot_ios_config['IOS_DEVICE_NAME'])

## not including the bundle id in the remote driver as it will try to run the app
options = XCUITestOptions()
options.platform_name = robot_ios_config['IOS_PLATFORM_NAME']
options.device_name = robot_ios_config['IOS_DEVICE_NAME']
options.platform_version = robot_ios_config['IOS_PLATFORM_VERSION']
#options.bundle_id = robot_ios_config['ANDROID_APP_PACKAGE']
options.udid = robot_ios_config['IOS_DEVICE_UDID']
options.include_safari_in_webviews = True
options.automation_name = robot_ios_config['IOS_AUTOMATION_NAME']
options.xcode_org_id = robot_ios_config['IOS_XCODE_ORGID']
appium_server_url = robot_ios_config['APPIUM_SERVER_URL']


def terminate_app():
    driver = webdriver.Remote(appium_server_url, options=options)
    driver.terminate_app(_FORK_VARS["IOS_BUNDLE_ID"])




