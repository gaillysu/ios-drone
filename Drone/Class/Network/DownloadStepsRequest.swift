//
//  DownloadStepsRequest.swift
//  Drone
//
//  Created by leiyuncun on 16/6/7.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit
import Alamofire
import XCGLogger
import SwiftyJSON


let stepsDownload = DownloadStepsRequest()

class DownloadStepsRequest: NSObject {
    
    class  func getRequest(url: String, uid:String, start_date:String, end_date:String, completion:(result:NSDictionary) -> Void){
        let URL:String = url+"/"+uid+"?token=ZQpFYPBMqFbUQq8E99FztS2x6yQ2v1Ei"+"&start_date="+start_date+"&end_date="+end_date
        Alamofire.request(Method.GET, URL, parameters: nil, encoding:ParameterEncoding.JSON, headers: ["Authorization": "Basic YXBwczptZWRfYXBwX2RldmVsb3BtZW50","Content-Type":"application/json"]).responseJSON { (response) -> Void in
            if response.result.isSuccess {
                //XCGLogger.defaultInstance().debug("getJSON: \(response.result.value)")
                completion(result: response.result.value as! NSDictionary)
            }else if (response.result.isFailure){
                if (response.result.value == nil) {
                    completion(result: NSDictionary(dictionary: ["error" : "request error","status":-1]))
                }else{
                    completion(result: response.result.value as! NSDictionary)
                }
            }
        }
    }
    
    func getClickTodayServiceSteps(startDate:NSDate,completion:(result:Bool) -> Void) {
        let start:NSDate = startDate.beginningOfDay
        let end:NSDate = startDate.endOfDay
        
        let profileArray:NSArray = UserProfile.getAll()
        let profile:UserProfile = profileArray.objectAtIndex(0) as! UserProfile
        
        //Download data selected days recently
        DownloadStepsRequest.getRequest("http://drone.karljohnchow.com/steps/user", uid: "\(profile.id)", start_date: "\(Int(start.timeIntervalSince1970))", end_date: "\(Int(end.timeIntervalSince1970))", completion: { (result) in
            XCGLogger.defaultInstance().debug("getJSON: \(result)")
            let json = JSON(result)
            let status:Int = json["status"].intValue
            if status>0 {
                let stepsArray = json["steps"].arrayValue
                self.savedServiceDataToLocalDatabase(stepsArray)
                completion(result: true)
            }else{
                completion(result: false)
            }
        })
    }
    
    /**
     Download data 30 days recently
     
     - parameter startDateWeek: start date
     */
    func getServiceSteps(startDateWeek:NSDate) {
        let startDate:NSDate = startDateWeek.beginningOfDay
        //Download data 30 days recently
        let totalOfDay = Int(((NSDate().endOfDay.timeIntervalSince1970+1)-startDate.timeIntervalSince1970)/86400)
        
        let profileArray:NSArray = UserProfile.getAll()
        let profile:UserProfile = profileArray.objectAtIndex(0) as! UserProfile
        
        //create steps network global queue
        let queue:dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        let group = dispatch_group_create()
        
        //Download data 30 days recently
        for index:Int in 0..<Int(totalOfDay/5) {
            dispatch_group_async(group, queue, {
                let start:Int = Int(startDate.timeIntervalSince1970)+Int((index*5)*86400)
                let end:Int = Int(startDate.timeIntervalSince1970)+Int((index*5)*86400+(5*86400))
                //XCGLogger.defaultInstance().debug("startDate: \(start),endtDate:\(end)")
                DownloadStepsRequest.getRequest("http://drone.karljohnchow.com/steps/user", uid: "\(profile.id)", start_date: "\(start)", end_date: "\(end)", completion: { (result) in
                    XCGLogger.defaultInstance().debug("getJSON: \(result)")
                    let json = JSON(result)
                    let status:Int = json["status"].intValue
                    if status>0 {
                        let stepsArray = json["steps"].arrayValue
                        self.savedServiceDataToLocalDatabase(stepsArray)
                    }
                })
            })
        }
        
        dispatch_group_notify(group, queue, {
            XCGLogger.defaultInstance().debug("create steps completed")
        })
    }
    
    func savedServiceDataToLocalDatabase(array:[JSON]) {
        for (index,value) in array.enumerate() {
            let stepsDict = value.dictionaryValue
            let dateString = stepsDict["date"]?.dictionaryValue["date"]?.stringValue
            let stepsString = stepsDict["steps"]?.stringValue
            let cid:Int = stepsDict["id"]!.intValue
            
            let dateArray = dateString?.componentsSeparatedByString(" ")
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let date = formatter.dateFromString(dateArray![0])
            let dateTimerInterval  = date?.beginningOfDay.timeIntervalSince1970
            let stepsArray:NSArray = AppTheme.jsonToArray(stepsString!)
            
            for (index,value) in stepsArray.enumerate() {
                var seconds:Int = index*60*60
                for (index2,value2) in (value as! NSArray).enumerate() {
                    if Int(value2 as! NSNumber)>0 {
                        seconds += (index2*5)*60
                        let queryArray:NSArray = UserSteps.getCriteria("WHERE date = \(Double(dateTimerInterval!+Double(seconds)))")
                        if queryArray.count == 0 {
                            let steps:UserSteps = UserSteps(keyDict: ["id":0, "cid":cid, "steps":Int(value2 as! NSNumber), "distance": "\(0)","date":Double(dateTimerInterval!+Double(seconds)),"syncnext":true])
                            steps.add({ (id, completion) in
                               
                            })
                        }else{
                            for (index,value) in queryArray.enumerate() {
                                let steps:UserSteps = value as! UserSteps
                                steps.steps = Int(value2 as! NSNumber)
                                steps.cid = cid
                                steps.update()
                            }
                        }
                        
                    }
                }
                
            }
        }
    }
}
