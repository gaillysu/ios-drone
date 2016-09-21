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
    
    class  func getRequest(_ url: String, uid:String, start_date:String, end_date:String, completion:@escaping (_ result:NSDictionary) -> Void){
        let URL:String = url+"/"+uid+"?token=ZQpFYPBMqFbUQq8E99FztS2x6yQ2v1Ei"+"&start_date="+start_date+"&end_date="+end_date
        Alamofire.request(URL, method: .get, parameters: nil, encoding: JSONEncoding.default)
            .authenticate(user: "apps", password: "med_app_development")
            .responseJSON { response in
                let dictionary:NSDictionary = NSKeyedUnarchiver.unarchiveObject(with: response.data!)! as! NSDictionary
                    completion(dictionary)
        }
    }
    
    func getClickTodayServiceSteps(_ startDate:Date,completion:@escaping (_ result:Bool) -> Void) {
        let start:Date = startDate.beginningOfDay
        let end:Date = startDate.endOfDay
        
        let profileArray:NSArray = UserProfile.getAll()
        let profile:UserProfile = profileArray.object(at: 0) as! UserProfile
        
        //Download data selected days recently
        DownloadStepsRequest.getRequest("http://drone.karljohnchow.com/steps/user", uid: "\(profile.id)", start_date: "\(Int(start.timeIntervalSince1970))", end_date: "\(Int(end.timeIntervalSince1970))", completion: { (result) in
            XCGLogger.default.debug("getJSON: \(result)")
            let json = JSON(result)
            let status:Int = json["status"].intValue
            if status>0 {
                let stepsArray = json["steps"].arrayValue
                self.savedServiceDataToLocalDatabase(stepsArray)
                completion(true)
            }else{
                completion(false)
            }
        })
    }
    
    /**
     Download data 30 days recently
     
     - parameter startDateWeek: start date
     */
    func getServiceSteps(_ startDateWeek:Date) {
        let startDate:Date = startDateWeek.beginningOfDay
        //Download data 30 days recently
        let totalOfDay = Int(((Date().endOfDay.timeIntervalSince1970+1)-startDate.timeIntervalSince1970)/86400)
        
        let profileArray:NSArray = UserProfile.getAll()
        let profile:UserProfile = profileArray.object(at: 0) as! UserProfile
        
        //create steps network global queue
        let queue:DispatchQueue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)
        let group = DispatchGroup()
        
        //Download data 30 days recently
        for index:Int in 0..<Int(totalOfDay/5) {
            queue.async(group: group, execute: {
                let start:Int = Int(startDate.timeIntervalSince1970)+Int((index*5)*86400)
                let end:Int = Int(startDate.timeIntervalSince1970)+Int((index*5)*86400+(5*86400))
                //XCGLogger.debug("startDate: \(start),endtDate:\(end)")
                DownloadStepsRequest.getRequest("http://drone.karljohnchow.com/steps/user", uid: "\(profile.id)", start_date: "\(start)", end_date: "\(end)", completion: { (result) in
                    XCGLogger.default.debug("getJSON: \(result)")
                    let json = JSON(result)
                    let status:Int = json["status"].intValue
                    if status>0 {
                        let stepsArray = json["steps"].arrayValue
                        self.savedServiceDataToLocalDatabase(stepsArray)
                    }
                })
            })
        }
        
        group.notify(queue: queue, execute: {
            XCGLogger.default.debug("create steps completed")
        })
    }
    
    func savedServiceDataToLocalDatabase(_ array:[JSON]) {
        for (_,value) in array.enumerated() {
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
                                    
                                })
                            }else{
                                for (_,value3) in queryArray.enumerated() {
                                    let steps:UserSteps = value3 as! UserSteps
                                    steps.steps = Int(value2 as! NSNumber)
                                    steps.cid = cid
                                    _ = steps.update()
                                }
                            }
                            
                        }
                    }
                    
                }
            }
            
        }
    }
}
