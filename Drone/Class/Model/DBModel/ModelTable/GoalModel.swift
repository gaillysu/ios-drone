//
//  PresetsModel.swift
//  Nevo
//
//  Created by leiyuncun on 15/11/25.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import FMDB

class GoalModel: UserDatabaseHelper {
    var goalSteps:Int = 0
    var label:String = ""
    var status:Bool = false

    override init() {
        super.init()
        let dic:NSDictionary = GoalModel.getAllProperties()
        columeNames = NSMutableArray(array: dic.object(forKey: "name") as! NSArray)
        columeTypes = NSMutableArray(array: dic.object(forKey: "type") as! NSArray)

    }

    /**
     Static lookup function according to conditions

     @param criteria To find the condition
     @param returns Returns the find results
     */
    override class func getCriteria(_ criteria:String)->NSArray {
        let dbQueue:FMDatabaseQueue = AppDelegate.getAppDelegate().dbQueue
        let goal:NSMutableArray = NSMutableArray()
        dbQueue.inDatabase { (db) -> Void in
            var tableName:String =  NSStringFromClass(self.classForCoder())
            tableName = tableName.replacingOccurrences(of: ".", with: "")
            let sql:String = "SELECT * FROM \(tableName) \(criteria)"
            let resultSet:FMResultSet = db!.executeQuery(sql, withArgumentsIn: nil)
            while (resultSet.next()) {
                let model:GoalModel = GoalModel()

                for i:Int in 0 ..< model.columeNames.count {
                    let columeName:NSString = (model.columeNames.object(at: i) as! NSString)
                    let columeType:NSString = (model.columeTypes.object(at: i) as! NSString)
                    if (columeType.isEqual(to: SQLTEXT)) {
                        model.setValue(resultSet.string(forColumn: "\(columeName)"), forKey: "\(columeName)")
                    } else {
                        model.setValue(NSNumber(value: resultSet.longLongInt(forColumn: "\(columeName)") as Int64), forKey: "\(columeName)")
                    }
                }
                goal.add(model)
            }
        }
        return goal;
    }

    /**
     Lookup table all field data
     :returns: Returns the query to the data
     */
    override class func getAll()->NSArray{
        let dbQueue:FMDatabaseQueue = AppDelegate.getAppDelegate().dbQueue
        let goal:NSMutableArray = NSMutableArray()
        dbQueue.inDatabase { (db) -> Void in
            var tableName:NSString = NSStringFromClass(self.classForCoder()) as NSString
            tableName = tableName.replacingOccurrences(of: ".", with: "") as NSString
            let sql:String = "SELECT * FROM \(tableName)"
            let resultSet:FMResultSet = db!.executeQuery(sql, withArgumentsIn: nil)
            while (resultSet.next()) {
                let model:GoalModel = GoalModel()

                for i:Int in 0 ..< model.columeNames.count {
                    let columeName:String = model.columeNames.object(at: i) as! String
                    let columeType:String = model.columeTypes.object(at: i) as! String
                    if (columeType.isEqual(SQLTEXT)) {
                        model.setValue(resultSet.string(forColumn: "\(columeName)"), forKey: "\(columeName)")
                    } else {
                        model.setValue(NSNumber(value: resultSet.longLongInt(forColumn: "\(columeName)") as Int64), forKey: "\(columeName)")
                    }
                }
                goal.add(model)
            }

        }
        return goal;
    }

}
