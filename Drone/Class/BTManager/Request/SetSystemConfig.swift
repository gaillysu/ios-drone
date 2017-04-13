//
//  SetSystemConfig.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/29.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class SetSystemConfig: NevoRequest {
    fileprivate var mAutoStart:TimeInterval = 0
    fileprivate var mAutoEnd:TimeInterval = 0
    fileprivate var mIndex:Int = 0
    class func HEADER() -> UInt8 {
        return 0x0F
    }

    init(autoStart:TimeInterval,autoEnd:TimeInterval,index:Int) {
        super.init()
        mAutoStart = autoStart
        mAutoEnd = autoEnd
        mIndex = index
    }

    override func getRawDataEx() -> NSArray {

        let values1 :[UInt8] = [0x80,SetSystemConfig.HEADER(),
            0x08,0x01,0x01,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        let values2 :[UInt8] = [0x80,SetSystemConfig.HEADER(),
            0x04,0x01,0x01,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        let values3 :[UInt8] = [0x80,SetSystemConfig.HEADER(),
                                0x09,0x05,
                                UInt8(Int(mAutoStart)&0xFF),
                                UInt8((Int(mAutoStart)>>8)&0xFF),
                                UInt8(Int(mAutoEnd)&0xFF),
                                UInt8((Int(mAutoEnd)>>8)&0xFF),0,0,0,0,0,0,0,0,0,0,0,0]
        let requestArray:[[UInt8]] = [values1,values2,values3]

        return NSArray(array: [Data(bytes: UnsafePointer<UInt8>(requestArray[mIndex]), count: requestArray[mIndex].count)])
    }
}
