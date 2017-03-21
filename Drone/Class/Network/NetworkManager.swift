
//
//  NetworkManager.swift
//  Drone
//
//  Created by Karl-John Chow on 28/10/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import UIKit
import Alamofire
import XCGLogger
import SwiftyJSON

class NetworkManager: NSObject {
    
    private static let baseUrl = "https://drone.dayton.med-corp.net"
    
    class func execute(request :NetworkRequest){
        if let urlPart = request.url, let encoding = request.encoding, let method = request.method {
            let url = NetworkManager.baseUrl + urlPart
            Alamofire.request(url, method: method, parameters: request.parameters, encoding: encoding, headers: request.headers).responseJSON(completionHandler: { response in
                 let result = isValidResponse(response: response)
                request.response(result.success, result.json, result.error)
            })
            
        }else{
            XCGLogger.error("URL/METHOD/ENCODING IS WRONGLY/NOT SPECIFIED IN THE REQUEST. DID NOT EXECUTE NETWORK REQUEST!")
        }
    }
    
    class func isValidResponse(response:DataResponse<Any>) -> (success:Bool, json:JSON?, error:Error?) {
        switch response.result {
        case .success(let data):
            let json = JSON(data)
            if(json["status"] > 0){
                return (true, json, nil)
            }else{
                print("Request was successful but, status was smaller then 0.")
                return (false,nil, nil)
            }
            
        case .failure(let error):
            print("Request was successful but, response wasn't good.")
            return (false,nil, error)
        }
    }
}
