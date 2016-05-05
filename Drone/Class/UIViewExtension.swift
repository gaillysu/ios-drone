//
//  UIViewExtension.swift
//  Drone
//
//  Created by Karl-John on 3/5/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

extension UIView {
    class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiateWithOwner(nil, options: nil)[0] as? UIView
    }
}