//
//  SetGoalRequest.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation

/*
Sets a goal to the given value
*/
class SetGoalRequest : NevoRequest {
    
    /*
    This header is the key by which this kind of packet is called.
    */
    class func HEADER() -> UInt8 {
        return 0x12
    }

    fileprivate var mThisGoal : Goal
    
    init (goal : Goal) {
        mThisGoal = goal
    }
    
    override func getRawDataEx() -> NSArray {

    let goal_steps = mThisGoal.getType() == NumberOfStepsGoal().getType() ? mThisGoal.getValue() : 0
        let values1 :[UInt8] = [0x80,SetGoalRequest.HEADER(),
            UInt8(goal_steps&0xFF),
            UInt8((goal_steps>>8)&0xFF),
            UInt8((goal_steps>>16)&0xFF),
            UInt8((goal_steps>>24)&0xFF)
            ,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

    return NSArray(array: [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)])
    }
    
}
