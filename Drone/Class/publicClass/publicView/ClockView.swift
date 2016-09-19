//
//  ClockView.swift
//  Nevo
//
//  Created by leiyuncun on 15/1/20.
//  Copyright (c) 2015年 Cloud. All rights reserved.
//

import UIKit

class ClockView: UIControl {

    fileprivate var mHourImageView:UIImageView!
    fileprivate var mMinuteImageView:UIImageView!
    fileprivate var mClockDialView:UIImageView!


    init(frame: CGRect ,hourImage:UIImage ,minuteImage:UIImage ,dialImage:UIImage) {
        super.init(frame: frame)
        super.backgroundColor = UIColor.clear

        // ------------------------------------------
        // --  Draw the Nevo clockDialeView image  --
        // ------------------------------------------
        let dialeRect:CGRect = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.width)
        mClockDialView = UIImageView(frame: dialeRect)
        mClockDialView.image = dialImage
        self.addSubview(mClockDialView)

        // --------------------------------
        // --  Draw the Nevo hour image  --
        // --------------------------------
        let hourImageRect:CGRect = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.width)
        mHourImageView = UIImageView(frame:hourImageRect)
        mHourImageView.image = hourImage
        self.addSubview(mHourImageView)

        // ----------------------------------
        // --  Draw the Nevo minute image  --
        // ----------------------------------
        let minuteImageRect:CGRect = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.width)
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
        let now:Date = Date()
        let cal:Calendar = Calendar.current
        let dd:DateComponents = (cal as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day ,NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.second,], from: now);
        let seconds:NSInteger = dd.second!
        let hour:NSInteger = dd.hour!;
        let minute:NSInteger = dd.minute!;

        let angleOfHour:CGFloat = (CGFloat(hour).truncatingRemainder(dividingBy: 12))*30.0 + ((CGFloat(minute) + CGFloat(seconds)/60.0 )/60.0)*30.0;
        mHourImageView.transform = CGAffineTransform.identity.rotated(by: DegreesToRadians(CGFloat(angleOfHour)));

        let angleOfMinute:CGFloat = (CGFloat(minute) + CGFloat(seconds)/60.0) * 6.0;
        mMinuteImageView.transform = CGAffineTransform.identity.rotated(by: DegreesToRadians(CGFloat(angleOfMinute)));
    }

    /*
    Used to calculate the rotate degree
    */
    fileprivate func DegreesToRadians(_ degrees:CGFloat) -> CGFloat {

        return (degrees * CGFloat(M_PI))/180.0;
    }
    /*
    set new Image
    */
    func setClockImage(_ dialImage:UIImage)
    {
       mClockDialView.image = dialImage
    }
}
