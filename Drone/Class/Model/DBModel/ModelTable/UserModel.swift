//
//  User.swift
//  Nevo
//
//  Created by leiyuncun on 15/11/18.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class UserModel: UserDatabaseHelper {
    var birfhday:NSTimeInterval = NSDate().timeIntervalSince1970
    var age:Int = 0
    var weight:Int = 0
    var lenght:Int = 0
    var created:NSTimeInterval = NSDate().timeIntervalSince1970

    override init() {

    }
}
