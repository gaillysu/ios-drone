//
//  UpdateWeatherInfoRequest.swift
//  Drone
//
//  Created by Cloud on 2017/4/13.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit

class UpdateWeatherInfoRequest: DroneRequest {
    fileprivate var weatherEntries:[WeatherUpdateModel] = []
    
    class func HEADER() -> UInt8 {
        return 0x26
    }
    
    init(entries:[WeatherUpdateModel]) {
        super.init()
        weatherEntries = entries
    }
    
    override func getRawDataEx() -> [Data] {
        let splitEntries =  weatherEntries.prefix(weatherEntries.count>WeatherUpdateModel.MAXENTRY ? WeatherUpdateModel.MAXENTRY:weatherEntries.count)
        var values:[UInt8] = [UpdateWeatherInfoRequest.HEADER(),UInt8(splitEntries.count&0xFF)]
        
        for weather in splitEntries {
            
            let weatherModel:WeatherUpdateModel = weather
            let id:UInt8 = weatherModel.getWeatherUpdateInfo().id
            let temperature:Int = weatherModel.getWeatherUpdateInfo().temperature
            let statusIcon:UInt8 = weatherModel.getWeatherUpdateInfo().icon.rawValue
            
            values.append(id)
            values.append(UInt8(temperature&0xFF))
            values.append(UInt8(temperature>>8&0xFF))
            values.append(statusIcon)
        }
        return Constants.splitPacketConverter(data: values)
    }
}
