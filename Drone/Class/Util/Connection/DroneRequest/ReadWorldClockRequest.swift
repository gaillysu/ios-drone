//
//  ReadWorldClockRequest.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/31.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class ReadWorldClockRequest: NevoRequest {
    class func HEADER() -> UInt8 {
        return 0x07
    }

    override func getRawDataEx() -> NSArray {

        let values1 :[UInt8] = [0x80,ReadWorldClockRequest.HEADER(),
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

        return NSArray(array: [NSData(bytes: values1, length: values1.count)])
    }
}
