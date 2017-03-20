//
//  Presets.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/7.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class UserGoal: MEDBaseModel {
    dynamic var id:Int = 0
    dynamic var goalSteps:Int = 0
    dynamic var label:String = ""
    dynamic var status:Bool = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
