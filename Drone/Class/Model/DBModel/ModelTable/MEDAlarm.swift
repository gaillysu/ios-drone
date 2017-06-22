//
//  MEDAlarm.swift
//  Drone
//
//  Created by Karl-John Chow on 19/6/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import UIKit

import Foundation
import RealmSwift

class MEDAlarm: MEDBaseModel {
    
    dynamic var hour = 8
    dynamic var minute = 0
    
    dynamic var label:String = "Alarm"
    dynamic var enabled:Bool = false
    dynamic var snoozable:Bool = false
    
    let daysInWeek = List<MEDWeekDayNumber>()
    dynamic var key:String = Date().stringFromFormat("yyyyMMddHHmmss", locale: DateFormatter().locale)
    
    override static func primaryKey() -> String? {
        return "key"
    }
    
    func repeatLabel() -> String{
        if daysInWeek.isEmpty{
            return "Never"
        }
        var weekDayString = ""
        daysInWeek.forEach { number in
            if weekDayString != ""{
                weekDayString += " "
            }
            weekDayString += number.weekDay.shortDay()
        }
        return weekDayString
    }
}
