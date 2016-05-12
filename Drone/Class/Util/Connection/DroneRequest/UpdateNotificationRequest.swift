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
        var values1 :[UInt8] = [0x80,UpdateNotificationRequest.HEADER(),UInt8(mOperation&0xFF),UInt8(mPackageLength&0xFF),UInt8(hexArray.count&0xFF)]+hexArray
        
        var valueArray:[UInt8] = []
        var dataArray:[NSData] = []
        if values1.count>20 {
            for (index,value) in values1.enumerate() {
                if index % 20 == 0 && index != 0 {
                    dataArray.append(NSData(bytes: valueArray, length: valueArray.count))
                    valueArray.removeAll()
                }else{
                    if(valueArray.count == 0 && dataArray.count != 0) {
                        valueArray.append(0x81)
                        valueArray.append(values1[index-1])
                    }
                    valueArray.append(value)
                    
                    if(index == values1.count-1) {
                        if(valueArray.count != 20) {
                            for _:Int in valueArray.count..<20 {
                                valueArray.append(0x00)
                            }
                        }
                        dataArray.append(NSData(bytes: valueArray, length: valueArray.count))
                        valueArray.removeAll()
                    }
                }
            }
        }else{
            if(values1.count != 20) {
                for _:Int in values1.count..<20 {
                    values1.append(0x00)
                }
            }
            dataArray.append(NSData(bytes: values1, length: values1.count));
        }
        
        return NSArray(array: dataArray)
    }
}
