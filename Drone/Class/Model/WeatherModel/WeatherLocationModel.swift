//
//  WeatherLocationModel.swift
//  Drone
//
//  Created by Cloud on 2017/4/13.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit

struct WeatherLocationModel {
    static let MAXENTRY:Int = 6;
    let id:UInt8
    let length: UInt8
    let title: String
    let latitude: Double
    let longitude: Double
    
    init(id:UInt8,city:City?) {
        self.id = id
        if let object = city {
            title = object.name
            length = UInt8(title.length)
            latitude = object.lat
            longitude = object.lng
        }else{
            title = ""
            length = UInt8(title.length)
            latitude = 0
            longitude = 0
        }
    }
}

