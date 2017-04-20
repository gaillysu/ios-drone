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
    
    fileprivate let schemaVersion:UInt64 = 5
    
    fileprivate override init() {
        super.init()
        updateRelam()
        
        copyBundleRealmToDocumentFolder()
    }
    
    fileprivate func updateRelam() {
        var config = Realm.Configuration(
            schemaVersion: schemaVersion,
            migrationBlock: { migration, oldSchemaVersion in
                
        })
        config.deleteRealmIfMigrationNeeded = true
        Realm.Configuration.defaultConfiguration = config
    }

    func copyBundleRealmToDocumentFolder() {
        if !AppTheme.realmISFirstCopy(findKey: .get) {
            DispatchQueue.global(qos: .background).async {
                WorldClockDatabaseHelper().setup()
            }
            return
        }
        
        // copy over old data files for migration
        let defaultURL = Realm.Configuration.defaultConfiguration.fileURL!
        
        if let v0URL = URL.bundleURL(name: "default") {
            do {
                if FileManager.default.fileExists(atPath: defaultURL.path) {
                    try FileManager.default.removeItem(at: defaultURL)
                }
                try FileManager.default.copyItem(at: v0URL, to: defaultURL)
                _ = AppTheme.realmISFirstCopy(findKey: .set)
            } catch let error {
                print("file copy or remove error:\(error)");
            }
        }
        
        let migrationBlock: MigrationBlock = { migration, oldSchemaVersion in
            if oldSchemaVersion < self.schemaVersion {
            }
            print("Migration complete.")
        }
        
        Realm.Configuration.defaultConfiguration = Realm.Configuration(schemaVersion: schemaVersion, migrationBlock: migrationBlock)
        
        print("Migrated objects in the default Realm: \(try! Realm().objects(City.self))")
    }
    
    func addOrUpdateDevice(fromAddress:String) {
        let userDevice = UserDevice.getFilter(String(format: "identifiers = '%@'", fromAddress))
        if userDevice.count == 0 {
            let device:UserDevice = UserDevice()
            device.id = Int(Date().timeIntervalSince1970)
            device.device_name = "Drone"
            device.identifiers = fromAddress
            device.connectionTimer = Date().timeIntervalSince1970
            _ = device.add()
        }else{
            let device:UserDevice = userDevice.first as! UserDevice
            let realm = try! Realm()
            try! realm.write {
                device.connectionTimer = Date().timeIntervalSince1970
            }
        }
    }
    
    func getAllDevice() -> [Any] {
        let userDevice = UserDevice.getAll()
        return userDevice
    }
}
