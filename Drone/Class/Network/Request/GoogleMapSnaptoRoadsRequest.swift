//
//  GoogleMapSnaptoRoadsRequest.swift
//  Drone
//
//  Created by Cloud on 2017/6/19.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class GoogleMapSnaptoRoadsRequest: GoogleRoadsAPIBaseRequest {
    init(path:String, responseBlock: @escaping (_ bool:Bool, _ json:JSON?, _ error:Error?) -> Void) {
        super.init(response: responseBlock)
        self.url = "/v1/snapToRoads"
        self.parameters["path"] = path
    }
}
