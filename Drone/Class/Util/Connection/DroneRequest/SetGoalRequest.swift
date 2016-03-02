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

    private var mThisGoal : Goal
    
    init (goal : Goal) {
        mThisGoal = goal
    }
    
    override func getRawDataEx() -> NSArray {
    
       
    let level :UInt8 = mThisGoal.getGoalIntensity().rawValue
    let display:UInt8 = 0  //default is step goal showing
    let goal_dist = 10000 //unit ??cm
  
    let goal_steps = mThisGoal.getType() == NumberOfStepsGoal().getType() ? mThisGoal.getValue() : 0
        
    let goal_carlories = 2000 // unit ??
    let goal_time = 0x00 //unit ??
    let goal_stroke = 3000 // unit ???
        let values1 :[UInt8] = [0x80,SetGoalRequest.HEADER(),
            UInt8(goal_steps&0xFF),
            UInt8((goal_steps>>8)&0xFF),
            UInt8((goal_steps>>16)&0xFF),
            UInt8((goal_steps>>24)&0xFF)
            ,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

    return NSArray(array: [NSData(bytes: values1, length: values1.count)])
    }
    
}