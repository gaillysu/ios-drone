
//
//  NetworkManager.swift
//  Drone
//
//  Created by Karl-John Chow on 28/10/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import UIKit
import Alamofire

import SwiftyJSON

class NetworkManager: NSObject {
    static let manager:NetworkManager = NetworkManager()
    fileprivate static let baseUrl = "https://drone.dayton.med-corp.net"
    
    fileprivate lazy var networkState: NetworkReachabilityManager = {
        let network:NetworkReachabilityManager = NetworkReachabilityManager(host: baseUrl)
        return network
    }()
    
    fileprivate override init() {
        super.init()
        networkState.startListening()
        
        networkState.listener = { status in
            debugPrint("Network Status Changed: \(status)")
        }
    }
    
    func getNetworkState() -> Bool {
        return networkState.isReachable
    }

}

extension NetworkManager {
    class func execute(request :NetworkRequest){
        if let urlPart = request.url, let encoding = request.encoding, let method = request.method {
            let url = NetworkManager.baseUrl + urlPart
            Alamofire.request(url, method: method, parameters: request.parameters, encoding: encoding, headers: request.headers).responseJSON(completionHandler: { response in
                let result = isValidResponse(response: response)
                request.response(result.success, result.json, result.error)
            })
            
        }else{
            debugPrint("URL/METHOD/ENCODING IS WRONGLY/NOT SPECIFIED IN THE REQUEST. DID NOT EXECUTE NETWORK REQUEST!")
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
