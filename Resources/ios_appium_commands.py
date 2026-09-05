import os
import sys

from appium import webdriver
from appium.options.ios import XCUITestOptions
import yaml

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


def _fork_ios_bundle_id():
    """Resolve the active fork's iOS bundle ID via Resources/fork_config.py (the single resolver)."""
    resources_dir = os.path.dirname(os.path.abspath(__file__))
    if resources_dir not in sys.path:
        sys.path.insert(0, resources_dir)
    import fork_config
    return fork_config.get_variables()['IOS_BUNDLE_ID']


def terminate_app(bundle_id=None):
    """Terminate the app under test on the iOS device.

    ``bundle_id`` defaults to the active fork's ``${IOS_BUNDLE_ID}`` from
    fork_config.py, so existing no-argument callers keep today's behavior;
    callers may pass ``${IOS_BUNDLE_ID}`` (or another bundle id) explicitly.
    """
    if bundle_id is None:
        bundle_id = _fork_ios_bundle_id()
    driver = webdriver.Remote(appium_server_url, options=options)
    driver.terminate_app(bundle_id)




