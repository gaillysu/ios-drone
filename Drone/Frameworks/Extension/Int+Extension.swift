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
    
    
    func secondsRepresentable() -> String{
        var string = ""
        let seconds = self % 60
        let min = self / 60
        if min == 1 {
            string.append("\(min)min ")
        } else if min > 1 {
            string.append("\(min)mins ")
        }
        if seconds == 1  {
            string.append("\(seconds)sec")
        }else if seconds > 1 {
            string.append("\(seconds)secs")
        }
        return string
    }
    
    func timeRepresentable() -> String{
        var string = ""
        let min = self % 60
        let hour = self / 60
        if hour == 1  {
            string.append("\(hour)hr ")
        }else if hour > 1 {
            string.append("\(hour)hrs ")
        }
        if min == 1 {
            string.append("\(min)min")
        } else if min > 1 {
            string.append("\(min)mins")
        }
        return string
    }
    
    func longTimeRepresentable() -> String{
        var string = ""
        let min = self % 60
        let hour = self / 60
        if hour > 0 {
            if hour == 1{
                string.append("\(hour) hour ")
            }else{
                string.append("\(hour) hours ")
            }
        }
        if min > 0 {
            if min == 1{
                string.append("\(min) minute")
            } else{
                string.append("\(min) minutes")
            }
        }
        return string
    }

}

