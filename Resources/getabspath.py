import os

def getandroidabspath():
     return (os.path.abspath('icaApp/app-staging-release.apk'))

def getiosabspath():
     return (os.path.abspath('icaApp/sgac_test.ipa'))


ANDROID_APP = getandroidabspath()
IOS_APP = getiosabspath()