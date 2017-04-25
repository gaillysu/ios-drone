//
//  UserCreateRequest.swift
//  Drone
//
//  Created by Karl-John Chow on 1/11/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import UIKit
import SwiftyJSON

class UserCreateRequest: BasePostRequest {
    
    init(firstName:String, lastName:String, email:String, password:String, birthday:String, length:String, weight:String, sex:Int, responseBlock: @escaping (_ success:Bool, _ id:JSON?, _ error:Error?) -> Void) {
        super.init(response: responseBlock)
        self.url = "/user/create"
        self.parameters["params"] = ["user":["first_name":firstName,"last_name":lastName,"email":email,"password":password,"birthday": birthday,"length":length, "weight":weight, "sex":sex]]
    }
}
