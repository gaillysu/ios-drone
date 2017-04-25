//
//  Double+Extension.swift
//  Nevo
//
//  Created by leiyuncun on 16/9/28.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import Foundation

extension Double {
    func to2Double() -> Double {
        return NSString(format: "%.2f", self).doubleValue
    }
    
    func toDouble() -> Double {
        return NSString(format: "%.0f", self).doubleValue
    }
    
    func toInt() -> Int {
        return Int(self)
    }
}
