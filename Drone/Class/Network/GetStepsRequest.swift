//
//  GetStepsRequest.swift
//  Drone
//
//  Created by Karl-John Chow on 28/10/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class GetStepsRequest: BaseGetRequest {

    init(uid:Int, startDate:Int, endDate:Int, responseBlock: @escaping (_ bool:Bool, _ json:JSON?, _ error:Error?) -> Void) {
        super.init(response: responseBlock)
        self.url = "/steps/user/\(uid)"
        self.parameters["start_date"] = startDate
        self.parameters["end_date"] = endDate
    }
}
