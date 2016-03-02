//
//  NevoHKImpl.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 24/2/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import HealthKit

/**
See NevoHK protocol
*/
class NevoHKImpl {
    private let mHealthKitStore = HKHealthStore()
    
    /**
    See NevoHK protocol
    */
    func requestPermission() {
        authorizeHealthKit { (authorized,  error) -> Void in
            if authorized {
                print("HealthKit authorization received.")
            }
            else
            {
                print("HealthKit authorization denied!")
                if error != nil {
                    print("\(error)")
                }
            }
        }
    }
    
    func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!)
    {
        // 1. Set the types you want to read from HK Store  HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)
        //quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        let healthKitTypesToRead = NSSet(array: [HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!])
        
        // 2. Set the types you want to write to HK Store  HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)
        let healthKitTypesToWrite = NSSet(array:[HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!])
        
        // 3. If the store is not available (for instance, iPad) return an error and don't go on.
        if !HKHealthStore.isHealthDataAvailable()
        {
            let error = NSError(domain: "com.nevowatch.nevo", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            if( completion != nil )
            {
                completion(success:false, error:error)
            }
            return;
        }
        
        // 4.  Request HealthKit authorization
        mHealthKitStore.requestAuthorizationToShareTypes(healthKitTypesToWrite as? Set<HKSampleType>, readTypes: healthKitTypesToRead as! Set<HKSampleType>) { (success, error) -> Void in
            
            if( completion != nil )
            {
                completion(success:success,error:error)
            }
        }
    }
    
    /**
    See NevoHK protocol
    */
    func writeDataPoint(data:NevoHKDataPoint,resultHandler:((result:Bool?,error:NSError?) -> Void)) {

        isPresent(data, handler:  { (present,object) -> Void in
            
            //We only write this data point if it isn't present in HK
            var saveData:HKObject!
            if(data is HourlySteps){
                saveData = data.toHKQuantitySample()
            }else{
                saveData = data.toHKCategorySample!()
            }

            if( present != true) {

                self.saveDataPoint(saveData, resultHandler: { (result, error) -> Void in
                    if( error != nil ) {
                        resultHandler(result: false,error: error)
                    } else {
                        resultHandler(result: true,error: nil)
                    }
                })
                
            } else {
                
                if data.isUpdate(){

                    self.replaceDataPoint(object!, saveData: saveData, resultHandler: { (result, error) -> Void in
                        if( error != nil ) {
                            resultHandler(result: false,error: error)
                        } else {
                            resultHandler(result: true,error: nil)
                        }
                    })

                }else{
                    resultHandler(result:false,error:NSError(domain:"Can't save Health Kit. Already present or Health Kit autorisation wasn't given : \(saveData)" , code: 404, userInfo: nil))
                }

            }
            
        })

        
    }

    private func saveDataPoint(data:HKObject,resultHandler:((result:Bool?,error:NSError?) -> Void)){
        self.mHealthKitStore.saveObject(data, withCompletion: { (success, error) -> Void in
            if( error != nil ) {
                print("Error saving sample: \(error!.localizedDescription)")
                resultHandler(result: false,error: error)
            } else {
                print("Saved in Health Kit : \(data)")
                resultHandler(result: true,error: nil)
            }
        })
    }

    private func deleteDataPoint(data:HKObject,resultHandler:((result:Bool?,error:NSError?) -> Void)){
        self.mHealthKitStore.deleteObject(data, withCompletion: { (success, error) -> Void in
            if( error != nil ) {
                resultHandler(result: false,error: error)
                print("Error delete sample: \(error!.localizedDescription)")
            } else {
                resultHandler(result: true,error: nil)
                print("Success delete in Health Kit : \(data as! HKQuantitySample)")
            }
        })
    }

    private func replaceDataPoint(deleData:HKObject,saveData:HKObject,resultHandler:((result:Bool?,error:NSError?) -> Void)){
        deleteDataPoint(deleData) { (result, error) -> Void in
            if(error == nil && result == true){
                self.saveDataPoint(saveData, resultHandler: { (result, error) -> Void in
                    resultHandler(result: result,error: error)
                    if(result!){
                        print("Success replace in Health Kit : \(saveData as! HKQuantitySample)")
                    }else{
                        print("Error Replace sample:\(deleData as! HKQuantitySample)")
                    }
                })
            }else{
                resultHandler(result: result,error: error)
                print("Error Replace sample:\(deleData as! HKQuantitySample)")
            }
        }

    }
    
    /**
    See NevoHK protocol
    */
    func isPresent(data:NevoHKDataPoint, handler:( (Bool?,HKObject?) -> Void) ) {
        var sample:AnyObject!
        if(data is HourlySteps){
            sample = data.toHKQuantitySample()
        }else{
            sample = data.toHKCategorySample!()
        }

        //Check if this data point is present in HK

        let datePredicate = HKQuery.predicateForSamplesWithStartDate(sample.startDate,
            endDate: sample.endDate, options: .None)
        
        let sourcePredicate:NSPredicate = HKQuery.predicateForObjectsFromSource(HKSource.defaultSource());
        
        let dateAndSourcePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate,sourcePredicate])

        var type:HKSampleType
        if(data is HourlySteps){
            type = sample.quantityType
        }else{
            type = (sample as! HKCategorySample ).categoryType
        }

        let query = HKSampleQuery(sampleType: type, predicate: dateAndSourcePredicate,
            limit: 1, sortDescriptors: nil, resultsHandler: {
                (query, results, error) in

                if error != nil {
                    //In case of error, it probably means that we don't have the autorisation to access HK
                    //Or that we are not in a HK capable device
                    handler(false,nil)
                    return;
                }else {
                    //If there's no error, if we have a result, then the data is present, if we don't it's absent
                    handler( results != nil && results!.count >= 1 ,(results != nil && results!.count >= 1) ?results?[0] as? HKQuantitySample:nil)
                    return;

                }

        })
        
        mHealthKitStore.executeQuery(query)
        
    }
}