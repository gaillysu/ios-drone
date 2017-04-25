//
//  WorldClockDatabaseHelper.swift
//  Drone
//
//  Created by Karl-John on 11/8/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON
class WorldClockDatabaseHelper: NSObject {
    
    fileprivate let WORLDCLOCK_KEY:String = "defaults_worldclock_key";
    
    fileprivate let WORLDCLOCK_NEWEST_VERSION:Int = 5;
    
    override init() {
        
    }
    
    func setup(){
        let realm:Realm = try! Realm()
        let oldCities = realm.objects(City.self)
        let oldTimezones = realm.objects(Timezone.self)

        let forceSync:Bool = oldCities.count == 0 || oldTimezones.count == 0
        print(oldTimezones.count)
        print(oldCities.count)
        if(forceSync || WORLDCLOCK_NEWEST_VERSION > DTUserDefaults.worldClockVersion){
            print("We need to update.")
            if let citiesPath = Bundle.main.path(forResource: "cities", ofType: "json"),
                let timezonesPath = Bundle.main.path(forResource: "timezones", ofType: "json"){
                do{
                    let citiesData = try Data(contentsOf: URL(fileURLWithPath: citiesPath), options: Data.ReadingOptions.mappedIfSafe)
                    let timezonesData = try Data(contentsOf: URL(fileURLWithPath: timezonesPath), options: Data.ReadingOptions.mappedIfSafe)
                    let citiesJSON = JSON(data: citiesData)
                    let timezonesJSON = JSON(data: timezonesData)
                    if citiesJSON != JSON.null && timezonesJSON != JSON.null {
                        if oldCities.count != 0 && oldTimezones.count != 0 {
                            try! realm.write({
                                print(oldCities.count)
                                print(oldTimezones.count)
                                realm.delete(oldCities)
                                realm.delete(oldTimezones)
                            })
                        }
                        
                        for i in 0..<timezonesJSON.count{
                            if let timezone:Timezone = Timezone.getTimeZoneObject(timezonesJSON[i]){
                                try! realm.write({
                                    realm.add(timezone)
                                })
                            }else{
                                print("Couldn't parse JSON");
                                break
                            }
                        }
                        
                        
                        for i in 0..<citiesJSON.count{
                            if let city:City = City.getCityObject(citiesJSON[i]){
                                let results:Results<Timezone> = realm.objects(Timezone.self).filter(String(format: "id == %d", city.timezoneId))
                                city.timezone = results.first
                                try! realm.write({
                                    realm.add(city, update: true)
                                })
                                
                            }else{
                                print("Couldn't parse JSON");
                                break
                            }
                        }
                        
                        DTUserDefaults.worldClockVersion = WORLDCLOCK_NEWEST_VERSION
                    } else {
                        print("One of the two JSON files are invalid.")
                    }
                }catch let error as NSError{
                    print(error.localizedDescription)
                }
            }else{
                print("One of the paths, or both, are incorrect.")
            }

        }else{
            print("We are ok! We got the newest version.")
        }
        print("Done setting up")
    }
}
