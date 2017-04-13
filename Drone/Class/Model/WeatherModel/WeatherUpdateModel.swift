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
    fileprivate var weatherStatus:UInt8 = 0;
    
    init(id:Int,temp:UInt8,status:UInt8) {
        super.init()
        identification = UInt8(id)
        temperature = temp
        weatherStatus = status
    }
    
    func getWeatherUpdateInfo() -> (id:UInt8,temperature:UInt8,status:UInt8) {
        return (identification,temperature,weatherStatus)
    }
}
