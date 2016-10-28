//
//  BasePostRequest.swift
//  Drone
//
//  Created by Karl-John Chow on 28/10/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import Alamofire

class BasePostRequest: BaseNetworkRequest{
    override init(response: @escaping (DataResponse<Any>) -> Void) {
        super.init(response: response)
        self.method = .post
        self.encoding = JSONEncoding.default
    }
}
