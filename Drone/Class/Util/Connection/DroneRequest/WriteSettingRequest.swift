//
//  WriteSettingRequest.swift
//  Nevo
//
//  Created by supernova on 15/2/12.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class WriteSettingRequest: NevoRequest {
    
    /*
    This header is the key by which this kind of packet is called.
    */
    class func HEADER() -> UInt8 {
        return 0x21
    }
    
    override func getRawDataEx() -> NSArray {
   
        let walk_stride :UInt16 = 73
        let run_stride :UInt16 =  122
        let swiming_stride :UInt16 = 105
        let enable:UInt8 = 3; //bit0:1, bit1:1
        
        
        let values1 :[UInt8] = [0x00,WriteSettingRequest.HEADER(),
            UInt8(walk_stride&0xFF),
            UInt8((walk_stride>>8)&0xFF),
            
            UInt8(run_stride&0xFF),
            UInt8((run_stride>>8)&0xFF),
            
            UInt8(swiming_stride&0xFF),
            UInt8((swiming_stride>>8)&0xFF),
            
            UInt8(enable&0xFF),
            
            0,0,0,0,0,0,0,0,0,0,0]
        
        let values2 :[UInt8] = [0xFF,WriteSettingRequest.HEADER(),
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        
        return NSArray(array: [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)
            ,Data(bytes: UnsafePointer<UInt8>(values2), count: values2.count)])
    }
   
}
