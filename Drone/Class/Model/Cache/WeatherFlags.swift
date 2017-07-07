//
//  WeatherFlags.swift
//  Drone
//
//  Created by Cloud on 2017/7/5.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import Foundation
import SwiftyJSON

struct WeatherFlags {
    let sources:[String]

    let units:WeatherUnits
    
    let darkSkyUnavailable: Bool?

    let darkSkyStations: [String]?

    let dataPointStations: [String]?

    let isdStations: [String]?

    let lampStations: [String]?

    let metarStations: [String]?

    let metnoLicense: Bool?
    
//    init(json:JSON) {
//        sources = json["sources"].arrayValue
//    }
}
