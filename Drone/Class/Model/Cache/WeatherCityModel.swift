//
//  WeatherCityModel.swift
//  Drone
//
//  Created by Cloud on 2017/4/21.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit

class WeatherCityModel: NSObject,NSCoding {
    var id:Int = 0
    var name:String = ""
    var lat:Float = 0
    var lon:Float = 0
    var country:String = ""
    
    override init() {
        super.init()
    }
    
    func encode(with aCoder:NSCoder) {
        aCoder.encode(id, forKey:"id")
        aCoder.encode(name, forKey:"name")
        aCoder.encode(lat, forKey:"lat")
        aCoder.encode(lon, forKey:"lon")
        aCoder.encode(country, forKey:"country")
    }
    
    required init(coder aDecoder:NSCoder) {
        super.init()
        if let cId = aDecoder.decodeObject(forKey:"id") {
            id = cId as! Int
        }
        
        if let cName = aDecoder.decodeObject(forKey:"name") {
            name = cName as! String
        }
        
        if let cLat = aDecoder.decodeObject(forKey:"lat") {
            lat = cLat as! Float
        }
        
        if let cLon = aDecoder.decodeObject(forKey:"lon") {
            lon = cLon as! Float
        }
        
        if let cCountry = aDecoder.decodeObject(forKey:"country") {
            country = cCountry as! String
        }
        
    }
}
