//
//  WeatherCacheModel.swift
//  Drone
//
//  Created by Cloud on 2017/4/21.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit

class WeatherCacheModel: NSObject,NSCoding {
    
    var cod:String = ""
    var message:String = ""
    var cnt:String = ""
    var list:[EveryHourWeatherModel] = []
    var city:WeatherCityModel = WeatherCityModel()
    var syncDate:String = ""
    
    override init() {
        super.init()
    }
    
    func encode(with aCoder:NSCoder) {
        NSLog("aCoder:\(cod),message:\(message),cnt:\(cnt),list:\(list),city:\(city),syncDate:\(syncDate)")
        aCoder.encode(cod, forKey:"cod")
        aCoder.encode(message, forKey:"message")
        aCoder.encode(cnt, forKey:"cnt")
        aCoder.encode(list, forKey:"list")
        aCoder.encode(city, forKey:"city")
        aCoder.encode(syncDate, forKey:"syncDate")
        NSLog("aCoder:\(aCoder)")
    }
    
    required init(coder aDecoder:NSCoder) {
        super.init()
        if let cCod = aDecoder.decodeObject(forKey:"cod") {
            cod = cCod as! String
        }
        
        if let cMessage = aDecoder.decodeObject(forKey:"message") {
            message = cMessage as! String
        }
        
        if let cCnt = aDecoder.decodeObject(forKey:"cnt") {
            cnt = cCnt as! String
        }
        
        if let cList = aDecoder.decodeObject(forKey:"list") {
            list = cList as! [EveryHourWeatherModel]
        }
        
        if let cCity = aDecoder.decodeObject(forKey:"city") {
            city = cCity as! WeatherCityModel
        }
        
        if let cSyncDate = aDecoder.decodeObject(forKey:"syncDate") {
            syncDate = cSyncDate as! String
        }
    }
}
