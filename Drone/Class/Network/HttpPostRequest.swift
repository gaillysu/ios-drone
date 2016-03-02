//
//  HttpPostRequest.swift
//  Nevo
//
//  Created by Karl-John on 31/12/2015.
//  Copyright © 2015 Nevo. All rights reserved.
//

import UIKit

class HttpPostRequest: NSObject {

    class  func postRequest(url: String, data:Dictionary<String,AnyObject>, completion:(result:NSDictionary) -> Void){
        let commonParams = getCommonParams();
        var finalData: [String : AnyObject] = [:];
        let params: [String: AnyObject] = ["time":commonParams.time, "check_key": commonParams.md5];
        for (key, value) in data {
            finalData[key] = value
        }
        finalData["params"] = params;
        print(finalData);
        AppDelegate.getAppDelegate().getRequestNetwork(url, parameters: finalData) { (result, error) -> Void in
            completion(result: result as! NSDictionary)
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
