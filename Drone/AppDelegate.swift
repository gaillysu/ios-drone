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


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,ConnectionControllerDelegate {
   
   var window: UIWindow?
   //Let's sync every days
   let SYNC_INTERVAL:TimeInterval = 0*30*60 //unit is second in iOS, every 30min, do sync
   let LAST_SYNC_DATE_KEY = "LAST_SYNC_DATE_KEY"
   fileprivate var mConnectionController : ConnectionControllerImpl?
   fileprivate var currentDay:UInt8 = 0
   fileprivate var mAlertUpdateFW = false
   fileprivate var masterCockroaches:[UUID:Int] = [:]
   
   fileprivate var worldclockDatabaseHelper: WorldClockDatabaseHelper?

   static let RESET_STATE = "RESET_STATE"
   static let RESET_STATE_DATE = "RESET_STATE_DATE"
   let SETUP_KEY = "SETUP_KEY"

   
   class func getAppDelegate()->AppDelegate {
      return UIApplication.shared.delegate as! AppDelegate
   }
   
   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
      Fabric.with([Crashlytics.self])
      
      _ = DataBaseManager.manager
      _ = NetworkManager.manager
    
      let sanbos:SandboxManager = SandboxManager()
      let _ = sanbos.copyDictFileToSandBox(folderName: "NotificationTypeFile", fileName: "NotificationTypeFile.plist")
      
      
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
   
   // MARK: - ConnectionControllerDelegate
   /**
    Called when a packet is received from the device
    */
   func packetReceived(_ packet: RawPacket) {
      
      if(!packet.isLastPacket()) {
         //We just received a full response, so we can safely send the next request
         SyncQueue.sharedInstance.next()
         
         SwiftEventBus.post(SWIFTEVENT_BUS_RAWPACKET_DATA_KEY, sender:packet as! RawPacketImpl)
         if(packet.getHeader() == GetSystemStatus.HEADER()) {
            let systemStatus:Int = SystemStatusPacket(data: packet.getRawData()).getSystemStatus()
            debugPrint("SystemStatus :\(systemStatus)")
            if(systemStatus == SystemStatus.systemReset.rawValue) {
               //step1 : Set systemconfig next 1
               DTUserDefaults.setupKey = true
               
               self.setSystemConfig()
               
               //Records need to use 0x30
               let cacheModel:ResetCacheModel = ResetCacheModel(reState: true, date: Date().timeIntervalSince1970)
               _ = AppTheme.KeyedArchiverName(AppDelegate.RESET_STATE, andObject: cacheModel)
               
            }else if(systemStatus == SystemStatus.goalCompleted.rawValue) {
               setGoal(nil)
            }else if(systemStatus == SystemStatus.activityDataAvailable.rawValue) {
               self.getActivity()
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
            SwiftEventBus.post(SWIFTEVENT_BUS_GET_SYSTEM_STATUS_KEY, sender:packet as! RawPacketImpl)
         }
         
         if(packet.getHeader() == SystemEventPacket.HEADER()) {
            let eventCommandStatus:Int = SystemEventPacket(data: packet.getRawData()).getSystemEventStatus()
            debugPrint("eventCommandStatus :\(eventCommandStatus)")
            if(eventCommandStatus == SystemEventStatus.goalCompleted.rawValue) {
               SwiftEventBus.post(SWIFTEVENT_BUS_GOAL_COMPLETED, sender:nil)
            }
            
            if(eventCommandStatus == SystemEventStatus.lowMemory.rawValue) {
               SwiftEventBus.post(SWIFTEVENT_BUS_BEGIN_SMALL_SYNCACTIVITY, sender:nil)
            }
            
            if(eventCommandStatus == SystemEventStatus.activityDataAvailable.rawValue) {
               SwiftEventBus.post(SWIFTEVENT_BUS_BEGIN_BIG_SYNCACTIVITY, sender:nil)
               self.getActivity()
            }
            
            if(eventCommandStatus == SystemEventStatus.batteryStatusChanged.rawValue) {
               sendRequest(GetBatteryRequest())
            }
         }
         
         if(packet.getHeader() == SetSystemConfig.HEADER()) {
            self.watchConfig()
         }
         
         if(packet.getHeader() == SetStepsToWatchReuqest.HEADER()) {
            //Set steps to watch response
            _ = AppTheme.KeyedArchiverName(AppDelegate.RESET_STATE, andObject: [AppDelegate.RESET_STATE:false, AppDelegate.RESET_STATE_DATE:Date()] as AnyObject)
         }
         if(packet.getHeader() == GetBatteryRequest.HEADER()) {
            let data:[UInt8] = Constants.NSData2Bytes(packet.getRawData())
            let batteryStatus:[Int] = [Int(data[2]),Int(data[3])]
            SwiftEventBus.post(SWIFTEVENT_BUS_BATTERY_STATUS_CHANGED, sender:(batteryStatus as AnyObject))
         }
         
         if(packet.getHeader() == GetStepsGoalRequest.HEADER()) {
            let rawGoalPacket:StepsGoalPacket = StepsGoalPacket(data: packet.getRawData())
            SwiftEventBus.post(SWIFTEVENT_BUS_SMALL_SYNCACTIVITY_DATA, sender:(rawGoalPacket as AnyObject))
         }
         
         if (packet.getHeader() == SetNotificationRequest.HEADER()) {
            debugPrint("Set Notification response")
         }
         
         if (packet.getHeader() == UpdateNotificationRequest.HEADER()) {
            debugPrint("Update notification response")
         }
         
         if(packet.getHeader() == UpdateContactsFilterRequest.HEADER()) {
            debugPrint("Update contacts filter response")
         }
         
         if(packet.getHeader() == UpdateContactsApplicationsRequest.HEADER()) {
            debugPrint("Update contacts applications response")
         }
         
         if(packet.getHeader() == SetContactsFilterRequest.HEADER()) {
            debugPrint("Set contacts filter response")
         }
         
         if(packet.getHeader() == GetActivityRequest.HEADER()) {
            //let activityPacket:ActivityPacket = ActivityPacket(data: packet.getRawData())
            let syncStatus:[UInt8] = Constants.NSData2Bytes(packet.getRawData())
            var timerInterval:Int = Int(syncStatus[2])
            timerInterval =  timerInterval + Int(syncStatus[3])<<8
            timerInterval =  timerInterval + Int(syncStatus[4])<<16
            timerInterval =  timerInterval + Int(syncStatus[5])<<24
         }
         
         if(packet.getHeader() == SetSystemConfig.HEADER()) {
            self.watchConfig()
         }
         
         if(packet.getHeader() == SetStepsToWatchReuqest.HEADER()) {
            //Set steps to watch response
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
            
            /**
             sync every hour weather data
             */
            if DTUserDefaults.syncWeatherDate.timeIntervalSince1970-Date().timeIntervalSince1970 > 3600 {
               setWeather()
            }
         }
         
         if (packet.getHeader() == SetNotificationRequest.HEADER()) {
            debugPrint("Set Notification response")
         }
         
         if (packet.getHeader() == UpdateNotificationRequest.HEADER()) {
            debugPrint("Update notification response")
         }
         
         if(packet.getHeader() == UpdateContactsFilterRequest.HEADER()) {
            debugPrint("Update contacts filter response")
         }
         
         if(packet.getHeader() == UpdateContactsApplicationsRequest.HEADER()) {
            debugPrint("Update contacts applications response")
         }
         
         if(packet.getHeader() == SetContactsFilterRequest.HEADER()) {
            debugPrint("Set contacts filter response")
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
   
   func firmwareVersionReceived(_ whichfirmware:DfuFirmwareTypes, version:NSString) {
      let mcuver = AppTheme.GET_SOFTWARE_VERSION()
      let blever = AppTheme.GET_FIRMWARE_VERSION()

      NSLog("Build in software version: \(mcuver), firmware version: \(blever)")
      if whichfirmware == DfuFirmwareTypes.application {
         let versionData:PostWatchVersionData = PostWatchVersionData(version: version as String, type: "BLE")
         SwiftEventBus.post(SWIFTEVENT_BUS_FIRMWARE_VERSION_RECEIVED_KEY, sender:versionData)
      }
   }
   
   /**
    *  Receiving the current device signal strength value
    */
   func receivedRSSIValue(_ number:NSNumber){
      SwiftEventBus.post(SWIFTEVENT_BUS_RECEIVED_RSSI_VALUE_KEY, sender:number)
   }
   
   func getMconnectionController()->ConnectionControllerImpl?{
      return mConnectionController
   }
}


extension AppDelegate{
   func watchConfig() {
      debugPrint("setp2 0x03")
      //setp2:start set RTC
      self.setRTC()
      //setp3:start set AppConfig
      debugPrint("setp3 0x04")
      self.setAppConfig()
      //step4: start set user profile
      debugPrint("setp4 0x31")
      self.setUserProfile()
      //step5: start set user default goal
      debugPrint("setp5 0x12")
      self.setGoal(nil)
      
      debugPrint("setp6 0x06")
      self.isSaveWorldClock()
      
      debugPrint("setp7 0x0A")
      self.setNotification()
      
      debugPrint("setp8 0x0B")
      self.updateNotification()
      
      debugPrint("setp9 0x30")
      self.setStepsToWatch()
      
      setWeather()
   }
   
   func setNotification() {
      let force = DTUserDefaults.setupKey
      if (force){
         DTUserDefaults.setupKey = false
      }
      let notificationRequest = SetNotificationRequest(mode: 1, force:  force ? 1 : 0)
      sendRequest(notificationRequest)
   }
   
   func updateNotification() {
      let realm = try! Realm()
      let notifications = realm.objects(DroneNotification.self)
      for notification in notifications {
         let updateRequest = UpdateNotificationRequest(operation: notification.state ? 1 : 2, package: notification.bundleIdentifier)
         AppDelegate.getAppDelegate().sendRequest(updateRequest)
      }
   }
   
   func isSaveWorldClock() {
      let realm = try! Realm()
      setWorldClock(Array(realm.objects(City.self).filter("selected = true")))
   }
}
