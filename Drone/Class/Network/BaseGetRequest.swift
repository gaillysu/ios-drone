//
//  BaseGetRequest.swift
//  Drone
//
//  Created by Karl-John Chow on 28/10/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import Alamofire

class BaseGetRequest: BaseNetworkRequest{
    override init(response: @escaping (DataResponse<Any>) -> Void) {
        super.init(response: response)
        self.method = .get
        self.encoding = URLEncoding.default
    }
}
