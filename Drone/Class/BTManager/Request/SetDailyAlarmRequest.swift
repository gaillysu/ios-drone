//
//  SetDailyAlarmRequest.swift
//  Drone
//
//  Created by Cloud on 2017/6/21.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit

enum AlarmWeekDay:Int {
    case sunday     = 7
    case monday     = 6
    case tuesday    = 5
    case wednesday  = 4
    case thursday   = 3
    case friday     = 2
    case saturday   = 1
    case snooze     = 0
}

class SetDailyAlarmRequest: DroneRequest {
    
    
    fileprivate var alarmWeekDay:[Int:[AlarmWeekDay]]?
    
    class func HEADER() -> UInt8 {
        return 0x37
    }
    
    
    /// 发送闹钟请求
    ///
    /// - Parameter alarmWeekDay: key 是alarm 的 Hour,Minute 以秒为单位的和，使用的时候需要主要转换对应的时间，注意:时间是 24 小时制, value,是闹钟重复日期的集合
    /// sample: alarmWeekDay = [56160:[AlarmWeekDay.sunday,AlarmWeekDay.monday],415200:[AlarmWeekDay.monday,AlarmWeekDay.tuesday],37920:[AlarmWeekDay.tuesday,AlarmWeekDay.friday]]
    
    init(alarmWeekDay:[Int:[AlarmWeekDay]]) {
        self.alarmWeekDay = alarmWeekDay
    }
    
    override func getRawDataEx() -> [Data] {
        var values1 :[UInt8] = [SetDailyAlarmRequest.HEADER()]
        alarmWeekDay?.forEach({ (alarmDate,weekDayKey) in
            var weekDay = ["0","0","0","0","0","0","0","0"]
            weekDayKey.forEach({ (week) in
                weekDay.replaceSubrange(week.rawValue..<week.rawValue+1, with: ["1"])
            })
            let hour:Int = Int(alarmDate/3600)
            let minute:Int = Int((alarmDate%3600)/60)
            values1 += [UInt8(hour&0xFF),UInt8(minute&0xFF),UInt8(weekDay.joined().binary2dec()&0xFF)]
        })
        return Constants.splitPacketConverter(data: values1)
    }
}
