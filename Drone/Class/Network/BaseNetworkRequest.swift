 //
//  BaseNetworkRequest.swift
//  Drone
//
//  Created by Karl-John Chow on 28/10/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import Alamofire
 import SwiftyJSON
 
 class BaseNetworkRequest: NetworkRequest {
    
    var response: (_ bool:Bool, _ json:JSON?, _ error:Error?) -> Void
    var parameters: Parameters
    var url: String? = ""
    var encoding: ParameterEncoding?
    var method: HTTPMethod?
    var headers: HTTPHeaders? = [:]
    
    init(response: @escaping (_ bool:Bool, _ json:JSON?, _ error:Error?) -> Void){
        if let authorizationHeader = Alamofire.Request.authorizationHeader(user: "apps", password: "med_app_development") {
            headers?[authorizationHeader.key] = authorizationHeader.value
        }
        self.parameters = ["token":"ZQpFYPBMqFbUQq8E99FztS2x6yQ2v1Ei"]
        self.response = response
    }
}
