//
//  DailySteps.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 24/2/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import HealthKit

/**
This class contains a data point  of how many steps was done at a particular day
*/
class DailySteps : NevoHKDataPoint {
    
    private var mNumberOfSteps:Int
    private var mDate:NSDate
    private var lateNight:NSDate
    
    init(numberOfSteps:Int, date:NSDate) {
        mNumberOfSteps=numberOfSteps
                
        //Here, we normalise the date
        //It's a daily data point, so we normalise it to midnight
        
        let cal: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        mDate = cal.dateBySettingHour(0, minute: 0, second: 0, ofDate: date, options: NSCalendarOptions())!
        //A daily data point if from 00AM to 23:59:59
        lateNight = cal.dateBySettingHour(23, minute: 59, second: 59, ofDate: date, options: NSCalendarOptions())!
    }
    
    @objc func toHKQuantitySample() -> HKQuantitySample {
        
        let stepCountQuantity = HKQuantity(unit:HKUnit.countUnit(), doubleValue: Double(mNumberOfSteps))
        return HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!,
            quantity: stepCountQuantity,
            startDate: mDate, endDate: lateNight)
    }
    @objc func isUpdate()->Bool {return false}
}