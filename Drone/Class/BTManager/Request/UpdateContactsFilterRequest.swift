//
//  UpdateContactsFilterRequest.swift
//  Drone
//
//  Created by leiyuncun on 16/3/22.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit

class UpdateContactsFilterRequest: DroneRequest {
    /**
     Length of contact field
     */
    fileprivate var mContactLength:Int = 0
    /**
     Contact string (Max 64)
     */
    fileprivate var mContactName:String = ""
    /**
     <0x01> - append contact
     <0x02> - remove contact
     <0x03> - append/update contact with ID
     */
    fileprivate var mOperation:Int = 0
    /**
     [Optional Field] sets contact Id if operation is <0x03>
     */
    fileprivate var mContactID:Int = 3

    class func HEADER() -> UInt8 {
        return 0x1A
    }

    init(contact:String,operation:Int,contactID:Int) {
        super.init()
        mContactLength = contact.lengthOfBytes(using: String.Encoding.utf8)
        mContactName = contact
        mOperation = operation
        if(contactID != 0) {
            mContactID = contactID
        }
    }

    override func getRawDataEx() -> [Data] {
        let hexArray:[UInt8] = NSData2Bytes(mContactName.data(using: String.Encoding.utf8)!)
        var values1 :[UInt8] = [UpdateContactsFilterRequest.HEADER(),UInt8(mContactLength&0xFF)]+hexArray+[UInt8(mOperation&0xFF),UInt8(mContactID&0xFF)]
        
        var valueArray:[UInt8] = []
        var dataArray:[Data] = []
        if values1.count>=20 {
            for (index,value) in values1.enumerated() {
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
                    dataArray.append(Data(bytes: UnsafePointer<UInt8>(valueArray), count: valueArray.count))
                    valueArray.removeAll()
                }
                
                if(index == values1.count-1) {
                    if(valueArray.count < 20) {
                        for _:Int in valueArray.count..<20 {
                            valueArray.append(0x00)
                        }
                    }
                    dataArray.append(Data(bytes: UnsafePointer<UInt8>(valueArray), count: valueArray.count))
                    valueArray.removeAll()
                }
            }
        }else{
            values1.insert(0x80, at: 0)
            if(values1.count < 20) {
                for _:Int in values1.count..<20 {
                    values1.append(0x00)
                }
            }
            dataArray.append(Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count));
        }
        return dataArray
    }
}
