//
//  ProfileMenuItem.Swift
//  Drone
//
//  Created by Karl Chow on 3/9/16.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import UIKit
import Font_Awesome_Swift

class ProfileMenuItem: MenuItem {
    
    func viewController() -> UIViewController{
        return ProfileViewController()
    }
    
    func icon() -> FAType?{
        return FAType.FAUser
    }
    
    func image() -> UIImage?{
        return nil
    }
    
    func title() -> String{
        return "Profile"
    }
    
    func comingSoon() -> Bool{
        return false
    }
}
