//
//  GoogleMapsDirectionsRequest.swift
//  Drone
//
//  Created by Cloud on 2017/6/15.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class GoogleMapsDirectionsRequest: GoogleMapsBaseRequest {
    
    /// – 作为您路线计算起点的addres、latitude/longitude text value or place id
    ///
    /// - Parameters:
    ///   - startLocation: Route calculation start location addres、latitude/longitude text value or place id
    ///   - endLocation: Route calculation end location addres、latitude/longitude text value or place id
    ///   - mode: （default: driving）– 指定在计算路线时使用的交通模式: "driving,walking,bicycling,transit"(lowercase)
    ///   - responseBlock: response block
    init(startLocation:String, endLocation:String, mode:String?, responseBlock: @escaping (_ bool:Bool, _ json:JSON?, _ error:Error?) -> Void) {
        super.init(response: responseBlock)
        self.url = "/maps/api/directions/json"
        self.parameters["origin"] = startLocation
        self.parameters["destination"] = endLocation
        self.parameters["mode"] = mode
    }
}
