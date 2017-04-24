//
//  TimeSettingsSectionItem.swift
//  Drone
//
//  Created by Karl-John Chow on 21/4/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import UIKit

class TimeSettingsSectionItem {
    var label: String
    var status:Bool
    
    init(label:String, status:Bool) {
        self.label = label
        self.status = status
    }
}
