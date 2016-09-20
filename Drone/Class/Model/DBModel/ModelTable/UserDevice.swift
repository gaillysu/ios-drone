//
//  UserDevice.swift
//  Drone
//
//  Created by leiyuncun on 16/4/12.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit

class UserDevice: NSObject,BaseEntryDatabaseHelper {
    internal func add(_ result: @escaping ((Int?, Bool?) -> Void)) {
        deviceModel.device_name = device_name
        deviceModel.identifiers = identifiers
        deviceModel.connectionTimer = connectionTimer
        
        deviceModel.add { (id, completion) -> Void in
            result(id, completion)
        }
    }

    var id:Int = 0
    var device_name:String = ""
    var identifiers:String = ""
    var connectionTimer:TimeInterval = Date().timeIntervalSince1970

    fileprivate var deviceModel:DeviceModel = DeviceModel()

    init(keyDict:NSDictionary) {
        super.init()
        for (key, value) in keyDict{
            self.setValue(value, forKey: key as! String)
        }
    }
 

    func update()->Bool{
        deviceModel.id = id
        deviceModel.device_name = device_name
        deviceModel.identifiers = identifiers
        deviceModel.connectionTimer = connectionTimer
        return deviceModel.update()
    }

    func remove()->Bool{
        deviceModel.id = id
        return deviceModel.remove()
    }

    class func removeAll()->Bool{
        return DeviceModel.removeAll()
    }

    class func getCriteria(_ criteria:String)->NSArray{
        let modelArray:NSArray = DeviceModel.getCriteria(criteria)
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let deviceModel:DeviceModel = model as! DeviceModel
            let device:UserDevice = UserDevice(keyDict: ["id":deviceModel.id, "device_name":deviceModel.device_name, "identifiers":deviceModel.identifiers, "connectionTimer":deviceModel.connectionTimer])
            allArray.add(device)
        }
        return allArray
    }

    class func getAll()->NSArray{
        let modelArray:NSArray = DeviceModel.getAll()
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let deviceModel:DeviceModel = model as! DeviceModel
            let device:UserDevice = UserDevice(keyDict: ["id":deviceModel.id, "device_name":deviceModel.device_name, "identifiers":deviceModel.identifiers, "connectionTimer":deviceModel.connectionTimer])
            allArray.add(device)
        }
        return allArray
    }

    class func isExistInTable()->Bool {
        return DeviceModel.isExistInTable()
    }
}
