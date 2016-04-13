//
//  SystemEventPacket.swift
//  Drone
//
//  Created by leiyuncun on 16/4/12.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit

enum SystemEventStatus:Int {
    case GoalCompleted = 1,
    LowMemory = 2,
    ActivityDataAvailable = 3,
    BatteryStatusChanged = 5
}

class SystemEventPacket: NSObject {
    private var packetData:NSData = NSData()

    class func HEADER() -> UInt8 {
        return 0x02
    }

    init(data:NSData) {
        super.init()
        packetData = data
    }

    func getSystemEventPacket() -> NSData {
        return packetData
    }

    func getSystemEventStatus() -> Int {
        let data:[UInt8] = NSData2Bytes(packetData)
        let eventCommandStatus:Int = Int(data[2])
        return eventCommandStatus
    }
}
