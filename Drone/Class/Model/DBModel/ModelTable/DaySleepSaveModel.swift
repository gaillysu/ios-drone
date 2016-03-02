//
//  DaySleepSaveModel.swift
//  Nevo
//
//  Created by leiyuncun on 15/8/10.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class DaySleepSaveModel: NevoDBModel {

//    var DailySleepTime:NSString?
//
//    var DailyWakeTime:NSString?
//
//    var DailyLightTime:NSString?
//
//    var DailyDeepTime:NSString?
//
//    var DailyDist:NSString?
//    var DailyCalories:NSString?

    var created:Int = 0

    var steps:Int = 0;

    var hourlysteps:NSString = "";

    var distance:Double = 0;

    var hourlydistance:NSString = "";

    var calories:Double = 0;

    var hourlycalories:NSString = "";

    var InactivityTime:Int = 0;

    var TotalInZoneTime:Int = 0;

    var TotalOutZoneTime:Int = 0;

    var avghrm:Int = 0;

    var maxhrm:Int = 0;

    var goalreach:Double = 0;

    var TotalSleepTime:Int = 0;

    var HourlySleepTime:NSString = "";

    var TotalWakeTime:Int = 0;

    var HourlyWakeTime:NSString = "";

    var TotalLightTime:Int = 0;

    var HourlyLightTime:NSString = "";

    var TotalDeepTime:Int = 0;

    var HourlyDeepTime:NSString = "";

    /**
    * Start date in milliseconds since January 1, 1970, 00:00:00 GMT, means sleep start time
    * this is the night sleep start
    */
    var startDateTime:NSTimeInterval = 0.00;

    /**
    * End date in milliseconds since January 1, 1970, 00:00:00 GMT, means sleep end time
    * this is the night sleep end
    */
    var endDateTime:NSTimeInterval = 0.00;

    /**
    * Start date in milliseconds since January 1, 1970, 00:00:00 GMT, means sleep start time
    * this is the day sleep start
    * if I like to have a short sleep after lunch, It is a good idea for showing the second graph.
    */
    var reststartDateTime:NSTimeInterval = 0.00;

    /**
    * End date in milliseconds since January 1, 1970, 00:00:00 GMT, means sleep end time
    * this is the day sleep end
    */
    var restendDateTime:NSTimeInterval = 0.00;

    //this field save other values with Json string
    var remarks:NSString = "";

     override init() {

    }

}
