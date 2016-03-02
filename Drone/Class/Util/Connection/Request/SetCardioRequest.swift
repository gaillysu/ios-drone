//
//  SetCardioRequest.swift
//  Nevo
//
//  Created by supernova on 15/2/12.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class SetCardioRequest: NevoRequest {
    
    /*
    This header is the key by which this kind of packet is called.
    */
    class func HEADER() -> UInt8 {
        return 0x23
    }
    
    override func getRawDataEx() -> NSArray {
        
        let maxHR :UInt8 = 210
        let restHR :UInt8 = 65
        let zone_HR_H :UInt8 = 180
        let zone_HR_L :UInt8 = 60
        
        let values1 :[UInt8] = [0x00,SetCardioRequest.HEADER(),
            UInt8(maxHR&0xFF),
            UInt8(restHR&0xFF),
            UInt8(zone_HR_H&0xFF),
            UInt8(zone_HR_L&0xFF),
            0,
            0,
            0,
            0,0,0,0,0,0,0,0,0,0,0]
        
        let values2 :[UInt8] = [0xFF,SetCardioRequest.HEADER(),
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        
        return NSArray(array: [NSData(bytes: values1, length: values1.count)
            ,NSData(bytes: values2, length: values2.count)])
    }

   
}
