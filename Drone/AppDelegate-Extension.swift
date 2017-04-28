//
//  AppDelegate-Extension.swift
//  Nevo
//
//  Created by leiyuncun on 16/9/8.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftEventBus
import SwiftyJSON

// MARK: - LAUNCH LOGIC
extension AppDelegate {
    
    // MARK: -AppDelegate SET Function
    func readsystemStatus() {
        sendRequest(GetSystemStatus())
    }
    
    func setSystemConfig() {
        sendRequest(SetSystemConfig(configtype: SystemConfigID.enabled, isAvailable: .enabled))
        sendRequest(SetSystemConfig(configtype: SystemConfigID.clockFormat, format: .format24h))
        sendRequest(SetSystemConfig(autoStart: Date().timeIntervalSince1970, autoEnd: Date.tomorrow().timeIntervalSince1970, configtype: SystemConfigID.sleepConfig, mode: .auto))
        sendRequest(SetSystemConfig(configtype: SystemConfigID.topKeyCustomization, isAvailable: .enabled))
        setAnalogTime()
    }
    
    func setCompassAutoMinutes(){
        if let obj = Compass.getAll().first, let compass = obj as? Compass{
            sendRequest(SetSystemConfig(configtype: SystemConfigID.compassAutoOnDuration, autoOnDuration: compass.activeTime))
        }else{
            sendRequest(SetSystemConfig(configtype: SystemConfigID.compassAutoOnDuration, autoOnDuration: 1))
        }
    }
    
    func setAnalogTime(){
        if DTUserDefaults.syncAnalogTime {
            if DTUserDefaults.syncLocalTime {
                sendRequest(SetSystemConfig(analogHandsConfig: .CurrentTime))
            } else{
                sendRequest(SetSystemConfig(analogHandsConfig: .WorldTimeFirst))
            }
        }
    }
    
    func startCalibrateHands(){
        sendRequest(StartSystemSettingRequest(id: .analogMovement, operation: .startHandsMode))
    }
    
    func stopCalibrateHands(){
        sendRequest(StartSystemSettingRequest(id: .analogMovement, operation: .exitHandsMode))
    }
    
    func calibrateHands(operation:SettingAnalogMovementOperation){
        sendRequest(StartSystemSettingRequest(id: .analogMovement, operation: operation))
    }
    
    func setRTC(force:Bool) {
        if DTUserDefaults.syncAnalogTime || force {
            sendRequest(SetRTCRequest())
        }
    }
    
    func subscribeToSignificantTimeChange(on:Bool){
        if on{
            // Get local time and sync home time
            NotificationCenter.default.addObserver(self, selector: #selector(significantTimeChanged), name: NSNotification.Name.NSSystemTimeZoneDidChange, object: nil)
        }else{
            // Get Home time and sync home time
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSSystemTimeZoneDidChange, object: nil)
        }
    }
    
    func significantTimeChanged(){
        self.setRTC(force: false)
    }
    
    func setAppConfig() {
        sendRequest(SetAppConfigRequest(appid: AppConfigApplicationID.worldClock, state: AppConfigAppState.on))
        sendRequest(SetAppConfigRequest(appid: AppConfigApplicationID.activityTracking, state: AppConfigAppState.on))
        sendRequest(SetAppConfigRequest(appid: AppConfigApplicationID.weather, state: AppConfigAppState.on))
        sendRequest(SetAppConfigRequest(appid: AppConfigApplicationID.compass, enabled: DTUserDefaults.compassState))
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
        let userDevice = DataBaseManager.manager.getAllDevice()
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
            if let unpackedData = AppTheme.LoadKeyedArchiverName(AppDelegate.RESET_STATE) {
                let resetModel = unpackedData as! ResetCacheModel
                let state:Bool = resetModel.resetState!
                if  let obj = resetModel.resetDate {
                    let date:Date = Date(timeIntervalSince1970: obj)
                    if state && (date.beginningOfDay == Date().beginningOfDay){
                        sendRequest(SetStepsToWatchReuqest(steps: daySteps))
                        let cacheSendSteps:SendStepsToWatchCache = SendStepsToWatchCache(sendSteps: daySteps, sendDate: Date().timeIntervalSince1970)
                        _ = AppTheme.KeyedArchiverName(IS_SEND_0X30_COMMAND, andObject: cacheSendSteps)
                    }
                }else{
                    if state {
                        sendRequest(SetStepsToWatchReuqest(steps: daySteps))
                        let cacheSendSteps:SendStepsToWatchCache = SendStepsToWatchCache(sendSteps: daySteps, sendDate: Date().timeIntervalSince1970)
                        _ = AppTheme.KeyedArchiverName(IS_SEND_0X30_COMMAND, andObject: cacheSendSteps)
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
    
    func setWeather() {
        DTUserDefaults.syncWeatherDate = Date()
        var cityArray:[City] = DataBaseManager.manager.getCitySelected()
        let timeZoneNameData = DateFormatter().localCityName()
        if timeZoneNameData.isEmpty {
            let city:City = City()
            city.name = timeZoneNameData
            cityArray.append(city)
        }
        
        
        var weatherArray:[WeatherLocationModel] = []
        for (index,city) in cityArray.enumerated() {
            let cityid:UInt8 = UInt8(index+10)
            let model:WeatherLocationModel = WeatherLocationModel(id: cityid, titleString: city.name)
            weatherArray.append(model)
        }
        
        let setWeatherRequest:SetWeatherLocationsRequest = SetWeatherLocationsRequest(entries: weatherArray)
        sendRequest(setWeatherRequest)
        
        for model in weatherArray {
            WeatherNetworkApiManager.manager.getWeatherInfo(regionName: model.getWeatherInfo().title, id: Int(model.getWeatherInfo().id)) { (cityid, temp, code, statusText) in
                let updateModel:WeatherUpdateModel = WeatherUpdateModel(id: UInt8(cityid), temp: temp, statusIcon: WeatherNetworkApiManager.manager.getWeatherStatusCode(code: code))
                let updateWeatherRequest:UpdateWeatherInfoRequest = UpdateWeatherInfoRequest(entries: [updateModel])
                self.sendRequest(updateWeatherRequest)
            }
        }
    }
}
