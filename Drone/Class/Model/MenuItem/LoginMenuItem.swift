//
//  LoginMenuItem.Swift
//  Drone
//
//  Created by Karl Chow on 3/9/16.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import UIKit
import Font_Awesome_Swift

class LoginMenuItem: MenuItem {
    
    func viewController() -> UIViewController{
        return WelcomeViewController(fromMenu: true)
    }
    
    func icon() -> FAType?{
        return FAType.FASignIn
    }
    
    func image() -> UIImage?{
        return nil
    }
    
    func title() -> String{
        return "Login"
    }
    
    func comingSoon() -> Bool{
        return false
    }
}
