//
//  Notification.swift
//  Drone
//
//  Created by Karl-John Chow on 28/4/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import Foundation
import RealmSwift

class Notification: Object{
    
    dynamic var bundleIdentifier = ""
    dynamic var appName = ""
    dynamic var state = false
    
    override static func primaryKey() -> String? {
        return "bundleIdentifier"
    }
}
