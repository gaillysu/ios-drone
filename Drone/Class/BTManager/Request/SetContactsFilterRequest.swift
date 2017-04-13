//
//  SetContactsFilterRequest.swift
//  Drone
//
//  Created by leiyuncun on 16/3/22.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit

class SetContactsFilterRequest: DroneRequest {
    /**
     <0x00> keep contacts list as it it
     <0x01> clear contacts list
     */
    fileprivate var mContactsMode:Int = 0
    /**
     <0x00> Keep contacts filtered applications as they are
     <0x01> reset all contacts filtered application to default notification filtering
     */
    fileprivate var mContacts_AppName_Mode:Int = 0
    /**
     Set Contacts Filter Commands
     - returns: 0x18
     */
    class func HEADER() -> UInt8 {
        return 0x18
    }

    init(contactsMode:Int,appNameMode:Int) {
        super.init()
        mContactsMode = contactsMode
        mContacts_AppName_Mode = appNameMode
    }

    override func getRawDataEx() -> [Data] {

        let values1 :[UInt8] = [0x80,SetContactsFilterRequest.HEADER(),
            UInt8(mContactsMode&0xFF),
            UInt8(mContacts_AppName_Mode&0xFF),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

        return [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)]
    }
}
