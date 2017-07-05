//
//  SetWeatherLocationsRequest.swift
//  Drone
//
//  Created by Cloud on 2017/4/13.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit

class SetWeatherLocationsRequest: DroneRequest {
    fileprivate var weatherEntries:[WeatherLocationModel] = []
    
    class func HEADER() -> UInt8 {
        return 0x24
    }
    
    init(entries:[WeatherLocationModel]) {
        super.init()
        weatherEntries = entries
    }
    
    override func getRawDataEx() -> [Data] {
        let splitEntries =  weatherEntries.prefix(weatherEntries.count>WeatherLocationModel.MAXENTRY ? WeatherLocationModel.MAXENTRY:weatherEntries.count)
        var values:[UInt8] = [SetWeatherLocationsRequest.HEADER(),UInt8(splitEntries.count&0xFF)]
        
        for weather in splitEntries {
            let weatherModel:WeatherLocationModel = weather
            let id:UInt8 = weatherModel.id
            let length:UInt8 = weatherModel.length
            let titleHex:[UInt8] = Constants.NSData2Bytes(weatherModel.title.data(using: String.Encoding.utf8)!)
            values.append(id)
            values.append(length)
            values = values+titleHex
        }
        return Constants.splitPacketConverter(data: values)
    }
}
