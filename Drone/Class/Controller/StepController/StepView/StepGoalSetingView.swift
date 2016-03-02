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

    func controllManager(sender:UIButton)

}

class StepGoalSetingView: UIView {

    //Put all UI operation HomeView inside
    private let mClockTimerView = ClockView(frame:CGRectMake(0, 0, UIScreen.mainScreen().bounds.width-60, UIScreen.mainScreen().bounds.width-60), hourImage:  UIImage(named: "clockViewHour")!, minuteImage: UIImage(named: "clockViewMinute")!, dialImage: UIImage(named: "clockView600")!);//init "ClockView" ,Use the code relative layout
    var progressView:CircleProgressView?
    var progresValue:CGFloat = 0.0

    func bulidStepGoalView(navigation:UINavigationItem){

        //animationView = AnimationView(frame: self.frame, delegate: delegate)
        mClockTimerView.currentTimer()
        mClockTimerView.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2.0, UIScreen.mainScreen().bounds.size.height/2.0)//Using the center property determines the location of the ClockView
        mClockTimerView.frame = CGRectMake(mClockTimerView.frame.origin.x, 45, mClockTimerView.frame.size.width, mClockTimerView.frame.size.height)
        //self.addSubview(mClockTimerView)

        progressView = CircleProgressView()
        progressView?.setProgressColor(AppTheme.NEVO_SOLAR_YELLOW())
        progressView?.frame = CGRectMake(mClockTimerView.frame.origin.x-5, mClockTimerView.frame.origin.y-5, UIScreen.mainScreen().bounds.width-50, UIScreen.mainScreen().bounds.width-50)
        progressView?.setProgress(0.0)
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
    func setProgress(progress: Float,dailySteps:Int,dailyStepGoal:Int){
        progresValue = CGFloat(progress)
        progressView?.setProgress(progresValue, Steps: dailySteps, GoalStep: dailyStepGoal)
    }

    // MARK: - toolbarSegmentedDelegate
    func didSelectedSegmentedControl(segment:UISegmentedControl){

    }
}
