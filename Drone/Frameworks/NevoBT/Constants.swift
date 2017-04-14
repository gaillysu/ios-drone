//
//  Constants.swift
//  Drone
//
//  Created by Cloud on 2017/4/14.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit

enum DfuFirmwareTypes:UInt8{
    case  softdevice            = 0x01,
    bootloader                  = 0x02,
    softdevice_AND_BOOTLOADER   = 0x03,
    application                 = 0x04
}

enum SystemConfigID:UInt8 {
    case dndConfig              = 0x01
    case airplaneMode           = 0x02
    case enabled                = 0x04
    case clockFormat            = 0x08
    case sleepConfig            = 0x09
    case compassAutoOnDuration  = 0x10
    case topKeyCustomization    = 0x11
}

enum AppConfigApplicationID:Int {
    case worldClock         = 1
    case activityTracking   = 2
    case weather            = 3
    case compass            = 10
}

enum AppConfigAppState:Int {
    case on     = 1
    case off    = 0
}

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

enum SettingCompassOperation {
    case stopCompassCalibration     = 0x00
    case startCompassCalibration    = 0x01
}

enum WeatherStatusIcon:UInt8 {
    case invalidData        = 0x00
    case partlyCloudyNight  = 0x01
    case partlyCloudyDay    = 0x02
    case tornado            = 0x03
    case typhoon            = 0x04
    case hurricane          = 0x05
    case cloudy             = 0x06
    case fog                = 0x07
    case windy              = 0x08
    case snow               = 0x09
    case rainLight          = 0x0A
    case rainHeavy          = 0x0B
    case stormy             = 0x0C
    case clearDay           = 0x0D
    case clearNight         = 0x0E
}

class Constants: NSObject {
    
    static func Bytes2NSData(_ bytes:[UInt8]) -> Data {
        return Data(bytes: UnsafePointer<UInt8>(bytes), count: bytes.count)
    }
    
    static func NSData2Bytes(_ data:Data) -> [UInt8] {
        let bytes = UnsafeBufferPointer<UInt8>(start: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count), count:data.count)
        
        var ret:[UInt8] = []
        for  byte in bytes {
            ret.append(byte)
        }
        return ret
    }
    
    static func NSData2BytesSigned(_ data:Data) -> [Int8] {
        let bytes = UnsafeBufferPointer<Int8>(start: (data as NSData).bytes.bindMemory(to: Int8.self, capacity: data.count), count:data.count)
        var ret:[Int8] = []
        for  byte in bytes {
            ret.append(byte)
        }
        return ret
    }
    
    static func splitPacketConverter(data:[UInt8]) ->[Data] {
        let packetLenght:Int = 20
        var valuesData:[UInt8] = data
        
        var rawData:[Data] = []
        
        var valueArray:[UInt8] = []
        
        if valuesData.count>=packetLenght {
            for (index,value) in valuesData.enumerated() {
                let header:UInt8 = 0x00
                let header1:UInt8 = 0x80
                
                if(valueArray.count == 0) {
                    if valuesData.count-index < packetLenght {
                        valueArray.append(header1+UInt8(rawData.count&0xFF))
                    }else{
                        valueArray.append(header+UInt8(rawData.count&0xFF))
                    }
                }
                valueArray.append(value)
                
                if valueArray.count == packetLenght {
                    rawData.append(Data(bytes: UnsafePointer<UInt8>(valueArray), count: valueArray.count))
                    valueArray.removeAll()
                }
                
                if(index == valuesData.count-1) {
                    if(valueArray.count < packetLenght) {
                        for _:Int in valueArray.count..<packetLenght {
                            valueArray.append(0x00)
                        }
                    }
                    rawData.append(Data(bytes: UnsafePointer<UInt8>(valueArray), count: valueArray.count))
                    valueArray.removeAll()
                }
            }
        }else{
            valuesData.insert(0x80, at: 0)
            if(valuesData.count < 20) {
                for _:Int in valuesData.count..<packetLenght {
                    valuesData.append(0x00)
                }
            }
            rawData.append(Data(bytes: UnsafePointer<UInt8>(valuesData), count: valuesData.count));
        }
        return rawData
    }
}
