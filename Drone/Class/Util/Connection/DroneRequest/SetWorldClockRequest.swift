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
        
        var values1 :[UInt8] = [0x80,SetWorldClockRequest.HEADER(),
            UInt8(mWorldTimerCount!&0xFF)]
        for (index,value) in zoneArray.enumerate() {
            //let timeZone:Int = NSTimeZone.localTimeZone().secondsFromGMT/3600*15
            //let timer:Int = Int(NSDate().timeIntervalSince1970+(3600*2))
            values1.append(UInt8(value&0xFF))
            values1.append(UInt8(nameDataArray[index].count&0xFF))
            for data in nameDataArray[index] {
                values1.append(data)
            }
        }
        
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
                        dataArray.append(NSData(bytes: valueArray, length: valueArray.count))
                        valueArray.removeAll()
                    }
                }
                
            }
        }else{
            dataArray.append(NSData(bytes: values1, length: values1.count));
        }
        
        return NSArray(array: dataArray)
    }
}
