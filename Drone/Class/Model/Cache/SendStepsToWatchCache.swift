//
//  SendStepsToWatchCache.swift
//  Drone
//
//  Created by Cloud on 2017/4/19.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit

class SendStepsToWatchCache: NSObject,NSCoding {
    var steps:Int = 0
    var date:TimeInterval = 0
    
    fileprivate override init() {
        super.init()
    }
    
    init(sendSteps:Int,sendDate:TimeInterval) {
        super.init()
        steps = sendSteps;
        date = sendDate;
    }
    
    func encode(with aCoder:NSCoder) {
        aCoder.encode(steps, forKey:"steps")
        aCoder.encode(date, forKey:"date")
    }
    
    required init(coder aDecoder:NSCoder) {
        super.init()
        steps = aDecoder.decodeObject(forKey:"steps") as! Int
        date = aDecoder.decodeObject(forKey:"date") as! TimeInterval
    }
}
