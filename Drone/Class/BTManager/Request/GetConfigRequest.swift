//
//  ActivityTrackingConfigRequest.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/29.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class GetConfigRequest: DroneRequest {
    class func HEADER() -> UInt8 {
        return 0x05
    }

    override func getRawDataEx() -> [Data] {

        let values1 :[UInt8] = [0x80,GetConfigRequest.HEADER(),
            0x02,0x01,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

        return [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)]
    }
}
