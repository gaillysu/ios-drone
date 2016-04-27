//
//  SplashScreenViewController.swift
//  Drone
//
//  Created by Karl Chow on 4/27/16.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

class SplashScreenViewController: BaseViewController {
 
    private final let TIMER_DURATION = 1.4;
    
    override func viewDidLoad() {
        let timer = NSTimer.scheduledTimerWithTimeInterval(TIMER_DURATION, target: self, selector: #selector(SplashScreenViewController.nextController), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    func nextController(){
        // IF !Logged in ->
        // RegisterViewController
        // ELSE
        let navigationController = UINavigationController(rootViewController:MenuViewController());
        self.presentViewController(navigationController, animated: true, completion: nil);
    }
}