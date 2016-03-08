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
    var hourlysteps:String = ""
    var date:NSTimeInterval = 0

    private var stepsModel:StepsModel = StepsModel()
    
    init(keyDict:NSDictionary) {
        super.init()
        self.setValue(keyDict.objectForKey("id"), forKey: "id")
        self.setValue(keyDict.objectForKey("steps"), forKey: "steps")
        self.setValue(keyDict.objectForKey("hourlysteps"), forKey: "hourlysteps")
        self.setValue(keyDict.objectForKey("date"), forKey: "date")
    }

    func add(result:((id:Int?,completion:Bool?) -> Void)){
        stepsModel.steps = steps
        stepsModel.hourlysteps = hourlysteps
        stepsModel.date = date

        stepsModel.add { (id, completion) -> Void in
            result(id: id, completion: completion)
        }
    }

    func update()->Bool{
        stepsModel.id = id
        stepsModel.steps = steps
        stepsModel.hourlysteps = hourlysteps
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
            let presets:UserSteps = UserSteps(keyDict: ["id":stepsModel.id, "steps":stepsModel.steps, "hourlysteps":stepsModel.hourlysteps, "date":stepsModel.date])
            allArray.addObject(presets)
        }
        return allArray
    }

    class func getAll()->NSArray{
        let modelArray:NSArray = StepsModel.getAll()
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let stepsModel:StepsModel = model as! StepsModel
            let presets:UserSteps = UserSteps(keyDict: ["id":stepsModel.id, "steps":stepsModel.steps,  "hourlysteps":stepsModel.hourlysteps, "date":stepsModel.date])
            allArray.addObject(presets)
        }
        return allArray
    }
}
