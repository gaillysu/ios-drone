//
//  PulleyViewController+Extension.swift
//  Drone
//
//  Created by Cloud on 2017/5/5.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit
import Pulley

extension PulleyViewController {

    open override func viewWillAppear(_ animated: Bool) {
        self.addCloseButton(#selector(dismissViewController))
    }
    
    func dismissViewController(){
        self.dismiss(animated: true, completion: nil)
    }
}
