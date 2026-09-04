import os

def getandroidabspath():
     return (os.path.abspath('icaApp/1.15.0_(3)_368.apk'))

def getiosabspath():
     return (os.path.abspath('icaApp/sgac_test.ipa'))


ANDROID_APP = getandroidabspath()
IOS_APP = getiosabspath()