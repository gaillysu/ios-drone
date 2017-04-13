//
//  ReadDailyTracker.swift
//  Nevo
//
//  Created by supernova on 15/3/3.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class ReadDailyTracker: NevoRequest {
    /*
    This header is the key by which this kind of packet is called.
    */
    class func HEADER() -> UInt8 {
        return 0x25
    }

    // tracker no is 0~6
    fileprivate var mTrackerNo:UInt8 = 0
    
    init(trackerno:UInt8)
    {
        mTrackerNo = trackerno
    }
    
    override func getRawDataEx() -> NSArray {
        
        let values1 :[UInt8] = [0x00,ReadDailyTracker.HEADER(),
            mTrackerNo,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        let values2 :[UInt8] = [0xFF,ReadDailyTracker.HEADER(),
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        
        return NSArray(array: [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)
            ,Data(bytes: UnsafePointer<UInt8>(values2), count: values2.count)])
    }

}
