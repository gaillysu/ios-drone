//
//  Sleep.swift
//  Nevo
//
//  Created by Karl Chow on 10/8/15.
//  Copyright © 2015 Nevo. All rights reserved.
//

import Foundation

class Sleep{
    
    private var weakSleep:Double;
    private var lightSleep:Double;
    private var deepSleep:Double;
    
    init(weakSleep: Double, lightSleep:Double , deepSleep:Double ){
        self.deepSleep  = deepSleep;
        self.lightSleep = lightSleep;
        self.weakSleep = weakSleep;
    }
    
    func getLightSleep() -> Double{
        return (lightSleep+weakSleep)
    }
    
    func getDeepSleep() -> Double{
        return (deepSleep)
    }
    
    func getTotalSleep() -> Double{
        return getLightSleep() + getDeepSleep()
    }
}