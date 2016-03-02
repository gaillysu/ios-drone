//
//  SetProfileRequest.swift
//  Nevo
//
//  Created by supernova on 15/2/12.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class SetProfileRequest: NevoRequest {
    
    /*
    This header is the key by which this kind of packet is called.
    */
    class func HEADER() -> UInt8 {
        return 0x20
    }
    
    override func getRawDataEx() -> NSArray {
        
        let age :UInt8 = 35
        let height :UInt8 = 175 //cm
        let weight :UInt8 = 77  //kg
        let sex:UInt8 = 1; //man:1,female:0
        var unit:UInt8 = 1; //unit ???
        
        let values1 :[UInt8] = [0x00,SetProfileRequest.HEADER(),
            UInt8(age&0xFF),
            UInt8(height&0xFF),
            UInt8(weight&0xFF),
            UInt8(sex&0xFF),
            0,
            0,
            0,
            0,0,0,0,0,0,0,0,0,0,0]
        
        let values2 :[UInt8] = [0xFF,SetProfileRequest.HEADER(),
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        
        return NSArray(array: [NSData(bytes: values1, length: values1.count)
            ,NSData(bytes: values2, length: values2.count)])
    }
   
}
