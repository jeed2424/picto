# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

target 'picto' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  #  pod 'FirebaseAnalytics'
    pod 'Firebase/Auth'
    pod 'Firebase/Messaging'
    pod 'Firebase/Storage'
    pod 'GoogleSignIn'
  # pod 'FirebaseFirestore'
    
    pod 'ActiveLabel'
    pod 'SDWebImage'
    pod 'Kingfisher', '~> 7.0'
    pod 'VerticalCardSwiper', :git => "https://github.com/jeed2424/VerticalCardSwiper.git"
  #  pod 'ReactiveCocoa'
    pod 'SwiftyBeaver'
    pod 'ObjectMapper'
    pod 'PixelSDK'
    pod 'CameraManager', '~> 5.1'
    pod 'UITextView+Placeholder'
    pod 'CDAlertView'
    pod 'SkyFloatingLabelTextField'
  # pod 'Delighted'
    pod 'SwiftLint'
    pod 'Foil'
    pod 'R.swift'
    pod 'Alamofire'
    pod 'SwifterSwift'
    pod 'DropDown'
    pod 'Kingfisher'
    pod 'Starscream', '~> 4.0'
    pod 'SnapKit', '~> 5.6.0'
    pod 'JGProgressHUD'
    pod 'DTPhotoViewerController'
    pod 'PanModal'
    pod 'YPImagePicker'
    pod 'SwiftyStoreKit'

  # Pods for picto

  target 'pictoTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'pictoUITests' do
    # Pods for testing
  end

end

post_install do |installer|
      installer.pods_project.targets.each do |target|
          target.build_configurations.each do |config|
          xcconfig_path = config.base_configuration_reference.real_path
          xcconfig = File.read(xcconfig_path)
          xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
          File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
          end
          target.build_configurations.each do |config|
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
          end

		installer.pods_project.build_configurations.each do |config|
    config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
    config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
  end
      end
  end