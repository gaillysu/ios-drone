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
        steps = aDecoder.decodeObject(forKey:"steps") as! Int
        goal = aDecoder.decodeObject(forKey:"goal") as! Int
        date = aDecoder.decodeObject(forKey:"date") as! TimeInterval
    }
}
