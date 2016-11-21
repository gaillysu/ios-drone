//
//  Int+Extension.swift
//  Nevo
//
//  Created by leiyuncun on 16/9/29.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import Foundation

extension String {
    func toInt() -> Int {
        return NSString(format: "%@", self).integerValue
    }
    
    func toDouble() -> Double {
        return NSString(format: "%@", self).doubleValue
    }
    
    func length() ->Int {
        return NSString(format: "%@", self).length
    }
}
