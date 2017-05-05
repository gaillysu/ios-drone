//
//  MapNavigationViewController.swift
//  Drone
//
//  Created by Cloud on 2017/5/5.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit
import Pulley

class MapNavigationViewController: UINavigationController,UINavigationControllerDelegate {
    var drawerPositions:[PulleyPosition] = PulleyPosition.all
    var collapsedHeight:CGFloat = 80.0
    weak var pulleyViewController:PulleyViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.navigationBar.isHidden = true
        self.interactivePopGestureRecognizer?.delegate = self
        self.interactivePopGestureRecognizer?.isEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if let pulley = self.pulleyViewController {
            var opacity:CGFloat = 0.5
            self.drawerPositions = PulleyPosition.all
            self.collapsedHeight = 80.0
            pulley.setNeedsSupportedDrawerPositionsUpdate()
            pulley.backgroundDimmingOpacity = opacity
        }
    }
}

extension MapNavigationViewController: PulleyDrawerViewControllerDelegate{
    
    func collapsedDrawerHeight() -> CGFloat{
        return self.collapsedHeight
    }
    
    func partialRevealDrawerHeight() -> CGFloat{
        return 250.0
    }
    
    func supportedDrawerPositions() -> [PulleyPosition]{
        return self.drawerPositions
    }
}

extension MapNavigationViewController: UIGestureRecognizerDelegate{
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
