//
//  DailyStepsNevoPacket.swift
//  Nevo
//
//  Created by supernova on 15/3/17.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class DailyStepsNevoPacket: NevoPacket {
    
    /**
    return the Current Daily steps
    */
    func getDailySteps() ->Int
    {
        var dailySteps:Int = Int(NSData2Bytes(getPackets()[0])[2] )
        dailySteps =  dailySteps + Int(NSData2Bytes(getPackets()[0])[3] )<<8
        dailySteps =  dailySteps + Int(NSData2Bytes(getPackets()[0])[4] )<<16
        dailySteps =  dailySteps + Int(NSData2Bytes(getPackets()[0])[5] )<<24
        return dailySteps
    }
    /**
    return the Daily steps Goal
    */
    func getDailyStepsGoal() ->Int
    {
        var dailyStepGoal:Int = Int(NSData2Bytes(getPackets()[0])[6] )
        dailyStepGoal =  dailyStepGoal + Int(NSData2Bytes(getPackets()[0])[7] )<<8
        dailyStepGoal =  dailyStepGoal + Int(NSData2Bytes(getPackets()[0])[8] )<<16
        dailyStepGoal =  dailyStepGoal + Int(NSData2Bytes(getPackets()[0])[9] )<<24
        return dailyStepGoal
    }

    
   
}
