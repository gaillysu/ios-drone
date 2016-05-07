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
    private var mTimerZone:Int?
    private var mTimerName:String?

    init(count:Int,timerZone:NSTimeZone,name:String) {
        super.init()
        mWorldTimerCount = count
        let timerzone:Int = timerZone.secondsFromGMT
        mTimerZone = timerZone.secondsFromGMT/3600*15
        mTimerName = name
    }

    class func HEADER() -> UInt8 {
        return 0x06
    }

    override func getRawDataEx() -> NSArray {
        let hexArray:[UInt8] = NSData2Bytes(mTimerName!.dataUsingEncoding(NSUTF8StringEncoding)!)

        var values1 :[UInt8] = [0x80,SetWorldClockRequest.HEADER(),
            UInt8(mWorldTimerCount!&0xFF),UInt8(mTimerZone!&0xFF),UInt8(hexArray.count&0xFF)]
        values1 = values1+hexArray
        for index:Int in values1.count ..< 20 {
            values1.append(0x00)
        }

        return NSArray(array: [NSData(bytes: values1, length: values1.count)])
    }
}
