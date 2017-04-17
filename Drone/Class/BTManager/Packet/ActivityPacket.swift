//
//  ActivityPacket.swift
//  Drone
//
//  Created by leiyuncun on 16/4/5.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit

class ActivityPacket: NSObject {
    fileprivate var packetData:Data = Data()

    init(data:Data) {
        super.init()
        packetData = data
    }

    func gettimerInterval() -> Int {
        let syncData:[UInt8] = Constants.NSData2Bytes(packetData)
        var timerInterval:Int = Int(syncData[2])
        timerInterval =  timerInterval + Int(syncData[3])<<8
        timerInterval =  timerInterval + Int(syncData[4])<<16
        timerInterval =  timerInterval + Int(syncData[5])<<24
        return timerInterval
    }

    func getStepCount() -> Int {
        let syncData:[UInt8] = Constants.NSData2Bytes(packetData)
        var dailySteps:Int = Int(syncData[6])
        dailySteps =  dailySteps + Int(syncData[7])<<8
        return dailySteps
    }

    func getStepDistance() -> Int {
        let syncData:[UInt8] = Constants.NSData2Bytes(packetData)
        var distance:Int = Int(syncData[8])
        distance =  distance + Int(syncData[9])<<8
        return distance
    }

    func getWakeupTime() -> Int {
        let syncData:[UInt8] = Constants.NSData2Bytes(packetData)
        let wakeuptimer:Int = Int(syncData[10])
        return wakeuptimer
    }

    func getLightSleepTime() -> Int {
        let syncData:[UInt8] = Constants.NSData2Bytes(packetData)
        let lightsleep:Int = Int(syncData[11])
        return lightsleep
    }

    func getDeepSleepTime() -> Int {
        let syncData:[UInt8] = Constants.NSData2Bytes(packetData)
        let deepsleep:Int = Int(syncData[12])
        return deepsleep
    }

    func getFIFOStatus() -> Int {
        let syncData:[UInt8] = Constants.NSData2Bytes(packetData)
        let status:Int = Int(syncData[13])
        return status
    }
}
