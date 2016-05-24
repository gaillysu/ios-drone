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


let DRONEDBFILE:String = "droneDBFile";
let DRONEDBNAME:String = "drone.sqlite";

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

    func rootTabbarController() {
        let navigationController:UINavigationController = UINavigationController(rootViewController: MenuViewController())
        navigationController.navigationBar.barTintColor = UIColor.getBaseColor()
        self.window?.rootViewController = navigationController
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

    func setGoal(goal:Goal) {
        sendRequest(SetGoalRequest(goal: goal))
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
                    setupResponseTimer()
                }

                if(systemStatus == SystemStatus.InvalidTime.rawValue) {
                    setRTC()
                }

                if(systemStatus == SystemStatus.GoalCompleted.rawValue) {
                    setGoal(NumberOfStepsGoal(intensity: GoalIntensity.LOW))
                }

                if(systemStatus == SystemStatus.ActivityDataAvailable.rawValue) {
                    self.getActivity()
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
                    setupResponseTimer()
                case 1:
                    log.debug("set system config 2")
                    self.setSystemConfig(2)
                    setupResponseTimer()
                case 2:
                    log.debug("set RTC")
                    //setp2:start set RTC
                    self.setRTC()
                    setupResponseTimer()
                default:
                    break
                }
                noResponseIndex += 1
            }

            if(packet.getHeader() == SetRTCRequest.HEADER()) {
                //setp3:start set AppConfig
                releaseResponseTimer()
                self.setAppConfig()
                setupResponseTimer()
            }

            if(packet.getHeader() == SetAppConfigRequest.HEADER()) {
                //step3: start set user default goal
                releaseResponseTimer()
                self.setUserProfile()
            }

            if(packet.getHeader() == SetGoalRequest.HEADER()) {
                //step4: get big syncactivity Activity data
                SwiftEventBus.post(SWIFTEVENT_BUS_BEGIN_BIG_SYNCACTIVITY, sender:nil)
                self.getActivity()
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
        releaseResponseTimer()
        switch noResponseIndex {
        case 0:
            log.debug("set system config 1")
            self.setSystemConfig(1)
            setupResponseTimer()
        case 1:
            log.debug("set system config 2")
            self.setSystemConfig(2)
            setupResponseTimer()
        case 2:
            log.debug("set RTC")
            self.setRTC()
            setupResponseTimer()
        case 3:
            log.debug("set app config")
            self.setAppConfig()
            setupResponseTimer()
        case 4:
            log.debug("set user profile")
            self.setUserProfile()
        case 5:
            releaseResponseTimer()
        default:
            break
        }
        noResponseIndex += 1
    }
    
    /**
     setup response timer
     */
    func setupResponseTimer() {
        self.responseTimer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(AppDelegate.noResponseAction(_:)), userInfo: nil, repeats: false)
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