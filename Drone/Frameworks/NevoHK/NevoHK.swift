//
//  NevoHK.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 24/2/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import HealthKit

/**
NevoBT should do one thing : control the connection with HealthKit
This class is rather low level, just ask Health Kit permission, store data (if allowed), and checks if data is available (if allowed)
It will ensure that there are no doublons, but won't handle any synchronisation logic
🚧🚧🚧Backbone Class : Modify with care🚧🚧🚧
*/
protocol NevoHK {
    /**
    Requests the HealthKit permissions
    */
    func requestPermission()
    
    /**
    Writes the given datapoint to the database
    This function will ensure that there are no doublons
    */
    func writeDataPoint(dataPoint: NevoHKDataPoint,resultHandler:((Bool?,NSError?) -> Void))
    
    /**
    Checks if a data point is present in the DB
    returns an empty Optional if we don't have the right to read this kind of data
    */
    func isPresent(dataPoint: NevoHKDataPoint, resultHandler:((Bool?) -> Void) )
    
}

@objc protocol NevoHKDataPoint{
    /**
    HKDataPoint should be mapable to a HealtkKitQuantity sample
    It's the only prerequisite
    */
    func toHKQuantitySample() -> HKQuantitySample
    
    /**
    if a HKQuantitySample has present in HK database, when its value changed, perhaps need update it.
    */
    func isUpdate()->Bool

    /**
    HKDataPoint should be mapable to a HealtkKitQuantity sample
    It's the only prerequisite
    */
    optional func toHKCategorySample()-> HKCategorySample
}