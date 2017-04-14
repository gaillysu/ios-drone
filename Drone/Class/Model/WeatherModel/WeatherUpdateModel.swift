//
//  WeatherUpdateModel.swift
//  Drone
//
//  Created by Cloud on 2017/4/13.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit

class WeatherUpdateModel: NSObject {
    static let MAXENTRY:Int = 6;
    
    fileprivate var identification :UInt8 = 0
    fileprivate var temperature:UInt8 = 0;
    fileprivate var weatherIcon:WeatherStatusIcon = WeatherStatusIcon.invalidData.rawValue;
    
    init(id:Int,temp:UInt8,statusIcon:WeatherStatusIcon) {
        super.init()
        identification = UInt8(id)
        temperature = temp
        weatherIcon = statusIcon
    }
    
    func getWeatherUpdateInfo() -> (id:UInt8,temperature:UInt8,statusIcon:WeatherStatusIcon) {
        return (identification,temperature,weatherIcon)
    }
}
