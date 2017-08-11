//
//  User.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/4.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class UserProfile: MEDBaseModel {
    dynamic var id:Int = 0
    dynamic var first_name:String = ""
    dynamic var last_name:String = ""
    dynamic var birthday:String = "" //2016-06-07
    dynamic var gender:Bool = true // true = male || false = female
    dynamic var weight:Int = 75 //KG
    dynamic var length:Int = 175 //CM
    dynamic var stride_length:Int = 0 //CM
    dynamic var metricORimperial:Bool = false
    dynamic var created:TimeInterval = Date().timeIntervalSince1970
    dynamic var email:String = ""
    override static func primaryKey() -> String? {
        return "id"
    }
}
