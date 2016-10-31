//
//  ForgetPasswordRequest.swift
//  Drone
//
//  Created by Karl-John Chow on 31/10/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class ForgetPasswordRequest: BasePostRequest {
    
    init(email:String, password:String, token:String, id:Int,  responseBlock: @escaping (_ bool:Bool, _ json:JSON?, _ error:Error?) -> Void) {
        super.init(response: responseBlock)
        self.url = "/user/request_password_token"
        self.parameters["params"] = ["user":["email":email, "id":id, "password":password, "password_token":token]]
    }
}
