platform :ios, '9.0'
use_frameworks!
target 'Drone' do
    pod 'FMDB'
    pod 'Alamofire', '~> 4.0'
    pod 'Charts', :git => 'https://github.com/danielgindi/Charts.git', :branch => 'Swift-3.0'
    pod 'PagingMenuController'
    pod 'SwiftEventBus', :tag => '2.1.0', :git => 'https://github.com/cesarferreira/SwiftEventBus.git'
    pod 'CircleProgressView', :git => 'https://github.com/CardinalNow/iOS-CircleProgressView.git'
    pod 'Timepiece'
    pod 'SMSegmentView', '~> 1.1'
    pod 'XCGLogger', :git => 'https://github.com/DaveWoodCom/XCGLogger.git', :branch => 'swift_3.0'
    pod 'SDCycleScrollView','~> 1.3'
    pod 'AutocompleteField','~> 1.1'
    pod 'UIColor_Hex_Swift', '~> 2.1'
    pod 'CVCalendar', '~> 1.4.0'
    pod 'BRYXBanner'
    pod 'RegexKitLite'
    pod 'SwiftyJSON', :git => 'https://github.com/IBM-Swift/SwiftyJSON.git'
    pod 'MRProgress'
    pod 'SwiftyTimer', git: 'https://github.com/radex/SwiftyTimer.git', branch: 'swift3'
    pod 'MSCellAccessory'
    pod 'IQKeyboardManagerSwift', '4.0.6'
    pod 'RealmSwift'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
