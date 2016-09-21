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
    fileprivate let mHealthKitStore = HKHealthStore()
    
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
    
    func authorizeHealthKit(_ completion: ((_ success:Bool, _ error:NSError?) -> Void)!)
    {
        // 1. Set the types you want to read from HK Store  HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)
        //quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        let healthKitTypesToRead = NSSet(array: [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!])
        
        // 2. Set the types you want to write to HK Store  HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)
        let healthKitTypesToWrite = NSSet(array:[HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!])
        
        // 3. If the store is not available (for instance, iPad) return an error and don't go on.
        if !HKHealthStore.isHealthDataAvailable()
        {
            let error = NSError(domain: "com.nevowatch.nevo", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            if let completionUnwrapped = completion {
                completionUnwrapped(false, error)
            }
            return;
        }
        
        // 4.  Request HealthKit authorization
        mHealthKitStore.requestAuthorization(toShare: healthKitTypesToWrite as? Set<HKSampleType>, read: healthKitTypesToRead as! Set<HKSampleType>) { (success, error) -> Void in
            if let completionUnwrapped = completion {
                completionUnwrapped(success,error as NSError?)
            }
        
        }
    }
    
    /**
    See NevoHK protocol
    */
    func writeDataPoint(_ data:NevoHKDataPoint,resultHandler:@escaping ((_ result:Bool?,_ error:NSError?) -> Void)) {

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
                        resultHandler(false,error)
                    } else {
                        resultHandler(true,nil)
                    }
                })
                
            } else {
                
                if data.isUpdate(){

                    self.replaceDataPoint(object!, saveData: saveData, resultHandler: { (result, error) -> Void in
                        if( error != nil ) {
                            resultHandler(false,error)
                        } else {
                            resultHandler(true,nil)
                        }
                    })

                }else{
                    resultHandler(false,NSError(domain:"Can't save Health Kit. Already present or Health Kit autorisation wasn't given : \(saveData)" , code: 404, userInfo: nil))
                }

            }
            
        })

        
    }

    fileprivate func saveDataPoint(_ data:HKObject,resultHandler:@escaping ((_ result:Bool?,_ error:NSError?) -> Void)){
        self.mHealthKitStore.save(data, withCompletion: { (success, error) -> Void in
            if( error != nil ) {
                print("Error saving sample: \(error!.localizedDescription)")
                resultHandler(false,error as NSError?)
            } else {
                print("Saved in Health Kit : \(data)")
                resultHandler(true,nil)
            }
        })
    }

    fileprivate func deleteDataPoint(_ data:HKObject,resultHandler:@escaping ((_ result:Bool?,_ error:NSError?) -> Void)){
        self.mHealthKitStore.delete(data, withCompletion: { (success, error) -> Void in
            if( error != nil ) {
                resultHandler(false,error as NSError?)
                print("Error delete sample: \(error!.localizedDescription)")
            } else {
                resultHandler(true,nil)
                print("Success delete in Health Kit : \(data as! HKQuantitySample)")
            }
        })
    }

    fileprivate func replaceDataPoint(_ deleData:HKObject,saveData:HKObject,resultHandler:@escaping ((_ result:Bool?,_ error:NSError?) -> Void)){
        deleteDataPoint(deleData) { (result, error) -> Void in
            if(error == nil && result == true){
                self.saveDataPoint(saveData, resultHandler: { (result, error) -> Void in
                    resultHandler(result,error)
                    if(result!){
                        print("Success replace in Health Kit : \(saveData as! HKQuantitySample)")
                    }else{
                        print("Error Replace sample:\(deleData as! HKQuantitySample)")
                    }
                })
            }else{
                resultHandler(result,error)
                print("Error Replace sample:\(deleData as! HKQuantitySample)")
            }
        }

    }
    
    /**
    See NevoHK protocol
    */
    func isPresent(_ data:NevoHKDataPoint, handler:@escaping ( (Bool?,HKObject?) -> Void) ) {
        var sample:AnyObject!
        if(data is HourlySteps){
            sample = data.toHKQuantitySample()
        }else{
            sample = data.toHKCategorySample!()
        }

        //Check if this data point is present in HK

        let datePredicate = HKQuery.predicateForSamples(withStart: sample.startDate,
            end: sample.endDate, options: HKQueryOptions())
        
        let sourcePredicate:NSPredicate = HKQuery.predicateForObjects(from: HKSource.default());
        
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
        
        mHealthKitStore.execute(query)
        
    }
}
