//
//  StartSystemSettingRequest.swift
//  Drone
//
//  Created by Cloud on 2017/4/13.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit

enum SystemSettingApplicationID:UInt8 {
    case analogMovement = 0x01
    case compass        = 0x02
}

enum SettingAnalogMovementOperation:UInt8 {
    case exitHandsMode          = 0x00
    case startHandsMode         = 0x01
    case stopHandsMovement      = 0x10
    case secondAdvanceOneStep   = 0x11
    case secondReverseOneStep   = 0x12
    case secondStartAC          = 0x13
    case secondStartRC          = 0x14
    case minuteAdvanceOneStep   = 0x15
    case minuteReverseOneStep   = 0x16
    case minuteStartAC          = 0x17
    case minuteStartRC          = 0x18
    case hourAdvanceOneStep     = 0x19
    case hourReverseOneStep     = 0x1A
    case hourStartAC            = 0x1B
    case hourStartRC            = 0x1C
}

enum SettingCompassOperation:UInt8 {
    case stopCompassCalibration     = 0x00
    case startCompassCalibration    = 0x01
}

class StartSystemSettingRequest: DroneRequest {
    fileprivate var appid:UInt8 = 0;
    fileprivate var appOperation:UInt8 = 0;
    
    class func HEADER() -> UInt8 {
        return 0x34
    }
    
    init(id:SystemSettingApplicationID,operation:SettingAnalogMovementOperation) {
        super.init()
        appid = id.rawValue
        appOperation = operation.rawValue
    }
    
    override func getRawDataEx() -> [Data] {
        let values1 :[UInt8] = [0x80,StartSystemSettingRequest.HEADER(), appid, appOperation,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        return [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)]
    }
}
