//
//  TimerViewModel.swift
//  Drone
//
//  Created by Karl-John Chow on 29/6/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import Foundation

class TimerViewModel {
    
    var countdownTime:Int {
        get { return DTUserDefaults.countdownTime }
        set { DTUserDefaults.countdownTime = newValue}
    }
    
    init() {
            
    }
    
    func syncCountDownTimer(){
        
    }
    
}
