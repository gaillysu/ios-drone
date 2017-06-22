//
//  SetCountdownTimerRequest.swift
//  Drone
//
//  Created by Cloud on 2017/6/22.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit

class SetCountdownTimerRequest: DroneRequest {
    fileprivate var countdown:Int = 0 //Number of minutes to countdown (Max.1439)
    
    class func HEADER() -> UInt8 {
        return 0x39
    }
    
    init(countdown:Int) {
        self.countdown = countdown
    }
    
    override func getRawDataEx() -> [Data] {
        let values1 :[UInt8] = [0x80,SetCountdownTimerRequest.HEADER(),
                                UInt8(countdown&0xFF),
                                UInt8(countdown>>8&0xFF),
                                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        return [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)]
    }
}
