//
//  WorldClockModel.swift
//  Drone
//
//  Created by Karl-John on 6/5/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import UIKit

class WorldClock: NSObject {
    var id:Int = 0
    var system_name:String = ""
    var city_name:String = ""
    var display_name:String = ""
    
    fileprivate var worldClockModel:WorldClockModel = WorldClockModel()
    
    init(keyDict:NSDictionary) {
        super.init()
        for(key, value) in keyDict {
            self.setValue(value, forKey: key as! String)
        }
    }
    
    func add(_ result:@escaping ((_ id:Int?,_ completion:Bool?) -> Void)){
        worldClockModel.city_name = city_name
        worldClockModel.system_name = system_name
        worldClockModel.display_name = display_name
        worldClockModel.add { (id, completion) -> Void in
            result(id, completion)
        }
    }
    
    func update()->Bool{
        worldClockModel.id = id
        worldClockModel.city_name = city_name
        worldClockModel.system_name = system_name
        worldClockModel.display_name = display_name
        return worldClockModel.update()
    }
    
    func remove()->Bool{
        worldClockModel.id = id
        return worldClockModel.remove()
    }
    
    class func removeAll()->Bool{
        return WorldClockModel.removeAll()
    }
    
    class func getCriteria(_ criteria:String)->NSArray{
        let modelArray:NSArray = WorldClockModel.getCriteria(criteria)
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let worldClockModel:WorldClockModel = model as! WorldClockModel
            let worldClock:WorldClock = WorldClock(keyDict: ["id":worldClockModel.id,"city_name":worldClockModel.city_name,"system_name":worldClockModel.system_name, "display_name": worldClockModel.display_name])
            allArray.add(worldClock)
        }
        return allArray
    }
    
    class func getAll()->NSArray{
        let modelArray:NSArray = WorldClockModel.getAll()
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let worldClockModel:WorldClockModel = model as! WorldClockModel
            let worldClock:WorldClock = WorldClock(keyDict: ["id":worldClockModel.id,"city_name":worldClockModel.city_name,"system_name":worldClockModel.system_name, "display_name": worldClockModel.display_name])
            allArray.add(worldClock)
        }
        return allArray
    }
    
    class func isExistInTable()->Bool {
        return WorldClockModel.isExistInTable()
    }
    
    class func updateTable()->Bool {
        return WorldClockModel.updateTable()
    }
    
    // Prevent the object properties and KVC dict key don't crash
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
}
