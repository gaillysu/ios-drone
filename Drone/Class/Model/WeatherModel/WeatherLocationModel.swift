//
//  WeatherLocationModel.swift
//  Drone
//
//  Created by Cloud on 2017/4/13.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit

class WeatherLocationModel: NSObject {
    static let MAXENTRY:Int = 6;
    fileprivate var identification :UInt8 = 0
    fileprivate var length:UInt8 = 0;
    fileprivate var title:String = "";
    
    init(id:UInt8,titleString:String) {
        super.init()
        identification = id
        title = titleString
        length = UInt8(titleString.length)
    
    }
    
    func getWeatherInfo() ->(id:UInt8,length:UInt8,title:String)  {
        return (identification,length,title)
    }
}
