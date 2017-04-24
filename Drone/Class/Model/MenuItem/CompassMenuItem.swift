//
//  CompassMenuItem.Swift
//  Drone
//
//  Created by Karl Chow on 3/9/16.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import UIKit
import Font_Awesome_Swift

class CompassMenuItem: MenuItem {
    
    func viewController() -> UIViewController{
        return CompassViewController()
    }
    
    func icon() -> FAType?{
        return FAType.FACompass
    }
    
    func image() -> UIImage?{
        return nil
    }
    
    func title() -> String{
        return "Compass"
    }
    
    func comingSoon() -> Bool{
        return true
    }
}
