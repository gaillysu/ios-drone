//
//  StepController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/2.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

let NUMBER_OF_STEPS_GOAL_KEY = "NUMBER_OF_STEPS_GOAL_KEY"

class StepController: UIViewController,UIActionSheetDelegate {
   
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.title = NSLocalizedString("stepGoalTitle", comment: "")
        self.navigationItem.title = "Steps"
    }
}
