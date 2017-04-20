//
//  SyncLastDataCache.swift
//  Drone
//
//  Created by Cloud on 2017/4/19.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit

class SyncLastDataCache: NSObject,NSCoding {
    var steps:Int = 0
    var goal:Int = 0
    var date:TimeInterval = 0
    
    override init() {
        super.init()

    }
    
    func encode(with aCoder:NSCoder) {
        aCoder.encode(steps, forKey:"steps")
        aCoder.encode(goal, forKey:"goal")
        aCoder.encode(date, forKey:"date")
    }
    
    required init(coder aDecoder:NSCoder) {
        super.init()
        if let cSteps = aDecoder.decodeObject(forKey:"steps") {
            steps = cSteps as! Int
        }
        
        if let cGoal = aDecoder.decodeObject(forKey:"goal") {
            goal = cGoal as! Int
        }
        
        if let cDate = aDecoder.decodeObject(forKey:"date") {
            date = cDate as! TimeInterval
        }
        
    }
}
