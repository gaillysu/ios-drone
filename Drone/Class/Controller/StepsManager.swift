//
//  StepsManager.swift
//  Drone
//
//  Created by Cloud on 2017/2/7.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit
import XCGLogger
import SwiftyJSON
import RealmSwift

class StepsManager: NSObject {
    static let sharedInstance:StepsManager = StepsManager()
    
    fileprivate override init() {
        super.init()
        
    }
    
    func syncLastSevenDaysData() {
        var dayDateArray:[Date] = []
        for index in 0..<7 {
            dayDateArray.append(Date().beginningOfDay-index.day)
        }
        self.syncServiceDayData(dayDateArray)
    }
    
    //Will be no sync of data sync to the server
    func syncServiceDayData(_ dayDateArray:[Date]) {
        
        var dayData:[String:String] = [:]
        var dayTime:[Double] = []
        var cidArray:[Int] = []
        for day:Date in dayDateArray {
            var yVals:[[Double]] = []
            var activeTime:Double = 0
            let dayDate:Date = day
            var cid:Int = 0
            for hour:Int in 0 ..< 24 {
                let dayTime:TimeInterval = Date.date(year: dayDate.year, month: dayDate.month, day: dayDate.day, hour: hour, minute: 0, second: 0).timeIntervalSince1970
                let hours = UserSteps.getFilter("date >= \(dayTime) AND date <= \(dayTime+3600)")//one hour = 3600s
                var hourData:[Double] = [0,0,0,0,0,0,0,0,0,0,0,0]
                var timer:Double = 0
                for userSteps in hours {
                    let hSteps:UserSteps = userSteps as! UserSteps
                    let minutesDate:Date = Date(timeIntervalSince1970: hSteps.date)
                    var k:Int = Int(minutesDate.minute/5)
                    if minutesDate.minute == 0 {
                        k = 0
                    }else{
                        minutesDate.minute%5 == 0 ? (k = Int(minutesDate.minute/5)-1):(k = Int(Double(13)/Double(5)))
                    }
                    
                    if hour == minutesDate.hour {
                        hourData[k] = Double(hSteps.steps)
                    }
                    
                    if hSteps.steps>0 {
                        timer+=5
                    }
                    
                    if cid != hSteps.cid {
                        cid = hSteps.cid
                    }
                    let realm = try! Realm()
                    try! realm.write({ 
                        hSteps.syncnext = true
                    })
                }
                activeTime = activeTime+timer
                yVals.append(hourData);
            }
            
            let dailySteps = AppTheme.toJSONString(yVals as AnyObject!)
            let date:Date = dayDate
            let dateString = date.stringFromFormat("yyyy-MM-dd")
            dayData[dateString] = "\(dailySteps)"
            dayTime.append(activeTime)
            cidArray.append(cid)
        }
        
        var cidIndex:Int = 0
        for (keys,value) in dayData {
            let cid:Int = cidArray[cidIndex]
            if cid>0 {
                self.updateToServerData(cid, key: keys, value: value)
            }else{
                self.createToServerData(keys, value: value)
            }
            cidIndex += 1
        }
        
    }
    
    func updateToServerData(_ cid:Int,key:String,value:String) {
        let userProfle = UserProfile.getAll()
        let profile:UserProfile = userProfle.first as! UserProfile
        
        //create steps network global queue
        let queue:DispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
        let group = DispatchGroup()
        
        StepsNetworkManager.updateSteps(id: cid, uid: profile.id, steps: value, date: key, activeTime: 0) { (updated) in
            if updated {
                XCGLogger.debug("Steps updated in the cloud.")
            } else {
                XCGLogger.debug("Could not update steps in the cloud.")
            }
        }
        
        group.notify(queue: queue, execute: {
            XCGLogger.default.debug("create steps completed")
        })
    }
    
    func createToServerData(_ key:String,value:String) {
        let userProfle = UserProfile.getAll()
        if userProfle.count>0 {
            let profile:UserProfile = userProfle.first as! UserProfile
            //create steps network global queue
            let queue:DispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
            let group = DispatchGroup()
            
            StepsNetworkManager.createSteps(uid: profile.id, steps: value, date: key, activeTime: 0) { (success) in
                if success{
                    XCGLogger.debug("Synced with cloud")
                }else{
                    XCGLogger.debug("Could not sync with cloud")
                }
            }
            
            group.notify(queue: queue, execute: {
                XCGLogger.default.debug("create steps completed")
            })
        }
    }
}
