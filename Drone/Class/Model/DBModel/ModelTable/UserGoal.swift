//
//  Presets.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/7.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class UserGoal: NSObject,BaseEntryDatabaseHelper {
    var id:Int = 0
    var goalSteps:Int = 0
    var label:String = ""
    var status:Bool = false
    private var goalModel:GoalModel = GoalModel()

    init(keyDict:NSDictionary) {
        super.init()
        keyDict.enumerateKeysAndObjectsUsingBlock { (key, value, stop) in
            self.setValue(value, forKey: key as! String)
        }
    }

    func add(result:((id:Int?,completion:Bool?) -> Void)){
        goalModel.goalSteps = goalSteps
        goalModel.label = label
        goalModel.status = status
        goalModel.add { (id, completion) -> Void in
           result(id: id!, completion: completion!)
        }
    }

    func update()->Bool{
        goalModel.id = id
        goalModel.goalSteps = goalSteps
        goalModel.label = label
        goalModel.status = status
        return goalModel.update()
    }

    func remove()->Bool{
        goalModel.id = id
        return goalModel.remove()
    }

    class func removeAll()->Bool{
        return GoalModel.removeAll()
    }

    class func getCriteria(criteria:String)->NSArray{
        let modelArray:NSArray = GoalModel.getCriteria(criteria)
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let goalModel:GoalModel = model as! GoalModel
            let goal:UserGoal = UserGoal(keyDict: ["goalSteps":"\(goalModel.goalSteps)","label":"\(goalModel.label)","status":"\(goalModel.status)"])
            allArray.addObject(goal)
        }
        return allArray
    }

    class func getAll()->NSArray{
        let modelArray:NSArray = GoalModel.getAll()
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let goalModel:GoalModel = model as! GoalModel
            let goal:UserGoal = UserGoal(keyDict: ["id":"\(goalModel.id)","goalSteps":"\(goalModel.goalSteps)","label":"\(goalModel.label)","status":"\(goalModel.status)"])
            allArray.addObject(goal)
        }
        return allArray
    }
}
