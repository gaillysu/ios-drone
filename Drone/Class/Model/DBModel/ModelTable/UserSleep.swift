//
//  UserSleep.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/23.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class UserSleep: NSObject,BaseEntryDatabaseHelper {

    var id:Int = 0
    var date:NSTimeInterval = 0
    var totalSleepTime:Int = 0;
    var hourlySleepTime:String = "";
    var totalWakeTime:Int = 0;
    var hourlyWakeTime:String = "";
    var totalLightTime:Int = 0;
    var hourlyLightTime:String = "";
    var totalDeepTime:Int = 0;
    var hourlyDeepTime:String = "";
    private var sleepModel:SleepModel = SleepModel()

    override init() {
        
    }

    init(keyDict:NSDictionary) {
        super.init()
        self.setValue(keyDict.objectForKey("id"), forKey: "id")
        self.setValue(keyDict.objectForKey("date"), forKey: "date")
        self.setValue(keyDict.objectForKey("totalSleepTime"), forKey: "totalSleepTime")
        self.setValue(keyDict.objectForKey("hourlySleepTime"), forKey: "hourlySleepTime")
        self.setValue(keyDict.objectForKey("totalWakeTime"), forKey: "totalWakeTime")
        self.setValue(keyDict.objectForKey("hourlyWakeTime"), forKey: "hourlyWakeTime")
        self.setValue(keyDict.objectForKey("totalLightTime"), forKey: "totalLightTime")
        self.setValue(keyDict.objectForKey("hourlyLightTime"), forKey: "hourlyLightTime")
        self.setValue(keyDict.objectForKey("totalDeepTime"), forKey: "totalDeepTime")
        self.setValue(keyDict.objectForKey("hourlyDeepTime"), forKey: "hourlyDeepTime")
    }

    func add(result:((id:Int?,completion:Bool?) -> Void)){
        sleepModel.date = date
        sleepModel.totalSleepTime = totalSleepTime
        sleepModel.hourlySleepTime = hourlySleepTime
        sleepModel.totalWakeTime = totalWakeTime
        sleepModel.hourlyWakeTime = hourlyWakeTime
        sleepModel.totalLightTime = totalLightTime
        sleepModel.hourlyLightTime = hourlyLightTime
        sleepModel.totalDeepTime = totalDeepTime
        sleepModel.hourlyDeepTime = hourlyDeepTime

        sleepModel.add { (id, completion) -> Void in
            result(id: id, completion: completion)
        }
    }

    func update()->Bool{
        sleepModel.date = date
        sleepModel.totalSleepTime = totalSleepTime
        sleepModel.hourlySleepTime = hourlySleepTime
        sleepModel.totalWakeTime = totalWakeTime
        sleepModel.hourlyWakeTime = hourlyWakeTime
        sleepModel.totalLightTime = totalLightTime
        sleepModel.hourlyLightTime = hourlyLightTime
        sleepModel.totalDeepTime = totalDeepTime
        sleepModel.hourlyDeepTime = hourlyDeepTime
        return sleepModel.update()
    }

    func remove()->Bool{
        sleepModel.id = id
        return sleepModel.remove()
    }

    class func removeAll()->Bool{
        return SleepModel.removeAll()
    }

    class func getCriteria(criteria:String)->NSArray{
        let modelArray:NSArray = SleepModel.getCriteria(criteria)
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let sleepModel:SleepModel = model as! SleepModel
            let presets:UserSleep = UserSleep(keyDict: ["id":sleepModel.id, "date":sleepModel.date, "totalSleepTime":sleepModel.totalSleepTime, "hourlySleepTime":sleepModel.hourlySleepTime, "totalWakeTime":sleepModel.totalWakeTime, "hourlyWakeTime":sleepModel.hourlyWakeTime , "totalLightTime":sleepModel.totalLightTime, "hourlyLightTime":sleepModel.hourlyLightTime, "totalDeepTime":sleepModel.totalDeepTime, "totalDeepTime":sleepModel.totalDeepTime, "hourlyDeepTime":sleepModel.hourlyDeepTime])
            allArray.addObject(presets)
        }
        return allArray
    }

    class func getAll()->NSArray{
        let modelArray:NSArray = SleepModel.getAll()
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let sleepModel:SleepModel = model as! SleepModel
            let presets:UserSleep = UserSleep(keyDict: ["id":sleepModel.id, "date":sleepModel.date, "totalSleepTime":sleepModel.totalSleepTime, "hourlySleepTime":sleepModel.hourlySleepTime, "totalWakeTime":sleepModel.totalWakeTime, "hourlyWakeTime":sleepModel.hourlyWakeTime , "totalLightTime":sleepModel.totalLightTime, "hourlyLightTime":sleepModel.hourlyLightTime, "totalDeepTime":sleepModel.totalDeepTime, "totalDeepTime":sleepModel.totalDeepTime, "hourlyDeepTime":sleepModel.hourlyDeepTime])
            allArray.addObject(presets)
        }
        return allArray
    }
}
