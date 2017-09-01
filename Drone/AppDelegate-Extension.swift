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
            sendRequest(SetSystemConfig(configtype: .compassTimeout, autoOnDuration: 15))
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
    
    func setStopwatch(){
        sendRequest(SetAppConfigRequest(appid: .stopwatch, enabled: DTUserDefaults.stopwatchEnabled))
    }
    
    func setTimer(){
        sendRequest(SetAppConfigRequest(appid: .timer, enabled: DTUserDefaults.timerEnabled))
    }
    
    func setCompass(){
        sendRequest(SetAppConfigRequest(appid: .compass, enabled: DTUserDefaults.compassEnabled))
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
        sendRequest(SetAppConfigRequest(appid: .worldClock, state: .on))
        sendRequest(SetAppConfigRequest(appid: .activityTracking, state: .on))
        sendRequest(SetAppConfigRequest(appid: .weather, state: .on))
        setTimeFormat()
        if AppTheme.hasGearbox(){
            setCompass()
            setTimer()
            setStopwatch()
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
    
    func setWorldClock() {
        let cities = City.findAll()
        var worldClocks = City.worldClockCities
        if let homeCityIndex = cities.index(where: { $0.id == DTUserDefaults.homeTimeId }) {
            worldClocks.insert(cities[homeCityIndex], at: 0)
        }
        
        var convertedWorldClockArray:[(cityName:String,gmtOffset:Float)] = []
        for city:City in worldClocks {
            if let timezone = city.timezone{
                convertedWorldClockArray.append((city.name,Float(timezone.getOffsetFromUTC()/60)))
            }
        }
        
        sendRequest(SetWorldClockRequest(worldClockArray: convertedWorldClockArray))
        if let location = LocationManager.manager.currentLocation {
            self.setGPSLocalWeather(location: location)
        }else {
            self.setWeather(cityname: DTUserDefaults.lastSyncedWeatherCity)
        }
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
        let dayTime:TimeInterval = Date(year: dayDate.year, month: dayDate.month, day: dayDate.day, hour: 0, minute: 0, second: 0).timeIntervalSince1970
        let query:String = String(format: "date > %f AND date < %f", dayTime ,dayTime+86400)
        let dayStepsArray = UserSteps.getFilter(query)
        var daySteps:Int = 0
        for steps in dayStepsArray {
            let userSteps:UserSteps = steps as! UserSteps
            daySteps = daySteps+userSteps.steps
        }
        if daySteps>0 {
            let resetModel = DTUserDefaults.resetCache()
            if resetModel.resetState && (Date(timeIntervalSince1970: resetModel.resetDate).beginningOfDay == Date().beginningOfDay){
                sendRequest(SetStepsToWatchReuqest(steps: daySteps))
                DTUserDefaults.setStepsToWatchCache(steps: daySteps, date: Date().timeIntervalSince1970)
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
    
    
    /// 根据城市名设置手表天气
    ///
    /// - Parameter cityname: 根据城市名来查询本地城市列表后再设置手表天气
    func setWeather(cityname:String?) {
        var cityArray:[City] = DataBaseManager.manager.getCitySelected()
        DTUserDefaults.lastSyncedWeatherDate = Date()
        let language = DTUserDefaults.localLanguage
        if let name = cityname {
            var transformCity = name
            if language.contains("zh-Hans") || language.contains("zh-Hant") {
                transformCity = transformCity.chineseTransform()
            }
            
            let queryCityObject = City.getFilter("name CONTAINS[c] '\(transformCity)'")
            if queryCityObject.count>0 {
                let city = queryCityObject.last as! City
                cityArray.append(city)
            }
        }
        
        var weatherArray:[WeatherLocationModel] = []
        for (index,city) in cityArray.reversed().enumerated() {
            let cityid:UInt8 = UInt8(index+10)
            let model:WeatherLocationModel = WeatherLocationModel(id: cityid, city: city)
            weatherArray.append(model)
        }
        
        if weatherArray.count>0 {
            let setWeatherRequest:SetWeatherLocationsRequest = SetWeatherLocationsRequest(entries: weatherArray)
            sendRequest(setWeatherRequest)
            for model in weatherArray {
                WeatherNetworkApiManager.manager.getWeatherInfo(coordinate:(model.title, latitude: model.latitude, longitude: model.longitude), id: Int(model.id)) { (cityid, temp, icon) in
                    let updateModel:WeatherUpdateModel = WeatherUpdateModel(id: UInt8(cityid), temp: temp, statusIcon: WeatherNetworkApiManager.manager.getWeatherStatusCode(icon: icon))
                    
                    let updateWeatherRequest:UpdateWeatherInfoRequest = UpdateWeatherInfoRequest(entries: [updateModel])
                    self.sendRequest(updateWeatherRequest)
                }
            }
        }
    }
    
    
    /// 根据城市经纬度设置天气
    ///
    /// - Parameter cityObject: 定位城市的位置信息
    func setWeather(cityObject:(cityname:String,longitude:Double,latitude:Double)) {
        var cityArray:[City] = DataBaseManager.manager.getCitySelected()
        DTUserDefaults.lastSyncedWeatherDate = Date()
        let language = DTUserDefaults.localLanguage
        var transformCity = cityObject.cityname
        if language.contains("zh-Hans") || language.contains("zh-Hant") {
            transformCity = transformCity.chineseTransform()
        }
        
        let city = City()
        city.name = transformCity
        city.lng = cityObject.longitude
        city.lat = cityObject.latitude
        cityArray.append(city)
        
        setWeatherRequest(cityArray: cityArray)
    }
    
    func setWeatherRequest(cityArray:[City]) {
        var weatherArray:[WeatherLocationModel] = []
        for (index,city) in cityArray.reversed().enumerated() {
            let cityid:UInt8 = UInt8(index+10)
            let model:WeatherLocationModel = WeatherLocationModel(id: cityid, city: city)
            weatherArray.append(model)
        }
        
        if weatherArray.count>0 {
            let setWeatherRequest:SetWeatherLocationsRequest = SetWeatherLocationsRequest(entries: weatherArray)
            sendRequest(setWeatherRequest)
            
            for model in weatherArray {
                let coordinateLatitude = model.latitude.roundTo(8)
                let coordinateLongitude = model.longitude.roundTo(8)
                WeatherNetworkApiManager.manager.getWeatherInfo(coordinate:(model.title, latitude: coordinateLatitude, longitude: coordinateLongitude), id: Int(model.id)) { (cityid, temp, icon) in
                    let updateModel:WeatherUpdateModel = WeatherUpdateModel(id: UInt8(cityid), temp: temp, statusIcon: WeatherNetworkApiManager.manager.getWeatherStatusCode(icon: icon))
                    self.sendRequest(UpdateWeatherInfoRequest(entries: [updateModel]))
                }
            }
        }
        
    }
    
    func setGPSLocalWeather(location:CLLocation) {
        CLGeocoder().reverseGeocodeLocationInfo(location: location) {(locationInfo, error) in
            if Date().timeIntervalSince1970-DTUserDefaults.lastSyncedWeatherDate.timeIntervalSince1970 > syncWeatherInterval {
                DTUserDefaults.lastSyncedWeatherCity = locationInfo.cityName
                self.setWeather(cityObject: ("Local Weather", location.coordinate.longitude, location.coordinate.latitude))
            }
        }
    }
    
    func startLocation() {
        LocationManager.manager.startLocation()
        LocationManager.manager.didUpdateLocations = { location in
            if Date().timeIntervalSince1970-DTUserDefaults.lastSyncedWeatherDate.timeIntervalSince1970 > syncWeatherInterval  || self.forcedWeatherSync{
                if let location = LocationManager.manager.currentLocation{
                    self.forcedWeatherSync = false
                    self.setGPSLocalWeather(location: location)
                }
            }
        }
    }
}
