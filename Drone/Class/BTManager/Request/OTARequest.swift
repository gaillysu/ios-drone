//
//  OTARequest.swift
//  Drone
//
//  Created by Cloud on 2017/4/26.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit

enum OTAMode:UInt8 {
    case ble    = 0x01
    case mcu    = 0x02 // MCU is currently not used for OTA.
}

class OTARequest: DroneRequest {
    fileprivate var otaMode:OTAMode = OTAMode.ble
    
    class func HEADER() -> UInt8 {
        return 0x70
    }
    
    init(mode:OTAMode) {
        otaMode = mode
    }

    override func getRawDataEx() -> [Data] {
        let values1 :[UInt8] = [0x80,OTARequest.HEADER(),0xD4,0x17,0xA6,0x84,otaMode.rawValue,0,0,0,0,0,0,0,0,0,0,0,0,0]
        return [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)]
    }
}
