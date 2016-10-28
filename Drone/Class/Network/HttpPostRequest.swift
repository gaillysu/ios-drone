//
//  HttpPostRequest.swift
//  Nevo
//
//  Created by Karl-John on 31/12/2015.
//  Copyright © 2015 Nevo. All rights reserved.
//

import UIKit
import Alamofire
import XCGLogger

class HttpPostRequest: NSObject {
        
    
    class func postRequest(_ url: String, data:Dictionary<String,Any>, completion:@escaping (_ result:NSDictionary) -> Void){
    
        var finalData: Dictionary<String,Any> = ["token":"ZQpFYPBMqFbUQq8E99FztS2x6yQ2v1Ei" as Any]
        finalData["params"] = data;
        let param:Parameters = finalData
        XCGLogger.debug("\(finalData)")
        
        var headers: HTTPHeaders = [:]
        
        if let authorizationHeader = Alamofire.Request.authorizationHeader(user: "apps", password: "med_app_development") {
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        Alamofire.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response  in
                if response.result.isSuccess {
                    XCGLogger.debug("getJSON: \(response.result.value)")
                    completion(
                        response.result.value as! NSDictionary)
                }else if (response.result.isFailure){
                    if (response.result.value == nil) {
                        completion(NSDictionary(dictionary: ["error" : "request error"]))
                    }else{
                        completion(response.result.value as! NSDictionary)
                    }
                }
        }
    }
    
    
    class  func putRequest(_ url: String, data:[String:AnyObject], completion:@escaping (_ result:NSDictionary) -> Void){
        var finalData: Dictionary<String,AnyObject> = ["token":"ZQpFYPBMqFbUQq8E99FztS2x6yQ2v1Ei" as AnyObject]
        finalData["params"] = data as AnyObject?;
        XCGLogger.debug("\(finalData)")
        
        var headers: HTTPHeaders = [:]
        
        if let authorizationHeader = Alamofire.Request.authorizationHeader(user: "apps", password: "med_app_development") {
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        
        Alamofire.request(url, method: .put, parameters: finalData, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response  in
                if response.result.isSuccess {
                    XCGLogger.debug("getJSON: \(response.result.value)")
                    completion(response.result.value as! NSDictionary)
                }else if (response.result.isFailure){
                    print(response.result.description)
                    print(response.result.debugDescription)
                    if (response.result.value == nil) {
                        completion(NSDictionary(dictionary: ["error" : "request error"]))
                    }else{
                        completion(response.result.value as! NSDictionary)
                    }
                }
        }
    }
    
}
