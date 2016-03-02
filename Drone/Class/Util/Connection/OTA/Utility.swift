//
//  Utility.swift
//  Nevo
//
//  Created by supernova on 15/2/4.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import Foundation


struct DFUResponse
{
    var responseCode:UInt8;
    var requestedCode:UInt8;
    var responseStatus:UInt8;
}

enum  enumFileExtension: UInt8 {
    case HEX,ZIP,BIN
}

enum  enumPacketOption: Int{
    case PACKETS_NOTIFICATION_INTERVAL = 10,
    PACKET_SIZE = 20
}

enum DfuOperations :UInt8 {
    case START_DFU_REQUEST = 0x01,
    INITIALIZE_DFU_PARAMETERS_REQUEST = 0x02,
    RECEIVE_FIRMWARE_IMAGE_REQUEST = 0x03,
    VALIDATE_FIRMWARE_REQUEST = 0x04,
    ACTIVATE_AND_RESET_REQUEST = 0x05,
    RESET_SYSTEM = 0x06,
    PACKET_RECEIPT_NOTIFICATION_REQUEST = 0x08,
    RESPONSE_CODE = 0x10,
    PACKET_RECEIPT_NOTIFICATION_RESPONSE = 0x11
    
}

enum DfuOperationStatus:UInt8{
    case OPERATION_SUCCESSFUL_RESPONSE = 0x01,
    OPERATION_INVALID_RESPONSE = 0x02,
    OPERATION_NOT_SUPPORTED_RESPONSE = 0x03,
    DATA_SIZE_EXCEEDS_LIMIT_RESPONSE = 0x04,
    CRC_ERROR_RESPONSE = 0x05,
    OPERATION_FAILED_RESPONSE = 0x06
    
}

enum DFUControllerState
{
    case INIT,
    DISCOVERING,
    IDLE,
    SEND_NOTIFICATION_REQUEST,
    SEND_START_COMMAND,
    SEND_RECEIVE_COMMAND,
    SEND_FIRMWARE_DATA,
    SEND_VALIDATE_COMMAND,
    SEND_RESET,
    WAIT_RECEIPT,
    FINISHED,
    CANCELED,
    SEND_RECONNECT
}

enum DfuFirmwareTypes:UInt8{
    case  SOFTDEVICE = 0x01,
    BOOTLOADER = 0x02,
    SOFTDEVICE_AND_BOOTLOADER = 0x03,
    APPLICATION = 0x04
}

func Bytes2NSData(bytes:[UInt8]) -> NSData
{
  return NSData(bytes: bytes, length: bytes.count)
}
func NSData2Bytes(data:NSData) -> [UInt8]
{
    let bytes = UnsafeBufferPointer<UInt8>(start: UnsafePointer(data.bytes), count:data.length)
    
    var ret:[UInt8] = []
    for  byte in bytes {
        ret.append(byte)
    }
    return ret
}

func NSString2NSData(string:NSString) -> NSData
{
    let mString = string
    let trimmedString:String = mString.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<> ")).stringByReplacingOccurrencesOfString(" ", withString: "")
    
    // make sure the cleaned up string consists solely of hex digits, and that we have even number of them
    
    var regex:NSRegularExpression?
    do {
        regex = try NSRegularExpression(pattern: "^[0-9a-f]*$", options: .CaseInsensitive)
    } catch {
        // deal with not exist
    }

    let found = regex!.firstMatchInString(trimmedString, options: NSMatchingOptions.Anchored, range: NSMakeRange(0, trimmedString.characters.count))
    if found == nil || found?.range.location == NSNotFound || trimmedString.characters.count % 2 != 0 {
        return NSData()
    }
    
    // everything ok, so now let's build NSData
    
    let data = NSMutableData(capacity: trimmedString.characters.count / 2)
    
    for var index = trimmedString.startIndex; index < trimmedString.endIndex; index = index.successor().successor() {
        let byteString = trimmedString.substringWithRange(Range<String.Index>(start: index, end: index.successor().successor()))
        let num = UInt8(byteString.withCString { strtoul($0, nil, 16) })
        data?.appendBytes([num] as [UInt8], length: 1)
    }
    
    return data!
}

func NSData2NSString(data:NSData) -> NSString {
    let str:NSMutableString = NSMutableString()
    let bytes = UnsafeBufferPointer<UInt8>(start: UnsafePointer(data.bytes), count:data.length)
    for byte in bytes {
        str.appendFormat("%02hhx", byte)
    }
    return str
}

/**
transfer GMT NSDate to locale NSDate
*/
func GmtNSDate2LocaleNSDate(gmtDate:NSDate) ->NSDate
{
    let sourceTimeZone:NSTimeZone = NSTimeZone(name: "UTC")!
    let destinationTimeZone:NSTimeZone = NSTimeZone.localTimeZone()
    let sourceGMTOffset:Int = sourceTimeZone.secondsFromGMTForDate(gmtDate)
    let destinationGMTOffset:Int = destinationTimeZone.secondsFromGMTForDate(gmtDate)
    let interval:NSTimeInterval = NSTimeInterval(destinationGMTOffset) - NSTimeInterval(sourceGMTOffset)
    let destinationDateNow:NSDate = NSDate(timeInterval: interval, sinceDate: gmtDate)
    return destinationDateNow
}

