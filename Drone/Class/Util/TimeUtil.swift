//
//  TimeUtil.swift
//  Drone
//
//  Created by Karl-John on 23/5/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

class TimeUtil: NSObject {
    class func getGmtOffSetForCity(_ city:String) -> Int{
        let now = Date()
        if(!city.isEmpty){
            let cst = TimeZone(identifier: city)!
            let dateInCST = now.beginningOfDay.change(timeZone: cst)
            let timezone = dateInCST.timeZone
            var secondsFromGMT = timezone.secondsFromGMT()
        if timezone.isDaylightSavingTime() && !cst.isDaylightSavingTime(for: now) {
            secondsFromGMT -= Int(timezone.daylightSavingTimeOffset())
        }
            let gmtOffSet:Int = Int(Float(secondsFromGMT)/(3600.0));
            return gmtOffSet
        }
        return 0
    }
}
