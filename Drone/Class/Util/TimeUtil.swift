//
//  TimeUtil.swift
//  Drone
//
//  Created by Karl-John on 23/5/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

class TimeUtil: NSObject {
    public static func getGmtOffSetForCity(city:String?) -> String{
        let now = NSDate()
        if(!(city?.isEmpty)!){
        let cst = NSTimeZone(name: city!)!
        let dateInCST = now.beginningOfDay.change(timeZone: cst)
        let timezone = dateInCST.timeZone
        var secondsFromGMT = timezone.secondsFromGMT
        if timezone.daylightSavingTime && !cst.isDaylightSavingTimeForDate(now) {
            secondsFromGMT -= Int(timezone.daylightSavingTimeOffset)
        }
        let gmtOffSet:String = String(secondsFromGMT/3600)
            return gmtOffSet
        }
        return "0"
        
    }
}
