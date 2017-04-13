//
//  ReadWorldClockRequest.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/31.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class GetWorldClockRequest: DroneRequest {
    class func HEADER() -> UInt8 {
        return 0x07
    }

    override func getRawDataEx() -> [Data] {
        let values1 :[UInt8] = [0x80,GetWorldClockRequest.HEADER(),
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        return [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)]
    }
}
