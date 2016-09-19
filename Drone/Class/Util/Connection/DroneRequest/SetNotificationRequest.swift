//
//  SetNotificationRequest.swift
//  Drone
//
//  Created by leiyuncun on 16/3/22.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit

class SetNotificationRequest: NevoRequest {
    /**
     <0x00> - Blacklist Mode -> app packages included in filter list are blocked
     <0x01> - Whitelist Mode -> app packages NOT included in filter list are blocked
     */
    fileprivate var mOperationMode:Int = 0
    /**
     If different than <0x00>, device will clear its filters list
     */
    fileprivate var mForce_List_Clear:Int = 0

    /**
     Set the notification Commands
     - returns: 0xA
     */
    class func HEADER() -> UInt8 {
        return 0xA
    }

    init(mode:Int,force:Int) {
        super.init()
        mOperationMode = mode
        mForce_List_Clear = force
    }

    override func getRawDataEx() -> NSArray {

        let values1 :[UInt8] = [0x80,SetNotificationRequest.HEADER(),
            UInt8(mOperationMode&0xFF),
            UInt8(mForce_List_Clear&0xFF),
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

        return NSArray(array: [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)])
    }
}
