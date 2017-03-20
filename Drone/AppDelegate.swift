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
    let RESET_STATE:String = "RESET_STATE"
    let SETUP_KEY = "SETUP_KEY"

    enum SYNC_STATE{
      case no_SYNC
      case big_SYNC
      case small_SYNC
    }
    
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
      fileprivate var realm:Realm?
      /**
       Record the current state of the sync
       */
      var syncState:SYNC_STATE = .no_SYNC
      
      var sendIndex:((_ index:Int) -> Void)?
      let network = NetworkReachabilityManager(host: "drone.karljohnchow.com")
      
      class func getAppDelegate()->AppDelegate {
         return UIApplication.shared.delegate as! AppDelegate
      }
      
      func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
         // Override point for customization after application launch.
         Fabric.with([Crashlytics.self])
         
         self.setUpRelam()
         
         let sanbos:SandboxManager = SandboxManager()
         let res:Bool = sanbos.copyDictFileToSandBox(folderName: "NotificationTypeFile", fileName: "NotificationTypeFile.plist")
         let replyString = res ? "Success":"fail"
         debugPrint("copy to file \(replyString)")
         
         DispatchQueue.global(qos: .background).async {
            WorldClockDatabaseHelper().setup()
         }
         
         mConnectionController = ConnectionControllerImpl()
         mConnectionController?.setDelegate(self)
         
         
         network?.listener = { status in
            debugPrint("Network Status Changed: \(status)")
         }
         network?.startListening()
         
         IQKeyboardManager.sharedManager().enable = true
         
         self.window = UIWindow(frame: UIScreen.main.bounds)
         UINavigationBar.appearance().tintColor = UIColor.getBaseColor()
         let nav:UINavigationController = UINavigationController(rootViewController: SplashScreenViewController())
         nav.isNavigationBarHidden = true
         self.window?.rootViewController = nav
         self.window?.makeKeyAndVisible()
         
         return true
      }
      
      func applicationWillResignActive(_ application: UIApplication) {
      }
      
      func applicationDidEnterBackground(_ application: UIApplication) {
         UIApplication.shared.beginBackgroundTask (expirationHandler: { () -> Void in })
         
      }
      
      func setUpRelam() {
         var config = Realm.Configuration(
            schemaVersion: 4,
            migrationBlock: { migration, oldSchemaVersion in
               
         })
         config.deleteRealmIfMigrationNeeded = true
         Realm.Configuration.defaultConfiguration = config
         realm = try! Realm()
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
                  UserDefaults.standard.setValue(true, forKeyPath: SETUP_KEY)
                  self.setSystemConfig(0)
                  self.setSystemConfig(1)
                  self.setSystemConfig(2)
                  //Records need to use 0x30
                  _ = AppTheme.KeyedArchiverName(RESET_STATE, andObject: [RESET_STATE:true,"RESET_STATE_DATE":Date().timeIntervalSince1970])
               }else if(systemStatus == SystemStatus.goalCompleted.rawValue) {
                  setGoal(nil)
               }else if(systemStatus == SystemStatus.activityDataAvailable.rawValue) {
                  self.getActivity()
               }else if(systemStatus != SystemStatus.lowMemory.rawValue && systemStatus != SystemStatus.subscribedToNotifications.rawValue) {
                  if let date = UserDefaults.standard.object(forKey: "SET_RTC") {
                     let syncDate:Date = date as! Date
                     if (Date().timeIntervalSince1970 - syncDate.timeIntervalSince1970) > 60 {
                        UserDefaults.standard.setValue(Date(), forKeyPath: "SET_RTC")
                        UserDefaults.standard.synchronize()
                        self.watchConfig()
                     }
                  }else{
                     UserDefaults.standard.setValue(Date(), forKeyPath: "SET_RTC")
                     UserDefaults.standard.synchronize()
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
               _ = AppTheme.KeyedArchiverName(RESET_STATE, andObject: [RESET_STATE:false,"RESET_STATE1":Date()] as AnyObject)
            }
            
            if(packet.getHeader() == SetWorldClockRequest.HEADER()) {

            }
            
            if(packet.getHeader() == GetBatteryRequest.HEADER()) {
               let data:[UInt8] = NSData2Bytes(packet.getRawData())
               let batteryStatus:[Int] = [Int(data[2]),Int(data[3])]
               SwiftEventBus.post(SWIFTEVENT_BUS_BATTERY_STATUS_CHANGED, sender:(batteryStatus as AnyObject))
            }
            
            if(packet.getHeader() == GetStepsGoalRequest.HEADER()) {
               let rawGoalPacket:StepsGoalPacket = StepsGoalPacket(data: packet.getRawData() as NSData)
               syncState = .small_SYNC
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
               let syncStatus:[UInt8] = NSData2Bytes(packet.getRawData())
               var timerInterval:Int = Int(syncStatus[2])
               timerInterval =  timerInterval + Int(syncStatus[3])<<8
               timerInterval =  timerInterval + Int(syncStatus[4])<<16
               timerInterval =  timerInterval + Int(syncStatus[5])<<24
               
               var stepCount:Int = Int(syncStatus[6])
               stepCount =  stepCount + Int(syncStatus[7])<<8
               
               let status:Int = Int(syncStatus[8])
               
               debugPrint("dailySteps:\(stepCount),dailyStepsDate:\(timerInterval),status:\(status)")
               let bigData = (time:timerInterval,dailySteps:stepCount)
               SwiftEventBus.post(SWIFTEVENT_BUS_BIG_SYNCACTIVITY_DATA, sender:(bigData as AnyObject))
               
               //Download more data
               if(status == ActivityDataStatus.moreData.rawValue) {
                  syncState = .big_SYNC
                  self.getActivity()
               }else{
                  syncState = .no_SYNC
                  SwiftEventBus.post(SWIFTEVENT_BUS_END_BIG_SYNCACTIVITY, sender:nil)
               }
            }
            
         }else{
            syncState = .no_SYNC
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
            
            let userDevice = UserDevice.getFilter(String(format: "identifiers = '%@'", fromAddress))
            if userDevice.count == 0 {
               let device:UserDevice = UserDevice()
               device.id = Int(Date().timeIntervalSince1970)
               device.device_name = "Drone"
               device.identifiers = fromAddress
               device.connectionTimer = Date().timeIntervalSince1970
               _ = device.add()
            }else{
               let device:UserDevice = userDevice.first as! UserDevice
               try! realm!.write {
                  device.connectionTimer = Date().timeIntervalSince1970
               }
            }
            
         }else{
            SyncQueue.sharedInstance.clear()
         }
      }
      
      func firmwareVersionReceived(_ whichfirmware:DfuFirmwareTypes, version:NSString) {
         let mcuver = AppTheme.GET_SOFTWARE_VERSION()
         let blever = AppTheme.GET_FIRMWARE_VERSION()
         
         NSLog("Build in software version: \(mcuver), firmware version: \(blever)")
         var versionData = ["MCU":version]
         if whichfirmware == DfuFirmwareTypes.application {
            versionData = ["BLE":version]
         }
         SwiftEventBus.post(SWIFTEVENT_BUS_FIRMWARE_VERSION_RECEIVED_KEY, sender:versionData as AnyObject)
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
   }
   
   func setNotification() {
      let force = UserDefaults.standard.bool(forKey: SETUP_KEY)
      if (force){
         UserDefaults.standard.set(false, forKey: SETUP_KEY)
      }
      let notificationRequest = SetNotificationRequest(mode: 1, force:  force ? 1 : 0)
      sendRequest(notificationRequest)
   }
   
   func updateNotification() {
      var contact:[String : Any] = SandboxManager().readDataWithName(type: "", fileName: "NotificationTypeFile.plist") as! [String : Any]
      let notification:[String:Any] = contact["NotificationType"] as! [String:Any]
      
      for (key,value) in JSON(notification).dictionaryValue {
         var operation:Int = 0
         let packageName:String = value["bundleId"].stringValue
         if value["state"].boolValue {
            operation = 1
         }else{
            operation = 2
         }
         let updateRequest = UpdateNotificationRequest(operation: operation, package: packageName)
         AppDelegate.getAppDelegate().sendRequest(updateRequest)
      }
   }
   
   func isSaveWorldClock() {
      setWorldClock(Array(realm!.objects(City.self).filter("selected = true")))
   }
}
