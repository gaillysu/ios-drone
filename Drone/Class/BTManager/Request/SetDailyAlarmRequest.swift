//
//  SetDailyAlarmRequest.swift
//  Drone
//
//  Created by Cloud on 2017/6/21.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit

class SetDailyAlarmRequest: DroneRequest {
    
    
    let alarmWeekDay:[MEDAlarm]
    
    class func HEADER() -> UInt8 {
        return 0x37
    }
    
    init(alarmWeekDay:[MEDAlarm]) {
        self.alarmWeekDay = alarmWeekDay
    }
    
    override func getRawDataEx() -> [Data] {
        var values :[UInt8] = [SetDailyAlarmRequest.HEADER()]
        alarmWeekDay.forEach({ alarm in
            var weekDay = ["0","0","0","0","0","0","0","0","0"]
            alarm.daysInWeek.forEach({ dayInWeek in
                weekDay[dayInWeek.weekDay] = "1"
            })
            if alarm.snoozable{
                weekDay[7] = "1"
            }
            values += [UInt8(alarm.hour&0xFF),UInt8(alarm.minute&0xFF),UInt8(weekDay.joined().binary2dec()&0xFF)]
        })
        return Constants.splitPacketConverter(data: values)
    }
}
