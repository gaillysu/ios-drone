//
//  UIButtonExtension.swift
//  Drone
//
//  Created by Karl-John Chow on 19/4/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import UIKit
import Font_Awesome_Swift
class ClockwiseButton: UIButton {
    override func awakeFromNib() {
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor("#95989A").cgColor
        self.setFAIcon(icon: .FARotateRight, iconSize: 33.0, forState: .normal)
    }
}
