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
import Pulley
import IQKeyboardManagerSwift

class CityNavigationMenuItem: MenuItem {
    
    func viewController() -> UIViewController{
        UIApplication.shared.statusBarStyle = .lightContent
        let mapTableViewController = MapTableViewController()
        let mapNavigationViewController = MapNavigationViewController(rootViewController: mapTableViewController)
        let pulleyViewController = PulleyViewController(contentViewController: NavigationController(), drawerViewController: mapNavigationViewController)
        pulleyViewController.topInset = 50.0
        mapNavigationViewController.pulleyViewController = pulleyViewController
        return pulleyViewController
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
        return false
    }
}
