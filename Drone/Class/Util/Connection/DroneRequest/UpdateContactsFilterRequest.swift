//
//  UpdateContactsFilterRequest.swift
//  Drone
//
//  Created by leiyuncun on 16/3/22.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit

class UpdateContactsFilterRequest: NevoRequest {
    /**
     Length of contact field
     */
    private var mContactLength:Int = 0
    /**
     Contact string (Max 64)
     */
    private var mContactName:String = ""
    /**
     <0x01> - append contact
     <0x02> - remove contact
     <0x03> - append/update contact with ID
     */
    private var mOperation:Int = 0
    /**
     [Optional Field] sets contact Id if operation is <0x03>
     */
    private var mContactID:Int = 3

    class func HEADER() -> UInt8 {
        return 0x1A
    }

    init(contact:String,operation:Int,contactID:Int) {
        super.init()
        mContactLength = contact.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        mContactName = contact
        mOperation = operation
        if(contactID != 0) {
            mContactID = contactID
        }
    }

    override func getRawDataEx() -> NSArray {
        let hexArray:[UInt8] = NSData2Bytes(mContactName.dataUsingEncoding(NSUTF8StringEncoding)!)
        var values1 :[UInt8] = [0x80,UpdateContactsFilterRequest.HEADER(),UInt8(mContactLength&0xFF)]
        values1 = values1+hexArray
        values1 = values1+[UInt8(mOperation&0xFF),UInt8(mContactID&0xFF)]

        return NSArray(array: [NSData(bytes: values1, length: values1.count)])
    }
}
