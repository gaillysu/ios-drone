//
//  ContactsFilter.swift
//  Drone
//
//  Created by Karl Chow on 5/11/16.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

class ContactsFilter: NSObject {
    
    var id:Int = 0
    var name:String = ""
    
    fileprivate var contactsFilterModel:ContactsFilterModel = ContactsFilterModel()
    
    init(keyDict:NSDictionary) {
        super.init()
        for(key, value) in keyDict {
            self.setValue(value, forKey: key as! String)
        }
    }
    
    func add(_ result:@escaping ((_ id:Int?,_ completion:Bool?) -> Void)){
        contactsFilterModel.name = name
        contactsFilterModel.add { (id, completion) -> Void in
            result(id, completion)
        }
    }
    
    func update()->Bool{
        contactsFilterModel.name = name
        return contactsFilterModel.update()
    }
    
    func remove()->Bool{
        contactsFilterModel.id = id
        return contactsFilterModel.remove()
    }
    
    class func removeAll()->Bool{
        
        return ContactsFilterModel.removeAll()
    }
    
    class func getCriteria(_ criteria:String)->NSArray{
        let modelArray:NSArray = ContactsFilterModel.getCriteria(criteria)
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let contactsFilterModel:ContactsFilterModel = model as! ContactsFilterModel
            let contactsFilter:ContactsFilter = ContactsFilter(keyDict: ["id":contactsFilterModel.id,"name":contactsFilterModel.name])
            allArray.add(contactsFilter)
        }
        return allArray
    }
    
    class func getAll()->NSArray{
        let modelArray:NSArray = ContactsFilterModel.getAll()
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let contactsFilterModel:ContactsFilterModel = model as! ContactsFilterModel
            let contactsFilter:ContactsFilter = ContactsFilter(keyDict: ["id":contactsFilterModel.id,"name":contactsFilterModel.name])
            allArray.add(contactsFilter)
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
