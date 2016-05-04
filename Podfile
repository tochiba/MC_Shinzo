platform :ios, "9.0"
use_frameworks!
pod 'NCMB', :git => 'https://github.com/NIFTYCloud-mbaas/ncmb_ios.git'
pod 'Fabric'
pod 'Crashlytics'
pod 'Meyasubaco'
pod 'Google-Mobile-Ads-SDK'
pod 'NendSDK_iOS'

post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods/Pods-Acknowledgements.plist', 'MC_Shinzo/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end