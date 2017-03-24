platform :ios, '9.0'
use_frameworks!

source 'https://github.com/CocoaPods/Specs.git'


target 'Drone' do
    pod 'Alamofire', '~> 4.0'
    pod 'Charts'
    pod 'PagingMenuController', '~> 1.4.0'
    pod 'SwiftEventBus', :tag => '2.1.0', :git => 'https://github.com/cesarferreira/SwiftEventBus.git'
    pod 'CircleProgressView'
    pod 'SMSegmentView', '~> 1.1'
    pod 'SDCycleScrollView','~> 1.3'
    pod 'AutocompleteField','~> 1.1'
    pod 'UIColor_Hex_Swift', '~> 2.1'
    pod 'CVCalendar', '~> 1.4.0'
    pod 'BRYXBanner'
    pod 'RegexKitLite'
    pod 'SwiftyJSON', '~> 3.1.4'
    pod 'MRProgress'
    pod 'SwiftyTimer', '~> 2.0.0'
    pod 'MSCellAccessory'
    pod 'IQKeyboardManagerSwift', '4.0.6'
    pod 'RealmSwift'
    pod 'SnapKit', '~> 3.0.1'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
