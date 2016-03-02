//
//  Presets.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/7.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class Presets: NSObject,BaseEntryDatabaseHelper {
    var id:Int = 0
    var steps:Int = 0
    var label:String = ""
    var status:Bool = false
    private var presetsModel:PresetsModel = PresetsModel()

    init(keyDict:NSDictionary) {
        super.init()
        self.setValue(keyDict.objectForKey("id"), forKey: "id")
        self.setValue(keyDict.objectForKey("steps"), forKey: "steps")
        self.setValue(keyDict.objectForKey("label"), forKey: "label")
        self.setValue(keyDict.objectForKey("status"), forKey: "status")
    }

    func add(result:((id:Int?,completion:Bool?) -> Void)){
        presetsModel.steps = steps
        presetsModel.label = label
        presetsModel.status = status
        presetsModel.add { (id, completion) -> Void in
           result(id: id!, completion: completion!)
        }
    }

    func update()->Bool{
        presetsModel.id = id
        presetsModel.steps = steps
        presetsModel.label = label
        presetsModel.status = status
        return presetsModel.update()
    }

    func remove()->Bool{
        presetsModel.id = id
        return presetsModel.remove()
    }

    class func removeAll()->Bool{
        return PresetsModel.removeAll()
    }

    class func getCriteria(criteria:String)->NSArray{
        let modelArray:NSArray = PresetsModel.getCriteria(criteria)
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let presetsModel:PresetsModel = model as! PresetsModel
            let presets:Presets = Presets(keyDict: ["steps":"\(presetsModel.steps)","label":"\(presetsModel.label)","status":"\(presetsModel.status)"])
            allArray.addObject(presets)
        }
        return allArray
    }

    class func getAll()->NSArray{
        let modelArray:NSArray = PresetsModel.getAll()
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let presetsModel:PresetsModel = model as! PresetsModel
            let presets:Presets = Presets(keyDict: ["id":"\(presetsModel.id)","steps":"\(presetsModel.steps)","label":"\(presetsModel.label)","status":"\(presetsModel.status)"])
            allArray.addObject(presets)
        }
        return allArray
    }
}
