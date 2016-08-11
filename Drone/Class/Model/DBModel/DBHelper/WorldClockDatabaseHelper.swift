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
    
    private let WORLDCLOCK_KEY:String = "defaults_worldclock_key";
    
    private let WORLDCLOCK_NEWEST_VERSION:Int = 4;
    private let realm:Realm
    
    let worldclockVersion:Int
    
    override init() {
        realm = try! Realm()
        let defaults = NSUserDefaults.standardUserDefaults()
        worldclockVersion = defaults.integerForKey(WORLDCLOCK_KEY);
    }
    
    func setup(){
        
        let oldCities = Array(realm.objects(City))
        let oldTimezones = Array(realm.objects(Timezone))
        
        var addedCities = [City]()
        var addedTimezones = [Timezone]()
        let forceSync:Bool = oldCities.count == 0 || oldTimezones.count == 0
        print(oldTimezones.count)
        print(oldCities.count)
        if(forceSync || WORLDCLOCK_NEWEST_VERSION > worldclockVersion){
            print("We need to update.")
            if let citiesPath = NSBundle.mainBundle().pathForResource("cities", ofType: "json"),
                let timezonesPath = NSBundle.mainBundle().pathForResource("timezones", ofType: "json"){
                do{
                    let citiesData = try NSData(contentsOfURL: NSURL(fileURLWithPath: citiesPath), options: NSDataReadingOptions.DataReadingMappedIfSafe)
                    let timezonesData = try NSData(contentsOfURL: NSURL(fileURLWithPath: timezonesPath), options: NSDataReadingOptions.DataReadingMappedIfSafe)
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
                        let results:Results<Timezone> = realm.objects(Timezone)
                        for i in 0...(citiesJSON.count-1){
                            if let city:City = City.getCityObject(citiesJSON[i]){
                                for timezone:Timezone in results{
                                    if city.timezoneId == timezone.id{
                                        city.timezone = timezone
                                        break
                                    }
                                }
                                try! realm.write({ 
                                    realm.add(city)
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
                            let defaults = NSUserDefaults.standardUserDefaults()
                            defaults.setInteger(WORLDCLOCK_NEWEST_VERSION, forKey: WORLDCLOCK_KEY);
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