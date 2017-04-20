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
        
        copyBundleRealmToDocumentFolder()
        
        updateRelam()
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
            
        }else{
            DispatchQueue.global(qos: .background).async {
                //WorldClockDatabaseHelper().setup()
            }
        }
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
    
    func getCitySelected()->[City] {
        let realm = try! Realm()
        var worldClockArray:[City] = []
        var selectedCityOrder = DTUserDefaults.selectedCityOrder
        if selectedCityOrder.isEmpty {
            realm.objects(City.self).filter("selected = true").sorted(by: {
                ($0.timezone?.getOffsetFromUTC())! < ($1.timezone?.getOffsetFromUTC())!
            }).forEach({
                worldClockArray.append($0)
            })
        } else {
            let selectedCtities = Array(realm.objects(City.self).filter("selected = true"))
            if selectedCtities.count != selectedCityOrder.count{
                if selectedCtities.count > selectedCityOrder.count {
                    selectedCtities.forEach({ city in
                        if !selectedCityOrder.contains(where: { $0 == city.id }){
                            selectedCityOrder.append(city.id)
                            DTUserDefaults.selectedCityOrder = selectedCityOrder
                        }
                    })
                }else{
                    selectedCtities.forEach({ city in
                        if !selectedCityOrder.contains(where: { $0 == city.id }){
                            if let index = selectedCityOrder.index(where: { $0 == city.id }){
                                selectedCityOrder.remove(at: index)
                            }
                        }
                    })
                }
            }
            selectedCityOrder.forEach({ cityId in
                if let city = realm.object(ofType: City.self, forPrimaryKey: cityId){
                    if city.selected{
                        worldClockArray.append(city)
                    }
                }
            })
        }
        return worldClockArray
    }
}
