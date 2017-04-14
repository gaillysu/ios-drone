//
//  PostBatteryStatus.swift
//  Drone
//
//  Created by Cloud on 2017/4/14.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit

class PostBatteryStatus: NSObject {
    var batteryStatus:Int = 0
    var percentValue:Int = 0
    
    override init() {
        super.init()
    }
    
    init(state:Int,percent:Int) {
        super.init()
        batteryStatus = state
        percentValue  = percent
    }
    
    func getStateString() ->String {
        switch batteryStatus {
        case 0:
            return "\(percentValue)%"
        case 1:
            return "Charging"
        case 2:
            return "Damaged"
        case 3:
            return "Calculating"
        default: break
            
        }
    }
    
    func encode(with aCoder:NSCoder) {
        aCoder.encode(batteryStatus, forKey:"batteryStatus")
        aCoder.encode(percentValue, forKey:"percentValue")
    }
    
    required init(coder aDecoder:NSCoder) {
        super.init()
        batteryStatus = aDecoder.decodeObject(forKey:"batteryStatus") as? Int
        percentValue  = aDecoder.decodeObject(forKey:"percentValue") as? Int
    }
}
