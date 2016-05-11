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
        var zoneArray:[Int] = []
        for name in mTimerName {
           let namedata:[UInt8] = NSData2Bytes(name.dataUsingEncoding(NSUTF8StringEncoding)!)
            if namedata.count<=16 {
              nameDataArray.append(namedata)
            }else{
                nameDataArray.append(namedata)
            }
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
        
        return NSArray(array: [NSData(bytes: values1, length: values1.count)])
    }
}
