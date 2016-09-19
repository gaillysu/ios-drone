//
//  SetUserProfileRequest.swift
//  Drone
//
//  Created by leiyuncun on 16/3/22.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit

class SetUserProfileRequest: NevoRequest {
    fileprivate var mWeight:Int = 0
    fileprivate var mHeight:Int = 0
    fileprivate var mGender:Int = 0
    fileprivate var mStridelength:Int = 0

    class func HEADER() -> UInt8 {
        return 0x31
    }

    init(weight:Int,height:Int,gender:Int,stridelength:Int) {
        super.init()
        mWeight = weight
        mHeight = height
        mGender = gender
        mStridelength = stridelength
    }

    override func getRawDataEx() -> NSArray {

        let values1 :[UInt8] = [0x80,SetUserProfileRequest.HEADER(),
            UInt8(mWeight&0xFF),
            UInt8((mWeight>>8)&0xFF),
            UInt8(mHeight&0xFF),
            UInt8(mGender&0xFF),
            UInt8(mStridelength&0xFF),0,0,0,0,0,0,0,0,0,0,0,0,0]

        return NSArray(array: [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)])
    }
}
