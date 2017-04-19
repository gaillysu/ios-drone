//
//  WeatherUpdateModel.swift
//  Drone
//
//  Created by Cloud on 2017/4/13.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit

enum WeatherStatusIcon:UInt8 {
    case invalidData        = 0x00
    case partlyCloudyNight  = 0x01
    case partlyCloudyDay    = 0x02
    case tornado            = 0x03
    case typhoon            = 0x04
    case hurricane          = 0x05
    case cloudy             = 0x06
    case fog                = 0x07
    case windy              = 0x08
    case snow               = 0x09
    case rainLight          = 0x0A
    case rainHeavy          = 0x0B
    case stormy             = 0x0C
    case clearDay           = 0x0D
    case clearNight         = 0x0E
}

class WeatherUpdateModel: NSObject {
    static let MAXENTRY:Int = 6;
    
    fileprivate var identification :UInt8 = 0
    fileprivate var temperature:UInt8 = 0;
    fileprivate var weatherIcon:WeatherStatusIcon = WeatherStatusIcon.invalidData;
    
    init(id:UInt8,temp:UInt8,statusIcon:WeatherStatusIcon) {
        super.init()
        identification = UInt8(id)
        temperature = temp
        weatherIcon = statusIcon
    }
    
    func getWeatherUpdateInfo() -> (id:UInt8,temperature:UInt8,icon:WeatherStatusIcon) {
        return (identification,temperature,weatherIcon)
    }
}
