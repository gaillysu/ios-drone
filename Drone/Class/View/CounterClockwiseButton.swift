//
//  UIButtonExtension.swift
//  Drone
//
//  Created by Karl-John Chow on 19/4/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import UIKit
import Font_Awesome_Swift
class CounterClockwiseButton: ClockwiseButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setFAIcon(icon: .FARotateLeft, iconSize: 33.0, forState: .normal)
    }
}
