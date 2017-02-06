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
            var cstComp = DateComponents()
            cstComp.year = now.year
            cstComp.month = now.month
            cstComp.day = now.day
            cstComp.timeZone = TimeZone(identifier: "cst")
            // not sure if this works
            let dateInCST = Calendar.current.date(from: cstComp)!
            
            let timezone = dateInCST.oldTimeZone
            var secondsFromGMT = timezone.secondsFromGMT
        if timezone.isDaylightSavingTime && !cst.isDaylightSavingTime(for: now) {
            secondsFromGMT -= Int(timezone.daylightSavingTimeOffset)
        }
            let gmtOffSet:Int = Int(Float(secondsFromGMT)/(3600.0));
            return gmtOffSet
        }
        return 0
    }
}
