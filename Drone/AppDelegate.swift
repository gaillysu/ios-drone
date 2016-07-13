    //
//  AppDelegate.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
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
    
let DRONEDBFILE:String = "droneDBFile";
let DRONEDBNAME:String = "drone.sqlite";
let RESET_STATE:String = "RESET_STATE"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,ConnectionControllerDelegate {

    var window: UIWindow?
    //Let's sync every days
    let SYNC_INTERVAL:NSTimeInterval = 0*30*60 //unit is second in iOS, every 30min, do sync
    let LAST_SYNC_DATE_KEY = "LAST_SYNC_DATE_KEY"
    private var mConnectionController : ConnectionControllerImpl?
    private let mHealthKitStore:HKHealthStore = HKHealthStore()
    private var currentDay:UInt8 = 0
    private var mAlertUpdateFW = false

    private var disConnectAlert:UIAlertView?
    let log = XCGLogger.defaultInstance()
    private var responseTimer:NSTimer?
    private var noResponseIndex:Int = 0
    private var sendContactsIndex:Int = 0
    var sendIndex:((index:Int) -> Void)?
    let network = NetworkReachabilityManager(host: "drone.karljohnchow.com")


    let dbQueue:FMDatabaseQueue = FMDatabaseQueue(path: AppDelegate.dbPath())

    class func getAppDelegate()->AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.with([Crashlytics.self])

        mConnectionController = ConnectionControllerImpl()
        mConnectionController?.setDelegate(self)

        log.setup(.Debug, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: "path/to/file", fileLogLevel: .Debug)
      
      network?.listener = { status in
         self.log.debug("Network Status Changed: \(status)")
      }
      network?.startListening()
      
      
      IQKeyboardManager.sharedManager().enable = true
      
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        UINavigationBar.appearance().tintColor = AppTheme.BASE_COLOR()
        let nav:UINavigationController = UINavigationController(rootViewController: SplashScreenViewController())
        nav.navigationBarHidden = true
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
        UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in }
        
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

    func applicationWillTerminate(application: UIApplication) {
    }

    func application(application: UIApplication , didReceiveLocalNotification notification: UILocalNotification ) {
        
    }

    // MARK: -dbPath
    class func dbPath()->String{
        var docsdir:String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last!
        let filemanage:NSFileManager = NSFileManager.defaultManager()
        //drone DB FileURL
        docsdir = docsdir.stringByAppendingFormat("%@%@/", "/",DRONEDBFILE)
        var isDir : ObjCBool = false
        let exit:Bool = filemanage.fileExistsAtPath(docsdir, isDirectory:&isDir )
        if (!exit || !isDir) {
            do{
                try filemanage.createDirectoryAtPath(docsdir, withIntermediateDirectories: true, attributes: nil)
            }catch {

            }

        }
        let dbpath:String = docsdir.stringByAppendingString(DRONEDBNAME)
        return dbpath;
    }
    
    // MARK: -AppDelegate SET Function
    func readsystemStatus() {
        sendRequest(GetSystemStatus())
    }

    func setSystemConfig(index:Int) {
        sendRequest(SetSystemConfig(autoStart: NSDate().timeIntervalSince1970, autoEnd: NSDate.tomorrow().timeIntervalSince1970, index: index))
    }

    func setRTC() {
        sendRequest(SetRTCRequest())
    }

    func setAppConfig() {
        sendRequest(SetAppConfigRequest())
    }

    func setGoal(goal:Goal?) {
      if goal == nil {
         let goalArray:NSArray = UserGoal.getAll()
         if goalArray.count>0 {
            let goal:UserGoal = UserGoal.getAll()[0] as! UserGoal
            self.setGoal(NumberOfStepsGoal(steps: goal.goalSteps))
         }else{
            self.setGoal(NumberOfStepsGoal(intensity: GoalIntensity.LOW))
         }
      }else{
         sendRequest(SetGoalRequest(goal: goal!))
      }
    }

    func setUserProfile() {
        let profileArray:NSArray = UserProfile.getAll()
        if profileArray.count>0 {
            //height (CM) X 0.415 ＝ stride length
            let profile:UserProfile = profileArray.objectAtIndex(0) as! UserProfile
            sendRequest(SetUserProfileRequest(weight: profile.weight*100, height: profile.length, gender: Int(profile.gender), stridelength: Int(Double(profile.length)*0.415)))
        }else{
            sendRequest(SetUserProfileRequest(weight: 6000, height: 175, gender: 1, stridelength: 65))
        }
    }

    func setWorldClock(clock:SetWorldClockRequest) {
        sendRequest(clock)
    }
   
    func isSaveWorldClock() {
       let array:NSArray = WorldClock.getAll()
       if array.count > 0 {
          var clockNameArray:[String] = []
          var zoneArray:[Int] = []
          for (index,value) in array.enumerate() {
             let worldclock:WorldClock = value as! WorldClock
             let beforeGmt:Int = TimeUtil.getGmtOffSetForCity(worldclock.system_name)
             clockNameArray.append(worldclock.city_name)
             zoneArray.append(beforeGmt)
          }
          setWorldClock(SetWorldClockRequest(count: zoneArray.count, timeZone: zoneArray, name: clockNameArray))
      }
   }

    /**
     Connect BLE Device
     */
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
      let dayDate:NSDate = NSDate()
      let dayTime:NSTimeInterval = NSDate.date(year: dayDate.year, month: dayDate.month, day: dayDate.day, hour: 0, minute: 0, second: 0).timeIntervalSince1970
      let dayStepsArray:NSArray = UserSteps.getCriteria("WHERE date BETWEEN \(dayTime) AND \(dayTime+86400)") //one hour = 3600s
      var daySteps:Int = 0
      for steps in dayStepsArray {
         let userSteps:UserSteps = steps as! UserSteps
         daySteps = daySteps+userSteps.steps
      }
      
      if daySteps>0 {
         let stateArray:NSArray = AppTheme.LoadKeyedArchiverName(RESET_STATE) as! NSArray
         if stateArray.count>0 {
            let state:[String:Bool] = stateArray[0] as! [String:Bool]
            if state[RESET_STATE]! {
               sendRequest(SetStepsToWatchReuqest(steps: daySteps))
               setupResponseTimer(["index":NSNumber(int: 7)])
               AppTheme.KeyedArchiverName(IS_SEND_0X30_COMMAND, andObject: [IS_SEND_0X30_COMMAND:true,"steps":"\(daySteps)"])
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

    func sendContactsRequest(r:Request,index:Int) {
        if(isConnected()) {
            sendContactsIndex = index
            self.mConnectionController?.sendRequest(r)
        }
    }
    
    func sendRequest(r:Request) {
        if(isConnected()){
            self.mConnectionController?.sendRequest(r)
        }else {
            //tell caller
            SwiftEventBus.post(SWIFTEVENT_BUS_CONNECTION_STATE_CHANGED_KEY, sender:false)
        }
    }

    // MARK: - ConnectionControllerDelegate
    /**
     Called when a packet is received from the device
     */
    func packetReceived(packet: RawPacket) {

        if(!packet.isLastPacket()) {
            SwiftEventBus.post(SWIFTEVENT_BUS_RAWPACKET_DATA_KEY, sender:packet as! RawPacketImpl)
         
            if(packet.getHeader() == GetSystemStatus.HEADER()) {
                let systemStatus:Int = SystemStatusPacket(data: packet.getRawData()).getSystemStatus()
                log.debug("SystemStatus :\(systemStatus)")
                if(systemStatus == SystemStatus.SystemReset.rawValue) {
                    //step1 : Set systemconfig next 1
                    self.setSystemConfig(0)
                    setupResponseTimer(["index":NSNumber(int: 1)])
                  //Records need to use 0x30
                  AppTheme.KeyedArchiverName(RESET_STATE, andObject: [RESET_STATE:true])
                }else if(systemStatus == SystemStatus.InvalidTime.rawValue) {
                    setRTC()
                }else if(systemStatus == SystemStatus.GoalCompleted.rawValue) {
                    setGoal(nil)
                }else if(systemStatus == SystemStatus.ActivityDataAvailable.rawValue) {
                    self.getActivity()
                }else{
                  setRTC()
                }

                SwiftEventBus.post(SWIFTEVENT_BUS_GET_SYSTEM_STATUS_KEY, sender:packet as! RawPacketImpl)
            }

            if(packet.getHeader() == SystemEventPacket.HEADER()) {
                let eventCommandStatus:Int = SystemEventPacket(data: packet.getRawData()).getSystemEventStatus()
                log.debug("eventCommandStatus :\(eventCommandStatus)")
                if(eventCommandStatus == SystemEventStatus.GoalCompleted.rawValue) {
                    SwiftEventBus.post(SWIFTEVENT_BUS_GOAL_COMPLETED, sender:nil)
                }

                if(eventCommandStatus == SystemEventStatus.LowMemory.rawValue) {
                    SwiftEventBus.post(SWIFTEVENT_BUS_BEGIN_SMALL_SYNCACTIVITY, sender:nil)
                }

                if(eventCommandStatus == SystemEventStatus.ActivityDataAvailable.rawValue) {
                    SwiftEventBus.post(SWIFTEVENT_BUS_BEGIN_BIG_SYNCACTIVITY, sender:nil)
                    self.getActivity()
                }

                if(eventCommandStatus == SystemEventStatus.BatteryStatusChanged.rawValue) {
                    sendRequest(GetBatteryRequest())
                }
            }

            if(packet.getHeader() == SetSystemConfig.HEADER()) {
                releaseResponseTimer()
                switch noResponseIndex {
                case 0:
                    log.debug("set system config 1")
                    self.setSystemConfig(1)
                    setupResponseTimer(["index":NSNumber(int: 1)])
                case 1:
                    log.debug("set system config 2")
                    self.setSystemConfig(2)
                    setupResponseTimer(["index":NSNumber(int: 2)])
                case 2:
                    log.debug("set RTC")
                    //setp2:start set RTC
                    self.setRTC()
                    setupResponseTimer(["index":NSNumber(int: 3)])
                default:
                    break
                }
                noResponseIndex += 1
            }

            if(packet.getHeader() == SetRTCRequest.HEADER()) {
                //setp3:start set AppConfig
                releaseResponseTimer()
                self.setAppConfig()
                setupResponseTimer(["index":NSNumber(int: 4)])
            }

            if(packet.getHeader() == SetAppConfigRequest.HEADER()) {
                //step4: start set user profile
                releaseResponseTimer()
                self.setUserProfile()
                setupResponseTimer(["index":NSNumber(int: 5)])
            }
         
            if(packet.getHeader() == SetUserProfileRequest.HEADER()) {
               //step5: start set user default goal
               releaseResponseTimer()
               self.setGoal(nil)
               setupResponseTimer(["index":NSNumber(int: 6)])
            }
         
            if(packet.getHeader() == SetGoalRequest.HEADER()) {
                sendIndex?(index: 0)
               releaseResponseTimer()
               self.setStepsToWatch()
               setupResponseTimer(["index":NSNumber(int: 7)])
            }
         
            if(packet.getHeader() == SetStepsToWatchReuqest.HEADER()) {
               releaseResponseTimer()
               self.isSaveWorldClock()
               //Set steps to watch response
               AppTheme.KeyedArchiverName(RESET_STATE, andObject: [RESET_STATE:false])
            }

            if(packet.getHeader() == GetBatteryRequest.HEADER()) {
                let data:[UInt8] = NSData2Bytes(packet.getRawData())
                let batteryStatus:[Int] = [Int(data[2]),Int(data[3])]
                SwiftEventBus.post(SWIFTEVENT_BUS_BATTERY_STATUS_CHANGED, sender:batteryStatus)
            }

            if(packet.getHeader() == GetStepsGoalRequest.HEADER()) {
                let rawGoalPacket:StepsGoalPacket = StepsGoalPacket(data: packet.getRawData())
                let stepsDict:[String:Int] = ["dailySteps":rawGoalPacket.getDailySteps(),"goal":rawGoalPacket.getGoal()]
                SwiftEventBus.post(SWIFTEVENT_BUS_SMALL_SYNCACTIVITY_DATA, sender:stepsDict)
            }
            
            if (packet.getHeader() == SetNotificationRequest.HEADER()) {
                log.debug("Set Notification response")
                sendIndex?(index: sendContactsIndex+1)
            }
            
            if (packet.getHeader() == UpdateNotificationRequest.HEADER()) {
                log.debug("Update notification response")
                sendIndex?(index: sendContactsIndex+1)
            }
            
            if(packet.getHeader() == UpdateContactsFilterRequest.HEADER()) {
                log.debug("Update contacts filter response")
                sendIndex?(index: sendContactsIndex+1)
            }
            
            if(packet.getHeader() == UpdateContactsApplicationsRequest.HEADER()) {
                log.debug("Update contacts applications response")
                sendIndex?(index: sendContactsIndex+1)
            }
            
            if(packet.getHeader() == SetContactsFilterRequest.HEADER()) {
                log.debug("Set contacts filter response")
                sendIndex?(index: sendContactsIndex+1)
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
                SwiftEventBus.post(SWIFTEVENT_BUS_BIG_SYNCACTIVITY_DATA, sender:bigData)

                //Download more data
                if(status == ActivityDataStatus.MoreData.rawValue) {
                    self.getActivity()
                }else{
                    SwiftEventBus.post(SWIFTEVENT_BUS_END_BIG_SYNCACTIVITY, sender:nil)
                }
            }

        }
    }

    func connectionStateChanged(isConnected : Bool) {
        SwiftEventBus.post(SWIFTEVENT_BUS_CONNECTION_STATE_CHANGED_KEY, sender:isConnected)

        if(isConnected) {
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.6 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                //setp1: cmd:0x01 read system status
                self.readsystemStatus()
            })
        }
    }

    func firmwareVersionReceived(whichfirmware:DfuFirmwareTypes, version:NSString) {
        let mcuver = AppTheme.GET_SOFTWARE_VERSION()
        let blever = AppTheme.GET_FIRMWARE_VERSION()

        NSLog("Build in software version: \(mcuver), firmware version: \(blever)")
        SwiftEventBus.post(SWIFTEVENT_BUS_FIRMWARE_VERSION_RECEIVED_KEY, sender:whichfirmware==DfuFirmwareTypes.APPLICATION ? ["BLE":version]:["MCU":version])
    }

    /**
     *  Receiving the current device signal strength value
     */
    func receivedRSSIValue(number:NSNumber){
        SwiftEventBus.post(SWIFTEVENT_BUS_RECEIVED_RSSI_VALUE_KEY, sender:number)
    }

    // MARK: - noResponseAction
    func noResponseAction(timer:NSTimer) {
      let info = timer.userInfo
      let index:Int = (info!["index"] as! NSNumber).integerValue
      releaseResponseTimer()
        switch index {
        case 0:
            log.debug("set system config 1,noResponseIndex:\(noResponseIndex)")
            self.setSystemConfig(1)
            setupResponseTimer(["index":NSNumber(int: 1)])
        case 1:
            log.debug("set system config 2,noResponseIndex:\(noResponseIndex)")
            self.setSystemConfig(2)
            setupResponseTimer(["index":NSNumber(int: 2)])
        case 2:
            log.debug("set RTC,noResponseIndex:\(noResponseIndex)")
            self.setRTC()
            setupResponseTimer(["index":NSNumber(int: 3)])
        case 3:
            log.debug("set app config,noResponseIndex:\(noResponseIndex)")
            self.setAppConfig()
            setupResponseTimer(["index":NSNumber(int: 4)])
        case 4:
            log.debug("set user profile,noResponseIndex:\(noResponseIndex)")
            self.setUserProfile()
            setupResponseTimer(["index":NSNumber(int: 5)])
        case 5:
            log.debug("set user goal,noResponseIndex:\(noResponseIndex)")
            self.setGoal(nil)
            setupResponseTimer(["index":NSNumber(int: 6)])
        case 6:
            log.debug("set user steps watch")
            self.setStepsToWatch()
            setupResponseTimer(["index":NSNumber(int: 7)])
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
    
    /**
     setup response timer
     */
   func setupResponseTimer(userInfo:AnyObject) {
        self.responseTimer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(noResponseAction(_:)), userInfo: userInfo, repeats: false)
    }
    
    /**
     release response Timer
     */
    func releaseResponseTimer() {
        self.responseTimer?.invalidate()
        self.responseTimer = nil
    }
}

protocol SyncControllerDelegate:NSObjectProtocol {

    /**
     Called when a packet is received from the device
     */
    func packetReceived(packet: RawPacket)
    /**
     Called when a peripheral connects or disconnects
     */
    func connectionStateChanged(isConnected : Bool)
    /**
     *  Receiving the current device signal strength value
     */
    func receivedRSSIValue(number:NSNumber)
    /**
     *  Data synchronization is complete callback
     */
    func syncFinished()
}