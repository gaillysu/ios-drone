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
