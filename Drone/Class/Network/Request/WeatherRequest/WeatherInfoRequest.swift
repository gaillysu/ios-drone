//
//  WeatherInfoRequest.swift
//  Drone
//
//  Created by Cloud on 2017/4/18.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class WeatherInfoRequest: WeatherBaseGetRequest {
    init(latitude lat: Double, longitude lon: Double, language:WeatherLanguage?, units:WeatherUnits?, responseBlock: @escaping (_ bool:Bool, _ json:JSON?, _ error:Error?) -> Void) {
        super.init(response: responseBlock)
        let apiKey = Bundle.darkSkyKey
        self.url = (apiKey == nil ? "":apiKey!)+"/\(lat),\(lon)"
        if let lang = language {
            self.parameters["lang"] = lang
        }
        
        if let unit = units {
            self.parameters["units"] = unit
        }
    }
}
