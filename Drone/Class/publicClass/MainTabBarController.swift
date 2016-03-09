//
//  MainTabBarController.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/13.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController,UITabBarControllerDelegate {

    var items:NSMutableArray!
    var selectedItem:UIButton!
    var itemView:UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        self.tabBar.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        // Do any additional setup after loading the view.

    }

    override func viewDidAppear(animated: Bool) {
        let viewArray:[AnyObject] = self.viewControllers!
        for nav in viewArray {
            let contll = (nav as! UINavigationController).topViewController
            if contll!.isKindOfClass(StepsViewController){
                (nav as! UINavigationController).tabBarItem.title = NSLocalizedString("Steps", comment: "")
                AppTheme.DLog("StepController:\(contll)")
            }
            if contll!.isKindOfClass(SettingsViewController){
                (nav as! UINavigationController).tabBarItem.title = NSLocalizedString("Setting", comment: "")
                AppTheme.DLog("SetingViewController:\(contll)")
            }
            
        }
    }

    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController){

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
