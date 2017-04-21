//
//  Int+Extension.swift
//  Nevo
//
//  Created by Cloud on 2016/11/1.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

extension Int {
    func to2String() -> String {
        let value1:NSString = NSString(format: "%d", self)
        if value1.length>1 {
            return value1 as String;
        }else{
            return NSString(format: "0%d", self) as String
        }
    }
    
    func toCGFloat() -> CGFloat {
        let value1:NSString = NSString(format: "%f", self)
        return CGFloat(value1.floatValue)
    }
    
    func toFloat() -> Float {
        let value1:NSString = NSString(format: "%f", self)
        return value1.floatValue
    }
}

