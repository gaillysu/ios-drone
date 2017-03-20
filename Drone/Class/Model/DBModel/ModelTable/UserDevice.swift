//
//  UserDevice.swift
//  Drone
//
//  Created by leiyuncun on 16/4/12.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import Foundation
import RealmSwift

class UserDevice: MEDBaseModel {
    dynamic var id:Int = 0
    dynamic var device_name:String = ""
    dynamic var identifiers:String = ""
    dynamic var connectionTimer:TimeInterval = Date().timeIntervalSince1970
    
    override static func primaryKey() -> String? {
        return "identifiers"
    }
}
