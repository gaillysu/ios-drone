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
        var values1 :[UInt8] = [UpdateNotificationRequest.HEADER(),UInt8(mOperation&0xFF),UInt8(mPackageLength&0xFF),UInt8(hexArray.count&0xFF)]+hexArray
        
        var valueArray:[UInt8] = []
        var dataArray:[NSData] = []
        if values1.count>=20 {
            for (index,value) in values1.enumerate() {
                let header:UInt8 = 0x00
                let header1:UInt8 = 0x80
                
                if(valueArray.count == 0) {
                    if values1.count-index < 20 {
                        valueArray.append(header1+UInt8(dataArray.count&0xFF))
                    }else{
                        valueArray.append(header+UInt8(dataArray.count&0xFF))
                    }
                }
                valueArray.append(value)
                
                if valueArray.count == 20 {
                    dataArray.append(NSData(bytes: valueArray, length: valueArray.count))
                    valueArray.removeAll()
                }
                
                if(index == values1.count-1) {
                    if(valueArray.count < 20) {
                        for _:Int in valueArray.count..<20 {
                            valueArray.append(0x00)
                        }
                    }
                    dataArray.append(NSData(bytes: valueArray, length: valueArray.count))
                    valueArray.removeAll()
                }
            }
        }else{
            values1.insert(0x80, atIndex: 0)
            if(values1.count < 20) {
                for _:Int in values1.count..<20 {
                    values1.append(0x00)
                }
            }
            dataArray.append(NSData(bytes: values1, length: values1.count));
        }
        
        return NSArray(array: dataArray)
    }
}
