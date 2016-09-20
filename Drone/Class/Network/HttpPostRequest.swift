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
    
    class  func postRequest(_ url: String, data:Dictionary<String,Any?>, completion:@escaping (_ result:NSDictionary) -> Void){
        var finalData: Dictionary<String,AnyObject> = ["token":"ZQpFYPBMqFbUQq8E99FztS2x6yQ2v1Ei" as AnyObject]
        finalData["params"] = data as AnyObject?;
        XCGLogger.debug("\(finalData)")
        
        Alamofire.request(url, method: .get, parameters: finalData, encoding: JSONEncoding.default)
            .authenticate(user: "apps", password: "med_app_development")
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
        
        Alamofire.request(url, method: .put, parameters: finalData, encoding: JSONEncoding.default)
            .authenticate(user: "apps", password: "med_app_development")
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
    
    static func getCommonParams() -> (md5: String,time: Int){
        let time = Int(Date().timeIntervalSince1970);
        
        let key = String(format: "%d-nevo2015medappteam",time)
        return (md5: md5(string:key),time: time);
    }
    
    fileprivate static func md5(string: String) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        if let data = string.data(using: String.Encoding.utf8) {
            CC_MD5((data as NSData).bytes, CC_LONG(data.count), &digest)
        }
        
        var digestHex = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        
        return digestHex
    }
}
