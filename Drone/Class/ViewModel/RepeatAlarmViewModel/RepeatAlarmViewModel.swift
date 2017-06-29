//
//  RepeatAlarmViewModel.swift
//  Drone
//
//  Created by Karl-John Chow on 22/6/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import Foundation
import RealmSwift

class RepeatAlarmViewModel {
    
    let alarm:MEDAlarm
    let realm:Realm
    init(alarm:MEDAlarm = MEDAlarm()) {
        self.alarm = alarm
        realm = try! Realm()
    }
    
    var selectedWeekDays:[Int] {
        get { return alarm.daysInWeek.map({ $0.weekDay })}
    }
    
    func addWeekDay(day:Int){
        try! realm.write {
            let weekDayNumber = MEDWeekDayNumber()
            weekDayNumber.weekDay = day
            if !alarm.daysInWeek.contains(weekDayNumber){
                alarm.daysInWeek.append(weekDayNumber)
            }
        }
    }
    
    func removeWeekDay(day:Int){
        if let index = self.alarm.daysInWeek.index(where: { number -> Bool in
            return number.weekDay == day
        }){
            try! realm.write {
                self.alarm.daysInWeek.remove(objectAtIndex: index)
            }
        }
    }
}
