//
//  BPMController.swift
//  Nevo
//
//  Created by leiyuncun on 16/3/2.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

class BPMViewController: BaseViewController {
    
    init() {
        super.init(nibName: "BPMViewController", bundle: NSBundle.mainBundle())
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
