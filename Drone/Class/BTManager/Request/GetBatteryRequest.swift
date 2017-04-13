//
//  ReadBatteryLevelNevoRequest.swift
//  Nevo
//
//  Created by supernova on 15/5/26.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class GetBatteryRequest: NevoRequest {
    /**
    batt_level
    0 - low battery level
    1 - half battery level
    2 - full battery level
    */
    /*
    This header is the key by which this kind of packet is called.
    */
    class func HEADER() -> UInt8 {
        return 0x0E
    }
    
    override func getRawDataEx() -> NSArray {
        
        let values1 :[UInt8] = [0x80,GetBatteryRequest.HEADER(),
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        return NSArray(array: [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)])
    }


}
