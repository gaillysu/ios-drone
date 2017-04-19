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
        sendRequest(SetSystemConfig(configtype: SystemConfigID.clockFormat, format: .format24h))
        sendRequest(SetSystemConfig(configtype: SystemConfigID.enabled, isAvailable: .enabled))
        sendRequest(SetSystemConfig(autoStart: Date().timeIntervalSince1970, autoEnd: Date.tomorrow().timeIntervalSince1970, configtype: SystemConfigID.sleepConfig, mode: .auto))
        sendRequest(SetSystemConfig(configtype: SystemConfigID.compassAutoOnDuration, autoOnDuration: 1))
        sendRequest(SetSystemConfig(configtype: SystemConfigID.topKeyCustomization, isAvailable: .enabled))
    }
    
    func setRTC() {
        sendRequest(SetRTCRequest())
    }
    
    func setAppConfig() {
        sendRequest(SetAppConfigRequest(appid: AppConfigApplicationID.worldClock, state: AppConfigAppState.on))
        sendRequest(SetAppConfigRequest(appid: AppConfigApplicationID.activityTracking, state: AppConfigAppState.on))
        sendRequest(SetAppConfigRequest(appid: AppConfigApplicationID.weather, state: AppConfigAppState.on))
        sendRequest(SetAppConfigRequest(appid: AppConfigApplicationID.compass, state: AppConfigAppState.on))
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
    
    func startLocation() {
        NSLog("AuthorizationStatus:\(LocationManager.instanceLocation.gpsAuthorizationStatus)")
        var syncWeatherDate:Date?
        if LocationManager.instanceLocation.gpsAuthorizationStatus>2 {
            LocationManager.instanceLocation.startLocation()
            LocationManager.instanceLocation.didChangeAuthorization = { status in
                let states:CLAuthorizationStatus = status as CLAuthorizationStatus

            }
            
            LocationManager.instanceLocation.didUpdateLocations = { location in
                let newLocation = location.last! as CLLocation
                debugPrint("Location didUpdateLocations:\(newLocation)")
                if let date = syncWeatherDate {
                    if (Date().timeIntervalSince1970-date.timeIntervalSince1970)>600 {
                        newLocation.reverseGeocodeLocationInfo(completion: { (gecodeInfo, error) in
                            syncWeatherDate = Date()
                        })
                    }
                }else{
                    newLocation.reverseGeocodeLocationInfo(completion: { (gecodeInfo, error) in
                        syncWeatherDate = Date()
                        
                    })
                }
            }
            
            LocationManager.instanceLocation.didFailWithError = { error in
                debugPrint("Location didFailWithError:\(error)")
            }
        }else{
            let banner:MEDBanner = MEDBanner(title: NSLocalizedString("Location Error", comment: ""), subtitle: NSLocalizedString("Drone did not authorization", comment: ""), image: nil, backgroundColor: UIColor.getBaseColor(), didTapBlock: {
                
            })
            banner.show()
        }
    }
    
    func settWeather() {
        let city:[String:UInt8] = ["Shenzhen":12,"New York":13,"Tokyo":14]
        let cityTemp:[String:UInt8] = ["Shenzhen":28,"New York":16,"Tokyo":26]
        let cityCode:[String:Int] = ["Shenzhen":802,"New York":803,"Tokyo":300]
        
        var weatherModel:[WeatherLocationModel] = []
        var updateWeatherModel:[WeatherUpdateModel] = []
        for (key,value) in city {
            let model:WeatherLocationModel = WeatherLocationModel(id: value, titleString: key)
            weatherModel.append(model)
    
            let updateModel:WeatherUpdateModel = WeatherUpdateModel(id: value, temp: Int(cityTemp[key]!), statusIcon: WeatherNetworkApiManager.manager.getWeatherStatusCode(code: cityCode[key]!))
            updateWeatherModel.append(updateModel)
        }
        
        let setWeatherRequest:SetWeatherLocationsRequest = SetWeatherLocationsRequest(entries: weatherModel)
        sendRequest(setWeatherRequest)
        
        let updateWeatherRequest:UpdateWeatherInfoRequest = UpdateWeatherInfoRequest(entries: updateWeatherModel)
        sendRequest(updateWeatherRequest)
    }
}
