source "https://github.com/CocoaPods/Old-Specs"
use_frameworks!
platform :ios, '8.0'

target 'Shelf' do

	pod 'Parse'
	pod 'ParseUI'
	pod 'ParseFacebookUtilsV4'
	pod 'FBSDKCoreKit'
	pod 'FBSDKLoginKit'
	pod 'FBSDKShareKit'
	pod 'AFNetworking'
	pod 'MBProgressHUD'
	pod 'Mobile-Buy-SDK'
	pod 'Firebase/Core'
	pod 'Stripe'
	pod 'Kingfisher'
	pod 'DZNEmptyDataSet'
	pod 'PhoneNumberKit'
	pod 'SwiftKeychainWrapper'
	pod 'ObjectMapper'
	pod 'RazzleDazzle'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
      config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
      config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
    end
  end
end
