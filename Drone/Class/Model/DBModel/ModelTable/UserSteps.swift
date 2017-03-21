//
//  UserSteps.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/23.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class UserSteps: MEDBaseModel {
    dynamic var id:Int = 0
    dynamic var cid:Int = 0
    dynamic var steps:Int = 0
    dynamic var distance:Int = 0
    dynamic var date:TimeInterval = 0
    dynamic var syncnext:Bool = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
