//
//  TimeSettingsSectionItem.swift
//  Drone
//
//  Created by Karl-John Chow on 21/4/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import UIKit

struct TimeSettingsSectionItem {
    var label: String
    var enabled:Bool?
    
    init(label:String) {
        self.label = label
        self.enabled = nil
    }
    
    init(label:String, enabled:Bool) {
        self.label = label
        self.enabled = enabled
    }
}
