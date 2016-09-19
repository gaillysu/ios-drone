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
    
    fileprivate var mNumberOfSteps:Int
    fileprivate var mDate:Date
    fileprivate var lateNight:Date
    
    init(numberOfSteps:Int, date:Date) {
        mNumberOfSteps=numberOfSteps
                
        //Here, we normalise the date
        //It's a daily data point, so we normalise it to midnight
        
        let cal: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        mDate = (cal as NSCalendar).date(bySettingHour: 0, minute: 0, second: 0, of: date, options: NSCalendar.Options())!
        //A daily data point if from 00AM to 23:59:59
        lateNight = (cal as NSCalendar).date(bySettingHour: 23, minute: 59, second: 59, of: date, options: NSCalendar.Options())!
    }
    
    @objc func toHKQuantitySample() -> HKQuantitySample {
        
        let stepCountQuantity = HKQuantity(unit:HKUnit.count(), doubleValue: Double(mNumberOfSteps))
        return HKQuantitySample(type: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
            quantity: stepCountQuantity,
            start: mDate, end: lateNight)
    }
    @objc func isUpdate()->Bool {return false}
}
