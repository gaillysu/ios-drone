//
//  UpdateNotificationRequest.swift
//  Drone
//
//  Created by leiyuncun on 16/3/22.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit

class UpdateNotificationRequest: NevoRequest {
    //Notification Operation default 0
    private var mOperation:Int = 0
    //Package Length
    private var mPackageLength:Int = 0
    //content package
    private var mPackage:String = "0"

    //Update Commands
    class func HEADER() -> UInt8 {
        return 0xB
    }

    init(operation:Int,package:String) {
        super.init()
        mOperation = operation
        mPackage = package
        mPackageLength = package.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
    }

    override func getRawDataEx() -> NSArray {
        let hexArray:[UInt8] = NSData2Bytes(mPackage.dataUsingEncoding(NSUTF8StringEncoding)!)
        var values1 :[UInt8] = [0x80,UpdateNotificationRequest.HEADER(),
            UInt8(mOperation&0xFF),
            UInt8(mPackageLength&0xFF),
            UInt8(hexArray.count&0xFF)]
        values1 = values1+hexArray

        for(var index:Int = values1.count;index<20;index++){
            values1.append(0x00)
        }

        return NSArray(array: [NSData(bytes: values1, length: values1.count)])
    }
}
