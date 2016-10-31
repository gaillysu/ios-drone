//
//  Request.swift
//  Drone
//
//  Created by Karl-John Chow on 28/10/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

protocol NetworkRequest {
    var url:String? { get }
    var method:HTTPMethod? { get }
    var encoding:ParameterEncoding? { get }
    var headers:HTTPHeaders? { get }
    var parameters:Parameters { get }
    var response: (_ success:Bool, _ response:JSON?, _ error:Error?) -> Void { get set }
}
