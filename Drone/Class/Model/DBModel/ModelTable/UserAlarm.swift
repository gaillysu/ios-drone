//
//  UserAlarm.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/7.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class UserAlarm: NSObject,BaseEntryDatabaseHelper {
    var id:Int = 0
    var timer:TimeInterval = 0.0
    var label:String = ""
    var status:Bool = false
    var repeatStatus:Bool = false

    fileprivate var alarmModel:AlarmModel = AlarmModel()

    init(keyDict:NSDictionary) {
        super.init()
        self.setValue(keyDict.object(forKey: "id"), forKey: "id")
        self.setValue(keyDict.object(forKey: "timer"), forKey: "timer")
        self.setValue(keyDict.object(forKey: "label"), forKey: "label")
        self.setValue(keyDict.object(forKey: "status"), forKey: "status")
        self.setValue(keyDict.object(forKey: "repeatStatus"), forKey: "repeatStatus")
    }

    func add(_ result:@escaping ((_ id:Int?,_ completion:Bool?) -> Void)){
        alarmModel.timer = timer
        alarmModel.label = label
        alarmModel.status = status
        alarmModel.repeatStatus = repeatStatus
        alarmModel.add { (id, completion) -> Void in
            result(id, completion)
        }
    }

    func update()->Bool{
        alarmModel.id = id
        alarmModel.timer = timer
        alarmModel.label = label
        alarmModel.status = status
        alarmModel.repeatStatus = repeatStatus
        return alarmModel.update()
    }

    func remove()->Bool{
        alarmModel.id = id
        return alarmModel.remove()
    }

    class func removeAll()->Bool{
        return AlarmModel.removeAll()
    }

    class func getCriteria(_ criteria:String)->NSArray{
        let modelArray:NSArray = AlarmModel.getCriteria(criteria)
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let alarmModel:AlarmModel = model as! AlarmModel
            let presets:UserAlarm = UserAlarm(keyDict: ["id":alarmModel.id,"timer":alarmModel.timer,"label":"\(alarmModel.label)","status":alarmModel.status,"repeatStatus":alarmModel.repeatStatus])
            allArray.add(presets)
        }
        return allArray
    }

    class func getAll()->NSArray{
        let modelArray:NSArray = AlarmModel.getAll()
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let alarmModel:AlarmModel = model as! AlarmModel
            let presets:UserAlarm = UserAlarm(keyDict: ["id":alarmModel.id,"timer":alarmModel.timer,"label":"\(alarmModel.label)","status":alarmModel.status,"repeatStatus":alarmModel.repeatStatus])
            allArray.add(presets)
        }
        return allArray
    }
}
