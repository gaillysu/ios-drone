//
//  UpdateContactsApplicationsRequest.swift
//  Drone
//
//  Created by leiyuncun on 16/3/22.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit

class UpdateContactsApplicationsRequest: NevoRequest {
    /**
     Application package string length
     */
    private var mAppPackageLength:Int = 0
    /**
     Application package to be updated
     */
    private var mAppPackage:String = ""
    /**
     <0x00> - Use default notification filters.
     <0x01> - Use contacts filtering
     */
    private var mOperationMode:Int = 0

    /**
     Bitfield informing ANCS fields scanning algorithm
     b0: Scan ANCS Title
     b1: Scan ANCS Subtitle
     b2: Scan ANCS Message
     b7: <SET> - “Begins with” match;
     <RESET> - “any” match
     */
    private var mSearchFields:Int = 0

    class func HEADER() -> UInt8 {
        return 0x1B
    }

    init(appPackage:String,operationMode:Int) {
        super.init()
        mAppPackage = appPackage
        mAppPackageLength = appPackage.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        mOperationMode = operationMode
    }

    override func getRawDataEx() -> NSArray {
        let hexArray:[UInt8] = NSData2Bytes(mAppPackage.dataUsingEncoding(NSUTF8StringEncoding)!)
        var values1 :[UInt8] = [0x80,UpdateContactsFilterRequest.HEADER(),UInt8(mAppPackageLength&0xFF)]
        values1 = values1+hexArray
        values1 = values1+[UInt8(mOperationMode&0xFF),UInt8(mSearchFields&0xFF)]

        return NSArray(array: [NSData(bytes: values1, length: values1.count)])
    }
}
