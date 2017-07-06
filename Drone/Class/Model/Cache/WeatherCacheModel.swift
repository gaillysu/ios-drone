//
//  WeatherCacheModel.swift
//  Drone
//
//  Created by Cloud on 2017/4/21.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import Foundation
import SwiftyJSON

struct WeatherCacheModel {
    let latitude:Double
    let longitude:Double
    let timezone:String
    let offset:Int
    let syncDate:Date
    let list:[EveryHourWeatherModel]
    
    init(json:JSON) {
        latitude = json["latitude"].doubleValue
        longitude = json["longitude"].doubleValue
        timezone = json["timezone"].stringValue
        offset = json["offset"].intValue
        syncDate = Date()
        
        let hourlyData = json["hourly"]["data"].arrayValue
        var everyHourData:[EveryHourWeatherModel] = []
        
        hourlyData.forEach { (dataJson) in
            let hourWeatherModel:EveryHourWeatherModel = EveryHourWeatherModel(json: dataJson)
            everyHourData.append(hourWeatherModel)
        }
        
        list = everyHourData
    }
}

