//
//  GetNotificationRequest.swift
//  Drone
//
//  Created by leiyuncun on 16/3/22.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit

class GetNotificationRequest: NevoRequest {
    /**
     <Read Notification Filter> and <Update Notification Filter> Commands
     - returns: 0x17
     */
    class func HEADER() -> UInt8 {
        return 0x17
    }

    override func getRawDataEx() -> NSArray {

        let values1 :[UInt8] = [0x80,GetNotificationRequest.HEADER(),
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

        return NSArray(array: [NSData(bytes: values1, length: values1.count)])
    }
}
