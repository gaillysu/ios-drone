//
//  readSystemStatus.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/24.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class GetSystemStatus: NevoRequest {

    class func HEADER() -> UInt8 {
        return 0x01
    }

    override func getRawDataEx() -> NSArray {

        let values1 :[UInt8] = [0x80,GetSystemStatus.HEADER(),
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

        return NSArray(array: [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)])
    }
}
