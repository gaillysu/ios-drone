//
//  PostActivityData.swift
//  Drone
//
//  Created by Cloud on 2017/4/14.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit

class PostActivityData: NSObject,NSCoding {
    var step:Int = 0
    var stepsDate:Int = 0
    var activityStatus:Int = 0
    
    override init() {
        super.init()
    }
    
    init(steps:Int,date:Int,state:Int) {
        super.init()
        step = steps
        stepsDate = date
        activityStatus = state
    }
    
    func encode(with aCoder:NSCoder) {
        aCoder.encode(step, forKey:"step")
        aCoder.encode(stepsDate, forKey:"stepsDate")
        aCoder.encode(activityStatus, forKey:"activityStatus")
    }
    

    required init(coder aDecoder:NSCoder) {
        super.init()
        step = aDecoder.decodeObject(forKey:"step") as! Int
        stepsDate = aDecoder.decodeObject(forKey:"stepsDate") as! Int
        activityStatus = aDecoder.decodeObject(forKey:"activityStatus") as! Int
    }
}
