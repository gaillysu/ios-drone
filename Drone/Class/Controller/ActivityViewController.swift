//
//  ActivityViewController.swift
//  Drone
//
//  Created by Karl Chow on 3/8/16.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

class ActivityViewController: UITabBarController {

    override func viewDidLoad() {
        let stepsController = StepsViewController()
        let sleepController = SleepViewController()
        setViewControllers([stepsController, sleepController], animated: true)
    }
}