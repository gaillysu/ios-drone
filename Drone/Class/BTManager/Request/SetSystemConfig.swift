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

enum ClockFormat:UInt8 {
    case format12h           = 0x01
    case format24h           = 0x02
}

enum DeviceEnabled:UInt8 {
    case disabled          = 0x00
    case enabled           = 0x01
}

enum DNDConfigMode:UInt8 {
    case off          = 0x00
    case on           = 0x01
    case auto         = 0x02
}

class SetSystemConfig: DroneRequest {
    fileprivate var sleepAutoStartTime:TimeInterval = 0;
    fileprivate var sleepAutoEndTime:TimeInterval = 0;
    fileprivate var systemConfig:SystemConfigID = SystemConfigID.dndConfig
    fileprivate var clockFormat:ClockFormat = ClockFormat.format24h
    fileprivate var deviceEnabled:DeviceEnabled = DeviceEnabled.enabled
    fileprivate var dndMode:DNDConfigMode = DNDConfigMode.auto
    fileprivate var duration:Int = 0
    
    class func HEADER() -> UInt8 {
        return 0x0F
    }

    init(autoStart:TimeInterval,autoEnd:TimeInterval,configtype:SystemConfigID,mode:DNDConfigMode) {
        super.init()
        dndMode = mode
        sleepAutoStartTime = autoStart
        sleepAutoEndTime = autoEnd
        systemConfig = configtype
    }
    
    init(configtype:SystemConfigID,autoOnDuration:Int) {
        super.init()
        duration = autoOnDuration
        systemConfig = configtype
    }
    
    init(configtype:SystemConfigID,format:ClockFormat) {
        super.init()
        clockFormat = format
        systemConfig = configtype
    }
    
    init(configtype:SystemConfigID,isAvailable:DeviceEnabled) {
        super.init()
        deviceEnabled = isAvailable
        systemConfig = configtype
    }

    override func getRawDataEx() -> [Data] {
        switch systemConfig {
        case SystemConfigID.dndConfig:
            let values:[UInt8] = [0x80,SetSystemConfig.HEADER(),systemConfig.rawValue,
                                  dndMode.rawValue,
                                  UInt8(Int(sleepAutoStartTime)&0xFF),
                                  UInt8((Int(sleepAutoStartTime)>>8)&0xFF),
                                  UInt8(Int(sleepAutoEndTime)&0xFF),
                                  UInt8((Int(sleepAutoEndTime)>>8)&0xFF),0,0,0,0,0,0,0,0,0,0,0,0]
            return [Data(bytes: UnsafePointer<UInt8>(values), count: values.count)]
            
        case SystemConfigID.airplaneMode:
            let values :[UInt8] = [0x80,SetSystemConfig.HEADER(),systemConfig.rawValue,deviceEnabled.rawValue,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
            return [Data(bytes: UnsafePointer<UInt8>(values), count: values.count)]
            
        case SystemConfigID.enabled:
            let values :[UInt8] = [0x80,SetSystemConfig.HEADER(),systemConfig.rawValue,deviceEnabled.rawValue,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
            return [Data(bytes: UnsafePointer<UInt8>(values), count: values.count)]
            
        case SystemConfigID.clockFormat:
            let values:[UInt8] = [0x80,SetSystemConfig.HEADER(),systemConfig.rawValue,clockFormat.rawValue,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
            return [Data(bytes: UnsafePointer<UInt8>(values), count: values.count)]
            
        case SystemConfigID.sleepConfig:
            let values:[UInt8] = [0x80,SetSystemConfig.HEADER(),systemConfig.rawValue,
                                    dndMode.rawValue,
                                    UInt8(Int(sleepAutoStartTime)&0xFF),
                                    UInt8((Int(sleepAutoStartTime)>>8)&0xFF),
                                    UInt8(Int(sleepAutoEndTime)&0xFF),
                                    UInt8((Int(sleepAutoEndTime)>>8)&0xFF),0,0,0,0,0,0,0,0,0,0,0,0]
            return [Data(bytes: UnsafePointer<UInt8>(values), count: values.count)]
            
        case SystemConfigID.compassAutoOnDuration:
            let values :[UInt8] = [0x80,SetSystemConfig.HEADER(),systemConfig.rawValue,0x02,UInt8(duration&0xFF),UInt8(duration>>8&0xFF),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
            return [Data(bytes: UnsafePointer<UInt8>(values), count: values.count)]
            
        case SystemConfigID.topKeyCustomization:
            let values :[UInt8] = [0x80,SetSystemConfig.HEADER(),systemConfig.rawValue,0x01,deviceEnabled.rawValue,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
            return [Data(bytes: UnsafePointer<UInt8>(values), count: values.count)]
        }
    }
}
