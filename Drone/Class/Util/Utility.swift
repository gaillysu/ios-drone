//
//  Utility.swift
//  Nevo
//
//  Created by supernova on 15/2/4.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import Foundation

enum DfuFirmwareTypes:UInt8{
    case  softdevice = 0x01,
    bootloader = 0x02,
    softdevice_AND_BOOTLOADER = 0x03,
    application = 0x04
}

enum SystemConfigID:UInt8 {
    case dndConfig = 0x01
    case airplaneMode = 0x02
    case enabled = 0x04
    case clockFormat = 0x08
    case sleepConfig = 0x09
    case compassAutoOnDuration = 0x10
    case topKeyCustomization = 0x11
}

enum ApplicationID:Int {
    case WorldClock = 1
    case ActivityTracking = 2
    case Weather = 3
    case Compass = 10
}

enum AppState:Int {
    case on = 1
    case off = 0
}

func Bytes2NSData(_ bytes:[UInt8]) -> Data
{
  return Data(bytes: UnsafePointer<UInt8>(bytes), count: bytes.count)
}

func NSData2Bytes(_ data:Data) -> [UInt8]
{
    let bytes = UnsafeBufferPointer<UInt8>(start: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count), count:data.count)
    
    var ret:[UInt8] = []
    for  byte in bytes {
        ret.append(byte)
    }
    return ret
}

func NSData2BytesSigned(_ data:Data) -> [Int8]
{
    let bytes = UnsafeBufferPointer<Int8>(start: (data as NSData).bytes.bindMemory(to: Int8.self, capacity: data.count), count:data.count)
    
    var ret:[Int8] = []
    for  byte in bytes {
        ret.append(byte)
    }
    return ret
}


func NSString2NSData(_ string:NSString) -> Data
{
    let mString = string
    let trimmedString:String = mString.trimmingCharacters(in: CharacterSet(charactersIn: "<> ")).replacingOccurrences(of: " ", with: "")
    
    // make sure the cleaned up string consists solely of hex digits, and that we have even number of them
    
    var regex:NSRegularExpression?
    do {
        regex = try NSRegularExpression(pattern: "^[0-9a-f]*$", options: .caseInsensitive)
    } catch {
        // deal with not exist
    }

    let found = regex!.firstMatch(in: trimmedString, options: NSRegularExpression.MatchingOptions.anchored, range: NSMakeRange(0, trimmedString.characters.count))
    if found == nil || found?.range.location == NSNotFound || trimmedString.characters.count % 2 != 0 {
        return Data()
    }
    
    // everything ok, so now let's build NSData
    
    let data = NSMutableData(capacity: trimmedString.characters.count / 2)
    //for var index = trimmedString.startIndex; index < trimmedString.endIndex; index = index.successor().successor() {

    for index in 0..<trimmedString.characters.count {
//        let byteString = trimmedString.substringWithRange(Range<String.Index>(start: index, end: index.successor().successor()))

        let idx = trimmedString.index(trimmedString.startIndex, offsetBy: index)
        let idx2 = trimmedString.index(trimmedString.startIndex, offsetBy: index+2)
        
        let byteString2 = trimmedString[idx..<idx2]
        let num = UInt8(byteString2.withCString { strtoul($0, nil, 16) })
        data?.append([num] as [UInt8], length: 1)
    }
    
    return data! as Data
}

func NSData2NSString(_ data:Data) -> NSString {
    let str:NSMutableString = NSMutableString()
    let bytes = UnsafeBufferPointer<UInt8>(start: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count), count:data.count)
    for byte in bytes {
        str.appendFormat("%02hhx", byte)
    }
    return str
}

/**
transfer GMT NSDate to locale NSDate
*/
func GmtNSDate2LocaleNSDate(_ gmtDate:Date) ->Date
{
    let sourceTimeZone:TimeZone = TimeZone(identifier: "UTC")!
    let destinationTimeZone:TimeZone = TimeZone.autoupdatingCurrent
    let sourceGMTOffset:Int = sourceTimeZone.secondsFromGMT(for: gmtDate)
    let destinationGMTOffset:Int = destinationTimeZone.secondsFromGMT(for: gmtDate)
    let interval:TimeInterval = TimeInterval(destinationGMTOffset) - TimeInterval(sourceGMTOffset)
    let destinationDateNow:Date = Date(timeInterval: interval, since: gmtDate)
    return destinationDateNow
}

class Utility: NSObject {
    fileprivate static let packetLenght:Int = 20
    
    static func splitPacketConverter(data:[UInt8]) ->[Data] {
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
