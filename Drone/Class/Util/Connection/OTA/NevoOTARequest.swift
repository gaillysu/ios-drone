//
//  NevoOTARequest.swift
//  Nevo
//
//  Created by supernova on 15/2/4.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import Foundation
import UIKit

/**

this file include all  OTA request class
*/

//class NevoOTARequest: Request {
//
//}

/**
below class is for Nordic BLE OTA, Firmware is hex file
*/

class SetOTAModeRequest : Request {
    
    let values :[UInt8] = [0x00,0x72,0xA0,0x8A,0x7D,0xDE,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    let values2 :[UInt8] = [0xFF,0x72,0x00,0x00,0x00,0x00,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    func getTargetProfile() -> Profile {
        return NevoOTAModeProfile()
    }
    
    func getRawData() -> Data {
        return Data(bytes: UnsafePointer<UInt8>(values), count: values.count)
    }
    func getRawDataEx() -> NSArray {
        return NSArray(array: [Data(bytes: UnsafePointer<UInt8>(values), count: values.count),
                               Data(bytes: UnsafePointer<UInt8>(values2), count: values2.count)])
    }
}


class StartOTARequest: Request {
    
    let values :[UInt8] = [DfuOperations.start_DFU_REQUEST.rawValue,DfuFirmwareTypes.application.rawValue]
    
    func getTargetProfile() -> Profile {
        return NevoOTAControllerProfile()
    }
    
    func getRawData() -> Data {
        return Data(bytes: UnsafePointer<UInt8>(values), count: values.count)
    }
    func getRawDataEx() -> NSArray {
        return NSArray()
    }
}

class StartOTAOldRequest: Request {
    
    let values :[UInt8] = [DfuOperations.start_DFU_REQUEST.rawValue,DfuFirmwareTypes.application.rawValue]
    
    func getTargetProfile() -> Profile {
        return NevoOTAControllerProfile()
    }
    
    func getRawData() -> Data {
        return Data(bytes: UnsafePointer<UInt8>(values), count: values.count)
    }
    func getRawDataEx() -> NSArray {
        return NSArray()
    }
}

class writeFileSizeRequest: Request {
    
    var mFilelength:Int?
    
    init(filelength: Int)
    {
        mFilelength = filelength
    }
    func getTargetProfile() -> Profile {
        return NevoOTAPacketProfile()
    }
    
    func getRawData() -> Data {
        let fileSizeCollection :[UInt32] = [0,0,UInt32(mFilelength!)];
        
        return Data(bytes: UnsafePointer<UInt8>(fileSizeCollection), count: fileSizeCollection.count * MemoryLayout<UInt32>.size)
    }
    func getRawDataEx() -> NSArray {
        return NSArray()
    }
}

class writeFileSizeOldRequest: Request {
    
    var mFilelength:Int?
    
    init(filelength: Int)
    {
        mFilelength = filelength
    }
    func getTargetProfile() -> Profile {
        return NevoOTAPacketProfile()
    }
    
    func getRawData() -> Data {
        let fileSizeCollection :[UInt32] = [0,0,UInt32(mFilelength!)];
        
        return Data(bytes: UnsafePointer<UInt8>(fileSizeCollection), count: fileSizeCollection.count * MemoryLayout<UInt32>.size)
    }
    func getRawDataEx() -> NSArray {
        return NSArray()
    }
}


class ResetSystemRequest:Request {
    
    let values :[UInt8] = [DfuOperations.reset_SYSTEM.rawValue]
    
    func getTargetProfile() -> Profile {
        return NevoOTAControllerProfile()
    }
    
    func getRawData() -> Data {
        return Data(bytes: UnsafePointer<UInt8>(values), count: values.count)
    }
    func getRawDataEx() -> NSArray {
        return NSArray()
    }
}

class EnablePacketNotifyRequest:Request {
    
    let values :[UInt8] = [DfuOperations.packet_RECEIPT_NOTIFICATION_REQUEST.rawValue, UInt8(enumPacketOption.packets_NOTIFICATION_INTERVAL.rawValue),0]
    
    func getTargetProfile() -> Profile {
        return NevoOTAControllerProfile()
    }
    
    func getRawData() -> Data {
        return Data(bytes: UnsafePointer<UInt8>(values), count: values.count)
    }
    func getRawDataEx() -> NSArray {
        return NSArray()
    }
}

class ReceiveFirmwareImageRequest:Request {
    
    let values :[UInt8] = [DfuOperations.receive_FIRMWARE_IMAGE_REQUEST.rawValue]
    
    func getTargetProfile() -> Profile {
        return NevoOTAControllerProfile()
    }
    
    func getRawData() -> Data {
        return Data(bytes: UnsafePointer<UInt8>(values), count: values.count)
    }
    func getRawDataEx() -> NSArray {
        return NSArray()
    }
}

class ValidateFirmwareRequest:Request {
    
    let values :[UInt8] = [DfuOperations.validate_FIRMWARE_REQUEST.rawValue]
    
    func getTargetProfile() -> Profile {
        return NevoOTAControllerProfile()
    }
    
    func getRawData() -> Data {
        return Data(bytes: UnsafePointer<UInt8>(values), count: values.count)
    }
    func getRawDataEx() -> NSArray {
        return NSArray()
    }
}

class ActivateAndResetRequest:Request {
    
    let values :[UInt8] = [DfuOperations.activate_AND_RESET_REQUEST.rawValue]
    
    func getTargetProfile() -> Profile {
        return NevoOTAControllerProfile()
    }
    
    func getRawData() -> Data {
        return Data(bytes: UnsafePointer<UInt8>(values), count: values.count)
    }
    func getRawDataEx() -> NSArray {
        return NSArray()
    }
}

class OnePacketRequest: Request {
    
    var mPacketData:Data?
    
    init(packetdata: Data)
    {
        mPacketData = NSData(data: packetdata) as Data
    }
    func getTargetProfile() -> Profile {
        return NevoOTAPacketProfile()
    }
    
    func getRawData() -> Data {
        
        return mPacketData!
    }
    func getRawDataEx() -> NSArray {
        return NSArray()
    }
}

/**
below class is for Epson MCU OTA, FW is bin file
*/

class Mcu_SetOTAModeRequest : Request {
    
    let values :[UInt8] = [0x00,0x70,0xA0,0x8A,0x7D,0xDE,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    let values2 :[UInt8] = [0xFF,0x70,0x00,0x00,0x00,0x00,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    
    func getTargetProfile() -> Profile {
        return NevoOTAModeProfile()
    }
    
    func getRawData() -> Data {
        return Data(bytes: UnsafePointer<UInt8>(values), count: values.count)
    }
    func getRawDataEx() -> NSArray {
        return NSArray(array: [Data(bytes: UnsafePointer<UInt8>(values), count: values.count),
            Data(bytes: UnsafePointer<UInt8>(values2), count: values2.count)])
    }
}

class Mcu_OnePacketRequest: Request {
    
    var mPacketData:Data?
    
    init(packetdata: Data)
    {
        mPacketData = NSData(data: packetdata) as Data
    }
    func getTargetProfile() -> Profile {
        return NevoOTAModeProfile()
    }
    
    func getRawData() -> Data {
        return mPacketData!
    }
    func getRawDataEx() -> NSArray {
        return NSArray()
    }
}

class Mcu_OnePageRequest: Request {
    
    var mOnePage:[Mcu_OnePacketRequest]
    
    init()
    {
        mOnePage = []
    }
    func addPacket(_ packet:Mcu_OnePacketRequest)
    {
        mOnePage.append(packet)
    }
    func getTargetProfile() -> Profile {
        return NevoOTAModeProfile()
    }
    
    func getRawData() -> Data {
        return Data()
    }
    
    func getRawDataEx() -> NSArray {
        let packetarray = NSMutableArray()
        for packet in mOnePage {
           packetarray.add(packet.getRawData())
        }
        return packetarray
    }
}


class Mcu_CheckSumPacketRequest: Request {
    
    var mTotalpage:Int
    var mChecksum:Int
    
    init(totalpage:Int,checksum:Int)
    {
        mTotalpage = totalpage
        mChecksum  = checksum
    }
    func getTargetProfile() -> Profile {
        return NevoOTAModeProfile()
    }
    
    func getRawData() -> Data {
        
        return Data()
    }
    func getRawDataEx() -> NSArray {
        
        let values :[UInt8] = [0x00,0x71,0xFF,0xFF,UInt8(mTotalpage&0xFF),UInt8((mTotalpage>>8)&0xFF)
            ,UInt8(mChecksum&0xFF),0,0,0,0,0,0,0,0,0,0,0,0,0]
        let values2 :[UInt8] = [0xFF,0x71,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        return NSArray(array: [Data(bytes: UnsafePointer<UInt8>(values), count: values.count),
            Data(bytes: UnsafePointer<UInt8>(values2), count: values2.count)])

    }
}

