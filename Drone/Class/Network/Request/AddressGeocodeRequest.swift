//
//  AddressGeocodeRequest.swift
//  Drone
//
//  Created by Cloud on 2017/6/14.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AddressGeocodeRequest: GoogleMapsBaseRequest {
    init(selectText:String, responseBlock: @escaping (_ bool:Bool, _ json:JSON?, _ error:Error?) -> Void) {
        super.init(response: responseBlock)
        self.url = "/maps/api/geocode/json"
        self.parameters["address"] = selectText
    }
}
