//
//  Alarm.swift
//  Nevo
//
//  Created by supernova on 15/7/28.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class Alarm: NSObject {
    fileprivate var mIndex :Int?
    fileprivate var mHour :Int?
    fileprivate var mMinute:Int?
    fileprivate var mEnable:Bool?
    
    init(index: Int, hour:Int,minute:Int,enable:Bool)
    {
        mIndex = index
        mHour  = hour
        mMinute = minute
        mEnable = enable
    }
    func getIndex()->Int{
        return mIndex!
    }

    func getHour() ->Int
    {
        return mHour!
    }
    func getMinute() ->Int
    {
        return mMinute!
    }
    func getEnable() ->Bool
    {
        return mEnable!
    }

}
