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

class City: MEDBaseModel {
    
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
    
    static var homeTime:City?{
        if let homeTime = City.byFilter("id == \(DTUserDefaults.homeTimeId)").first{
            return homeTime
        }
        return nil
    }
    
    static var worldClockCities:[City]{
        let cities = City.findAll()
        var worldClocks = cities
            .filter({ $0.selected })
            .sorted(by: { ($0.timezone?.getOffsetFromUTC())! < ($1.timezone?.getOffsetFromUTC())!})
        var order = DTUserDefaults.selectedCityOrder
        if !order.isEmpty{
            if worldClocks.count > order.count{
                worldClocks.forEach({ worldClock in
                    if !order.contains(worldClock.id){
                        order.append(worldClock.id)
                        DTUserDefaults.selectedCityOrder = order
                    }
                })
            }else{
                order.forEach({ id in
                    if !worldClocks.contains(where: {  $0.id == id
                    }){
                        if let index = order.index(where: {$0 == id}){
                            order.remove(at: index)
                        }
                    }
                })
            }
            worldClocks = order.map({ id -> City in
                guard let index = worldClocks.index(where: { $0.id == id}) else{
                    fatalError("Wow index is wrong")
                }
                return worldClocks[index]
            })
        }
        return worldClocks
    } 
    
}
