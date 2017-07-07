//
//  EveryHourWeatherModel.swift
//  Drone
//
//  Created by Cloud on 2017/4/21.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import Foundation
import SwiftyJSON

struct EveryHourWeatherModel {
    let time:Double
    let summary:String
    let icon:WeatherIcon
    let precipIntensity:Float
    let precipProbability:Float
    let temperature:Float
    let apparentTemperature:Float
    let dewPoint:Float
    let humidity:Float
    let windSpeed:Float
    let windGust:Float
    let windBearing:Float
    let cloudCover:Float
    let pressure:Float
    let ozone:Float
    let uvIndex:Int
    
    init(json:JSON) {
        time = json["time"].doubleValue
        summary = json["summary"].stringValue
        icon = WeatherIcon(rawValue: json["icon"].stringValue)!
        precipIntensity = json["precipIntensity"].floatValue
        precipProbability = json["precipProbability"].floatValue
        temperature = json["temperature"].floatValue
        apparentTemperature = json["apparentTemperature"].floatValue
        dewPoint = json["dewPoint"].floatValue
        humidity = json["humidity"].floatValue
        windSpeed = json["windSpeed"].floatValue
        windGust = json["windGust"].floatValue
        windBearing = json["windBearing"].floatValue
        cloudCover = json["cloudCover"].floatValue
        pressure = json["pressure"].floatValue
        ozone = json["ozone"].floatValue
        uvIndex = json["uvIndex"].intValue
    }
}
