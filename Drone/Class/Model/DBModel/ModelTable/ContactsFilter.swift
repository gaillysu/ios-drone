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
    var phone:Bool = true
    var sms:Bool = true
    var mail:Bool = true
    
    private var contactsFilterModel:ContactsFilterModel = ContactsFilterModel()
    
    init(keyDict:NSDictionary) {
        super.init()
        keyDict.enumerateKeysAndObjectsUsingBlock { (key, value, stop) in
            self.setValue(value, forKey: key as! String)
        }
    }
    
    func add(result:((id:Int?,completion:Bool?) -> Void)){
        
        contactsFilterModel.add { (id, completion) -> Void in
            result(id: id, completion: completion)
        }
    }
    
    func update()->Bool{
        
        return contactsFilterModel.update()
    }
    
    func remove()->Bool{
        return contactsFilterModel.remove()
    }
    
    class func removeAll()->Bool{
        return ContactsFilterModel.removeAll()
    }
    
    class func getCriteria(criteria:String)->NSArray{
        let modelArray:NSArray = ContactsFilterModel.getCriteria(criteria)
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let contactsFilterModel:ContactsFilterModel = model as! ContactsFilterModel
            let contactsFilter:ContactsFilter = ContactsFilter(keyDict: ["id":contactsFilterModel.id,"name":contactsFilterModel.name,"phone":contactsFilterModel.phone,"sms":contactsFilterModel.sms,"mail":contactsFilterModel.mail])
            allArray.addObject(contactsFilter)
        }
        return allArray
    }
    
    class func getAll()->NSArray{
        let modelArray:NSArray = ContactsFilterModel.getAll()
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let contactsFilterModel:ContactsFilterModel = model as! ContactsFilterModel
            let contactsFilter:ContactsFilter = ContactsFilter(keyDict: ["id":contactsFilterModel.id,"name":contactsFilterModel.name,"phone":contactsFilterModel.phone,"sms":contactsFilterModel.sms,"mail":contactsFilterModel.mail])
            allArray.addObject(contactsFilter)
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