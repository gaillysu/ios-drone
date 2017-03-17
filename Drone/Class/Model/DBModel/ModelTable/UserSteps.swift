//
//  UserSteps.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/23.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class UserSteps: MEDBaseModel {
    var id:Int = 0
    var cid:Int = 0
    var steps:Int = 0
    var distance:Int = 0
    var date:TimeInterval = 0
    var syncnext:Bool = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
