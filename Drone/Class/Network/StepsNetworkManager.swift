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
    
    class func getStepsForDate(uid:Int, date:Date, completion:@escaping ( _ result:
        (requestSuccess:Bool, databaseSaved:Bool))->Void){
        let startDateInt = Int(date.beginningOfDay.timeIntervalSince1970)
        let endDateInt = Int(date.endOfDay.timeIntervalSince1970)
        NetworkManager.execute(request: GetStepsRequest(uid: uid, startDate: startDateInt, endDate: endDateInt) { response in
            completion(handleResponse(response: response))
        })
    }
    
    class func getStepsForPeriod(uid:Int,startDate:Date, endDate:Date, completion:@escaping ( _ result:
        (requestSuccess:Bool, databaseSaved:Bool))->Void){
        let startDateInt = Int(startDate.beginningOfDay.timeIntervalSince1970)
        let endDateInt = Int(endDate.endOfDay.timeIntervalSince1970)
        NetworkManager.execute(request: GetStepsRequest(uid: uid, startDate: startDateInt, endDate: endDateInt) { response in
            completion(handleResponse(response: response))
        })
    }
    
    private class func handleResponse(response:DataResponse<Any>) -> (requestSuccess:Bool,databaseSaved:Bool){
        switch response.result {
        case .success(let data):
            let json = JSON(data)
            let status:Int = json["status"].intValue
            if status > 0{
                let steps = json["steps"].arrayValue
                var successSynced = true
                for (_,value) in steps.enumerated() {
                    let stepsDict = value.dictionaryValue
                    let dateString = stepsDict["date"]?.dictionaryValue["date"]?.stringValue
                    let stepsString = stepsDict["steps"]?.stringValue
                    let cid:Int = stepsDict["id"]!.intValue
                    
                    let dateArray = dateString?.components(separatedBy: " ")
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    let date = formatter.date(from: dateArray![0])
                    let dateTimerInterval  = date?.beginningOfDay.timeIntervalSince1970
                    if stepsString != nil {
                        let stepsArray:NSArray = AppTheme.jsonToArray(stepsString!)
                        
                        for (index,value) in stepsArray.enumerated() {
                            var seconds:Int = index*60*60
                            for (index2,value2) in (value as! NSArray).enumerated() {
                                if Int(value2 as! NSNumber)>0 {
                                    seconds += (index2*5)*60
                                    let queryArray:NSArray = UserSteps.getCriteria("WHERE date = \(Double(dateTimerInterval!+Double(seconds)))")
                                    if queryArray.count == 0 {
                                        let steps:UserSteps = UserSteps(keyDict: ["id":0, "cid":cid, "steps":Int(value2 as! NSNumber), "distance": "\(0)","date":Double(dateTimerInterval!+Double(seconds)),"syncnext":true])
                                        steps.add({ (id, completion) in
                                            if successSynced {
                                                successSynced = completion!
                                            }
                                        })
                                    }else{
                                        for (_,value3) in queryArray.enumerated() {
                                            let steps:UserSteps = value3 as! UserSteps
                                            steps.steps = Int(value2 as! NSNumber)
                                            steps.cid = cid
                                            let dbUpdateStatus = steps.update()
                                            if successSynced {
                                                successSynced = dbUpdateStatus
                                            }
                                        }
                                    }
                                    
                                }
                            }
                            
                        }
                    }
                    
                }
                return (true, successSynced)
            }
            return (false, false)
        case .failure( _):
            return (false, false)
        }
        return (false, false)
    }
}
