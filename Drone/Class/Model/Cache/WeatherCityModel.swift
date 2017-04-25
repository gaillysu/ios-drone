//
//  WeatherCityModel.swift
//  Drone
//
//  Created by Cloud on 2017/4/21.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit

class WeatherCityModel: NSObject,NSCoding {
    var id:String = ""
    var name:String = ""
    var lat:String = ""
    var lon:String = ""
    var country:String = ""
    
    override init() {
        super.init()
    }
    
    func encode(with aCoder:NSCoder) {
        NSLog("id:\(id),name:\(name),lat:\(lat),lon:\(lon),country:\(country)")
        aCoder.encode(id, forKey:"id")
        aCoder.encode(name, forKey:"name")
        aCoder.encode(lat, forKey:"lat")
        aCoder.encode(lon, forKey:"lon")
        aCoder.encode(country, forKey:"country")
    }
    
    required init(coder aDecoder:NSCoder) {
        super.init()
        if let cId = aDecoder.decodeObject(forKey:"id") {
            id = cId as! String
        }
        
        if let cName = aDecoder.decodeObject(forKey:"name") {
            name = cName as! String
        }
        
        if let cLat = aDecoder.decodeObject(forKey:"lat") {
            lat = cLat as! String
        }
        
        if let cLon = aDecoder.decodeObject(forKey:"lon") {
            lon = cLon as! String
        }
        
        if let cCountry = aDecoder.decodeObject(forKey:"country") {
            country = cCountry as! String
        }
        
    }
}
