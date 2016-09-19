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
    var birthday:String = "" //2016-06-07
    var gender:Bool = false // true = male || false = female
    var weight:Int = 0 //KG
    var length:Int = 0 //CM
    var stride_length:Int = 0 //CM
    var metricORimperial:Bool = false
    var created:TimeInterval = Date().timeIntervalSince1970
    var email:String = ""

    fileprivate var profileModel:ProfileModel = ProfileModel()

    init(keyDict:NSDictionary) {
        super.init()
        keyDict.enumerateKeysAndObjects { (key, value, stop) in
            self.setValue(value, forKey: key as! String)
        }
    }

    func add(_ result:@escaping ((_ id:Int?,_ completion:Bool?) -> Void)){
        profileModel.id = id
        profileModel.first_name = first_name
        profileModel.last_name = last_name
        profileModel.birthday = birthday
        profileModel.gender = gender
        profileModel.weight = weight
        profileModel.length = length
        profileModel.stride_length = stride_length
        profileModel.metricORimperial = metricORimperial
        profileModel.created = created
        profileModel.email = email
        profileModel.add { (id, completion) -> Void in
            result(id, completion)
        }
    }

    func update()->Bool{
        profileModel.id = id
        profileModel.first_name = first_name
        profileModel.last_name = last_name
        profileModel.birthday = birthday
        profileModel.gender = gender
        profileModel.weight = weight
        profileModel.length = length
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
        return ProfileModel.removeAll()
    }

    class func getCriteria(_ criteria:String)->NSArray{
        let modelArray:NSArray = ProfileModel.getCriteria(criteria)
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let userProfileModel:ProfileModel = model as! ProfileModel

            let profile:UserProfile = UserProfile(keyDict: ["id":userProfileModel.id,"first_name":userProfileModel.first_name,"last_name":"\(userProfileModel.last_name)","birthday":userProfileModel.birthday,"gender":userProfileModel.gender,"weight":userProfileModel.weight,"length":userProfileModel.length,"stride_length":userProfileModel.stride_length,"metricORimperial":userProfileModel.metricORimperial,"created":userProfileModel.created,"email":userProfileModel.email])
            allArray.add(profile)
        }
        return allArray
    }

    class func getAll()->NSArray{
        let modelArray:NSArray = ProfileModel.getAll()
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let userProfileModel:ProfileModel = model as! ProfileModel
            let profile:UserProfile = UserProfile(keyDict: ["id":userProfileModel.id,"first_name":userProfileModel.first_name,"last_name":"\(userProfileModel.last_name)","birthday":userProfileModel.birthday,"gender":userProfileModel.gender,"weight":userProfileModel.weight,"length":userProfileModel.length,"stride_length":userProfileModel.stride_length,"metricORimperial":userProfileModel.metricORimperial,"created":userProfileModel.created,"email":userProfileModel.email])
            allArray.add(profile)
        }
        return allArray
    }

    class func isExistInTable()->Bool {
        return ProfileModel.isExistInTable()
    }

    class func updateTable()->Bool {
        return ProfileModel.updateTable()
    }

    // Prevent the object properties and KVC dict key don't crash
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
}
