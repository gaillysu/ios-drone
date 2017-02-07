//
//  StepsNetworkController.swift
//  Drone
//
//  Created by Karl-John Chow on 28/10/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class StepsNetworkManager: NSObject {
    
    class func createSteps(uid:Int, steps:String, date:String, activeTime:Int, completion:@escaping ((_ created:Bool) -> Void)){
        NetworkManager.execute(request: StepsCreateRequest(uid: uid, value: steps, date: date, activeTime: activeTime, responseBlock: { (success, optionalJson, optionalError) in
            if success, let _ = optionalJson {
                completion(true)
            }else{
                completion(false)
            }
        }))
    }
    
    class func updateSteps(id:Int, uid:Int, steps:String, date:String, activeTime:Int, completion: @escaping ((_ updated:Bool)->Void)){
        NetworkManager.execute(request: StepsUpdateRequest(id: id, uid: uid, steps: steps, date: date, activeTime: activeTime, responseBlock: { (success, optionalJson, optionalError) in
            if success, let _ = optionalJson{
                completion(true)
            }else{
                completion(false)
            }
        }))
    }
    
    class func stepsForDate(uid:Int, date:Date, completion:@escaping ( _ result:
        (requestSuccess:Bool, databaseSaved:Bool)) -> Void){
        print(date.description)
        let startDateInt = Int(date.beginningOfDay.timeIntervalSince1970)
        print("Start Date \(date.beginningOfDay.description)")
        let endDateInt = Int(date.endOfDay.timeIntervalSince1970)
        print("End Date \(date.endOfDay.description)")
        NetworkManager.execute(request: StepsGetRequest(uid: uid, startDate: startDateInt, endDate: endDateInt, responseBlock: { success, json, error in
            if success, let unpackedJson = json {
                completion(handleResponse(json: unpackedJson))
            }else{
                completion((requestSuccess: false, databaseSaved: false))
            }
        }))
    }
    
    class func stepsForPeriod(uid:Int,startDate:Date, endDate:Date, completion:@escaping ( _ result:
        (requestSuccess:Bool, databaseSaved:Bool)) -> Void){
        let startDateInt = Int(startDate.beginningOfDay.timeIntervalSince1970)
        print("Start Date \(startDate.beginningOfDay.description)")
        let endDateInt = Int(endDate.endOfDay.timeIntervalSince1970)
        print("End Date \(endDate.endOfDay.description)")
        
        NetworkManager.execute(request: StepsGetRequest(uid: uid, startDate: startDateInt, endDate: endDateInt, responseBlock: { success, json, error in
            if success, let unpackedJson = json {
                completion(handleResponse(json: unpackedJson))
            }else{
                completion((requestSuccess: false, databaseSaved: false))
            }
        }))
        
    }
    
    private class func handleResponse(json:JSON) -> (requestSuccess:Bool,databaseSaved:Bool){
        let steps = json["steps"]
        var successSynced = true
        let dateString = steps["date"]["date"].stringValue
        let stepsString = steps["steps"].description
        let cid:Int = steps["id"].intValue
        
        let dateArray = dateString.components(separatedBy: " ")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.date(from: dateArray[0])
        let dateTimerInterval  = date?.beginningOfDay.timeIntervalSince1970
        let stepsArray:NSArray = AppTheme.jsonToArray(stepsString)
        for (hourIndex,hourValue) in stepsArray.enumerated() {
            var seconds:Int = hourIndex*60*60
            for (minuteIndex,minuteValue) in (hourValue as! NSArray).enumerated() {
                if Int(minuteValue as! NSNumber)>0 {
                    seconds += (minuteIndex*5)*60
                    let queryArray:NSArray = UserSteps.getCriteria("WHERE date = \(Double(dateTimerInterval!+Double(seconds)))")
                    if queryArray.count == 0 {
                        let steps:UserSteps = UserSteps(keyDict: ["id":0, "cid":cid, "steps":Int(minuteValue as! NSNumber), "distance": "\(0)","date":Double(dateTimerInterval!+Double(seconds)),"syncnext":true])
                        steps.add({ (id, completion) in
                            if successSynced {
                                successSynced = completion!
                            }
                        })
                    } else {
                        for (_,value3) in queryArray.enumerated() {
                            let steps:UserSteps = value3 as! UserSteps
                            steps.steps = Int(minuteValue as! NSNumber)
                            steps.cid = cid
                            steps.syncnext = true
                            let dbUpdateStatus = steps.update()
                            if successSynced {
                                successSynced = dbUpdateStatus
                            }
                        }
                    }
                }
            }
        }
        return (true, successSynced)
    }
}
