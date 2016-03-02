//
//  NevoPacket.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation

/*
Represents a series of packets concatenated together to form the response from the watch
🚧🚧🚧Backbone Class : Modify with care🚧🚧🚧
*/
class NevoPacket {
    private var mPackets:[NSData]=[]
    private var mHeader:UInt8 = 0
    let endFlag:UInt8 = 0xFF
    
    struct DailyHistory
    {
        var TotalSteps:Int = 0;
        var HourlySteps:[Int] = [];
        //add new from v1.2.2
        //unit:cm->meter
        var TotalDist:Int = 0;
        var HourlyDist:[Int] = [];
        //unit: cal->kcal
        var TotalCalories:Int = 0;
        var HourlyCalories:[Int] = [0];
        var InactivityTime:Int = 0;
        var TotalInZoneTime:Int = 0;
        var TotalOutZoneTime:Int = 0;
        //unit: minute
        var TotalSleepTime:Int = 0;
        var HourlySleepTime:[Int] = [];
        var TotalWakeTime:Int = 0;
        var HourlyWakeTime:[Int] = [];
        var TotalLightTime:Int = 0;
        var HourlyLightTime:[Int] = [];
        var TotalDeepTime:Int = 0;
        var HourlyDeepTime:[Int] = [];
        //end add new
        var Date:NSDate;
        init( date:NSDate)
        {
           Date = date
        }
    }
    
    init(packets:[NSData])
    {
        if(packets.count >= 2)
        {
        mPackets = packets
        mHeader = NSData2Bytes(mPackets[0])[1]
        }
    }
    
    func getHeader() ->UInt8
    {
        return mHeader
    }
    func getPackets() ->[NSData]
    {
        return mPackets
    }
    
    func copy()->DailyStepsNevoPacket
    {
        return DailyStepsNevoPacket(packets: mPackets)
    }
    func copy()->DailyTrackerInfoNevoPacket
    {
        return DailyTrackerInfoNevoPacket(packets: mPackets)
    }
    func copy()->DailyTrackerNevoPacket
    {
        return DailyTrackerNevoPacket(packets: mPackets)
    }
    func copy()->BatteryLevelNevoPacket
    {
        return BatteryLevelNevoPacket(packets: mPackets)
    }
    //only two types packets: 2/78 count
    func isVaildPacket() ->Bool
    {
        if(mPackets.count == 2)
        {
           return true
        }
        if(mPackets.count == 78)
        {
            for var i:Int = 0 ;i < mPackets.count ; i++
            {
                if UInt8(i) != NSData2Bytes(mPackets[i])[0] && i != mPackets.count - 1
                {
                    return false
                }
                if mHeader != NSData2Bytes(mPackets[i])[1]
                {
                    return false
                }
            }
            return true
        }
        return false
    }
}