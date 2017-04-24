//
//  StepsMenuItem.Swift
//  Drone
//
//  Created by Karl Chow on 3/9/16.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import UIKit
import Font_Awesome_Swift

class TimeMenuItem: MenuItem {
    
    func viewController() -> UIViewController{
        return TimeTabViewController()
    }
    
    func icon() -> FAType?{
        return FAType.FAClockO
    }
    
    func image() -> UIImage?{
        return nil
    }
    
    func title() -> String{
        return "Time"
    }
    
    func comingSoon() -> Bool{
        return false
    }
}
