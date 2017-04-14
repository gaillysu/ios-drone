//
//  UpdateNotificationRequest.swift
//  Drone
//
//  Created by leiyuncun on 16/3/22.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit

class UpdateNotificationRequest: DroneRequest {
    //Notification Operation default 0
    fileprivate var mOperation:Int = 0
    //Package Length
    fileprivate var mPackageLength:Int = 0
    //content package
    fileprivate var mPackage:String = "0"

    //Update Commands
    class func HEADER() -> UInt8 {
        return 0x0B
    }

    init(operation:Int,package:String) {
        super.init()
        mOperation = operation
        mPackage = package
        mPackageLength = package.lengthOfBytes(using: String.Encoding.utf8)
    }

    override func getRawDataEx() -> [Data] {
        let hexArray:[UInt8] = Constants.NSData2Bytes(mPackage.data(using: String.Encoding.utf8)!)
        let values1 :[UInt8] = [UpdateNotificationRequest.HEADER(),UInt8(mOperation&0xFF),UInt8(mPackageLength&0xFF)]+hexArray
        return Utility.splitPacketConverter(data: values1)
    }
}
