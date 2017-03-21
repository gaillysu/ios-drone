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
    import FMDB
    import SwiftEventBus
    import XCGLogger
    import Fabric
    import Crashlytics
    import IQKeyboardManagerSwift
    import RealmSwift
    import SwiftyJSON
    let DRONEDBFILE:String = "droneDBFile";
    let DRONEDBNAME:String = "drone.sqlite";
    let RESET_STATE:String = "RESET_STATE"
    
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
      let SETUP_KEY = "SETUP_KEY"
      
      fileprivate var mConnectionController : ConnectionControllerImpl?
      fileprivate var currentDay:UInt8 = 0
      fileprivate var mAlertUpdateFW = false
      fileprivate var masterCockroaches:[UUID:Int] = [:]
      
      let log = XCGLogger.default
      fileprivate var responseTimer:Timer?
      var noResponseIndex:Int = 0
      fileprivate var sendContactsIndex:Int = 0
      fileprivate var worldclockDatabaseHelper: WorldClockDatabaseHelper?
      fileprivate var realm:Realm?
      /**
       Record the current state of the sync
       */
      var syncState:SYNC_STATE = .no_SYNC
      
      var sendIndex:((_ index:Int) -> Void)?
      let network = NetworkReachabilityManager(host: "https://drone.dayton.med-corp.net")
      
      let dbQueue:FMDatabaseQueue = FMDatabaseQueue(path: AppDelegate.dbPath())
      
      class func getAppDelegate()->AppDelegate {
         return UIApplication.shared.delegate as! AppDelegate
      }
      
      func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
         // Override point for customization after application launch.
         Fabric.with([Crashlytics.self])
         var config = Realm.Configuration(
            schemaVersion: 3,
            migrationBlock: { migration, oldSchemaVersion in
               
         })
         config.deleteRealmIfMigrationNeeded = true
         Realm.Configuration.defaultConfiguration = config
         realm = try! Realm()
         
         let sanbos:SandboxManager = SandboxManager()
         let res:Bool = sanbos.copyDictFileToSandBox(folderName: "NotificationTypeFile", fileName: "NotificationTypeFile.plist")
         let replyString = res ? "Success":"fail"
         log.debug("copy to file \(replyString)")
         DispatchQueue.global(qos: .background).async {
            WorldClockDatabaseHelper().setup()
         }
         
         mConnectionController = ConnectionControllerImpl()
         mConnectionController?.setDelegate(self)
         
         log.setup(level: .debug, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: "path/to/file", fileLevel: .debug)
         
         network?.listener = { status in
            self.log.debug("Network Status Changed: \(status)")
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
      // MARK: -dbPath
      class func dbPath()->String{
         var docsdir:String = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!
         let filemanage:FileManager = FileManager.default
         //drone DB FileURL
         docsdir = docsdir.appendingFormat("%@%@/", "/",DRONEDBFILE)
         var isDir : ObjCBool = false
         let exit:Bool = filemanage.fileExists(atPath: docsdir, isDirectory:&isDir )
         if (!exit || !isDir.boolValue) {
            do{
               try filemanage.createDirectory(atPath: docsdir, withIntermediateDirectories: true, attributes: nil)
            }catch {
               
            }
            
         }
         let dbpath:String = docsdir + DRONEDBNAME
         return dbpath;
      }

      // MARK: - ConnectionControllerDelegate
      /**
       Called when a packet is received from the device
       */
      func packetReceived(_ packet: RawPacket) {
         
         if(!packet.isLastPacket()) {
            SwiftEventBus.post(SWIFTEVENT_BUS_RAWPACKET_DATA_KEY, sender:packet as! RawPacketImpl)
            if(packet.getHeader() == GetSystemStatus.HEADER()) {
               let systemStatus:Int = SystemStatusPacket(data: packet.getRawData()).getSystemStatus()
               log.debug("SystemStatus :\(systemStatus)")
               if(systemStatus == SystemStatus.systemReset.rawValue) {
                  //step1 : Set systemconfig next 1
                  self.setSystemConfig(0)
                  setupResponseTimer(["index":NSNumber(value: 1 as Int32)])
                  //Records need to use 0x30
                  _ = AppTheme.KeyedArchiverName(RESET_STATE, andObject: [RESET_STATE:true] as AnyObject)
               }else if(systemStatus == SystemStatus.invalidTime.rawValue) {
                  setRTC()
               }else if(systemStatus == SystemStatus.goalCompleted.rawValue) {
                  setGoal(nil)
               }else if(systemStatus == SystemStatus.activityDataAvailable.rawValue) {
                  self.getActivity()
               }else{
                  setRTC()
               }
               SwiftEventBus.post(SWIFTEVENT_BUS_GET_SYSTEM_STATUS_KEY, sender:packet as! RawPacketImpl)
            }
            
            if(packet.getHeader() == SystemEventPacket.HEADER()) {
               let eventCommandStatus:Int = SystemEventPacket(data: packet.getRawData()).getSystemEventStatus()
               log.debug("eventCommandStatus :\(eventCommandStatus)")
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
               releaseResponseTimer()
               switch noResponseIndex {
               case 0:
                  UserDefaults.standard.setValue(true, forKeyPath: SETUP_KEY)
                  self.setSystemConfig(1)
                  setupResponseTimer(["index":NSNumber(value: 1 as Int32)])
               case 1:
                  self.setSystemConfig(2)
                  setupResponseTimer(["index":NSNumber(value: 2 as Int32)])
               case 2:
                  log.debug("set RTC")
                  //setp2:start set RTC
                  self.setRTC()
                  setupResponseTimer(["index":NSNumber(value: 3 as Int32)])
               default:
                  break
               }
               noResponseIndex += 1
            }
            
            if(packet.getHeader() == SetRTCRequest.HEADER()) {
               //setp3:start set AppConfig
               releaseResponseTimer()
               self.setAppConfig()
               setupResponseTimer(["index":NSNumber(value: 4 as Int32)])
            }
            
            if(packet.getHeader() == SetAppConfigRequest.HEADER()) {
               //step4: start set user profile
               releaseResponseTimer()
               self.setUserProfile()
               setupResponseTimer(["index":NSNumber(value: 5 as Int32)])
            }
            
            if(packet.getHeader() == SetUserProfileRequest.HEADER()) {
               //step5: start set user default goal
               releaseResponseTimer()
               self.setGoal(nil)
               setupResponseTimer(["index":NSNumber(value: 6 as Int32)])
            }
            
            if(packet.getHeader() == SetGoalRequest.HEADER()) {
               sendIndex?(0)
               releaseResponseTimer()
               self.setStepsToWatch()
               setupResponseTimer(["index":NSNumber(value: 7 as Int32)])
            }
            
            if(packet.getHeader() == SetStepsToWatchReuqest.HEADER()) {
               releaseResponseTimer()
               self.isSaveWorldClock()
               //Set steps to watch response
               _ = AppTheme.KeyedArchiverName(RESET_STATE, andObject: [RESET_STATE:false] as AnyObject)
            }
            
            if(packet.getHeader() == SetWorldClockRequest.HEADER()) {
               let force = UserDefaults.standard.bool(forKey: SETUP_KEY)
               if (force){
                  UserDefaults.standard.set(false, forKey: SETUP_KEY)
               }
               let notificationRequest = SetNotificationRequest(mode: 1, force:  force ? 1 : 0)
               sendRequest(notificationRequest)
            }
            
            if(packet.getHeader() == GetBatteryRequest.HEADER()) {
               let data:[UInt8] = NSData2Bytes(packet.getRawData())
               let batteryStatus:[Int] = [Int(data[2]),Int(data[3])]
               SwiftEventBus.post(SWIFTEVENT_BUS_BATTERY_STATUS_CHANGED, sender:(batteryStatus as AnyObject))
            }
            
            if(packet.getHeader() == GetStepsGoalRequest.HEADER()) {
               let rawGoalPacket:StepsGoalPacket = StepsGoalPacket(data: packet.getRawData() as NSData)
               let stepsDict:[String:Int] = ["dailySteps":rawGoalPacket.getDailySteps(),"goal":rawGoalPacket.getGoal()]
               syncState = .small_SYNC
               SwiftEventBus.post(SWIFTEVENT_BUS_SMALL_SYNCACTIVITY_DATA, sender:(stepsDict as AnyObject))
            }
            
            if (packet.getHeader() == SetNotificationRequest.HEADER()) {
               log.debug("Set Notification response")
               sendIndex?(sendContactsIndex+1)
            }
            
            if (packet.getHeader() == UpdateNotificationRequest.HEADER()) {
               log.debug("Update notification response")
               sendIndex?(sendContactsIndex+1)
            }
            
            if(packet.getHeader() == UpdateContactsFilterRequest.HEADER()) {
               log.debug("Update contacts filter response")
               sendIndex?(sendContactsIndex+1)
            }
            
            if(packet.getHeader() == UpdateContactsApplicationsRequest.HEADER()) {
               log.debug("Update contacts applications response")
               sendIndex?(sendContactsIndex+1)
            }
            
            if(packet.getHeader() == SetContactsFilterRequest.HEADER()) {
               log.debug("Set contacts filter response")
               sendIndex?(sendContactsIndex+1)
            }
            
            if(packet.getHeader() == GetActivityRequest.HEADER()) {
               let syncStatus:[UInt8] = NSData2Bytes(packet.getRawData())
               var timerInterval:Int = Int(syncStatus[2])
               timerInterval =  timerInterval + Int(syncStatus[3])<<8
               timerInterval =  timerInterval + Int(syncStatus[4])<<16
               timerInterval =  timerInterval + Int(syncStatus[5])<<24
               
               var stepCount:Int = Int(syncStatus[6])
               stepCount =  stepCount + Int(syncStatus[7])<<8
               
               let status:Int = Int(syncStatus[8])
               //let activityPacket:ActivityPacket = ActivityPacket(data: packet.getRawData())
               
               NSLog("dailySteps:\(stepCount),dailyStepsDate:\(timerInterval),status:\(status)")
               let bigData:[String:Int] = ["timerInterval":timerInterval,"dailySteps":stepCount]
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
      
      func connectionStateChanged(_ isConnected : Bool) {
         SwiftEventBus.post(SWIFTEVENT_BUS_CONNECTION_STATE_CHANGED_KEY, sender:isConnected as AnyObject)
         if(isConnected) {
            let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(0.6 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
               //setp1: cmd:0x01 read system status
               self.readsystemStatus()
            })
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
      
      // MARK: - noResponseAction
      func noResponseAction(_ timer:Timer) {
         let info = timer.userInfo
         let index:Int = ((info! as AnyObject)["index"] as! NSNumber).intValue
         releaseResponseTimer()
         switch index {
         case 0:
            log.debug("set system config 1, noResponseIndex:\(self.noResponseIndex)")
            self.setSystemConfig(1)
            setupResponseTimer(["index":NSNumber(value: 1 as Int32)])
         case 1:
            log.debug("set system config 2, noResponseIndex:\(self.noResponseIndex)")
            self.setSystemConfig(2)
            setupResponseTimer(["index":NSNumber(value: 2 as Int32)])
         case 2:
            log.debug("set RTC, noResponseIndex:\(self.noResponseIndex)")
            self.setRTC()
            setupResponseTimer(["index":NSNumber(value: 3 as Int32)])
         case 3:
            log.debug("set app config, noResponseIndex:\(self.noResponseIndex)")
            self.setAppConfig()
            setupResponseTimer(["index":NSNumber(value: 4 as Int32)])
         case 4:
            log.debug("set user profile, noResponseIndex:\(self.noResponseIndex)")
            self.setUserProfile()
            setupResponseTimer(["index":NSNumber(value: 5 as Int32)])
         case 5:
            log.debug("set user goal, noResponseIndex:\(self.noResponseIndex)")
            self.setGoal(nil)
            setupResponseTimer(["index":NSNumber(value: 6 as Int32)])
         case 6:
            log.debug("set user steps watch")
            self.setStepsToWatch()
            setupResponseTimer(["index":NSNumber(value: 7 as Int32)])
         case 7:
            log.debug("set user world clock")
            self.isSaveWorldClock()
         case 8:
            releaseResponseTimer()
         default:
            break
         }
         noResponseIndex += 1
      }
      
      func setupResponseTimer(_ userInfo:Any?) {
         //not response send timer
         self.responseTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(noResponseAction(_:)), userInfo: userInfo, repeats: false)
      }
      
      func releaseResponseTimer() {
         self.responseTimer?.invalidate()
         self.responseTimer = nil
      }
      
      func getMconnectionController()->ConnectionControllerImpl?{
         return mConnectionController
      }
      
    }
    
    extension AppDelegate{
      func sendContactsRequest(_ r:Request,index:Int) {
         if(isConnected()) {
            sendContactsIndex = index
            self.getMconnectionController()?.sendRequest(r)
         }
      }
      
      func isSaveWorldClock() {
         setWorldClock(Array(realm!.objects(City.self).filter("selected = true")))
      }
      
}
