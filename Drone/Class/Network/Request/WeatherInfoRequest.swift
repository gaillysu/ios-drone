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
    init(selectText:String, responseBlock: @escaping (_ bool:Bool, _ json:JSON?, _ error:Error?) -> Void) {
        super.init(response: responseBlock)
        self.url = "data/2.5/weather"
        self.parameters = ["q":selectText,"appid":"b2e00dd9220bc986ed54db4ed4bf66a1"]
    }
}
