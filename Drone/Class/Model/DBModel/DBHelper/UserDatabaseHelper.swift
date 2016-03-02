
//
//  UserDatabaseHelper.swift
//  Nevo
//
//  Created by leiyuncun on 15/11/18.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

/** SQLite Five types of data */
let SQLTEXT = "TEXT"
let SQLINTEGER = "INTEGER"
let SQLREAL = "REAL"
let SQLBLOB = "BLOB"
let SQLNULL = "NULL"

let PrimaryKey = "primary key"
let primaryId = "id"

class UserDatabaseHelper:NSObject,BaseEntryDatabaseHelper {

    /** 主键 id */
    var id:Int = 0;
    /** 列名 */
    var columeNames:NSMutableArray = NSMutableArray();
    /** 列类型 */
    var columeTypes:NSMutableArray = NSMutableArray();

    override class func initialize() {
        if (self !== UserDatabaseHelper.self) {
            self.createTable()
        }
    }

    override init() {
        super.init()
        let dic:NSDictionary = self.classForCoder.getAllProperties()
        columeNames = NSMutableArray(array: dic.objectForKey("name") as! NSArray)
        columeTypes = NSMutableArray(array: dic.objectForKey("type") as! NSArray)
    }

    /**
    * 创建表
    * 如果已经创建，返回YES
    */
    private class func createTable()->Bool {
        let db:FMDatabase = FMDatabase(path: AppDelegate.dbPath())
        if (!db.open()) {
            NSLog("数据库打开失败!");
            return false;
        }

        var tableName:NSString = NSStringFromClass(self.classForCoder());
        tableName = tableName.stringByReplacingOccurrencesOfString(".", withString: "")
        let columeAndType:NSString = self.getColumeAndTypeString()
        let sql:NSString = NSString(format: "CREATE TABLE IF NOT EXISTS %@(%@);", tableName,columeAndType)

        do {
            let args:CVaListPointer = getVaList([1,2,3,4]);
            let isSuccess = db.executeUpdate("\(sql)", withVAList: args)
            if (!isSuccess) {
                return false;
            }
            let columns:NSMutableArray = NSMutableArray()
            let resultSet:FMResultSet = db.getTableSchema("\(tableName)")
            while (resultSet.next()) {
                //[resultSet next]
                let column:NSString = resultSet.stringForColumn("name")
                columns.addObject(column)
            }
            let dict:NSDictionary = self.getAllProperties()
            let properties:NSArray = dict.objectForKey("name") as! NSArray
            let filterPredicate:NSPredicate = NSPredicate(format: "NOT (SELF IN %@)",columns)
            //过滤数组
            let resultArray:NSArray = properties.filteredArrayUsingPredicate(filterPredicate)

            for column in resultArray {
                let index:Int = properties.indexOfObject(column)
                let proType:NSString = (dict.objectForKey("type") as! NSArray).objectAtIndex(index) as! NSString
                let fieldSql:NSString = NSString(format: "\(column) \(proType)")
                let sql:NSString = NSString(format: "ALTER TABLE %@ ADD COLUMN %@ ",NSStringFromClass(self),fieldSql)
                if (!db.executeUpdate("\(sql)", withArgumentsInArray: nil)) {
                    return false
                }
            }
            db.close()
            return true
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
    }

    private class func getColumeAndTypeString()->String {
        let pars:NSMutableString = NSMutableString()
        let dict:NSDictionary = self.getAllProperties()
        let proNames:NSMutableArray = NSMutableArray(array: (dict.objectForKey("name") as! [NSString]))
        let proTypes:NSMutableArray = NSMutableArray(array: (dict.objectForKey("type") as! [NSString]))
        for (var i:Int = 0; i < proNames.count; i++) {
            pars.appendFormat("%@ %@", proNames.objectAtIndex(i) as! NSString,proTypes.objectAtIndex(i) as! NSString)
            if(i+1 != proNames.count){
                pars.appendString(",")
            }
        }
        return pars as String;
    }

    /** 获取所有属性，包含主键pk */
    class func getAllProperties()->NSDictionary {
        let dict:NSDictionary = self.getPropertys()
        let proNames:NSMutableArray = NSMutableArray()
        let proTypes:NSMutableArray = NSMutableArray()
        proNames.addObject(primaryId)
        proTypes.addObject(NSString(format: "%@ %@", SQLINTEGER,PrimaryKey))
        proNames.addObjectsFromArray((dict.objectForKey("name") as! [NSString]))
        proTypes.addObjectsFromArray(dict.objectForKey("type") as! [NSString])
        return NSDictionary(dictionary: ["name":proNames,"type":proTypes])
    }

    /**
    *  获取该类的所有属性
    */
    private class func getPropertys()->NSDictionary {
        let proNames:NSMutableArray = NSMutableArray()
        let proTypes:NSMutableArray = NSMutableArray()
        let theTransients:NSArray = self.transients()
        var outCount:UInt32 = 0, i:UInt32 = 0;
        let properties:UnsafeMutablePointer = class_copyPropertyList(self,&outCount)
        for (i = 0; i < outCount; i++) {
            let property:objc_property_t = properties[Int(i)];
            //获取属性名
            let propertyName:NSString = NSString(CString: property_getName(property), encoding: NSUTF8StringEncoding)!
            if (theTransients.containsObject(propertyName)) {
                continue;
            }
            proNames.addObject(propertyName)
            //获取属性类型等参数
            let propertyType:NSString = NSString(CString: property_getAttributes(property), encoding: NSUTF8StringEncoding)!
            /*
            c char         C unsigned char
            i int          I unsigned int
            l long         L unsigned long
            s short        S unsigned short
            d double       D unsigned double
            f float        F unsigned float
            q long long    Q unsigned long long
            B BOOL
            @ 对象类型 //指针 对象类型 如NSString 是@“NSString”


            64位下long 和long long 都是Tq
            SQLite 默认支持五种数据类型TEXT、INTEGER、REAL、BLOB、NULL
            */
            if (propertyType.hasPrefix("T@")) {
                proTypes.addObject(SQLTEXT)
            } else if (propertyType.hasPrefix("Ti")||propertyType.hasPrefix("TI")||propertyType.hasPrefix("Ts")||propertyType.hasPrefix("TS")||propertyType.hasPrefix("TB")) {
                proTypes.addObject(SQLINTEGER)
            } else {
                proTypes.addObject(SQLREAL)
            }
        }
        free(properties)
        return NSDictionary(dictionary: ["name":proNames,"type":proTypes])
    }

    /** 数据库中是否存在表 */
    class func isExistInTable()->Bool {
        var res:Bool = false
        let dbQueue:FMDatabaseQueue = AppDelegate.getAppDelegate().dbQueue
        dbQueue.inDatabase { (db) -> Void in
            var tableName:NSString = NSStringFromClass(self);
            tableName = tableName.stringByReplacingOccurrencesOfString(".", withString: "")
            res = db.tableExists("\(tableName)")
        }
        return res;
    }

    /** 如果子类中有一些property不需要创建数据库字段，那么这个方法必须在子类中重写
    */
    class func transients()->NSArray {
        return NSArray()
    }

    //MARK: - BaseEntryDatabaseHelper protocol
    /**
     Insert a table fields

     :returns: Insert results，YES or NO
     */
    func add(result:((id:Int?,completion:Bool?) -> Void)){
        var tableName:NSString = NSStringFromClass(self.classForCoder);
        tableName = tableName.stringByReplacingOccurrencesOfString(".", withString: "")
        let keyString:NSMutableString = NSMutableString()
        let valueString:NSMutableString = NSMutableString()
        let insertValues:NSMutableArray = NSMutableArray()
        for (var i:Int = 0; i < self.columeNames.count; i++) {
            let proname:NSString = self.columeNames.objectAtIndex(i) as! NSString
            if (proname.isEqualToString(primaryId)) {
                continue;
            }
            keyString.appendFormat("%@,", proname)
            valueString.appendString("?,")

            var value = self.valueForKey("\(proname)")
            if (value == nil) {
                value = "";
            }
            insertValues.addObject(value!)
        }

        keyString.deleteCharactersInRange(NSMakeRange(keyString.length - 1, 1))
        valueString.deleteCharactersInRange(NSMakeRange(valueString.length - 1, 1))

        let dbQueue:FMDatabaseQueue = AppDelegate.getAppDelegate().dbQueue
        var res:Bool = false
        dbQueue.inDatabase { (db) -> Void in
            let sql:NSString = NSString(format: "INSERT INTO %@(%@) VALUES (%@);", tableName, keyString, valueString)
            res = db.executeUpdate("\(sql)", withArgumentsInArray: insertValues as [AnyObject])
            self.id = res ? NSNumber(longLong: db.lastInsertRowId()).integerValue : 0
            AppTheme.DLog("\(res ? "Insert success" : "Insert failed"),SQL:\(sql)");
            result(id: self.id,completion: res)
        }
    }

    /**
     Based updating a table has a primary key field

     :returns: update the result ，YES or NO
     */
    func update()->Bool{
        let dbQueue:FMDatabaseQueue = AppDelegate.getAppDelegate().dbQueue
        var res:Bool = false;
        dbQueue.inDatabase { (let db) -> Void in
            var tableName:NSString = NSStringFromClass(self.classForCoder);
            tableName = tableName.stringByReplacingOccurrencesOfString(".", withString: "")
            let primaryValue = self.valueForKey(primaryId)
            if ((primaryValue == nil) || (primaryValue as! Int) <= 0) {
                return;
            }
            let keyString:NSMutableString = NSMutableString()
            let updateValues:NSMutableArray = NSMutableArray()
            for (var i:Int = 0; i < self.columeNames.count; i++) {
                let proname:NSString = self.columeNames.objectAtIndex(i) as! NSString
                if (proname.isEqualToString(primaryId)) {
                    continue;
                }
                keyString.appendFormat(" %@=?,", proname)
                var value = self.valueForKey(proname as String)
                if (value == nil) {
                    value = "";
                }
                updateValues.addObject(value!)
            }
            keyString.deleteCharactersInRange(NSMakeRange(keyString.length - 1, 1))
            let sql:NSString = NSString(format: "UPDATE %@ SET %@ WHERE %@ = ?;", tableName, keyString, primaryId)
            updateValues.addObject(primaryValue!)
            res = db.executeUpdate(sql as String, withArgumentsInArray: updateValues as [AnyObject])
            NSLog("\(res ? "Update Success" : "Update failed")");
        }
        return res
    }

    /**
     Delete all of the fields but reserved table

     @param returns Delete the result
     */
    func remove()->Bool{
        let dbQueue:FMDatabaseQueue = AppDelegate.getAppDelegate().dbQueue
        var res:Bool = false
        dbQueue.inDatabase { (db) -> Void in
            var tableName:NSString = NSStringFromClass(self.classForCoder);
            tableName = tableName.stringByReplacingOccurrencesOfString(".", withString: "")
            let primaryValue = self.valueForKey(primaryId)
            if (primaryValue == nil || (primaryValue as! Int) <= 0) {
                return ;
            }
            let sql:String = "DELETE FROM \(tableName) WHERE \(primaryId) = ?"
            res = db.executeUpdate(sql, withArgumentsInArray: [primaryValue!])
            NSLog("\(res ? "Delete the success" : "Delete failed")");
        }
        return res;
    }

    /** clear Table */
    class func removeAll()->Bool{
        let dbQueue:FMDatabaseQueue = AppDelegate.getAppDelegate().dbQueue
        var res:Bool = false
        dbQueue.inDatabase { (db) -> Void in
            var tableName:NSString = NSStringFromClass(self.classForCoder())
            tableName = tableName.stringByReplacingOccurrencesOfString(".", withString: "")
            let sql:String = "DELETE FROM \(tableName)"
            res = db.executeUpdate(sql,withArgumentsInArray: nil)
        }
        return res;
    }

    /**
     Static lookup function according to conditions

     @param criteria To find the condition
     @param returns Returns the find results
     */
     class func getCriteria(criteria:String)->NSArray {
        let dbQueue:FMDatabaseQueue = AppDelegate.getAppDelegate().dbQueue
        let users:NSMutableArray = NSMutableArray()
        dbQueue.inDatabase { (db) -> Void in
            var tableName:String =  NSStringFromClass(self.classForCoder())
            tableName = tableName.stringByReplacingOccurrencesOfString(".", withString: "")
            let sql:String = "SELECT * FROM \(tableName) \(criteria)"
            let resultSet:FMResultSet = db.executeQuery(sql, withArgumentsInArray: nil)
            while (resultSet.next()) {
                let model:UserDatabaseHelper = UserDatabaseHelper()

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
    class func getAll()->NSArray{
        let dbQueue:FMDatabaseQueue = AppDelegate.getAppDelegate().dbQueue
        let users:NSMutableArray = NSMutableArray()
        dbQueue.inDatabase { (db) -> Void in
            var tableName:NSString = NSStringFromClass(self.classForCoder())
            tableName = tableName.stringByReplacingOccurrencesOfString(".", withString: "")
            let sql:String = "SELECT * FROM \(tableName)"
            let resultSet:FMResultSet = db.executeQuery(sql, withArgumentsInArray: nil)
            while (resultSet.next()) {
                //let classType: AnyObject.Type = self.classForCoder()
                //let nsobjectype : NevoDBModel.Type = classType as! NevoDBModel.Type
                let model:UserDatabaseHelper = UserDatabaseHelper()

                for (var i:Int = 0; i < model.columeNames.count; i++) {
                    let columeName:NSString = model.columeNames.objectAtIndex(i) as! NSString
                    let columeType:NSString = model.columeTypes.objectAtIndex(i) as! NSString
                    if (columeType.isEqualToString(SQLTEXT)) {
                        model.setValue(resultSet.stringForColumn("\(columeName)"), forKey: "\(columeName)")
                    } else {
                        model.setValue(NSNumber(longLong: Int64(columeName.integerValue)), forKey: "\(columeName)")
                    }
                }
                users.addObject(model)
            }

        }
        return users;
    }
}
