//
//  SystemStatusPacket.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/31.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

enum SystemStatus:Int {
    case LowMemory = 0,
    InvalidTime = 3,
    GoalCompleted = 4,
    ActivityDataAvailable = 5,
    SubscribedToNotifications = 7,
    SystemReset = 8
}

class SystemStatusPacket: NSObject {

    private var packetData:NSData = NSData()

    init(data:NSData) {
        super.init()
        packetData = data
    }

    func getSystemStatusPacket() -> NSData {
        return packetData
    }

    func getSystemStatus() -> Int {
        let data:[UInt8] = NSData2Bytes(packetData)
        let systemStatus:Int = Int(data[2])
        return systemStatus
    }
}
