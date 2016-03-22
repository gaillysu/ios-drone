//
//  GetUserProfileRequest.swift
//  Drone
//
//  Created by leiyuncun on 16/3/22.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit

class GetUserProfileRequest: NevoRequest {

    class func HEADER() -> UInt8 {
        return 0x32
    }

    override func getRawDataEx() -> NSArray {

        let values1 :[UInt8] = [0x80,GetUserProfileRequest.HEADER(),
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

        return NSArray(array: [NSData(bytes: values1, length: values1.count)])
    }
}
