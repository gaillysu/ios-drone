//
//  StartSystemSettingRequest.swift
//  Drone
//
//  Created by Cloud on 2017/4/13.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit

class StartSystemSettingRequest: DroneRequest {
    fileprivate var appid:Int = 0;
    fileprivate var appOperation:Int = 0;
    
    class func HEADER() -> UInt8 {
        return 0x34
    }
    
    init(id:Int,operation:Int) {
        super.init()
        appid = id
        appOperation = operation
    }
    
    override func getRawDataEx() -> [Data] {
        let values1 :[UInt8] = [0x80,StartSystemSettingRequest.HEADER(), UInt8(appid&0xFF),UInt8(appOperation&0xFF),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        return [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)]
    }
}
