//
//  SleepController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/2.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class SleepViewController: BaseViewController {

    init() {
        super.init(nibName: "SleepViewController", bundle: NSBundle.mainBundle())
        self.tabBarItem.title = "Sleep"
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = "Steps"
    }
}
