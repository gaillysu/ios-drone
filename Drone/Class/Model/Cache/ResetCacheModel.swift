//
//  ResetCacheModel.swift
//  Drone
//
//  Created by Cloud on 2017/4/19.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit

class ResetCacheModel: NSObject,NSCoding {
    var resetState:Bool?
    var resetDate:TimeInterval?
    
    fileprivate override init() {
        super.init()
    }
    
    init(reState:Bool,date:TimeInterval) {
        super.init()
        resetState = reState;
        resetDate = date;
    }
    
    func encode(with aCoder:NSCoder) {
        aCoder.encode(resetState, forKey:"resetState")
        aCoder.encode(resetDate, forKey:"resetDate")
    }
    
    required init(coder aDecoder:NSCoder) {
        super.init()
        resetState = aDecoder.decodeObject(forKey:"resetState") as? Bool
        resetDate = aDecoder.decodeObject(forKey:"resetDate") as? TimeInterval
    }
}
