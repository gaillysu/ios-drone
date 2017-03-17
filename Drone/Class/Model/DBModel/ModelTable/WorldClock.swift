//
//  WorldClockModel.swift
//  Drone
//
//  Created by Karl-John on 6/5/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import UIKit

class WorldClock: MEDBaseModel {
    var id:Int = 0
    var system_name:String = ""
    var city_name:String = ""
    var display_name:String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
