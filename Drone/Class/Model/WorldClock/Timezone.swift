//
//  Timezone.swift
//  Drone
//
//  Created by Karl-John on 11/8/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class Timezone: Object {
    
    dynamic var id:Int = 0
    
    dynamic var name:String = ""
    
    dynamic var gmt:String = ""
    
    dynamic var gmtTimeOffset:Int = 0
    
    dynamic var stdName:String = ""
    
    dynamic var dstMonthStart:Int = 0
    
    dynamic var dstDayInMonthStart:Int = 0
    
    dynamic var dstTimeStart:String = ""
    
    dynamic var dstName:String = ""
    
    dynamic var dstTimeOffset:Int = 0
    
    dynamic var dstMonthEnd:Int = 0
    
    dynamic var dstDayInMonthEnd:Int = 0
    
    dynamic var dstTimeEnd:String = ""
    
    class func getTimeZoneObject(_ json:JSON) -> Timezone?{
        
        if let id = json["id"].int,
            let name = json["name"].string,
            let gmt = json["gmt"].string,
            let gmtOffset = json["offset"].int,
            let stdName = json["std_name"].string,
            let dstMonthStart = json["dst_month_start"].int,
            let dstDayInMonthStart = json["day_in_month_start"].int,
            let dstTimeStart = json["dst_time_start"].string,
            let dstName = json["dst_name"].string,
            let dstTimeOffset = json["dst_time_offset"].int,
            let dstMonthEnd = json["dst_month_end"].int,
            let dstDayInMonthEnd = json["day_in_month_end"].int,
            let dstTimeEnd = json["dst_time_end"].string
        {
            let timezone:Timezone = Timezone()
            timezone.name = name
            timezone.id = id
            timezone.gmt = gmt
            timezone.gmtTimeOffset = gmtOffset
            timezone.stdName = stdName
            timezone.dstMonthStart = dstMonthStart
            timezone.dstDayInMonthStart = dstDayInMonthStart
            timezone.dstTimeStart = dstTimeStart
            timezone.dstName = dstName
            timezone.dstTimeOffset = dstTimeOffset
            timezone.dstMonthEnd = dstMonthEnd
            timezone.dstDayInMonthEnd = dstDayInMonthEnd
            timezone.dstTimeEnd = dstTimeEnd
            return timezone
        } else {
            print("The provided JSON is not according the right keys.")
        }
        return nil;
    }

    func getOffsetFromUTC() -> Int{
        if dstTimeOffset > 0 {
            let startDate = WorldClockUtil.getStartDateForDST(self)
            let stopDate = WorldClockUtil.getStopDateForDST(self)
            if startDate.timeIntervalSince1970 < Date().timeIntervalSince1970 && stopDate.timeIntervalSince1970 > Date().timeIntervalSince1970 {
                return gmtTimeOffset + dstTimeOffset
            }
        }
        return gmtTimeOffset
    }

}
