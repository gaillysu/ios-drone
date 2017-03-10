//
//  AppDelegate-Extension.swift
//  Nevo
//
//  Created by leiyuncun on 16/9/8.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import Foundation
import XCGLogger
import SwiftEventBus

// MARK: - LAUNCH LOGIC
extension AppDelegate {
    
    // MARK: -AppDelegate SET Function
    func readsystemStatus() {
        sendRequest(GetSystemStatus())
    }
    
    func setSystemConfig(_ index:Int) {
        print("Set system config: \(index)")
        sendRequest(SetSystemConfig(autoStart: Date().timeIntervalSince1970, autoEnd: Date.tomorrow().timeIntervalSince1970, index: index))
    }
    
    func setRTC() {
        sendRequest(SetRTCRequest())
    }
    
    func setAppConfig() {
        sendRequest(SetAppConfigRequest())
    }
    
    func setGoal(_ goal:Goal?) {
        if goal == nil {
            let goalArray:NSArray = UserGoal.getAll()
            if goalArray.count>0 {
                let goal:UserGoal = UserGoal.getAll()[0] as! UserGoal
                self.setGoal(NumberOfStepsGoal(steps: goal.goalSteps))
            }else{
                self.setGoal(NumberOfStepsGoal(intensity: GoalIntensity.low))
            }
        }else{
            sendRequest(SetGoalRequest(goal: goal!))
        }
    }
    
    func setUserProfile() {
        let profileArray:NSArray = UserProfile.getAll()
        if profileArray.count>0 {
            //height (CM) X 0.415 ＝ stride length
            let profile:UserProfile = profileArray.object(at: 0) as! UserProfile
            var gender = 1
            if !profile.gender{
                gender = 0
            }
            sendRequest(SetUserProfileRequest(weight: profile.weight*100, height: profile.length, gender: gender, stridelength: Int(Double(profile.length)*0.415)))
        }else{
            sendRequest(SetUserProfileRequest(weight: 6000, height: 175, gender: 1, stridelength: 65))
        }
    }
    
    func setWorldClock(_ cities:[City]) {
        var convertedWorldClockArray:[(cityName:String,gmtOffset:Float)] = []
        for city:City in cities {
            if let timezone = city.timezone{
                convertedWorldClockArray.append((city.name,Float(timezone.getOffsetFromUTC()/60)))
            }
        }
        sendRequest(SetWorldClockRequest(worldClockArray: convertedWorldClockArray))
    }
    
    func startConnect(){
        self.noResponseIndex = 0
        let userDevice:NSArray = UserDevice.getAll()
        if(userDevice.count>0) {
            var deviceAddres:[String] = []
            for device in userDevice {
                let deviceModel:UserDevice = device as! UserDevice;
                deviceAddres.append(deviceModel.identifiers)
            }
            self.getMconnectionController()?.connect(deviceAddres)
        }
    }
    
    func connectNew(){
        self.noResponseIndex = 0
        self.getMconnectionController()?.connectNew()
    }
    
    func setStepsToWatch() {
        let dayDate:Date = Date()
        let dayTime:TimeInterval = Date.date(year: dayDate.year, month: dayDate.month, day: dayDate.day, hour: 0, minute: 0, second: 0).timeIntervalSince1970
        let dayStepsArray:NSArray = UserSteps.getCriteria("WHERE date BETWEEN \(dayTime) AND \(dayTime+86400)") //one hour = 3600s
        var daySteps:Int = 0
        for steps in dayStepsArray {
            let userSteps:UserSteps = steps as! UserSteps
            daySteps = daySteps+userSteps.steps
        }
        
        if daySteps>0 {
            if let unpackedData = AppTheme.LoadKeyedArchiverName(RESET_STATE) {
                if let stateArray:NSArray =  unpackedData as? NSArray{
                    if stateArray.count>0 {
                        let state:[String:Bool] = stateArray[0] as! [String:Bool]
                        let date:Date = (stateArray[1] as! String).dateFromFormat("YYYY/MM/dd")!
                        if state[RESET_STATE]! && (date.beginningOfDay == Date().beginningOfDay){
                            sendRequest(SetStepsToWatchReuqest(steps: daySteps))
                            setupResponseTimer(["index":NSNumber(value: 7 as Int32)])
                            _ = AppTheme.KeyedArchiverName(IS_SEND_0X30_COMMAND, andObject: [IS_SEND_0X30_COMMAND:true,"steps":"\(daySteps)"] as AnyObject)
                        }
                        
                    }
                }
            }
        }
    }
    
    // MARK: -AppDelegate GET Function
    
    func getActivity(){
        sendRequest(GetActivityRequest())
    }
    
    func getGoal(){
        sendRequest(GetStepsGoalRequest())
    }
    
    
    func ReadBatteryLevel() {
        sendRequest(GetBatteryRequest())
    }
    
    // MARK: - ConnectionController protocol
    func  getFirmwareVersion() -> NSString{
        return isConnected() ? self.getMconnectionController()!.getFirmwareVersion() : NSString()
    }
    
    func  getSoftwareVersion() -> NSString{
        return isConnected() ? self.getMconnectionController()!.getSoftwareVersion() : NSString()
    }
    
    func disconnect() {
        self.getMconnectionController()?.disconnect()
    }
    
    func isConnected() -> Bool{
        return self.getMconnectionController()!.isConnected()
    }
    
    func sendRequest(_ r:Request) {
        if(isConnected()){
            self.getMconnectionController()?.sendRequest(r)
        }
    }
}
