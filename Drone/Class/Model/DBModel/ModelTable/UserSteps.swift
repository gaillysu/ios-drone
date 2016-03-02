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
    var steps:Int = 0
    var distance:Int = 0
    var hourlysteps:String = ""
    var hourlydistance:String = ""
    var calories:Double = 0
    var hourlycalories:String = ""
    var inZoneTime:Int = 0;
    var outZoneTime:Int = 0;
    var inactivityTime:Int = 0;
    var goalreach:Double = 0;
    var date:NSTimeInterval = 0
    private var stepsModel:StepsModel = StepsModel()
    
    init(keyDict:NSDictionary) {
        super.init()
        self.setValue(keyDict.objectForKey("id"), forKey: "id")
        self.setValue(keyDict.objectForKey("steps"), forKey: "steps")
        self.setValue(keyDict.objectForKey("distance"), forKey: "distance")
        self.setValue(keyDict.objectForKey("hourlysteps"), forKey: "hourlysteps")
        self.setValue(keyDict.objectForKey("hourlydistance"), forKey: "hourlydistance")
        self.setValue(keyDict.objectForKey("calories"), forKey: "calories")
        self.setValue(keyDict.objectForKey("hourlycalories"), forKey: "hourlycalories")
        self.setValue(keyDict.objectForKey("inZoneTime"), forKey: "inZoneTime")
        self.setValue(keyDict.objectForKey("outZoneTime"), forKey: "outZoneTime")
        self.setValue(keyDict.objectForKey("inactivityTime"), forKey: "inactivityTime")
        self.setValue(keyDict.objectForKey("goalreach"), forKey: "goalreach")
        self.setValue(keyDict.objectForKey("date"), forKey: "date")
    }

    func add(result:((id:Int?,completion:Bool?) -> Void)){
        stepsModel.steps = steps
        stepsModel.distance = distance
        stepsModel.hourlysteps = hourlysteps
        stepsModel.hourlydistance = hourlydistance
        stepsModel.calories = calories
        stepsModel.hourlycalories = hourlycalories
        stepsModel.inZoneTime = inZoneTime
        stepsModel.outZoneTime = outZoneTime
        stepsModel.inactivityTime = inactivityTime
        stepsModel.goalreach = goalreach
        stepsModel.date = date

        stepsModel.add { (id, completion) -> Void in
            result(id: id, completion: completion)
        }
    }

    func update()->Bool{
        stepsModel.id = id
        stepsModel.steps = steps
        stepsModel.distance = distance
        stepsModel.hourlysteps = hourlysteps
        stepsModel.hourlydistance = hourlydistance
        stepsModel.calories = calories
        stepsModel.hourlycalories = hourlycalories
        stepsModel.inZoneTime = inZoneTime
        stepsModel.outZoneTime = outZoneTime
        stepsModel.inactivityTime = inactivityTime
        stepsModel.goalreach = goalreach
        stepsModel.date = date
        return stepsModel.update()
    }

    func remove()->Bool{
        stepsModel.id = id
        return stepsModel.remove()
    }

    class func removeAll()->Bool{
        return StepsModel.removeAll()
    }

    class func getCriteria(criteria:String)->NSArray{
        let modelArray:NSArray = StepsModel.getCriteria(criteria)
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let stepsModel:StepsModel = model as! StepsModel
            let presets:UserSteps = UserSteps(keyDict: ["id":stepsModel.id, "steps":stepsModel.steps, "distance":stepsModel.distance, "hourlysteps":stepsModel.hourlysteps, "hourlydistance":stepsModel.hourlydistance, "calories":stepsModel.calories , "hourlycalories":stepsModel.hourlycalories, "inZoneTime":stepsModel.inZoneTime, "outZoneTime":stepsModel.outZoneTime, "inactivityTime":stepsModel.inactivityTime, "goalreach":stepsModel.goalreach, "date":stepsModel.date])
            allArray.addObject(presets)
        }
        return allArray
    }

    class func getAll()->NSArray{
        let modelArray:NSArray = StepsModel.getAll()
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let stepsModel:StepsModel = model as! StepsModel
            let presets:UserSteps = UserSteps(keyDict: ["id":stepsModel.id, "steps":stepsModel.steps, "distance":stepsModel.distance, "hourlysteps":stepsModel.hourlysteps, "hourlydistance":stepsModel.hourlydistance, "calories":stepsModel.calories , "hourlycalories":stepsModel.hourlycalories, "inZoneTime":stepsModel.inZoneTime, "outZoneTime":stepsModel.outZoneTime, "inactivityTime":stepsModel.inactivityTime, "goalreach":stepsModel.goalreach, "date":stepsModel.date])
            allArray.addObject(presets)
        }
        return allArray
    }
}
