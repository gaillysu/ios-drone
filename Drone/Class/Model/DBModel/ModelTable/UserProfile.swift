//
//  User.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/4.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class UserProfile: NSObject {
    var id:Int = 0
    var first_name:String = ""
    var last_name:String = ""
    var birthday:NSTimeInterval = NSDate().timeIntervalSince1970
    var gender:Bool = false
    var age:Int = 0
    var weight:Int = 0
    var lenght:Int = 0
    var stride_length:Int = 0
    var metricORimperial:Bool = false
    var created:NSTimeInterval = NSDate().timeIntervalSince1970
    var email:String = ""

    private var profileModel:UserProfileModel = UserProfileModel()

    init(keyDict:NSDictionary) {
        super.init()
        keyDict.enumerateKeysAndObjectsUsingBlock { (key, value, stop) in
            self.setValue(value, forKey: key as! String)
        }
    }

    func add(result:((id:Int?,completion:Bool?) -> Void)){
        profileModel.first_name = first_name
        profileModel.last_name = last_name
        profileModel.birthday = birthday
        profileModel.gender = gender
        profileModel.age = age
        profileModel.weight = weight
        profileModel.lenght = lenght
        profileModel.stride_length = stride_length
        profileModel.metricORimperial = metricORimperial
        profileModel.created = created
        profileModel.email = email
        profileModel.add { (id, completion) -> Void in
            result(id: id, completion: completion)
        }
    }

    func update()->Bool{
        profileModel.id = id
        profileModel.first_name = first_name
        profileModel.last_name = last_name
        profileModel.birthday = birthday
        profileModel.gender = gender
        profileModel.age = age
        profileModel.weight = weight
        profileModel.lenght = lenght
        profileModel.stride_length = stride_length
        profileModel.metricORimperial = metricORimperial
        profileModel.created = created
        profileModel.email = email
        return profileModel.update()
    }

    func remove()->Bool{
        profileModel.id = id
        return profileModel.remove()
    }

    class func removeAll()->Bool{
        return UserProfileModel.removeAll()
    }

    class func getCriteria(criteria:String)->NSArray{
        let modelArray:NSArray = UserProfileModel.getCriteria(criteria)
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let userProfileModel:UserProfileModel = model as! UserProfileModel

            let profile:UserProfile = UserProfile(keyDict: ["id":userProfileModel.id,"first_name":userProfileModel.first_name,"last_name":"\(userProfileModel.last_name)","birthday":userProfileModel.birthday,"gender":userProfileModel.gender,"age":userProfileModel.age,"weight":userProfileModel.weight,"lenght":userProfileModel.lenght,"stride_length":userProfileModel.stride_length,"metricORimperial":userProfileModel.metricORimperial,"created":userProfileModel.created,"email":userProfileModel.email])
            allArray.addObject(profile)
        }
        return allArray
    }

    class func getAll()->NSArray{
        let modelArray:NSArray = UserProfileModel.getAll()
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let userProfileModel:UserProfileModel = model as! UserProfileModel
            let profile:UserProfile = UserProfile(keyDict: ["id":userProfileModel.id,"first_name":userProfileModel.first_name,"last_name":"\(userProfileModel.last_name)","birthday":userProfileModel.birthday,"gender":userProfileModel.gender,"age":userProfileModel.age,"weight":userProfileModel.weight,"lenght":userProfileModel.lenght,"stride_length":userProfileModel.stride_length,"metricORimperial":userProfileModel.metricORimperial,"created":userProfileModel.created,"email":userProfileModel.email])
            allArray.addObject(profile)
        }
        return allArray
    }

    class func isExistInTable()->Bool {
        return UserProfileModel.isExistInTable()
    }

    class func updateTable()->Bool {
        return UserProfileModel.updateTable()
    }

    /**
     When it is the first time you install and use must be implemented
     *在用户第一次安装使用的时候必须实现
     */
    class func defaultProfile(){
        let array = UserProfile.getAll()
        if(array.count == 0){
            let uesrProfile:UserProfile = UserProfile(keyDict: ["id":0,"first_name":"First name","last_name":"Last name","birthday":NSDate().timeIntervalSince1970,"gender":false,"age":25,"weight":60,"lenght":168,"stride_length":60,"metricORimperial":false,"created":NSDate().timeIntervalSince1970])
            uesrProfile.add({ (id, completion) -> Void in
                
            })
        }
    }

    // Prevent the object properties and KVC dict key don't crash
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
}
