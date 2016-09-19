//
//  StepGoalSetingView.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/11.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

/*
StepGoalSetingView class all button events to follow this protocol
*/
protocol StepGoalButtonActionCallBack {

    func controllManager(_ sender:UIButton)

}

class StepGoalSetingView: UIView {

    //Put all UI operation HomeView inside
    fileprivate let mClockTimerView = ClockView(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width-60, height: UIScreen.main.bounds.width-60), hourImage:  UIImage(named: "clockViewHour")!, minuteImage: UIImage(named: "clockViewMinute")!, dialImage: UIImage(named: "clockView600")!);//init "ClockView" ,Use the code relative layout

    var progresValue:CGFloat = 0.0

    func bulidStepGoalView(_ navigation:UINavigationItem){

        //animationView = AnimationView(frame: self.frame, delegate: delegate)
        mClockTimerView.currentTimer()
        mClockTimerView.center = CGPoint(x: UIScreen.main.bounds.size.width/2.0, y: UIScreen.main.bounds.size.height/2.0)//Using the center property determines the location of the ClockView
        mClockTimerView.frame = CGRect(x: mClockTimerView.frame.origin.x, y: 45, width: mClockTimerView.frame.size.width, height: mClockTimerView.frame.size.height)
        //self.addSubview(mClockTimerView)

        //self.layer.addSublayer(progressView!)
    }

    func getClockTimerView() -> ClockView {
        return mClockTimerView
    }

    /**
     set the progress of the progressView

     :param: progress
     :param: animated
     */
    func setProgress(_ progress: Float,dailySteps:Int,dailyStepGoal:Int){
        progresValue = CGFloat(progress)
    }

    // MARK: - toolbarSegmentedDelegate
    func didSelectedSegmentedControl(_ segment:UISegmentedControl){

    }
}
