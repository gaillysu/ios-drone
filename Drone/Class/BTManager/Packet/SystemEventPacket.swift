//
//  SystemEventPacket.swift
//  Drone
//
//  Created by leiyuncun on 16/4/12.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit

enum SystemEventStatus:Int {
    case goalCompleted = 1,
    lowMemory = 2,
    activityDataAvailable = 3,
    batteryStatusChanged = 5
}

class SystemEventPacket: NSObject {
    fileprivate var packetData:Data = Data()

    class func HEADER() -> UInt8 {
        return 0x02
    }

    init(data:Data) {
        super.init()
        packetData = data
    }

    func getSystemEventPacket() -> Data {
        return packetData
    }

    func getSystemEventStatus() -> Int {
        let data:[UInt8] = NSData2Bytes(packetData)
        let eventCommandStatus:Int = Int(data[2])
        return eventCommandStatus
    }
}
