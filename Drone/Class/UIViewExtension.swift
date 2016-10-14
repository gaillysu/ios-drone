//
//  UIViewExtension.swift
//  Drone
//
//  Created by Karl-John on 3/5/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    class func loadFromNibNamed(_ nibNamed: String, bundle : Bundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }
}
