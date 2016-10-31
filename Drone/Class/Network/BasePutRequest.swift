//
//  BasePutRequest.swift
//  Drone
//
//  Created by Karl-John Chow on 28/10/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class BasePutRequest: BaseNetworkRequest {
    override init(response: @escaping (_ bool:Bool, _ json:JSON?, _ error:Error?) -> Void) {
        super.init(response: response)
        self.method = .put
        self.encoding = JSONEncoding.default
    }
}
