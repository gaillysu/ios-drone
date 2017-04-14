//
//  StartSystemSettingRequest.swift
//  Drone
//
//  Created by Cloud on 2017/4/13.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit

class StartSystemSettingRequest: DroneRequest {
    fileprivate var appid:UInt8 = 0;
    fileprivate var appOperation:UInt8 = 0;
    
    class func HEADER() -> UInt8 {
        return 0x34
    }
    
    init(id:SystemSettingApplicationID,operation:SettingAnalogMovementOperation) {
        super.init()
        appid = id.rawValue
        appOperation = operation.rawValue
    }
    
    override func getRawDataEx() -> [Data] {
        let values1 :[UInt8] = [0x80,StartSystemSettingRequest.HEADER(), appid, appOperation,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        return [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)]
    }
}
