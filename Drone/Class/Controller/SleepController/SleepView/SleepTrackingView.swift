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
    private let mClockTimerView = ClockView(frame:CGRectMake(0, 0, UIScreen.mainScreen().bounds.width-60, UIScreen.mainScreen().bounds.width-60), hourImage:  UIImage(named: "clockViewHour")!, minuteImage: UIImage(named: "clockViewMinute")!, dialImage: UIImage(named: "clockView600")!);//init "ClockView" ,Use the code relative layout

    var progressView:CircleSleepProgressView?
    var progresValue:CGFloat = 0.0
    //var animationView:AnimationView!
    var historyButton:UIButton?
    var infoButton:UIButton?

    private var mDelegate:ButtonManagerCallBack!

    func bulidHomeView(delegate:ButtonManagerCallBack) {
        mDelegate = delegate
        //animationView = AnimationView(frame: self.frame, delegate: delegate)
        //self.backgroundColor = AppTheme.hexStringToColor("#d1cfcf")
        //title.text = NSLocalizedString("SLEEP_TITLE", comment: "")

        mClockTimerView.currentTimer()
        self.addSubview(mClockTimerView)
        mClockTimerView.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2.0, UIScreen.mainScreen().bounds.size.height/2.0)//Using the center property determines the location of the ClockView
         mClockTimerView.frame = CGRectMake(mClockTimerView.frame.origin.x, 45, mClockTimerView.frame.size.width, mClockTimerView.frame.size.height)

        progressView = CircleSleepProgressView()
        progressView?.frame = CGRectMake(mClockTimerView.frame.origin.x-5, mClockTimerView.frame.origin.y-5, UIScreen.mainScreen().bounds.width-50, UIScreen.mainScreen().bounds.width-50)
        self.layer.addSublayer(progressView!)
    }


    func getClockTimerView() -> ClockView {
        return mClockTimerView
    }

    @IBAction func ButtonAction(sender: AnyObject) {
        mDelegate?.controllManager(sender)
    }

    /**
    set the progress of the progressView

    :param: progress
    :param: animated
    */
    func setProgress(dailySleep:NSArray){
        //progressView?.setProgress(progresValue, Steps: dailySteps, GoalStep: dailyStepGoal)
        progressView?.setSleepProgress(dailySleep)
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
