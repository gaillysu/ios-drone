
//
//  UserDatabaseHelper.swift
//  Nevo
//
//  Created by leiyuncun on 15/11/18.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import FMDB

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
            _ = self.createTable()
        }
    }

    override init() {
        super.init()
//        let dic:NSDictionary = self.classForCoder.getAllProperties()
//        columeNames = NSMutableArray(array: dic.object(forKey: "name") as! NSArray)
//        columeTypes = NSMutableArray(array: dic.object(forKey: "type") as! NSArray)
    }

    /**
    * 创建表
    * 如果已经创建，返回YES
    */
    fileprivate class func createTable()->Bool {
        let db:FMDatabase = FMDatabase(path: AppDelegate.dbPath())
        if (!db.open()) {
            NSLog("数据库打开失败!");
            return false;
        }

        var tableName:NSString = NSStringFromClass(self.classForCoder()) as NSString;
        tableName = tableName.replacingOccurrences(of: ".", with: "") as NSString
        let columeAndType:NSString = self.getColumeAndTypeString() as NSString
        let sql:NSString = NSString(format: "CREATE TABLE IF NOT EXISTS %@(%@);", tableName,columeAndType)

            let args:CVaListPointer = getVaList([1,2,3,4]);
            let isSuccess = db.executeUpdate("\(sql)", withVAList: args)
            if (!isSuccess) {
                return false;
            }
            let columns:NSMutableArray = NSMutableArray()
            let resultSet:FMResultSet = db.getTableSchema("\(tableName)")
            while (resultSet.next()) {
                //[resultSet next]
                let column:NSString = resultSet.string(forColumn: "name") as NSString
                columns.add(column)
            }
            let dict:NSDictionary = self.getAllProperties()
            let properties:NSArray = dict.object(forKey: "name") as! NSArray
            let filterPredicate:NSPredicate = NSPredicate(format: "NOT (SELF IN %@)",columns)
            //过滤数组
            let resultArray:NSArray = properties.filtered(using: filterPredicate) as NSArray

            for column in resultArray {
                let index:Int = properties.index(of: column)
                let proType:NSString = (dict.object(forKey: "type") as! NSArray).object(at: index) as! NSString
                let fieldSql:NSString = NSString(format: "\(column) \(proType)" as NSString)
                let sql:NSString = NSString(format: "ALTER TABLE %@ ADD COLUMN %@ ",NSStringFromClass(self),fieldSql)
                if (!db.executeUpdate("\(sql)", withArgumentsIn: nil)) {
                    return false
                }
            }
            db.close()
            return true
    }

    fileprivate class func getColumeAndTypeString()->String {
        let pars:NSMutableString = NSMutableString()
        let dict:NSDictionary = self.getAllProperties()
        let proNames:NSMutableArray = NSMutableArray(array: (dict.object(forKey: "name") as! [NSString]))
        let proTypes:NSMutableArray = NSMutableArray(array: (dict.object(forKey: "type") as! [NSString]))
        for i in 0..<proNames.count {
            pars.appendFormat("%@ %@", proNames.object(at: i) as! NSString,proTypes.object(at: i) as! NSString)
            if(i+1 != proNames.count){
                pars.append(",")
            }
        }
        return pars as String;
    }

    /** 获取所有属性，包含主键pk */
    class func getAllProperties()->NSDictionary {
        let dict:NSDictionary = self.getPropertys()
        let proNames:NSMutableArray = NSMutableArray()
        let proTypes:NSMutableArray = NSMutableArray()
        proNames.add(primaryId)
        proTypes.add(NSString(format: "%@ %@", SQLINTEGER,PrimaryKey))
        proNames.addObjects(from: (dict.object(forKey: "name") as! [NSString]))
        proTypes.addObjects(from: dict.object(forKey: "type") as! [NSString])
        return NSDictionary(dictionary: ["name":proNames,"type":proTypes])
    }

    /**
    *  获取该类的所有属性
    */
    fileprivate class func getPropertys()->NSDictionary {
        let proNames:NSMutableArray = NSMutableArray()
        let proTypes:NSMutableArray = NSMutableArray()
        let theTransients:NSArray = self.transients()
        var outCount:UInt32 = 0
        let properties:UnsafeMutablePointer = class_copyPropertyList(self,&outCount)
        for count in 0..<outCount {
            let property:objc_property_t = properties[Int(count)]!;
            //获取属性名
            let propertyName:NSString = NSString(cString: property_getName(property), encoding: String.Encoding.utf8.rawValue)!
            if (theTransients.contains(propertyName)) {
                continue;
            }
            proNames.add(propertyName)
            //获取属性类型等参数
            let propertyType:NSString = NSString(cString: property_getAttributes(property), encoding: String.Encoding.utf8.rawValue)!
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
                proTypes.add(SQLTEXT)
            } else if (propertyType.hasPrefix("Ti")||propertyType.hasPrefix("TI")||propertyType.hasPrefix("Ts")||propertyType.hasPrefix("TS")||propertyType.hasPrefix("TB")) {
                proTypes.add(SQLINTEGER)
            } else {
                proTypes.add(SQLREAL)
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
            var tableName:NSString = NSStringFromClass(self) as NSString;
            tableName = tableName.replacingOccurrences(of: ".", with: "") as NSString
            res = (db?.tableExists("\(tableName)"))!
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
    func add(_ result:@escaping ((_ id:Int?,_ completion:Bool?) -> Void)){
        var tableName:NSString = NSStringFromClass(self.classForCoder) as NSString;
        tableName = tableName.replacingOccurrences(of: ".", with: "") as NSString
        let keyString:NSMutableString = NSMutableString()
        let valueString:NSMutableString = NSMutableString()
        let insertValues:NSMutableArray = NSMutableArray()
        for i:Int in 0 ..< self.columeNames.count {
            let proname:NSString = self.columeNames.object(at: i) as! NSString
            if (proname.isEqual(to: primaryId) && self.id == 0) {
                continue;
            }
            keyString.appendFormat("%@,", proname)
            valueString.append("?,")

            var value = self.value(forKey: "\(proname)")
            if (value == nil) {
                value = "";
            }
            insertValues.add(value!)
        }

        keyString.deleteCharacters(in: NSMakeRange(keyString.length - 1, 1))
        valueString.deleteCharacters(in: NSMakeRange(valueString.length - 1, 1))

        let dbQueue:FMDatabaseQueue = AppDelegate.getAppDelegate().dbQueue
        var res:Bool = false
        dbQueue.inDatabase { (db) -> Void in
            let sql:NSString = NSString(format: "INSERT INTO %@(%@) VALUES (%@);", tableName, keyString, valueString)
            res = (db?.executeUpdate("\(sql)", withArgumentsIn: insertValues as [AnyObject]))!
            self.id = res ? NSNumber(value: (db?.lastInsertRowId())! as Int64).intValue : 0
            NSLog("\(res ? "Insert success" : "Insert failed"),SQL:\(sql)");
            result(self.id,res)
        }
    }

    /**
     Based updating a table has a primary key field

     :returns: update the result ，YES or NO
     */
    func update()->Bool{
        let dbQueue:FMDatabaseQueue = AppDelegate.getAppDelegate().dbQueue
        var res:Bool = false;
        dbQueue.inDatabase { (db) -> Void in
            var tableName:NSString = NSStringFromClass(self.classForCoder) as NSString;
            tableName = tableName.replacingOccurrences(of: ".", with: "") as NSString
            let primaryValue = self.value(forKey: primaryId)
            if ((primaryValue == nil) || (primaryValue as! Int) <= 0) {
                return;
            }
            let keyString:NSMutableString = NSMutableString()
            let updateValues:NSMutableArray = NSMutableArray()
            for i in 0..<self.columeNames.count {
                let proname:NSString = self.columeNames.object(at: i) as! NSString
                if (proname.isEqual(to: primaryId)) {
                    continue;
                }
                keyString.appendFormat(" %@=?,", proname)
                var value = self.value(forKey: proname as String)
                if (value == nil) {
                    value = "";
                }
                updateValues.add(value!)
            }
            keyString.deleteCharacters(in: NSMakeRange(keyString.length - 1, 1))
            let sql:NSString = NSString(format: "UPDATE %@ SET %@ WHERE %@ = ?;", tableName, keyString, primaryId)
            updateValues.add(primaryValue!)
            res = (db?.executeUpdate(sql as String, withArgumentsIn: updateValues as [AnyObject]))!
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
            var tableName:NSString = NSStringFromClass(self.classForCoder) as NSString;
            tableName = tableName.replacingOccurrences(of: ".", with: "") as NSString
            let primaryValue = self.value(forKey: primaryId)
            if (primaryValue == nil || (primaryValue as! Int) <= 0) {
                return ;
            }
            let sql:String = "DELETE FROM \(tableName) WHERE \(primaryId) = ?"
            res = (db?.executeUpdate(sql, withArgumentsIn: [primaryValue!]))!
            NSLog("\(res ? "Delete the success" : "Delete failed")");
        }
        return res;
    }

    /** clear Table */
    class func removeAll()->Bool{
        let dbQueue:FMDatabaseQueue = AppDelegate.getAppDelegate().dbQueue
        var res:Bool = false
        dbQueue.inDatabase { (db) -> Void in
            var tableName:NSString = NSStringFromClass(self.classForCoder()) as NSString
            tableName = tableName.replacingOccurrences(of: ".", with: "") as NSString
            let sql:String = "DELETE FROM \(tableName)"
            res = (db?.executeUpdate(sql,withArgumentsIn: nil))!
        }
        return res;
    }

    /**
     Static lookup function according to conditions

     @param criteria To find the condition
     @param returns Returns the find results
     */
     class func getCriteria(_ criteria:String)->NSArray {
        let dbQueue:FMDatabaseQueue = AppDelegate.getAppDelegate().dbQueue
        let users:NSMutableArray = NSMutableArray()
        dbQueue.inDatabase { (db) -> Void in
            var tableName:String =  NSStringFromClass(self.classForCoder())
            tableName = tableName.replacingOccurrences(of: ".", with: "")
            let sql:String = "SELECT * FROM \(tableName) \(criteria)"
            let resultSet:FMResultSet = db!.executeQuery(sql, withArgumentsIn: nil)
            while (resultSet.next()) {
                let model:UserDatabaseHelper = UserDatabaseHelper()

                for i in 0..<model.columeNames.count {
                    let columeName:NSString = (model.columeNames.object(at: i) as! NSString)
                    let columeType:NSString = (model.columeTypes.object(at: i) as! NSString)
                    if (columeType.isEqual(to: SQLTEXT)) {
                        model.setValue(resultSet.string(forColumn: "\(columeName)"), forKey: "\(columeName)")
                    } else {
                        model.setValue(NSNumber(value: resultSet.longLongInt(forColumn: "\(columeName)") as Int64), forKey: "\(columeName)")
                    }
                }
                users.add(model)
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
            var tableName:NSString = NSStringFromClass(self.classForCoder()) as NSString
            tableName = tableName.replacingOccurrences(of: ".", with: "") as NSString
            let sql:String = "SELECT * FROM \(tableName)"
            let resultSet:FMResultSet = db!.executeQuery(sql, withArgumentsIn: nil)
            while (resultSet.next()) {
                //let classType: AnyObject.Type = self.classForCoder()
                //let nsobjectype : NevoDBModel.Type = classType as! NevoDBModel.Type
                let model:UserDatabaseHelper = UserDatabaseHelper()

                for i in 0..<model.columeNames.count {
                    let columeName:NSString = model.columeNames.object(at: i) as! NSString
                    let columeType:NSString = model.columeTypes.object(at: i) as! NSString
                    if (columeType.isEqual(to: SQLTEXT)) {
                        model.setValue(resultSet.string(forColumn: "\(columeName)"), forKey: "\(columeName)")
                    } else {
                        model.setValue(NSNumber(value: Int64(columeName.integerValue) as Int64), forKey: "\(columeName)")
                    }
                }
                users.add(model)
            }

        }
        return users;
    }

    /**
     * update Table
     * succes return true, failure return false
     */
    class func updateTable()->Bool {
        let db:FMDatabase = FMDatabase(path: AppDelegate.dbPath())
        if(db.open()) {
            NSLog("数据库打开失败!数据库路径:\(AppDelegate.dbPath())");
            return false;
        }

        var tableName:NSString = NSStringFromClass(self.classForCoder()) as NSString
        tableName = tableName.replacingOccurrences(of: ".", with: "") as NSString
        let columns:NSMutableArray = NSMutableArray()
        let resultSet:FMResultSet = db.getTableSchema(tableName as String)
        while (resultSet.next()) {
            let column:NSString = resultSet.string(forColumn: "name") as NSString
            columns.add(column)
        }

        let dict:NSDictionary = self.getAllProperties();
        let properties:NSArray = dict.object(forKey: "name") as! NSArray
        let filterPredicate:NSPredicate = NSPredicate(format: "NOT (SELF IN %@)",columns)
        //过滤数组
        let resultArray:NSArray = properties.filtered(using: filterPredicate) as NSArray

        for column in resultArray {
            let index:Int = properties.index(of: column)
            let proType:String = (dict.object(forKey: "type") as! NSArray).object(at: index) as! String
            let fieldSql:String = "\(column) \(proType)"
            //[NSString stringWithFormat:@"%@ %@",column,proType];
            let sql:String = String(format: "ALTER TABLE %@ ADD COLUMN %@ ",tableName,fieldSql)
            let args:CVaListPointer? = nil
            if (db.executeUpdate(sql, withVAList: args!)) {
                return false;
            }
        }
        db.close();
        return true
    }
}
