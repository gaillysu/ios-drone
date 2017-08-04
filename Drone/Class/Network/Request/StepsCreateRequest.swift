//
//  StepsCreateRequest.swift
//  Drone
//
//  Created by Karl-John Chow on 1/11/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import SwiftyJSON

class StepsCreateRequest: BasePostRequest {
    
    init(uid:Int, value:String, date:String, activeTime:Int, responseBlock: @escaping (_ bool:Bool, _ json:JSON?, _ error:Error?) -> Void) {
        super.init(response: responseBlock)
        self.url = "/steps/create"
        self.parameters["params"] = ["steps": ["uid": uid,"steps": value,"date": date,"active_time":activeTime]]
    }
}
