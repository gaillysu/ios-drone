//
//  HourlySteps.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 24/2/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import HealthKit

class HourlySteps : NevoHKDataPoint {
    
    private var mNumberOfSteps:Int
    private var mDate:NSDate
    private var lateNight:NSDate
    private var mUpdate:Bool
    init(numberOfSteps:Int, date:NSDate,hour:Int,update:Bool) {
        mNumberOfSteps=numberOfSteps
        mUpdate = update
        let cal: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        mDate = cal.dateBySettingHour(hour, minute: 0, second: 0, ofDate: date, options: NSCalendarOptions())!
        //A hourly data point if from hh:00:00 to hh:59:59
        lateNight = cal.dateBySettingHour(hour, minute: 59, second: 59, ofDate: date, options: NSCalendarOptions())!
        
    }
    
    @objc func toHKQuantitySample() -> HKQuantitySample {
        
        let stepCountQuantity = HKQuantity(unit:HKUnit.countUnit(), doubleValue: Double(mNumberOfSteps))
        return HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!,
            quantity: stepCountQuantity,
            startDate: mDate, endDate: lateNight)
    }

    @objc func isUpdate()->Bool
    {
        return mUpdate
    }
}