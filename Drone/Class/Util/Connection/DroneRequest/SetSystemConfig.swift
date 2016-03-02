//
//  SetSystemConfig.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/29.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class SetSystemConfig: NevoRequest {

    class func HEADER() -> UInt8 {
        return 0x0F
    }

    override func getRawDataEx() -> NSArray {

        let values1 :[UInt8] = [0x80,SetSystemConfig.HEADER(),
            0x08,0x01,0x01,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        let values2 :[UInt8] = [0x80,SetSystemConfig.HEADER(),
            0x04,0x01,0x01,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

        return NSArray(array: [NSData(bytes: values1, length: values1.count),NSData(bytes: values2, length: values2.count)])
    }
}
