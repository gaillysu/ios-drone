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

class StepsMenuItem: MenuItem {
    
    func viewController() -> UIViewController{
        return StepsViewController()
    }
    
    func icon() -> FAType?{
        return FAType.FAAreaChart
    }
    
    func image() -> UIImage?{
        return nil
    }
    
    func title() -> String{
        return "Activities"
    }
    
    func comingSoon() -> Bool{
        return false
    }
}
