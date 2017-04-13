//
//  ReadSystemConfig.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/29.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class GetSystemConfig: NevoRequest {

    class func HEADER() -> UInt8 {
        return 0x10
    }

    override func getRawDataEx() -> NSArray {

        let values1 :[UInt8] = [0x80,GetSystemConfig.HEADER(),
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

        return NSArray(array: [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)])
    }
}
