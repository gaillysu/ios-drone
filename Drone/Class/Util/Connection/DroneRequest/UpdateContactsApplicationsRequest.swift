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
    private var mSearchFields:UInt8 = 0x01

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
        var values1 :[UInt8] = [UpdateContactsApplicationsRequest.HEADER(),UInt8(mAppPackageLength&0xFF)]+hexArray+[UInt8(mOperationMode&0xFF),UInt8(mSearchFields&0xFF)]
        
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
