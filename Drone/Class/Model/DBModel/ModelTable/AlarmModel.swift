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
    var timer:NSTimeInterval = 0.0
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
    override class func getCriteria(criteria:String)->NSArray {
        let dbQueue:FMDatabaseQueue = AppDelegate.getAppDelegate().dbQueue
        let users:NSMutableArray = NSMutableArray()
        dbQueue.inDatabase { (db) -> Void in
            var tableName:String =  NSStringFromClass(self.classForCoder())
            tableName = tableName.stringByReplacingOccurrencesOfString(".", withString: "")
            let sql:String = "SELECT * FROM \(tableName) \(criteria)"
            let resultSet:FMResultSet = db.executeQuery(sql, withArgumentsInArray: nil)
            while (resultSet.next()) {
                let model:AlarmModel = AlarmModel()

                for (var i:Int = 0; i < model.columeNames.count; i++) {
                    let columeName:NSString = (model.columeNames.objectAtIndex(i) as! NSString)
                    let columeType:NSString = (model.columeTypes.objectAtIndex(i) as! NSString)
                    if (columeType.isEqualToString(SQLTEXT)) {
                        model.setValue(resultSet.stringForColumn("\(columeName)"), forKey: "\(columeName)")
                    } else {
                        model.setValue(NSNumber(longLong: resultSet.longLongIntForColumn("\(columeName)")), forKey: "\(columeName)")
                    }
                }
                users.addObject(model)
            }
        }
        return users;
    }

    /**
     Lookup table all field data

     :returns: Returns the query to the data
     */
    override class func getAll()->NSArray{
        let dbQueue:FMDatabaseQueue = AppDelegate.getAppDelegate().dbQueue
        let users:NSMutableArray = NSMutableArray()
        dbQueue.inDatabase { (db) -> Void in
            var tableName:NSString = NSStringFromClass(self.classForCoder())
            tableName = tableName.stringByReplacingOccurrencesOfString(".", withString: "")
            let sql:String = "SELECT * FROM \(tableName)"
            let resultSet:FMResultSet = db.executeQuery(sql, withArgumentsInArray: nil)
            while (resultSet.next()) {
                let model:AlarmModel = AlarmModel()

                for (var i:Int = 0; i < model.columeNames.count; i++) {
                    let columeName:NSString = model.columeNames.objectAtIndex(i) as! NSString
                    let columeType:NSString = model.columeTypes.objectAtIndex(i) as! NSString
                    if (columeType.isEqualToString(SQLTEXT)) {
                        model.setValue(resultSet.stringForColumn("\(columeName)"), forKey: "\(columeName)")
                    } else {
                        model.setValue(NSNumber(longLong: resultSet.longLongIntForColumn("\(columeName)")), forKey: "\(columeName)")
                    }
                }
                users.addObject(model)
            }
            
        }
        return users;
    }


}
