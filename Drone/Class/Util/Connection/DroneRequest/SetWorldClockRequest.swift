//
//  SetWorldClockRequest.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/29.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class SetWorldClockRequest: NevoRequest {
    fileprivate let worldClockArray: [(cityName:String,gmtOffset:Float)]
    init(worldClockArray:[(cityName:String,gmtOffset:Float)]) {
        self.worldClockArray = worldClockArray
        super.init()
    }

    class func HEADER() -> UInt8 {
        return 0x06
    }

    override func getRawDataEx() -> NSArray {
        var nameDataArray:[[UInt8]] = []
        nameDataArray.reserveCapacity(16)
        var zoneArray:[Int] = []
        for worldClock:(cityName:String,gmtOffset:Float) in worldClockArray {
           let namedata:[UInt8] = NSData2Bytes(worldClock.cityName.data(using: String.Encoding.utf8)!)
            nameDataArray.append(namedata)
            zoneArray.append(Int(worldClock.gmtOffset * 4))//8.5
        }
         
        var values1 :[UInt8] = [SetWorldClockRequest.HEADER(),
            UInt8(worldClockArray.count&0xFF)]
        for (index,value) in zoneArray.enumerated() {
            values1.append(UInt8(value&0xFF))
            values1.append(UInt8(nameDataArray[index].count&0xFF))
            for data in nameDataArray[index] {
                values1.append(data)
            }
        }
        
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
        
        return NSArray(array: dataArray)
    }
}
