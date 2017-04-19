//
//  DataBaseManager.swift
//  Drone
//
//  Created by Cloud on 2017/4/14.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit
import RealmSwift

class DataBaseManager: NSObject {
    static let manager:DataBaseManager = DataBaseManager()
    
    fileprivate override init() {
        super.init()
        updateRelam()
        
        DispatchQueue.global(qos: .background).async {
            WorldClockDatabaseHelper().setup()
        }
    }
    
    fileprivate func updateRelam() {
        var config = Realm.Configuration(
            schemaVersion: 4,
            migrationBlock: { migration, oldSchemaVersion in
                
        })
        config.deleteRealmIfMigrationNeeded = true
        Realm.Configuration.defaultConfiguration = config
    }

}
