//
//  UIButton+Extension.swift
//  Drone
//
//  Created by Karl-John Chow on 8/5/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import UIKit

extension UIButton{
    
    func setBackgroundColor(color: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, for: forState)
    }
    
    func enable(bool:Bool){
        self.isEnabled = bool
        self.alpha = bool ? 1.0 : 0.5
    }
}
