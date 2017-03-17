//
//  User.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/4.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class UserProfile: MEDBaseModel {
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
    override static func primaryKey() -> String? {
        return "id"
    }
}
