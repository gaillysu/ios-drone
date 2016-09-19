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
    var date:TimeInterval = 0
    var wakeup_time:Int = 0;
    var light_sleep_time:Int = 0;
    var deep_sleep_time:Int = 0;
    fileprivate var sleepModel:SleepModel = SleepModel()

    override init() {
        
    }

    init(keyDict:NSDictionary) {
        super.init()
        keyDict.enumerateKeysAndObjects { (key, value, stop) in
            self.setValue(value, forKey: key as! String)
        }
    }

    func add(_ result:@escaping ((_ id:Int?,_ completion:Bool?) -> Void)){
        sleepModel.date = date
        sleepModel.wakeup_time = wakeup_time
        sleepModel.light_sleep_time = light_sleep_time
        sleepModel.deep_sleep_time = deep_sleep_time

        sleepModel.add { (id, completion) -> Void in
            result(id, completion)
        }
    }

    func update()->Bool{
        sleepModel.date = date
        sleepModel.wakeup_time = wakeup_time
        sleepModel.light_sleep_time = light_sleep_time
        sleepModel.deep_sleep_time = deep_sleep_time
        return sleepModel.update()
    }

    func remove()->Bool{
        sleepModel.id = id
        return sleepModel.remove()
    }

    class func removeAll()->Bool{
        return SleepModel.removeAll()
    }

    class func getCriteria(_ criteria:String)->NSArray{
        let modelArray:NSArray = SleepModel.getCriteria(criteria)
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let sleepModel:SleepModel = model as! SleepModel
            let sleep:UserSleep = UserSleep(keyDict: ["id":sleepModel.id, "date":sleepModel.date, "wakeup_time":sleepModel.wakeup_time, "light_sleep_time":sleepModel.light_sleep_time, "deep_sleep_time":sleepModel.deep_sleep_time])
            allArray.add(sleep)
        }
        return allArray
    }

    class func getAll()->NSArray{
        let modelArray:NSArray = SleepModel.getAll()
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let sleepModel:SleepModel = model as! SleepModel
            let sleep:UserSleep = UserSleep(keyDict: ["id":sleepModel.id, "date":sleepModel.date, "wakeup_time":sleepModel.wakeup_time, "light_sleep_time":sleepModel.light_sleep_time, "deep_sleep_time":sleepModel.deep_sleep_time])
            allArray.add(sleep)
        }
        return allArray
    }
}
