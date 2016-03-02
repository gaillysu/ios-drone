//
//  ClockView.swift
//  Nevo
//
//  Created by leiyuncun on 15/1/20.
//  Copyright (c) 2015年 Cloud. All rights reserved.
//

import UIKit

class ClockView: UIControl {

    private var mHourImageView:UIImageView!
    private var mMinuteImageView:UIImageView!
    private var mClockDialView:UIImageView!


    init(frame: CGRect ,hourImage:UIImage ,minuteImage:UIImage ,dialImage:UIImage) {
        super.init(frame: frame)
        super.backgroundColor = UIColor.clearColor()

        // ------------------------------------------
        // --  Draw the Nevo clockDialeView image  --
        // ------------------------------------------
        let dialeRect:CGRect = CGRectMake(0, 0, frame.size.width, frame.size.width)
        mClockDialView = UIImageView(frame: dialeRect)
        mClockDialView.image = dialImage
        self.addSubview(mClockDialView)

        // --------------------------------
        // --  Draw the Nevo hour image  --
        // --------------------------------
        let hourImageRect:CGRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.width)
        mHourImageView = UIImageView(frame:hourImageRect)
        mHourImageView.image = hourImage
        self.addSubview(mHourImageView)

        // ----------------------------------
        // --  Draw the Nevo minute image  --
        // ----------------------------------
        let minuteImageRect:CGRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.width)
        mMinuteImageView = UIImageView(frame:minuteImageRect)
        mMinuteImageView.image = minuteImage
        self.addSubview(mMinuteImageView)

        // ------------------------
        // --  SET TIMER RADIANS --
        // ------------------------
        currentTimer()

    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /*
    SET TIMER RADIANS
    */
    func currentTimer() {
        let now:NSDate = NSDate()
        let cal:NSCalendar = NSCalendar.currentCalendar()
        let dd:NSDateComponents = cal.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day ,NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second,], fromDate: now);
        let seconds:NSInteger = dd.second
        let hour:NSInteger = dd.hour;
        let minute:NSInteger = dd.minute;

        let angleOfHour:CGFloat = (CGFloat(hour)%12)*30.0 + ((CGFloat(minute) + CGFloat(seconds)/60.0 )/60.0)*30.0;
        mHourImageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity,  DegreesToRadians(CGFloat(angleOfHour)));

        let angleOfMinute:CGFloat = (CGFloat(minute) + CGFloat(seconds)/60.0) * 6.0;
        mMinuteImageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity,  DegreesToRadians(CGFloat(angleOfMinute)));
    }

    /*
    Used to calculate the rotate degree
    */
    private func DegreesToRadians(degrees:CGFloat) -> CGFloat {

        return (degrees * CGFloat(M_PI))/180.0;
    }
    /*
    set new Image
    */
    func setClockImage(dialImage:UIImage)
    {
       mClockDialView.image = dialImage
    }
}