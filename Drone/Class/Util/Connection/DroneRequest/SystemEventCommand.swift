//
//  SystemEventCommand.swift
//  Drone
//
//  Created by leiyuncun on 16/3/11.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit

enum SystemEventStatus:Int {
    case GoalCompleted = 1,
    LowMemory = 2,
    ActivityDataAvailable = 3,
    BatteryStatusChanged = 5
}

class SystemEventCommand: NevoRequest {
    class func HEADER() -> UInt8 {
        return 0x02
    }
}
