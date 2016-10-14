//
//  AlarmModel.swift
//  Nevo
//
//  Created by leiyuncun on 15/11/25.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import FMDB

class AlarmModel: UserDatabaseHelper {
    var timer:TimeInterval = 0.0
    var label:String = ""
    var status:Bool = false
    var repeatStatus:Bool = false

    override init() {
        
    }

    /**
     Static lookup function according to conditions

     @param criteria To find the condition
     @param returns Returns the find results
     */
    override class func getCriteria(_ criteria:String)->NSArray {
        let dbQueue:FMDatabaseQueue = AppDelegate.getAppDelegate().dbQueue
        let alarm:NSMutableArray = NSMutableArray()
        dbQueue.inDatabase { (db) -> Void in
            var tableName:String =  NSStringFromClass(self.classForCoder())
            tableName = tableName.replacingOccurrences(of: ".", with: "")
            let sql:String = "SELECT * FROM \(tableName) \(criteria)"
            let resultSet:FMResultSet = db!.executeQuery(sql, withArgumentsIn: nil)
            while (resultSet.next()) {
                let model:AlarmModel = AlarmModel()

                for i:Int in 0 ..< model.columeNames.count {
                    let columeName:NSString = (model.columeNames.object(at: i) as! NSString)
                    let columeType:NSString = (model.columeTypes.object(at: i) as! NSString)
                    if (columeType.isEqual(to: SQLTEXT)) {
                        model.setValue(resultSet.string(forColumn: "\(columeName)"), forKey: "\(columeName)")
                    } else {
                        model.setValue(NSNumber(value: resultSet.longLongInt(forColumn: "\(columeName)") as Int64), forKey: "\(columeName)")
                    }
                }
                alarm.add(model)
            }
        }
        return alarm;
    }

    /**
     Lookup table all field data

     :returns: Returns the query to the data
     */
    override class func getAll()->NSArray{
        let dbQueue:FMDatabaseQueue = AppDelegate.getAppDelegate().dbQueue
        let alarm:NSMutableArray = NSMutableArray()
        dbQueue.inDatabase { (db) -> Void in
            var tableName:NSString = NSStringFromClass(self.classForCoder()) as NSString
            tableName = tableName.replacingOccurrences(of: ".", with: "") as NSString
            let sql:String = "SELECT * FROM \(tableName)"
            let resultSet:FMResultSet = db!.executeQuery(sql, withArgumentsIn: nil)
            while (resultSet.next()) {
                let model:AlarmModel = AlarmModel()

                for i:Int in 0 ..< model.columeNames.count {
                    let columeName:NSString = model.columeNames.object(at: i) as! NSString
                    let columeType:NSString = model.columeTypes.object(at: i) as! NSString
                    if (columeType.isEqual(to: SQLTEXT)) {
                        model.setValue(resultSet.string(forColumn: "\(columeName)"), forKey: "\(columeName)")
                    } else {
                        model.setValue(NSNumber(value: resultSet.longLongInt(forColumn: "\(columeName)") as Int64), forKey: "\(columeName)")
                    }
                }
                alarm.add(model)
            }
            
        }
        return alarm;
    }

}
