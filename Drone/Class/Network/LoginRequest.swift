//
//  LoginRequest.swift
//  Drone
//
//  Created by Karl-John Chow on 31/10/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LoginRequest: BasePostRequest {
    
    init(email:String, password:String, responseBlock: @escaping (_ bool:Bool, _ json:JSON?, _ error:Error?) -> Void) {
        super.init(response: responseBlock)
        self.url = "/user/login"
        self.parameters["params"] = ["user":["email":email,"password":password]]
    }
}
