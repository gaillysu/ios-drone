//
//  ReadDailyAlarmRequest.swift
//  Drone
//
//  Created by Cloud on 2017/6/22.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit

class ReadDailyAlarmRequest: DroneRequest {
    class func HEADER() -> UInt8 {
        return 0x38
    }
    
    override func getRawDataEx() -> [Data] {
        let values1 :[UInt8] = [0x80,ReadDailyAlarmRequest.HEADER(),
                                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        return [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)]
    }
}
