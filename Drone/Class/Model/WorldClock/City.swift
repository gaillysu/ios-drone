//
//  City.swift
//  Drone
//
//  Created by Karl-John on 11/8/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class City: Object {
    
    dynamic var id = 0
    
    dynamic var name = ""
    
    dynamic var country = ""
    
    dynamic var lat:Double = 0.0
    
    dynamic var lng:Double = 0.0
    
    dynamic var timezoneId = 0
    
    dynamic var selected = false
    
    dynamic var timezone: Timezone?
    
    class func getCityObject(_ json:JSON) -> City?{
        if let id = json["id"].int,
        let name = json["name"].string,
        let country = json["country"].string,
        let lat = json["lat"].double,
        let lng = json["lng"].double,
        let timezoneId = json["timezone_id"].int {
            let city:City = City()
            city.id = id
            city.name = name
            city.country = country
            city.lat = lat
            city.lng = lng
            city.timezoneId = timezoneId
            return city
        } else {
            print("The provided JSON is not according the right keys.")
        }
        return nil;
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
