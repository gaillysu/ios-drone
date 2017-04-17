//
//  SetSystemConfig.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/29.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

enum SystemConfigID:UInt8 {
    case dndConfig              = 0x01
    case airplaneMode           = 0x02
    case enabled                = 0x04
    case clockFormat            = 0x08
    case sleepConfig            = 0x09
    case compassAutoOnDuration  = 0x10
    case topKeyCustomization    = 0x11
}

class SetSystemConfig: DroneRequest {
    
    fileprivate var mIndex:Int = 0
    fileprivate var clockFormat:Int = 0;
    fileprivate var sleepMode:Int = 0 ;
    fileprivate var sleepAutoStartTime:TimeInterval = 0;
    fileprivate var sleepAutoEndTime:TimeInterval = 0;
    fileprivate var systemConfig:SystemConfigID = SystemConfigID.dndConfig
    
    class func HEADER() -> UInt8 {
        return 0x0F
    }

    init(autoStart:TimeInterval,autoEnd:TimeInterval,configtype:SystemConfigID) {
        super.init()
        sleepAutoStartTime = autoStart
        sleepAutoEndTime = autoEnd
        systemConfig = configtype
    }

    override func getRawDataEx() -> [Data] {
        switch systemConfig {
        case SystemConfigID.dndConfig:
            let values :[UInt8] = [0x80,SetSystemConfig.HEADER(),systemConfig.rawValue,0x01,0x01,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
            return [Data(bytes: UnsafePointer<UInt8>(values), count: values.count)]
        case SystemConfigID.airplaneMode:
            let values :[UInt8] = [0x80,SetSystemConfig.HEADER(),systemConfig.rawValue,0x01,0x01,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
            return [Data(bytes: UnsafePointer<UInt8>(values), count: values.count)]
        case SystemConfigID.enabled:
            let values :[UInt8] = [0x80,SetSystemConfig.HEADER(),systemConfig.rawValue,0x01,0x01,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
            return [Data(bytes: UnsafePointer<UInt8>(values), count: values.count)]
        case SystemConfigID.clockFormat:
            let values:[UInt8] = [0x80,SetSystemConfig.HEADER(),systemConfig.rawValue,0x01,0x01,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
            return [Data(bytes: UnsafePointer<UInt8>(values), count: values.count)]
        case SystemConfigID.sleepConfig:
            let values:[UInt8] = [0x80,SetSystemConfig.HEADER(),systemConfig.rawValue,0x05,
                                    UInt8(Int(sleepAutoStartTime)&0xFF),
                                    UInt8((Int(sleepAutoStartTime)>>8)&0xFF),
                                    UInt8(Int(sleepAutoEndTime)&0xFF),
                                    UInt8((Int(sleepAutoEndTime)>>8)&0xFF),0,0,0,0,0,0,0,0,0,0,0,0]
            return [Data(bytes: UnsafePointer<UInt8>(values), count: values.count)]
        case SystemConfigID.compassAutoOnDuration:
            let values :[UInt8] = [0x80,SetSystemConfig.HEADER(),systemConfig.rawValue,0x02,0x01,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
            return [Data(bytes: UnsafePointer<UInt8>(values), count: values.count)]
        case SystemConfigID.topKeyCustomization:
            let values :[UInt8] = [0x80,SetSystemConfig.HEADER(),systemConfig.rawValue,0x01,0x01,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
            return [Data(bytes: UnsafePointer<UInt8>(values), count: values.count)]
        }
    }
}
