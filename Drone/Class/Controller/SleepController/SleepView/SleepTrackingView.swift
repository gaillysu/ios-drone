//
//  SleepTrackingView.swift
//  Nevo
//
//  Created by leiyuncun on 15/10/6.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class SleepTrackingView: UIView {

    //Put all UI operation HomeView inside
    fileprivate let mClockTimerView = ClockView(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width-60, height: UIScreen.main.bounds.width-60), hourImage:  UIImage(named: "clockViewHour")!, minuteImage: UIImage(named: "clockViewMinute")!, dialImage: UIImage(named: "clockView600")!);//init "ClockView" ,Use the code relative layout

     var progresValue:CGFloat = 0.0
    //var animationView:AnimationView!
    var historyButton:UIButton?
    var infoButton:UIButton?
 
    func getClockTimerView() -> ClockView {
        return mClockTimerView
    }

}
