//
//  SystemStatusPacket.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/31.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

enum SystemStatus:Int {
    case lowMemory = 0,
    invalidTime = 3,
    goalCompleted = 4,
    activityDataAvailable = 5,
    subscribedToNotifications = 7,
    systemReset = 8
}

class SystemStatusPacket: NSObject {

    fileprivate var packetData:Data = Data()

    init(data:Data) {
        super.init()
        packetData = data
    }

    func getSystemStatusPacket() -> Data {
        return packetData
    }

    func getSystemStatus() -> Int {
        let data:[UInt8] = Constants.NSData2Bytes(packetData)
        let systemStatus:Int = Int(data[2])
        return systemStatus
    }
}
