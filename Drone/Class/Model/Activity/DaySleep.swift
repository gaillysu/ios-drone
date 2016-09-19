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
class DaySleep : NevoHKDataPoint {
    
    fileprivate var mNumberOfSleeps:Int
    fileprivate var mDate:Date
    fileprivate var lateNight:Date
    fileprivate var mIsAsleep:Bool
    
    init(isAsleep:Bool, numberOfSleeps:Int, startDate:Date,endDate:Date) {
        mNumberOfSleeps=numberOfSleeps
        //Here, we normalise the date
        //It's a daily data point, so we normalise it to midnight
        mDate = startDate
        //A daily data point if from 00AM to 23:59:59
        lateNight = endDate

        mIsAsleep = isAsleep;
    }

    @objc func toHKQuantitySample() -> HKQuantitySample {
        let stepCountQuantity = HKQuantity(unit:HKUnit.count(), doubleValue: Double(0))
        return HKQuantitySample(type: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
            quantity: stepCountQuantity,
            start: mDate, end: lateNight)
    }
    @objc func isUpdate()->Bool {return false}

    @objc func toHKCategorySample()-> HKCategorySample {
        
        let sleepType = mIsAsleep ? (HKCategoryValueSleepAnalysis.asleep.rawValue) : (HKCategoryValueSleepAnalysis.inBed.rawValue)

        let categoryType:HKCategoryType = HKCategoryType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!
        let sleepSample:HKCategorySample = HKCategorySample(type: categoryType, value: sleepType, start: mDate, end: lateNight);
        return sleepSample
    }
}
