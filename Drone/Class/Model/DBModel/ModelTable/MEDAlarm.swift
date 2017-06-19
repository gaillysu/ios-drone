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
    
    let daysInWeek = List<MEDWeekDayNumber>()
    dynamic var key:String = Date().stringFromFormat("yyyyMMddHHmmss", locale: DateFormatter().locale)
    
    override static func primaryKey() -> String? {
        return "key"
    }
}
