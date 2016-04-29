//
//  SplashScreenViewController.swift
//  Drone
//
//  Created by Karl Chow on 4/27/16.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import UIColor_Hex_Swift

class SplashScreenViewController: BaseViewController {
 
    private final let TIMER_DURATION = 1.4;
    var timer:NSTimer?
    override func viewDidAppear(animated: Bool) {
        timer = NSTimer.scheduledTimerWithTimeInterval(TIMER_DURATION, target: self, selector: #selector(SplashScreenViewController.nextController), userInfo: nil, repeats: true)
    }
    
    func nextController(){
        // IF !Logged in ->
        // RegisterViewController
        // ELSE
        let user:NSArray = UserProfile.getAll()
        if(user.count>0) {
            let navigationController = UINavigationController(rootViewController:MenuViewController());
            navigationController.navigationBar.barTintColor = UIColor.getBaseColor()

            self.presentViewController(navigationController, animated: true, completion: nil);
        }else{
            let navigationController = UINavigationController(rootViewController:WelcomeViewController());
            navigationController.navigationBarHidden = true
            self.presentViewController(navigationController, animated: true, completion: nil);
        }

        timer?.invalidate()
        timer = nil;
    }
}