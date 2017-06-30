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
        sendRequest(SetSystemConfig(configtype: .enabled, isAvailable: .enabled))
        sendRequest(SetSystemConfig(configtype: .clockFormat, format: .format24h))
        sendRequest(SetSystemConfig(autoStart: Date().timeIntervalSince1970, autoEnd: Date.tomorrow().timeIntervalSince1970, configtype: .sleepConfig, mode: .auto))
     }
    
    func setCompassAutoMotionDetection(){
        if let obj = Compass.getAll().first, let compass = obj as? Compass{
            sendRequest(SetSystemConfig(configtype: .compassAutoMotionDetection, autoOnDuration: compass.autoMotionDetection))
        }else{
            sendRequest(SetSystemConfig(configtype: .compassAutoMotionDetection, autoOnDuration: 1))
        }
    }
    
    func setCompassTimeout(){
        if let obj = Compass.getAll().first, let compass = obj as? Compass{
            sendRequest(SetSystemConfig(configtype: .compassTimeout, autoOnDuration: compass.screenTimeout))
        }else{
            sendRequest(SetSystemConfig(configtype: .compassTimeout, autoOnDuration: 20))
        }
    }
    
    func startCompassCalibration(){
        sendRequest(StartSystemSettingRequest(compass: .startCompassCalibration))
    }
    func stopCompassCalibration(){
        sendRequest(StartSystemSettingRequest(compass: .stopCompassCalibration))
    }
    
    func setTopKeyCustomization(){
        if DTUserDefaults.topKeySelection < 0{
            sendRequest(SetSystemConfig(topKeyConfig: .defaultCase))
        }else{
            sendRequest(SetSystemConfig(topKeyConfig: SetSystemConfig.TopKeyConfiguration(rawValue: UInt8(DTUserDefaults.topKeySelection))!))
        }
        
    }
    
    func setAnalogTime(forceCurrentTime:Bool){
        if DTUserDefaults.syncAnalogTime {
            if DTUserDefaults.syncLocalTime || forceCurrentTime{
                sendRequest(SetSystemConfig(analogHandsConfig: .currentTime))
            } else{
                sendRequest(SetSystemConfig(analogHandsConfig: .worldTimeFirst))
            }
        }
    }
    
    // 1 = 24 hour, 0 = pussy shit
    func setTimeFormat(){
        sendRequest(SetSystemConfig(configtype: .clockFormat, format: DTUserDefaults.hourFormat == 0 ? .format12h : .format24h))
    }
    
    func startCalibrateHands(){
        sendRequest(StartSystemSettingRequest(analogMovement: .startHandsMode))
    }
    
    func stopCalibrateHands(){
        sendRequest(StartSystemSettingRequest(analogMovement: .exitHandsMode))
    }
    
    func calibrateHands(operation:SettingAnalogMovementOperation){
        sendRequest(StartSystemSettingRequest(analogMovement: operation))
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
        if DTUserDefaults.compassState {
            sendRequest(SetAppConfigRequest(appid: AppConfigApplicationID.compass, state: AppConfigAppState.on))
        }else{
            sendRequest(SetAppConfigRequest(appid: AppConfigApplicationID.compass, state: AppConfigAppState.off))
        }
        
    }
    
    func setGoal() {
            let goalArray = UserGoal.getAll()
            if goalArray.count>0 {
                let goal:UserGoal = goalArray.first as! UserGoal
                sendRequest(SetGoalRequest(goal: goal))
            }else{
                sendRequest(SetGoalRequest(steps: 10000))
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
        self.setWeather(cityname: DTUserDefaults.lastSyncedWeatherCity)
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
    
    func stopNavigation() {
        let navigation = UrbanNavigationRequest()
        self.sendRequest(navigation)
    }
    
    func startNavigation(name:String) {
        guard LocationManager.manager.currentLocation != nil else {
            return
        }
        let latitude:Int = Int(-LocationManager.manager.currentLocation!.coordinate.latitude*1000000)
        let longitude:Int = Int(LocationManager.manager.currentLocation!.coordinate.longitude*1000000)
        let navigation = UrbanNavigationRequest(latitude: latitude, longitude: longitude, mName: name)
        self.sendRequest(navigation)
    }
    
    func updateNavigation(distance:Int) {
        guard LocationManager.manager.currentLocation != nil else {
            return
        }
        let latitude:Int = Int(LocationManager.manager.currentLocation!.coordinate.latitude*1000000)
        let longitude:Int = Int(LocationManager.manager.currentLocation!.coordinate.longitude*1000000)
        let navigation = UrbanNavigationRequest(latitude: latitude, longitude: longitude, mDistance: distance)
        self.sendRequest(navigation)
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
    func  getFirmwareVersion() -> String{
        return isConnected() ? self.getMconnectionController()!.getFirmwareVersion() : "0"
    }
    
    func  getSoftwareVersion() -> String{
        return isConnected() ? self.getMconnectionController()!.getSoftwareVersion() : "0"
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
    
    func setWeather(cityname:String?) {
        var cityArray:[City] = DataBaseManager.manager.getCitySelected()
        if let name = cityname {
            DTUserDefaults.lastSyncedWeatherDate = Date()
            let language = DTUserDefaults.localLanguage
            var transformCity = name
            if language.contains("zh-Hans") || language.contains("zh-Hant") {
                transformCity = name.chineseTransform()
            }
            
            let cityObject = City.getFilter("name CONTAINS[c] '\(transformCity)'")
            var city:City = City()
            if cityObject.count>0 {
                city = cityObject.last as! City
            }else{
                city.name = name
            }
            cityArray.append(city)
        }
        
        var weatherArray:[WeatherLocationModel] = []
        for (index,city) in cityArray.reversed().enumerated() {
            let cityid:UInt8 = UInt8(index+10)
            let model:WeatherLocationModel = WeatherLocationModel(id: cityid, titleString: city.name)
            weatherArray.append(model)
        }
        
        if weatherArray.count>0 {
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
    
    func setGPSLocalWeather(location:CLLocation) {
        CLGeocoder().reverseGeocodeLocationInfo(location: location) {(locationInfo, error) in
            if Date().timeIntervalSince1970-DTUserDefaults.lastSyncedWeatherDate.timeIntervalSince1970 > syncWeatherInterval {
                DTUserDefaults.lastSyncedWeatherCity = locationInfo.cityName
                self.setWeather(cityname: locationInfo.cityName)
            } 
        }
    }
    
    func startLocation() {
        LocationManager.manager.startLocation()
        
        LocationManager.manager.didUpdateLocations = { location in
            let locationArray = location as [CLLocation]
            /**
             sync every 30 min weather data
             */
            if Date().timeIntervalSince1970-DTUserDefaults.lastSyncedWeatherDate.timeIntervalSince1970 > syncWeatherInterval {
                if let location = locationArray.last {
                    self.setGPSLocalWeather(location: location)
                }
            }
        }
    }
    
}
