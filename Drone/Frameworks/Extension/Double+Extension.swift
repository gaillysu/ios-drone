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
    
    func timeConvertString() -> String {
        if self>3600{
            return String(format: "%.2f hour", self/3600)
        }
        
        if self > 60 {
            return String(format: "%.2f minute", self/60.0)
        }
        
        return "\(self) second"
    }
    
    func distanceConvertMetricString() -> String {
        if self>1000 {
            return String(format: "%.2f km", self/1000)
        }
        
        return String(format: "%.2f m", self)
    }
    
    func roundTo(_ places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
        
    }
}
