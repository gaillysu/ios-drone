//
//  UserNetworkManager.swift
//  Drone
//
//  Created by Karl-John Chow on 31/10/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class UserNetworkManager: NSObject {
    
    class func login(email:String, password:String, completion:@escaping ( _
        loggedIn:Bool, _ user:UserProfile?) -> Void){
        NetworkManager.execute(request: LoginRequest(email: email, password: password, responseBlock: { (success,json,error) in
            if success, let unpackedJson = json{
                let user = unpackedJson["user"]
                let jsonBirthday = user["birthday"];
                let dateString: String = jsonBirthday["date"].stringValue
                var birthday:String = ""
                if !jsonBirthday.isEmpty || !dateString.isEmpty {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "y-M-d h:m:s.000000"
                    
                    let birthdayDate = dateFormatter.date(from: dateString)
                    dateFormatter.dateFormat = "y-M-d"
                    birthday = dateFormatter.string(from: birthdayDate!)
                }
                
                let userprofile:UserProfile = UserProfile(keyDict: ["id":user["id"].intValue,"first_name":user["first_name"].stringValue,"last_name":user["last_name"].stringValue,"birthday":birthday,"length":user["length"].intValue,"email":user["email"].stringValue, "weight":user["weight"].floatValue])
                userprofile.add({ _ in
                    completion(true, userprofile)
                })
            }else{
                completion(false, nil)
            }
        }))
    }
    
    class func requestPassword(email:String, completion:@escaping ( _ result:
        (success:Bool, token:String, id:Int)) -> Void) {
        NetworkManager.execute(request: RequestPasswordRequest(email: email, responseBlock: { (success,json,error) in
            if success, let unpackedJson = json{
                let token:String = unpackedJson["user"]["password_token"].string!
                let id:Int = unpackedJson["user"]["id"].intValue
                completion((success: true, token: token, id: id))
            }else{
                completion((success: false, token: "", id: -1))
            }
        }))
    }
    
    class func forgetPassword(email:String, password:String, id:Int, token:String, completion:@escaping ( _ changeSuccess:
        Bool) -> Void){
        NetworkManager.execute(request: ForgetPasswordRequest(email: email, password: password, token: token, id: id, responseBlock: { (success,json,error) in
            if success{
                completion(true)
            }else{
                completion(false)
            }
        }))
    }
}
