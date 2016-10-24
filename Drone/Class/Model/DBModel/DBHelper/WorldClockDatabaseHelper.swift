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
    
    fileprivate let WORLDCLOCK_NEWEST_VERSION:Int = 4;
    fileprivate let realm:Realm
    
    let worldclockVersion:Int
    
    override init() {
        realm = try! Realm()
        let defaults = UserDefaults.standard
        worldclockVersion = defaults.integer(forKey: WORLDCLOCK_KEY);
    }
    
    func setup(){
        
        let oldCities = Array(realm.objects(City.self))
        let oldTimezones = Array(realm.objects(Timezone.self))
        
        var addedCities = [City]()
        var addedTimezones = [Timezone]()
        let forceSync:Bool = oldCities.count == 0 || oldTimezones.count == 0
        print(oldTimezones.count)
        print(oldCities.count)
        if(forceSync || WORLDCLOCK_NEWEST_VERSION > worldclockVersion){
            print("We need to update.")
            if let citiesPath = Bundle.main.path(forResource: "cities", ofType: "json"),
                let timezonesPath = Bundle.main.path(forResource: "timezones", ofType: "json"){
                do{
                    let citiesData = try Data(contentsOf: URL(fileURLWithPath: citiesPath), options: NSData.ReadingOptions.mappedIfSafe)
                    let timezonesData = try Data(contentsOf: URL(fileURLWithPath: timezonesPath), options: NSData.ReadingOptions.mappedIfSafe)
                    let citiesJSON = JSON(data: citiesData)
                    let timezonesJSON = JSON(data: timezonesData)
                    if citiesJSON != JSON.null && timezonesJSON != JSON.null {
                        for i in 0...(timezonesJSON.count-1){
                            if let timezone:Timezone = Timezone.getTimeZoneObject(timezonesJSON[i]){
                                try! realm.write({
                                    realm.add(timezone)
                                    addedTimezones.append(timezone)
                                })
                            }else{
                                print("Couldn't parse JSON");
                                break
                            }
                        }
                        let results:Results<Timezone> = realm.objects(Timezone.self)
                        for i in 0...(citiesJSON.count-1){
                            if let city:City = City.getCityObject(citiesJSON[i]){
                                for timezone:Timezone in results{
                                    if city.timezoneId == timezone.id{
                                        city.timezone = timezone
                                        break
                                    }
                                }
                                try! realm.write({
                                    //realm.add(city)
                                    realm.add(city, update: true)
                                    addedCities.append(city)
                                })
                                
                            }else{
                                print("Couldn't parse JSON");
                                break
                            }
                        }
                        if addedCities.count == citiesJSON.count && addedTimezones.count == timezonesJSON.count {
                            try! realm.write({
                                print(oldCities.count)
                                print(oldTimezones.count)
                                realm.delete(oldCities)
                                realm.delete(oldTimezones)
                            })
                            let defaults = UserDefaults.standard
                            defaults.set(WORLDCLOCK_NEWEST_VERSION, forKey: WORLDCLOCK_KEY);
                        }else if addedCities.count > 0 || addedTimezones.count > 0 {
                            try! realm.write({
                                realm.delete(addedCities)
                                realm.delete(addedTimezones)
                            })
                        }
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
    }
}
