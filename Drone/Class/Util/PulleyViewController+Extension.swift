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
        let appdelegate:AppDelegate = AppDelegate.getAppDelegate()
        if appdelegate.getNavigationState() {
            let alertControl:UIAlertController = UIAlertController(title: "exit error", message: "is can not exit in navigation", preferredStyle: UIAlertControllerStyle.alert)
            let alertAction:UIAlertAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.cancel, handler: { (action) in
                
            })
            alertControl.addAction(alertAction)
            self.present(alertControl, animated: true, completion: nil)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
}
