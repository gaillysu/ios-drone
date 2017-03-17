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
    
    class func createUser(firstName: String, lastName: String, email: String, password: String, birthday: String, length: String, weight: String, sex: Int, completion:@escaping (_ created:Bool) -> Void){
        NetworkManager.execute(request: UserCreateRequest(firstName: firstName, lastName: lastName, email: email, password: password, birthday: birthday, length: length, weight: weight, sex: sex, responseBlock: { (success, optionalJson, optionalError) in
            completion(success)
        }))
    }
    
    class func updateUser(profile:UserProfile, completion:@escaping (_ created:Bool, _ profile:UserProfile?) -> Void){
        NetworkManager.execute(request: UserUpdateRequest(profile: profile, responseBlock: { (success, optionalJson, optionalError) in
            if success, let json = optionalJson{
                let user:UserProfile = jsonToUser(user: json["user"])
                completion(true, user)
            }else{
                completion(false, nil)
            }
        }))
    }
    
    class func login(email:String, password:String, completion:@escaping ( _
        loggedIn:Bool, _ user:UserProfile?) -> Void){
        NetworkManager.execute(request: LoginRequest(email: email, password: password, responseBlock: { (success, optionalJson, optionalError) in
            if success, let json = optionalJson{
                let user:UserProfile = jsonToUser(user: json["user"])
                _ = user.add()
                completion(true, user)
            }else{
                completion(false, nil)
            }
        }))
    }
    
    class func requestPassword(email:String, completion:@escaping ( _ result:
        (success:Bool, token:String, id:Int)) -> Void) {
        NetworkManager.execute(request: RequestPasswordRequest(email: email, responseBlock: { (success, optionalJson, optionalError) in
            if success, let json = optionalJson{
                let token:String = json["user"]["password_token"].string!
                let id:Int = json["user"]["id"].intValue
                completion((success: true, token: token, id: id))
            }else{
                completion((success: false, token: "", id: -1))
            }
        }))
    }
    
    class func forgetPassword(email:String, password:String, id:Int, token:String, completion:@escaping ( _ changeSuccess:
        Bool) -> Void){
        NetworkManager.execute(request: ForgetPasswordRequest(email: email, password: password, token: token, id: id, responseBlock: { (success, optionalJson, optionalError) in
            if success{
                completion(true)
            }else{
                completion(false)
            }
        }))
    }
    
    private class func jsonToUser(user:JSON) -> UserProfile{
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
        let userProfile:UserProfile = UserProfile()
        userProfile.id = user["id"].intValue
        userProfile.first_name = user["first_name"].stringValue
        userProfile.last_name = user["last_name"].stringValue
        userProfile.birthday = birthday
        userProfile.length = user["length"].intValue
        userProfile.email = user["email"].stringValue
        userProfile.weight = user["weight"].intValue
        return userProfile
    }
}
