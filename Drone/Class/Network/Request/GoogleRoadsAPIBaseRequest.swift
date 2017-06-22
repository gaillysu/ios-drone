//
//  GoogleRoadsAPIBaseRequest.swift
//  Drone
//
//  Created by Cloud on 2017/6/19.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class GoogleRoadsAPIBaseRequest: NetworkRequest {
    var response: (Bool, JSON?, Error?) -> Void
    var url:String? = ""
    var method:HTTPMethod?
    var encoding:ParameterEncoding?
    var headers:HTTPHeaders? = [:]
    var parameters:Parameters
    
    init(response: @escaping (_ bool:Bool, _ json:JSON?, _ error:Error?) -> Void){
        self.parameters = ["key":Bundle.googleMapKey ?? "","interpolate":true]
        self.method = .get
        self.encoding = URLEncoding.default
        self.response = response
    }
}
