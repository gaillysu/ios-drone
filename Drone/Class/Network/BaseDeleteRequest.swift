//
//  BaseDeleteRequest.swift
//  Drone
//
//  Created by Karl-John Chow on 28/10/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class BaseDeleteRequest: BaseNetworkRequest {
    override init(response: @escaping (_ bool:Bool, _ json:JSON?, _ error:Error?) -> Void) {
        super.init(response: response)
        self.method = .delete
        self.encoding = JSONEncoding.default
        self.response = response
    }
}
