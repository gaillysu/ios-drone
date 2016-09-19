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
   
    fileprivate var mNumberOfSteps:Int
    fileprivate var mDate:Date
    
    struct Constants {
        static let classname = "RealTimeCountSteps"
    }
    struct Variables {
        static var mLastDate:Date = (Calendar(identifier: NSGregorianCalendar)! as NSCalendar).date(bySettingHour: 0, minute: 0, second: 0, of: Date(), options: NSCalendar.Options())!
        static var mLastNumberOfSteps:Int = 0
    }
    
    init(numberOfSteps:Int, date:Date) {
        mNumberOfSteps=numberOfSteps
        mDate = date
    }
    
    @objc func toHKQuantitySample() -> HKQuantitySample {
        
        let stepCountQuantity = HKQuantity(unit:HKUnit.count(), doubleValue: Double(mNumberOfSteps))
        
        return HKQuantitySample(type: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
            quantity: stepCountQuantity,
            start: mDate, end: Date())
    }
    
    class func getLastDate()->Date
    {
         return RealTimeCountSteps.Variables.mLastDate
    }
    class func setLastDate(_ date:Date)
    {
        RealTimeCountSteps.Variables.mLastDate = Date(timeIntervalSince1970:date.timeIntervalSince1970 + 1)
    }
    
    class func getLastNumberOfSteps()->Int
    {
        return RealTimeCountSteps.Variables.mLastNumberOfSteps
    }
    class func setLastNumberOfSteps(_ data:Int)
    {
        RealTimeCountSteps.Variables.mLastNumberOfSteps = data
    }
    @objc func isUpdate()->Bool {return false}
}
