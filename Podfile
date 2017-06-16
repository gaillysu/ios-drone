platform :ios, '9.0'
use_frameworks!

source 'https://github.com/CocoaPods/Specs.git'


target 'Drone' do
    pod 'Alamofire'
    pod 'Charts'
    pod 'PagingMenuController'
    pod 'SwiftEventBus', :tag => '2.2.0', :git => 'https://github.com/cesarferreira/SwiftEventBus.git'
    pod 'CircleProgressView'
    pod 'UIColor_Hex_Swift'
    pod 'CVCalendar'
    pod 'BRYXBanner'
    pod 'SwiftyJSON'
    pod 'MRProgress'
    pod 'SwiftyTimer'
    pod 'MSCellAccessory'
    pod 'IQKeyboardManagerSwift'
    pod 'RealmSwift'
    pod 'SwiftReorder', '~> 2.0'
    pod 'RxSwift',    '~> 3.0'
    pod 'RxCocoa',    '~> 3.0'
    pod 'RxDataSources', '~> 1.0'
    pod 'SwiftyTimer'
    pod 'GoogleMaps'
    pod 'GooglePlaces'
    pod 'Font-Awesome-Swift'
    pod 'Pulley'
    pod 'PKHUD', '~> 4.0'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
