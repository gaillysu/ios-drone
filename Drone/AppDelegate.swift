//
//  AppDelegate.swift
//  Nevo
//
//  Created by Karl-John Chow on Today
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftEventBus
import Fabric
import Crashlytics
import IQKeyboardManagerSwift
import RealmSwift
import SwiftyJSON
import GoogleMaps
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,ConnectionControllerDelegate {
   
   var window: UIWindow?
   //Let's sync every days
   fileprivate var mConnectionController : ConnectionControllerImpl?
   fileprivate var currentDay:UInt8 = 0
   
   fileprivate var worldclockDatabaseHelper: WorldClockDatabaseHelper?
   
   fileprivate var isNavigation = false
   var forcedWeatherSync = false

   var timer:Timer?
   static let RESET_STATE = "RESET_STATE"
   
   class func getAppDelegate()->AppDelegate {
      return UIApplication.shared.delegate as! AppDelegate
   }
   
   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
      Fabric.with([Crashlytics.self])
      configGoogleMap()
      
      self.startLocation()
      
      _ = DataBaseManager.manager
      _ = NetworkManager.manager
      
      let sandbox:SandboxManager = SandboxManager()
      let _ = sandbox.copyDictFileToSandBox(folderName: "NotificationTypeFile", fileName: "NotificationTypeFile.plist")
      
      mConnectionController = ConnectionControllerImpl()
      mConnectionController?.setDelegate(self)
      
      IQKeyboardManager.sharedManager().enable = true
      
      self.window = UIWindow(frame: UIScreen.main.bounds)
      UINavigationBar.appearance().tintColor = UIColor.getBaseColor()
      let nav:UINavigationController = UINavigationController(rootViewController: SplashScreenViewController())
      nav.isNavigationBarHidden = true
      self.window?.rootViewController = nav
      self.window?.makeKeyAndVisible()
      return true
   }
   
   func applicationDidEnterBackground(_ application: UIApplication) {
      UIApplication.shared.beginBackgroundTask (expirationHandler: { () -> Void in })  
   }
   
   func applicationSignificantTimeChange(_ application: UIApplication) {
      
      print("applicationSignificantTimeChange")
      if (mConnectionController?.isConnected())!{
         watchConfig()
      }else{
         DTUserDefaults.setupKey = true
      }
   }
   
   func configGoogleMap() {
      if let googleMapAppKey = Bundle.googleMapKey {
         GMSServices.provideAPIKey(googleMapAppKey)
         GMSPlacesClient.provideAPIKey(googleMapAppKey)
      }
   }
   
   // MARK: - ConnectionControllerDelegate
   /**
    Called when a packet is received from the device
    */
   func packetReceived(_ packet: RawPacket) {
      
      if(!packet.isLastPacket()) {
         //We just received a full response, so we can safely send the next request
         SyncQueue.sharedInstance.next()
         
         debugPrint("RawPacketImpl :\(Constants.NSData2Bytes(packet.getRawData()))")
         if(packet.getHeader() == GetSystemStatus.HEADER()) {
            let systemStatus:Int = SystemStatusPacket(data: packet.getRawData()).getSystemStatus()
            debugPrint("SystemStatus :\(systemStatus)")
            if(systemStatus == SystemStatus.systemReset.rawValue) {
               //step1 : Set systemconfig next 1
               DTUserDefaults.setupKey = true
               DTUserDefaults.hourFormat = 1
               self.setSystemConfig()
               //Records need to use 0x30
               let cacheModel:ResetCacheModel = ResetCacheModel(reState: true, date: Date().timeIntervalSince1970)
               _ = AppTheme.KeyedArchiverName(AppDelegate.RESET_STATE, andObject: cacheModel)
               
            }else if(systemStatus == SystemStatus.activityDataAvailable.rawValue) {
               self.getActivity()
            }else if(systemStatus == SystemStatus.weatherDataNeeded.rawValue){
               if let location = LocationManager.manager.currentLocation {
                  self.setGPSLocalWeather(location: location)
               }else{
                  forcedWeatherSync = true
                  self.startLocation()
               }
            }else if(systemStatus != SystemStatus.lowMemory.rawValue && systemStatus != SystemStatus.subscribedToNotifications.rawValue) {
               if let date = DTUserDefaults.rtcDate {
                  if (Date().timeIntervalSince1970 - date.timeIntervalSince1970) > 60 {
                     DTUserDefaults.rtcDate = Date()
                     self.watchConfig()
                  }
               }else{
                  DTUserDefaults.rtcDate = Date()
                  self.watchConfig()
               }
            }
         }
         
         if(packet.getHeader() == SystemEventPacket.HEADER()) {
            let eventCommandStatus:Int = SystemEventPacket(data: packet.getRawData()).getSystemEventStatus()
            debugPrint("eventCommandStatus :\(eventCommandStatus)")
            
            if(eventCommandStatus == SystemEventStatus.activityDataAvailable.rawValue) {
               SwiftEventBus.post(SWIFTEVENT_BUS_BEGIN_BIG_SYNCACTIVITY, sender:nil)
               self.getActivity()
            }
            
            if(eventCommandStatus == SystemEventStatus.batteryStatusChanged.rawValue) {
               sendRequest(GetBatteryRequest())
            }
            
            if(eventCommandStatus == SystemEventStatus.weatherDataExpired.rawValue) {
               if let location = LocationManager.manager.currentLocation {
                  self.setGPSLocalWeather(location: location)
               }
            }
            
            
         }
         
         if(packet.getHeader() == OTARequest.HEADER()) {
            SwiftEventBus.post(SWIFTEVENT_OTA_PACKET_RECEIVED, sender:nil)
         }
         
         if(packet.getHeader() == GetStepsGoalRequest.HEADER()) {
            let rawGoalPacket:StepsGoalPacket = StepsGoalPacket(data: packet.getRawData())
            SwiftEventBus.post(SWIFTEVENT_BUS_SMALL_SYNCACTIVITY_DATA, sender:(rawGoalPacket as AnyObject))
         }
         
         if(packet.getHeader() == SetSystemConfig.HEADER()) {
            if (DTUserDefaults.setupKey){
               self.watchConfig()
            }
         }
         
         if(packet.getHeader() == SetStepsToWatchReuqest.HEADER()) {
            let cacheModel:ResetCacheModel = ResetCacheModel(reState: false, date: Date().timeIntervalSince1970)
            _ = AppTheme.KeyedArchiverName(AppDelegate.RESET_STATE, andObject: cacheModel)
         }
         if(packet.getHeader() == GetBatteryRequest.HEADER()) {
            let data:[UInt8] = Constants.NSData2Bytes(packet.getRawData())
            let batteryStatus:Int = Int(data[2])
            let percent:Int = Int(data[3])
            let postBattery:PostBatteryStatus = PostBatteryStatus(state: batteryStatus, percent: percent)
            SwiftEventBus.post(SWIFTEVENT_BUS_BATTERY_STATUS_CHANGED, sender:postBattery)
         }
         
         if(packet.getHeader() == GetStepsGoalRequest.HEADER()) {
            let rawGoalPacket:StepsGoalPacket = StepsGoalPacket(data: packet.getRawData())
            SwiftEventBus.post(SWIFTEVENT_BUS_SMALL_SYNCACTIVITY_DATA, sender:(rawGoalPacket))
            
            if Date().timeIntervalSince1970-DTUserDefaults.lastSyncedWeatherDate.timeIntervalSince1970 > syncWeatherInterval {
               if let location = LocationManager.manager.currentLocation {
                  self.setGPSLocalWeather(location: location)
               }else{
                  forcedWeatherSync = true
                  self.startLocation()
               }
            }
         }
         
         if packet.getHeader() == FindMyPhonePacket.HEADER() {
            let findPhonePacket = FindMyPhonePacket(data: packet.getRawData())
            if findPhonePacket.getFindMyPhoneState() == FindMyPhoneState.enable {
               DTUserDefaults.saveLog(message: "Ping ping", key: "pingpingsound")
               NotificationAlertSoundController.manager.playSound()
            }
         }
         
         if(packet.getHeader() == SetGoalRequest.HEADER()){
            SwiftEventBus.post(SWIFTEVENT_BUS_INITIALIZATION_COMPLETED, sender:nil)
         }
         
         if(packet.getHeader() == GetActivityRequest.HEADER()) {
            let syncStatus:[UInt8] = Constants.NSData2Bytes(packet.getRawData())
            let status:Int = Int(syncStatus[8])
            let activityPacket:ActivityPacket = ActivityPacket(data: packet.getRawData())
            let postData:PostActivityData = PostActivityData(steps: activityPacket.getStepCount(), date: activityPacket.gettimerInterval(), state: status)
            SwiftEventBus.post(SWIFTEVENT_BUS_BIG_SYNCACTIVITY_DATA, sender:postData)
            
            //Download more data
            if(status == ActivityDataStatus.moreData.rawValue) {
               self.getActivity()
            }else{
               SwiftEventBus.post(SWIFTEVENT_BUS_END_BIG_SYNCACTIVITY, sender:nil)
            }
         }
         
      }else{
         SwiftEventBus.post(SWIFTEVENT_BUS_END_BIG_SYNCACTIVITY, sender:nil)
      }
   }
   
   func connectionStateChanged(_ isConnected : Bool, fromAddress:String) {
      SwiftEventBus.post(SWIFTEVENT_BUS_CONNECTION_STATE_CHANGED_KEY, sender:isConnected as AnyObject)
      if(isConnected) {
         let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(0.6 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
         DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
            //setp1: cmd:0x01 read system status
            self.readsystemStatus()
         })
         DataBaseManager.manager.addOrUpdateDevice(fromAddress: fromAddress)
      }else{
         SyncQueue.sharedInstance.clear()
      }
   }
   
   func firmwareVersionReceived(_ whichfirmware:DfuFirmwareTypes, version:String) {
      if whichfirmware == DfuFirmwareTypes.application {
         let versionData:PostWatchVersionData = PostWatchVersionData(version: version, type: "BLE")
         if let version = Double(versionData.watchVersion){
            DTUserDefaults.lastKnownWatchVersion = version
         }
         SwiftEventBus.post(SWIFTEVENT_BUS_FIRMWARE_VERSION_RECEIVED_KEY, sender:versionData)
      }
   }
   
   /**
    *  Receiving the current device signal strength value
    */
   func receivedRSSIValue(_ number:NSNumber){
   }
   
   func getMconnectionController()->ConnectionControllerImpl?{
      return mConnectionController
   }
}


extension AppDelegate{
   func watchConfig() {
      print("start watchConfig")
      self.setRTC(force: true)
      self.setAppConfig()
      self.setUserProfile()
      self.setGoal()
      self.setWorldClock()
      self.setNotification()
      self.updateNotification()
      self.setStepsToWatch()
      self.setAnalogTime(forceCurrentTime: false)
      DTUserDefaults.setupKey = false
      print("end watchConfig")
   }
   
   func setNotification() {
      sendRequest(SetNotificationRequest(mode: 1, force: DTUserDefaults.setupKey ? 1 : 0))
   }
   
   func updateNotification() {
      if DTUserDefaults.enabledAllNotifications {
         sendRequest(SetNotificationRequest(mode: 0, force: 1))
      } else {
         sendRequest(SetNotificationRequest(mode: 1, force: 0))
         Notification.findAll().forEach({ notification in
            let updateRequest = UpdateNotificationRequest(operation: notification.state ? 1 : 2, package: notification.bundleIdentifier)
            AppDelegate.getAppDelegate().sendRequest(updateRequest)
         })
      }
   }
      
   func setNavigation(state:Bool) {
      isNavigation = state
   }
   
   func getNavigationState() -> Bool {
      return isNavigation
   }
}
