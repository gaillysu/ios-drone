//
//  DeviceMenuItem.Swift
//  Drone
//
//  Created by Karl Chow on 3/9/16.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import UIKit
import Font_Awesome_Swift

class DeviceMenuItem: MenuItem {
    
    func viewController() -> UIViewController{
        return WorldClockViewController()
    }
    
    func icon() -> FAType?{
        return FAType.FAClockO
    }
    
    func image() -> UIImage?{
        return UIImage(named: "icon_watch")
    }
    
    func title() -> String{
        return "Device"
    }
    
    func comingSoon() -> Bool{
        return false
    }
}
