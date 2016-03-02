//
//  RealTimeSteps.swift
//  Nevo
//
//  Created by supernova on 15/3/11.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import Foundation
import HealthKit
/**
this class count real time steps of current day, 
record format:
00:00:00~00:03:15, 100 steps
00:03:15~00:10:30, 200 steps
00:10:30~00:11:20, 20  steps
*/
class RealTimeCountSteps: NevoHKDataPoint {
   
    private var mNumberOfSteps:Int
    private var mDate:NSDate
    
    struct Constants {
        static let classname = "RealTimeCountSteps"
    }
    struct Variables {
        static var mLastDate:NSDate = NSCalendar(calendarIdentifier: NSGregorianCalendar)!.dateBySettingHour(0, minute: 0, second: 0, ofDate: NSDate(), options: NSCalendarOptions())!
        static var mLastNumberOfSteps:Int = 0
    }
    
    init(numberOfSteps:Int, date:NSDate) {
        mNumberOfSteps=numberOfSteps
        mDate = date
    }
    
    @objc func toHKQuantitySample() -> HKQuantitySample {
        
        let stepCountQuantity = HKQuantity(unit:HKUnit.countUnit(), doubleValue: Double(mNumberOfSteps))
        
        return HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!,
            quantity: stepCountQuantity,
            startDate: mDate, endDate: NSDate())
    }
    
    class func getLastDate()->NSDate
    {
         return RealTimeCountSteps.Variables.mLastDate
    }
    class func setLastDate(date:NSDate)
    {
        RealTimeCountSteps.Variables.mLastDate = NSDate(timeIntervalSince1970:date.timeIntervalSince1970 + 1)
    }
    
    class func getLastNumberOfSteps()->Int
    {
        return RealTimeCountSteps.Variables.mLastNumberOfSteps
    }
    class func setLastNumberOfSteps(data:Int)
    {
        RealTimeCountSteps.Variables.mLastNumberOfSteps = data
    }
    @objc func isUpdate()->Bool {return false}
}
