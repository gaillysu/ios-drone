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
 
    fileprivate final let TIMER_DURATION = 1.4;
    var timer:Timer?
    init() {
        super.init(nibName: "SplashScreenViewController", bundle: Bundle.main)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        timer = Timer.scheduledTimer(timeInterval: TIMER_DURATION, target: self, selector: #selector(SplashScreenViewController.nextController), userInfo: nil, repeats: true)
    }
    
    func nextController(){
        let user:NSArray = UserProfile.getAll()
        if(user.count > 0 ||  UserDevice.getAll().count > 0) {
            self.present(makeStandardUINavigationController(MenuViewController()), animated: true, completion: nil)
        }else{
            let navigationController = UINavigationController(rootViewController:WelcomeViewController());
            navigationController.isNavigationBarHidden = true
            self.present(navigationController, animated: true, completion: nil);
        }
        timer?.invalidate()
        timer = nil;
    }
}
