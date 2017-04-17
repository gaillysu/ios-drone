platform :ios, '9.0'
use_frameworks!

source 'https://github.com/CocoaPods/Specs.git'


target 'Drone' do
    pod 'Alamofire', '~> 4.0'
    pod 'Charts'
    pod 'PagingMenuController', '~> 1.4.0'
    pod 'SwiftEventBus', :tag => '2.2.0', :git => 'https://github.com/cesarferreira/SwiftEventBus.git'
    pod 'CircleProgressView'
    pod 'UIColor_Hex_Swift'
    pod 'CVCalendar', '~> 1.4.0'
    pod 'BRYXBanner'
    pod 'SwiftyJSON'
    pod 'MRProgress'
    pod 'SwiftyTimer', '~> 2.0.0'
    pod 'MSCellAccessory'
    pod 'IQKeyboardManagerSwift'
    pod 'RealmSwift'
    pod 'SnapKit', '~> 3.0.1'
    pod 'SwiftReorder', '~> 2.0'
    pod 'RxSwift',    '~> 3.0'
    pod 'RxCocoa',    '~> 3.0'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
