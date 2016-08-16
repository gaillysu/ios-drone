//
//  WorldClockUtil.swift
//  Drone
//
//  Created by Karl-John on 12/8/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import UIKit

class WorldClockUtil: NSObject {

    class func getStartDateForDST(timezone:Timezone) -> NSDate{
        return getDateFrom(timezone.dstDayInMonthStart, month: timezone.dstMonthStart, time: timezone.dstTimeStart)
    }
    
    class func getStopDateForDST(timezone:Timezone) -> NSDate{
        return getDateFrom(timezone.dstDayInMonthEnd, month: timezone.dstMonthEnd, time: timezone.dstTimeEnd)
    }
    
    class func getDateFrom(dateInMonth:Int, month:Int, time:String) -> NSDate{
        let date = NSDate()
        let utcTimeZone = NSTimeZone(name: "UTC")!
        var dateInUTC = date.beginningOfDay.change(timeZone: utcTimeZone)
        if let unpackedTime = time.dateFromFormat("HH:mm:ss.SSS"){
            dateInUTC = dateInUTC.change(year: dateInUTC.year, month: month, day: dateInMonth, hour: unpackedTime.hour, minute: unpackedTime.minute, second: 0)
        }else{
            print("Couldn't parse Time in timezone!!")
            dateInUTC.change(year: dateInUTC.year, month: month, day: dateInMonth, hour: 0, minute: 0, second: 0)
        }
        return dateInUTC
    }
    
    class func getBluetoothWorldClockModel(worldClockArray: [City]) -> [(cityName:String,gmtOffset:Float)]{
        var convertedWorldClockArray:[(cityName:String,gmtOffset:Float)] = []
        for city:City in worldClockArray {
            if let timezone = city.timezone{
                convertedWorldClockArray.append((city.name,Float(timezone.getOffsetFromUTC()/60)))
            }
        }
        return convertedWorldClockArray

    }
}