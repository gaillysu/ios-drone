//
//  SetStepsToWatchReuqest.swift
//  Drone
//
//  Created by leiyuncun on 16/6/7.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import Foundation

class SetStepsToWatchReuqest: NevoRequest {
    fileprivate var mSteps:Int = 0
    
    class func HEADER() -> UInt8 {
        return 0x30
    }
    
    init (steps:Int) {
        mSteps = steps
    }
    
    override func getRawDataEx() -> NSArray {
        let values1 :[UInt8] = [0x80,SetStepsToWatchReuqest.HEADER(),
                                UInt8(mSteps&0xFF),
                                UInt8((mSteps>>8)&0xFF),
                                UInt8((mSteps>>16)&0xFF),
                                UInt8((mSteps>>24)&0xFF),0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        return NSArray(array: [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)])
    }
}
