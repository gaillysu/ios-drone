//
//  SetWorldClockRequest.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/29.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class SetWorldClockRequest: NevoRequest {
    private var mWorldTimerCount:Int?
    private var mTimeZone:[Int] = []
    private var mTimerName:[String] = []

    init(count:Int,timeZone:[Int],name:[String]) {
        super.init()
        mWorldTimerCount = count
        mTimeZone = timeZone
        mTimerName = name
        //let timezone:Int = timeZone.secondsFromGMT
        //mTimeZone = timeZone.secondsFromGMT/3600*15
        //mTimerName = name
    }

    class func HEADER() -> UInt8 {
        return 0x06
    }

    override func getRawDataEx() -> NSArray {
        var nameDataArray:[[UInt8]] = []
        nameDataArray.reserveCapacity(16)
        var zoneArray:[Int] = []
        for name in mTimerName {
           let namedata:[UInt8] = NSData2Bytes(name.dataUsingEncoding(NSUTF8StringEncoding)!)
            nameDataArray.append(namedata)
        }
        
        for timezone in mTimeZone {
            zoneArray.append(timezone)
        }
        
        var values1 :[UInt8] = [SetWorldClockRequest.HEADER(),
            UInt8(mWorldTimerCount!&0xFF)]
        for (index,value) in zoneArray.enumerate() {
            values1.append(UInt8(value&0xFF))
            values1.append(UInt8(nameDataArray[index].count&0xFF))
            for data in nameDataArray[index] {
                values1.append(data)
            }
        }
        
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
