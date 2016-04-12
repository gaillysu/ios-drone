//
//  DeviceModel.swift
//  Drone
//
//  Created by leiyuncun on 16/4/12.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit
import FMDB

class DeviceModel: UserDatabaseHelper {
    var device_name:String = ""
    var identifiers:String = ""
    var connectionTimer:NSTimeInterval = NSDate().timeIntervalSince1970

    override init() {
        super.init()

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
                let model:DeviceModel = DeviceModel()

                for i:Int in 0 ..< model.columeNames.count {
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
                let model:DeviceModel = DeviceModel()

                for i:Int in 0 ..< model.columeNames.count {
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

    override class func isExistInTable()->Bool {
        var res:Bool = false
        let dbQueue:FMDatabaseQueue = AppDelegate.getAppDelegate().dbQueue
        dbQueue.inDatabase { (db) -> Void in
            var tableName:NSString = NSStringFromClass(self.classForCoder())
            tableName = tableName.stringByReplacingOccurrencesOfString(".", withString: "")
            res = db.tableExists("\(tableName)")
        }
        return res
    }

    /**
     * update Table
     * succes return true, failure return false
     */
    override class func updateTable()->Bool {
        let db:FMDatabase = FMDatabase(path: AppDelegate.dbPath())
        if(!db.open()) {
            NSLog("数据库打开失败!数据库路径:\(AppDelegate.dbPath())");
            return false;
        }

        var tableName:NSString = NSStringFromClass(self.classForCoder())
        tableName = tableName.stringByReplacingOccurrencesOfString(".", withString: "")
        let columns:NSMutableArray = NSMutableArray()
        let resultSet:FMResultSet = db.getTableSchema(tableName as String)
        while (resultSet.next()) {
            let column:NSString = resultSet.stringForColumn("name")
            columns.addObject(column)
        }

        let dict:NSDictionary = self.getAllProperties();
        let properties:NSArray = dict.objectForKey("name") as! NSArray
        let filterPredicate:NSPredicate = NSPredicate(format: "NOT (SELF IN %@)",columns)
        //过滤数组
        let resultArray:NSArray = properties.filteredArrayUsingPredicate(filterPredicate)

        for column in resultArray {
            let index:Int = properties.indexOfObject(column)
            let proType:String = (dict.objectForKey("type") as! NSArray).objectAtIndex(index) as! String
            let fieldSql:String = "\(column) \(proType)"
            let sql:String = String(format: "ALTER TABLE %@ ADD COLUMN %@ ",tableName,fieldSql)
            let args:CVaListPointer = getVaList([0,1,2,3,4,5,6,7]);
            if (db.executeUpdate(sql, withVAList: args)) {
                return false;
            }
        }
        db.close();
        return true
    }
}
