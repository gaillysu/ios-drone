//
//  SetRTCRequest.swift
//  Nevo
//
//  Created by supernova on 15/2/12.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class SetRTCRequest: NevoRequest {
    
    /*
    This header is the key by which this kind of packet is called.
    */
    class func HEADER() -> UInt8 {
        return 0x03
    }

    override func getRawDataEx() -> NSArray {
        // hahaha
        let timeZone:Int = NSTimeZone.localTimeZone().secondsFromGMT/900
        let timer:Int = Int(NSDate().timeIntervalSince1970)

        let values1 :[UInt8] = [0x80,SetRTCRequest.HEADER(),
            UInt8(timer&0xFF),
            UInt8(timer>>8&0xFF),
            UInt8(timer>>16&0xFF),
            UInt8(timer>>24&0xFF),
            UInt8(timeZone&0xFF),0,0,0,0,0,0,0,0,0,0,0,0,0]
        return NSArray(array: [NSData(bytes: values1, length: values1.count)])
    }
}