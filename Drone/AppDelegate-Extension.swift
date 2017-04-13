//
//  AppDelegate-Extension.swift
//  Nevo
//
//  Created by leiyuncun on 16/9/8.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import Foundation

import SwiftEventBus
import SwiftyJSON

// MARK: - LAUNCH LOGIC
extension AppDelegate {
    
    // MARK: -AppDelegate SET Function
    func readsystemStatus() {
        sendRequest(GetSystemStatus())
    }
    
    func setSystemConfig() {
        sendRequest(SetSystemConfig(autoStart:  Date().timeIntervalSince1970, autoEnd: Date.tomorrow().timeIntervalSince1970, configtype: SystemConfigID.clockFormat))
        sendRequest(SetSystemConfig(autoStart:  Date().timeIntervalSince1970, autoEnd: Date.tomorrow().timeIntervalSince1970, configtype: SystemConfigID.enabled))
        sendRequest(SetSystemConfig(autoStart:  Date().timeIntervalSince1970, autoEnd: Date.tomorrow().timeIntervalSince1970, configtype: SystemConfigID.sleepConfig))
        sendRequest(SetSystemConfig(autoStart:  Date().timeIntervalSince1970, autoEnd: Date.tomorrow().timeIntervalSince1970, configtype: SystemConfigID.compassAutoOnDuration))
        sendRequest(SetSystemConfig(autoStart:  Date().timeIntervalSince1970, autoEnd: Date.tomorrow().timeIntervalSince1970, configtype: SystemConfigID.topKeyCustomization))
    }
    
    func setRTC() {
        sendRequest(SetRTCRequest())
    }
    
    func setAppConfig() {
        sendRequest(SetAppConfigRequest(appid: ApplicationID.WorldClock, state: AppState.on))
        sendRequest(SetAppConfigRequest(appid: ApplicationID.ActivityTracking, state: AppState.on))
    }
    
    func setGoal(_ goal:Goal?) {
        if goal == nil {
            let goalArray = UserGoal.getAll()
            if goalArray.count>0 {
                let goal:UserGoal = goalArray.first as! UserGoal
                self.setGoal(NumberOfStepsGoal(steps: goal.goalSteps))
            }else{
                self.setGoal(NumberOfStepsGoal(intensity: GoalIntensity.low))
            }
        }else{
            sendRequest(SetGoalRequest(goal: goal!))
        }
    }
    
    func setUserProfile() {
        let profileArray = UserProfile.getAll()
        if profileArray.count>0 {
            let profile:UserProfile = profileArray.first as! UserProfile
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
        let userDevice = UserDevice.getAll()
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
        self.getMconnectionController()?.connectNew()
    }
    
    func setStepsToWatch() {
        let dayDate:Date = Date()
        let dayTime:TimeInterval = Date.date(year: dayDate.year, month: dayDate.month, day: dayDate.day, hour: 0, minute: 0, second: 0).timeIntervalSince1970
        let query:String = String(format: "date > %f AND date < %f", dayTime ,dayTime+86400)
        let dayStepsArray = UserSteps.getFilter(query)
        var daySteps:Int = 0
        for steps in dayStepsArray {
            let userSteps:UserSteps = steps as! UserSteps
            daySteps = daySteps+userSteps.steps
        }
        
        if daySteps>0 {
            if let unpackedData = AppTheme.LoadKeyedArchiverName(RESET_STATE) {
                let stateArray = JSON(unpackedData).dictionaryValue
                if stateArray.count>0 {
                    let state:Bool = stateArray[RESET_STATE]!.boolValue
                    print(stateArray)
                    if  let obj = stateArray[RESET_STATE_DATE] {
                        let date:Date = Date(timeIntervalSince1970: obj.doubleValue)
                        if state && (date.beginningOfDay == Date().beginningOfDay){
                            sendRequest(SetStepsToWatchReuqest(steps: daySteps))
                            _ = AppTheme.KeyedArchiverName(IS_SEND_0X30_COMMAND, andObject: [IS_SEND_0X30_COMMAND:true,"steps":"\(daySteps)","date":Date()])
                        }
                    }else{
                        if state {
                            sendRequest(SetStepsToWatchReuqest(steps: daySteps))
                            _ = AppTheme.KeyedArchiverName(IS_SEND_0X30_COMMAND, andObject: [IS_SEND_0X30_COMMAND:true,"steps":"\(daySteps)","date":Date()])
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
            SyncQueue.sharedInstance.post( { (Void) -> (Void) in
                self.getMconnectionController()?.sendRequest(r)
            } )
        }
    }
}
