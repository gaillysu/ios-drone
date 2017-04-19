//
//  Int+Extension.swift
//  Drone
//
//  Created by Karl-John Chow on 18/4/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import Foundation

extension Int{
    func timeRepresentable() -> String{
        var string = ""
        let min = self % 60
        let hour = self / 60
        if hour > 0 {
                string.append("\(hour)h ")
        }
        if min > 0 {
            string.append("\(min)m")
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
