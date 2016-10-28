//
//  GetStepsRequest.swift
//  Drone
//
//  Created by Karl-John Chow on 28/10/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import Alamofire

class GetStepsRequest: BaseGetRequest {


    init(uid:Int, startDate:Int, endDate:Int, responseBlock: @escaping (DataResponse<Any>) -> Void) {
        super.init(response: responseBlock)
        self.url = "/steps/user/\(uid)"
        self.parameters["start_date"] = startDate
        self.parameters["end_date"] = endDate
    }
}
