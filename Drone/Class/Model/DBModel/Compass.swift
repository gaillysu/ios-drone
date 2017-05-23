//
//  Compass.swift
//  Drone
//
//  Created by Karl-John Chow on 18/4/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import UIKit

class Compass: MEDBaseModel {
    
    dynamic var id:Int = 0
    dynamic var autoMotionDetection:Int = 0
    dynamic var screenTimeout:Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
