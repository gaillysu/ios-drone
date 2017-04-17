//
//  ReadDailyTrackerInfo.swift
//  Nevo
//
//  Created by supernova on 15/3/3.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class ReadDailyTrackerInfo: DroneRequest {
     /*
    This header is the key by which this kind of packet is called.
    */
    class func HEADER() -> UInt8 {
        return 0x24
    }

    override func getRawDataEx() -> [Data] {
        
        let values1 :[UInt8] = [0x00,ReadDailyTrackerInfo.HEADER(),
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        let values2 :[UInt8] = [0xFF,ReadDailyTrackerInfo.HEADER(),
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        
        return [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)
            ,Data(bytes: UnsafePointer<UInt8>(values2), count: values2.count)]
    }

}
