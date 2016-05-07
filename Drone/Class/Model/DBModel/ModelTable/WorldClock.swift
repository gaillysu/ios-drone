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
    var gmt_offset:String = ""
    var city_name:String = ""
    
    private var worldClockModel:WorldClockModel = WorldClockModel()
    
    init(keyDict:NSDictionary) {
        super.init()
        keyDict.enumerateKeysAndObjectsUsingBlock { (key, value, stop) in
            self.setValue(value, forKey: key as! String)
        }
    }
    
    func add(result:((id:Int?,completion:Bool?) -> Void)){
        worldClockModel.city_name = city_name
        worldClockModel.gmt_offset = gmt_offset
        worldClockModel.add { (id, completion) -> Void in
            result(id: id, completion: completion)
        }
    }
    
    func update()->Bool{
        worldClockModel.id = id
        worldClockModel.city_name = city_name
        worldClockModel.gmt_offset = gmt_offset
        return worldClockModel.update()
    }
    
    func remove()->Bool{
        worldClockModel.id = id
        return worldClockModel.remove()
    }
    
    class func removeAll()->Bool{
        return WorldClockModel.removeAll()
    }
    
    class func getCriteria(criteria:String)->NSArray{
        let modelArray:NSArray = WorldClockModel.getCriteria(criteria)
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let worldClockModel:WorldClockModel = model as! WorldClockModel
            let worldClock:WorldClock = WorldClock(keyDict: ["id":worldClockModel.id,"city_name":worldClockModel.city_name,"gmt_offset":worldClockModel.gmt_offset])
            allArray.addObject(worldClock)
        }
        return allArray
    }
    
    class func getAll()->NSArray{
        let modelArray:NSArray = WorldClockModel.getAll()
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let worldClockModel:WorldClockModel = model as! WorldClockModel
            let worldClock:WorldClock = WorldClock(keyDict: ["id":worldClockModel.id,"city_name":worldClockModel.city_name,"gmt_offset":worldClockModel.gmt_offset])
            allArray.addObject(worldClock)
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
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
}
