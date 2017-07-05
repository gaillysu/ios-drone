//
//  WeChatBaseGetRequest.swift
//  pocketmate
//
//  Created by Cloud on 2017/2/21.
//  Copyright © 2017年 MED Enterprises Limited. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class WeatherBaseGetRequest: NetworkRequest {
    var response: (Bool, JSON?, Error?) -> Void
    var url:String? = ""
    var method:HTTPMethod?
    var encoding:ParameterEncoding?
    var headers:HTTPHeaders? = [:]
    var parameters:Parameters
    
    init(response: @escaping (_ bool:Bool, _ json:JSON?, _ error:Error?) -> Void){
        self.parameters = ["":""]
        self.method = .get
        self.encoding = URLEncoding.default
        self.response = response
    }
}
