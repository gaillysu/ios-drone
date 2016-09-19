//
//  UserSteps.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/23.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class UserSteps: NSObject,BaseEntryDatabaseHelper {
    var id:Int = 0
    var cid:Int = 0
    var steps:Int = 0
    var distance:Int = 0
    var date:TimeInterval = 0
    var syncnext:Bool = false

    fileprivate var stepsModel:StepsModel = StepsModel()
    
    init(keyDict:NSDictionary) {
        super.init()
        keyDict.enumerateKeysAndObjects { (key, value, stop) in
            self.setValue(value, forKey: key as! String)
        }
    }

    func add(_ result:@escaping ((_ id:Int?,_ completion:Bool?) -> Void)){
        stepsModel.steps = steps
        stepsModel.distance = "\(distance)"
        stepsModel.date = date
        stepsModel.syncnext = syncnext

        stepsModel.add { (id, completion) -> Void in
            result(id, completion)
        }
    }

    func update()->Bool{
        stepsModel.id = id
        stepsModel.steps = steps
        stepsModel.distance = "\(distance)"
        stepsModel.date = date
        stepsModel.syncnext = syncnext
        return stepsModel.update()
    }

    func remove()->Bool{
        stepsModel.id = id
        return stepsModel.remove()
    }

    class func removeAll()->Bool{
        return StepsModel.removeAll()
    }

    class func getCriteria(_ criteria:String)->NSArray{
        let modelArray:NSArray = StepsModel.getCriteria(criteria)
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let stepsModel:StepsModel = model as! StepsModel
            let presets:UserSteps = UserSteps(keyDict: ["id":stepsModel.id, "steps":stepsModel.steps, "distance":stepsModel.distance, "date":stepsModel.date, "syncnext":stepsModel.syncnext])
            allArray.add(presets)
        }
        return allArray
    }

    class func getAll()->NSArray{
        let modelArray:NSArray = StepsModel.getAll()
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let stepsModel:StepsModel = model as! StepsModel
            let presets:UserSteps = UserSteps(keyDict: ["id":stepsModel.id, "steps":stepsModel.steps, "distance":stepsModel.distance, "date":stepsModel.date, "syncnext":stepsModel.syncnext])
            allArray.add(presets)
        }
        return allArray
    }
}
