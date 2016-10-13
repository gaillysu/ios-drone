    //
    //  AppDelegate.swift
    //  Nevo
    //
    //  Created by Karl-John Chow on Today 🤔.
    //  Copyright (c) 2015 Nevo. All rights reserved.
    //
    
    import UIKit
    import CoreData
    import HealthKit
    import Alamofire
    import FMDB
    import SwiftEventBus
    import XCGLogger
    import Fabric
    import Crashlytics
    import IQKeyboardManagerSwift
    import RealmSwift
    
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
      fileprivate var mConnectionController : ConnectionControllerImpl?
      fileprivate let mHealthKitStore:HKHealthStore = HKHealthStore()
      fileprivate var currentDay:UInt8 = 0
      fileprivate var mAlertUpdateFW = false
      fileprivate var masterCockroaches:[UUID:Int] = [:]
      
      let log = XCGLogger.default
      fileprivate var responseTimer:Timer?
      fileprivate var noResponseIndex:Int = 0
      fileprivate var sendContactsIndex:Int = 0
      fileprivate var worldclockDatabaseHelper: WorldClockDatabaseHelper?
      fileprivate var realm:Realm?
      /**
       Record the current state of the sync
       */
      var syncState:SYNC_STATE = .no_SYNC
      
      var sendIndex:((_ index:Int) -> Void)?
      let network = NetworkReachabilityManager(host: "drone.karljohnchow.com")
      
      
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
         worldclockDatabaseHelper = WorldClockDatabaseHelper()
         worldclockDatabaseHelper?.setup()
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
      
      // MARK: -AppDelegate SET Function
      func readsystemStatus() {
         sendRequest(GetSystemStatus())
      }
      
      func setSystemConfig(_ index:Int) {
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
      
      func isSaveWorldClock() {
         setWorldClock(Array(realm!.objects(City.self).filter("selected = true")))
      }
      
      
      /**
       Connect BLE Device
       */
      
      func connectCockroach(){
         mConnectionController?.connectCockroach()
      }
      
      func startConnect(){
         let userDevice:NSArray = UserDevice.getAll()
         if(userDevice.count>0) {
            var deviceAddres:[String] = []
            for device in userDevice {
               let deviceModel:UserDevice = device as! UserDevice;
               deviceAddres.append(deviceModel.identifiers)
            }
            mConnectionController?.connect(deviceAddres)
         }else{
            mConnectionController?.connect([])
         }
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
      
      func getMconnectionController()->ConnectionControllerImpl{
         return mConnectionController!
      }
      
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
         return isConnected() ? self.mConnectionController!.getFirmwareVersion() : NSString()
      }
      
      func  getSoftwareVersion() -> NSString{
         return isConnected() ? self.mConnectionController!.getSoftwareVersion() : NSString()
      }
      
      func disconnect() {
         mConnectionController!.disconnect()
      }
      
      func isConnected() -> Bool{
         return mConnectionController!.isConnected()
      }
      
      func sendContactsRequest(_ r:Request,index:Int) {
         if(isConnected()) {
            sendContactsIndex = index
            self.mConnectionController?.sendRequest(r)
         }
      }
      
      func sendRequest(_ r:Request) {
         if(isConnected()){
            self.mConnectionController?.sendRequest(r)
         }else {
            //tell caller
            SwiftEventBus.post(SWIFTEVENT_BUS_CONNECTION_STATE_CHANGED_KEY, sender:false as AnyObject)
         }
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
                  log.debug("set system config 1")
                  self.setSystemConfig(1)
                  setupResponseTimer(["index":NSNumber(value: 1 as Int32)])
               case 1:
                  log.debug("set system config 2")
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
            log.debug("set system config 1,noResponseIndex:\(self.noResponseIndex)")
            self.setSystemConfig(1)
            setupResponseTimer(["index":NSNumber(value: 1 as Int32)])
         case 1:
            log.debug("set system config 2,noResponseIndex:\(self.noResponseIndex)")
            self.setSystemConfig(2)
            setupResponseTimer(["index":NSNumber(value: 2 as Int32)])
         case 2:
            log.debug("set RTC,noResponseIndex:\(self.noResponseIndex)")
            self.setRTC()
            setupResponseTimer(["index":NSNumber(value: 3 as Int32)])
         case 3:
            log.debug("set app config,noResponseIndex:\(self.noResponseIndex)")
            self.setAppConfig()
            setupResponseTimer(["index":NSNumber(value: 4 as Int32)])
         case 4:
            log.debug("set user profile,noResponseIndex:\(self.noResponseIndex)")
            self.setUserProfile()
            setupResponseTimer(["index":NSNumber(value: 5 as Int32)])
         case 5:
            log.debug("set user goal,noResponseIndex:\(self.noResponseIndex)")
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
         self.responseTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(noResponseAction(_:)), userInfo: userInfo, repeats: false)
      }
      
      func releaseResponseTimer() {
         self.responseTimer?.invalidate()
         self.responseTimer = nil
      }
    }
    
    extension AppDelegate{
      func cockRoachesChanged(_ isConnected: Bool, fromAddress: UUID!) {
         SwiftEventBus.post(SWIFTEVENT_BUS_COCKROACHES_CHANGED, sender: CockroachMasterChanged(connected: isConnected, address: fromAddress))
         if isConnected && !self.masterCockroaches.keys.contains(fromAddress) {
            self.masterCockroaches[fromAddress] = 1
         }else if self.masterCockroaches.keys.contains(fromAddress) && !isConnected {
            self.masterCockroaches.removeValue(forKey: fromAddress)
         }
         
      }
      func cockRoachDataReceived(_ coordinates: CoordinateSet, withAddress address: UUID, forBabyCockroach number: Int) {
         
         if let amountCockroach = self.masterCockroaches[address] {
            if amountCockroach < (number + 1) {
               self.masterCockroaches[address] = (number + 1)
            }
         }else{
            print("something went wrong")
         }
         
         SwiftEventBus.post(SWIFTEVENT_BUS_COCKROACHES_DATA_UPDATED, sender: CockroachMasterDataReceived(coordinates: coordinates, address: address, babyCockroachNumber: number))
      }
      
      func getConnectedCockroaches() -> [UUID:Int]{
         return self.masterCockroaches
      }
    }
