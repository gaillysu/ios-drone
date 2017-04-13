//
//  NotificationsMenuItem.Swift
//  Drone
//
//  Created by Karl Chow on 3/9/16.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import UIKit
import Font_Awesome_Swift

class NotificationsMenuItem: MenuItem {
    
    func viewController() -> UIViewController{
        return NotificationViewController()
    }
    
    func icon() -> FAType?{
        return FAType.FASliders
    }
    
    func image() -> UIImage?{
        return nil
    }
    
    func title() -> String{
        return "Notifications"
    }
    
    func comingSoon() -> Bool{
        return false
    }
}
