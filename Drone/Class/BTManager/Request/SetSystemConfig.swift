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
    case analogHandsConfig      = 0x12
}

class SetSystemConfig: DroneRequest {
    
    fileprivate var mIndex:Int = 0
    fileprivate var clockFormat:Int = 0;
    fileprivate var sleepMode:Int = 0 ;
    fileprivate var sleepAutoStartTime:TimeInterval = 0;
    fileprivate var sleepAutoEndTime:TimeInterval = 0;
    fileprivate var systemConfig = SystemConfigID.dndConfig
    fileprivate var mode:Int = 0
    fileprivate var analogHandsConfig = AnalogHandsConfig.CurrentTime
    
    class func HEADER() -> UInt8 {
        return 0x0F
    }
    init(autoStart:TimeInterval,autoEnd:TimeInterval,configtype:SystemConfigID) {
        super.init()
        sleepAutoStartTime = autoStart
        sleepAutoEndTime = autoEnd
        systemConfig = configtype
    }

    init(autoStart:TimeInterval,autoEnd:TimeInterval,configtype:SystemConfigID,autoMode:Int) {
        super.init()
        sleepAutoStartTime = autoStart
        sleepAutoEndTime = autoEnd
        systemConfig = configtype
        mode = autoMode
    }

    init(analogHandsConfig:AnalogHandsConfig) {
        super.init()
        self.systemConfig = .analogHandsConfig
        self.analogHandsConfig = analogHandsConfig
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
            let values :[UInt8] = [0x80,SetSystemConfig.HEADER(),systemConfig.rawValue,UInt8(mode&0xFF),UInt8((mode>>8)&0xFF),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
            return [Data(bytes: UnsafePointer<UInt8>(values), count: values.count)]
        case SystemConfigID.topKeyCustomization:
            let values :[UInt8] = [0x80,SetSystemConfig.HEADER(),systemConfig.rawValue,0x01,0x01,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
            return [Data(bytes: UnsafePointer<UInt8>(values), count: values.count)]
        case .analogHandsConfig:
            let values :[UInt8] = [0x80,SetSystemConfig.HEADER(),systemConfig.rawValue,analogHandsConfig.rawValue,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
            return [Data(bytes: UnsafePointer<UInt8>(values), count: values.count)]
        }
    }
    
    enum AnalogHandsConfig: UInt8 {
        case CurrentTime        =      0x00
        case WorldTimeFirst     =      0x01
        case WorldTimeSecond    =      0x02
        case WorldTimeThird     =      0x03
        case WorldTimeFourth    =      0x04
        case WorldTimeFifth     =      0x05
        case WorldTimeSixth     =      0x06
    }
}
