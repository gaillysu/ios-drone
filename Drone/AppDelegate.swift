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
    private let log = XCGLogger.defaultInstance()


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
        self.window?.rootViewController = SplashScreenViewController()
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

    func getRequestNetwork(requestURL:String,parameters:AnyObject,resultHandler:((result:AnyObject?,error:NSError?) -> Void)){
        Alamofire.request(Method.POST, requestURL, parameters: parameters as? [String : AnyObject]).responseJSON { (response) -> Void in
            if response.result.isSuccess {
                NSLog("getJSON: \(response.result.value)")
                resultHandler(result: response.result.value, error: nil)
            }else if (response.result.isFailure){
                resultHandler(result: response.result.value, error: nil)
            }else{
                resultHandler(result: nil, error: nil)
            }
        }
        
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

    func setSystemConfig() {
        sendRequest(SetSystemConfig(autoStart: NSDate().timeIntervalSince1970, autoEnd: NSDate.tomorrow().timeIntervalSince1970))
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
        sendRequest(SetUserProfileRequest(weight: 6000, height: 165, gender: 1, stridelength: 65))
    }

    func setWorldClock(clock:[SetWorldClockRequest]) {
        for worldclock in clock{
            sendRequest(worldclock)
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

    func isConnected() -> Bool{
        return mConnectionController!.isConnected()

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
                setGoal(NumberOfStepsGoal(steps: 100))
                let systemStatus:Int = SystemStatusPacket(data: packet.getRawData()).getSystemStatus()
                log.debug("SystemStatus :\(systemStatus)")
                if(systemStatus == SystemStatus.SystemReset.rawValue) {

                    let myQueue:dispatch_queue_t = dispatch_queue_create("Config_Drone", DISPATCH_QUEUE_SERIAL);

                    //step1 : Set systemconfig
                    dispatch_async(myQueue, {
                        NSThread.sleepForTimeInterval(0.2)
                        self.setSystemConfig()
                        NSLog("NSThread.sleepForTimeInterval(0.2)");
                    })

                    //step2: Set RTC
                    dispatch_async(myQueue, {
                        NSThread.sleepForTimeInterval(0.4)
                        self.setRTC()
                        NSLog(" NSThread.sleepForTimeInterval(0.4)");
                    })

                    //step3: Set appconfig
                    dispatch_async(myQueue, {
                        NSThread.sleepForTimeInterval(0.6)
                        self.setAppConfig()
                        NSLog("NSThread.sleepForTimeInterval(0.6)");
                    })

                    //step4: Set user profile
                    dispatch_async(myQueue, {
                        NSThread.sleepForTimeInterval(0.8)
                        self.setUserProfile()
                        NSLog("NSThread.sleepForTimeInterval(0.8)");
                    })
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
                //setp2:start set RTC
                setRTC()
            }

            if(packet.getHeader() == SetRTCRequest.HEADER()) {
                //setp3:start set AppConfig
                setAppConfig()
            }

            if(packet.getHeader() == SetAppConfigRequest.HEADER()) {
                //step3: start set user default goal
                setGoal(NumberOfStepsGoal(steps: 1000))
            }

            if(packet.getHeader() == SetGoalRequest.HEADER()) {
                //step4: get big syncactivity Activity data
                SwiftEventBus.post(SWIFTEVENT_BUS_BEGIN_BIG_SYNCACTIVITY, sender:nil)
                self.getActivity()
            }

            if(packet.getHeader() == GetBatteryRequest.HEADER()) {
                let data:[UInt8] = NSData2Bytes(packet.getRawData())
                let batteryStatus:Int = Int(data[1])
                SwiftEventBus.post(SWIFTEVENT_BUS_BATTERY_STATUS_CHANGED, sender:batteryStatus)
            }

            if(packet.getHeader() == GetStepsGoalRequest.HEADER()) {
                let rawGoalPacket:StepsGoalPacket = StepsGoalPacket(data: packet.getRawData())
                let stepsDict:[String:Int] = ["dailySteps":rawGoalPacket.getDailySteps(),"goal":rawGoalPacket.getGoal()]

                SwiftEventBus.post(SWIFTEVENT_BUS_SMALL_SYNCACTIVITY_DATA, sender:stepsDict)
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

                if (stepCount != 0) {
                    let stepsArray = UserSteps.getCriteria("WHERE date = \(timerInterval)")
                    if(stepsArray.count>0) {
                        let step:UserSteps = stepsArray[0] as! UserSteps
                        NSLog("Data that has been saved····")
                        let stepsModel:UserSteps = UserSteps(keyDict: ["id":step.id, "steps":"\(stepCount)", "distance": "\(0)","date":timerInterval])
                        stepsModel.update()
                    }else {
                        let stepsModel:UserSteps = UserSteps(keyDict: ["id":0, "steps":"\(stepCount)",  "distance": "\(0)", "date":timerInterval])
                        stepsModel.add({ (id, completion) -> Void in

                        })
                    }
                }
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