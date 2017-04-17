//
//  ActivityViewController.swift
//  Drone
//
//  Created by Karl Chow on 3/8/16.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import CircleProgressView

class AnalysisViewController: UIViewController {
    @IBOutlet var caloriesLabel: UILabel!
    @IBOutlet var activeTimeLabel: UILabel!
    @IBOutlet var milesLabel: UILabel!
    
    init() {
        super.init(nibName: "ActivityViewController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {

        
    }

}
