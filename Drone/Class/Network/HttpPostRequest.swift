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
    
    class  func postRequest(url: String, data:Dictionary<String,AnyObject>, completion:(result:NSDictionary) -> Void){
        var finalData: Dictionary<String,AnyObject> = ["token":"ZQpFYPBMqFbUQq8E99FztS2x6yQ2v1Ei"]
        finalData["params"] = data;
        XCGLogger.defaultInstance().debug("\(finalData)")
        
        Alamofire.request(Method.POST, url, parameters: finalData, encoding:ParameterEncoding.JSON, headers: ["Authorization": "Basic YXBwczptZWRfYXBwX2RldmVsb3BtZW50","Content-Type":"application/json"]).responseJSON { (response) -> Void in
            if response.result.isSuccess {
                XCGLogger.defaultInstance().debug("getJSON: \(response.result.value)")
                completion(result: response.result.value as! NSDictionary)
            }else if (response.result.isFailure){
                if (response.result.value == nil) {
                    completion(result: NSDictionary(dictionary: ["error" : "request error"]))
                }else{
                    completion(result: response.result.value as! NSDictionary)
                }
            }
        }
    }

    
    class  func putRequest(url: String, data:Dictionary<String,AnyObject>, completion:(result:NSDictionary) -> Void){
        var finalData: Dictionary<String,AnyObject> = ["token":"ZQpFYPBMqFbUQq8E99FztS2x6yQ2v1Ei"]
        finalData["params"] = data;
        XCGLogger.defaultInstance().debug("\(finalData)")
        Alamofire.request(Method.PUT, url, parameters: finalData, encoding:ParameterEncoding.JSON, headers: ["Authorization": "Basic YXBwczptZWRfYXBwX2RldmVsb3BtZW50","Content-Type":"application/json"]).responseJSON { (response) -> Void in
            if response.result.isSuccess {
                XCGLogger.defaultInstance().debug("getJSON: \(response.result.value)")
                completion(result: response.result.value as! NSDictionary)
            }else if (response.result.isFailure){
                print(response.result.description)
                print(response.result.debugDescription)
                if (response.result.value == nil) {
                    completion(result: NSDictionary(dictionary: ["error" : "request error"]))
                }else{
                    completion(result: response.result.value as! NSDictionary)
                }
            }
        }
    }
    
    static func getCommonParams() -> (md5: String,time: Int){
        let time = Int(NSDate().timeIntervalSince1970);
        
        let key = String(format: "%d-nevo2015medappteam",time)
        return (md5: md5(string:key),time: time);
    }
    
    private static func md5(string string: String) -> String {
        var digest = [UInt8](count: Int(CC_MD5_DIGEST_LENGTH), repeatedValue: 0)
        if let data = string.dataUsingEncoding(NSUTF8StringEncoding) {
            CC_MD5(data.bytes, CC_LONG(data.length), &digest)
        }
        
        var digestHex = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        
        return digestHex
    }
}
