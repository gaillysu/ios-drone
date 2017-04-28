//
//  CityMenuItem.Swift
//  Drone
//
//  Created by Karl Chow on 3/9/16.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import UIKit
import Font_Awesome_Swift

class CityNavigationMenuItem: MenuItem {
    
    func viewController() -> UIViewController{
        return WorldClockViewController()
    }
    
    func icon() -> FAType?{
        return FAType.FAMapO
    }
    
    func image() -> UIImage?{
        return nil
    }
    
    func title() -> String{
        return "City Navigation"
    }
    
    func comingSoon() -> Bool{
        return true
    }
}
