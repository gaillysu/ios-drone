//
//  StepsGoalPacket.swift
//  Drone
//
//  Created by leiyuncun on 16/4/5.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit

class StepsGoalPacket: NSObject {
    private var packetData:NSData = NSData()

    init(data:NSData) {
        super.init()
        packetData = data
    }

    func getStepsGoalPacket() -> NSData {
        return packetData
    }

    func getGoal() -> Int {
        let data:[UInt8] = NSData2Bytes(packetData as Data)
        var goal:Int = Int(data[2] )
        goal =  goal + Int(data[3])<<8
        goal =  goal + Int(data[4])<<16
        goal =  goal + Int(data[5])<<24
        return goal
    }

    func getDailySteps() -> Int {
        let data:[UInt8] = NSData2Bytes(packetData as Data)
        var dailySteps:Int = Int(data[7])
        dailySteps =  dailySteps + Int(data[8])<<8
        dailySteps =  dailySteps + Int(data[9])<<16
        dailySteps =  dailySteps + Int(data[10])<<24
        return dailySteps
    }
}
