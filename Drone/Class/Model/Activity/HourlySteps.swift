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
    
    fileprivate var mNumberOfSteps:Int
    fileprivate var mDate:Date
    fileprivate var lateNight:Date
    fileprivate var mUpdate:Bool
    init(numberOfSteps:Int, date:Date,hour:Int,update:Bool) {
        mNumberOfSteps=numberOfSteps
        mUpdate = update
        let cal: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        mDate = (cal as NSCalendar).date(bySettingHour: hour, minute: 0, second: 0, of: date, options: NSCalendar.Options())!
        //A hourly data point if from hh:00:00 to hh:59:59
        lateNight = (cal as NSCalendar).date(bySettingHour: hour, minute: 59, second: 59, of: date, options: NSCalendar.Options())!
        
    }
    
    @objc func toHKQuantitySample() -> HKQuantitySample {
        
        let stepCountQuantity = HKQuantity(unit:HKUnit.count(), doubleValue: Double(mNumberOfSteps))
        return HKQuantitySample(type: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
            quantity: stepCountQuantity,
            start: mDate, end: lateNight)
    }

    @objc func isUpdate()->Bool
    {
        return mUpdate
    }
}
