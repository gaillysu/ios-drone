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
import YRSideViewController
import XCGLogger

let DRONEDBFILE:String = "droneDBFile";
let DRONEDBNAME:String = "drone.sqlite";

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,ConnectionControllerDelegate {

    var window: UIWindow?
    //Let's sync every days
    let SYNC_INTERVAL:NSTimeInterval = 0*30*60 //unit is second in iOS, every 30min, do sync
    let LAST_SYNC_DATE_KEY = "LAST_SYNC_DATE_KEY"
    private var mDelegates:[SyncControllerDelegate] = []
    private var mConnectionController : ConnectionControllerImpl?
    private var mPacketsbuffer:[NSData] = []
    private let mHealthKitStore:HKHealthStore = HKHealthStore()
    private var savedDailyHistory:[NevoPacket.DailyHistory] = []
    private var currentDay:UInt8 = 0
    private var mAlertUpdateFW = false

    private var todaySleepData:NSMutableArray = NSMutableArray(capacity: 2)
    private var disConnectAlert:UIAlertView?
    private let log = XCGLogger.defaultInstance()
    let sideViewController:YRSideViewController = YRSideViewController()


    let dbQueue:FMDatabaseQueue = FMDatabaseQueue(path: AppDelegate.dbPath())

    class func getAppDelegate()->AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        mConnectionController = ConnectionControllerImpl()
        mConnectionController?.setDelegate(self)

        sideViewController.rootViewController = UINavigationController(rootViewController: MenuViewController());
        sideViewController.leftViewController = ProfileViewController();
        sideViewController.rightViewController = UINavigationController(rootViewController: MyDroneController());
        sideViewController.leftViewShowWidth = UIScreen.mainScreen().bounds.size.width
        sideViewController.rightViewShowWidth = UIScreen.mainScreen().bounds.size.width
        sideViewController.showBoundsShadow = false
        sideViewController.needSwipeShowMenu = true
        sideViewController.rootViewMoveBlock = { (rootView, orginFrame, xoffset) -> Void in
            rootView.frame=CGRectMake(xoffset, orginFrame.origin.y, orginFrame.size.width, orginFrame.size.height);
        }


        log.setup(.Debug, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: "path/to/file", fileLogLevel: .Debug)

        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        UINavigationBar.appearance().tintColor = AppTheme.BASE_COLOR()
        self.window?.rootViewController = sideViewController
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

    func GET_TodaySleepData()->NSArray{
        return todaySleepData;
    }

    // MARK: -AppDelegate syncActivityData
    /**
     This function will syncrhonise activity data with the watch.
     It is a long process and hence shouldn't be done too often, so we save the date of previous sync.
     The watch should be emptied after all data have been saved.
     */
    func syncActivityData() {
        var lastSync = 0.0
        if let lastSyncSaved = NSUserDefaults.standardUserDefaults().objectForKey(LAST_SYNC_DATE_KEY) as? Double {
            lastSync = lastSyncSaved
        }

        if( NSDate().timeIntervalSince1970-lastSync > SYNC_INTERVAL) {
            //We haven't synched for a while, let's sync now !
            AppTheme.DLog("*** Sync started ! ***")
            //self.getDailyTrackerInfo()
        }

    }

    /**
     When the sync process is finished, le't refresh the date of sync
     */
    func syncFinished() {

        log.debug("*** Sync finished ***")

        let userDefaults = NSUserDefaults.standardUserDefaults();

        userDefaults.setObject(NSDate().timeIntervalSince1970,forKey:LAST_SYNC_DATE_KEY)

        userDefaults.synchronize()
    }

    // MARK: - ConnectionController protocol
    func  getFirmwareVersion() -> NSString{
        return isConnected() ? self.mConnectionController!.getFirmwareVersion() : NSString()
    }

    func  getSoftwareVersion() -> NSString{
        return isConnected() ? self.mConnectionController!.getSoftwareVersion() : NSString()
    }

    func connect() {
        self.startConnect()
    }

    func isConnected() -> Bool{
        return mConnectionController!.isConnected()

    }

    func sendRequest(r:Request) {
        if(isConnected()){
            self.mConnectionController?.sendRequest(r)
//            SyncQueue.sharedInstance.post( { (Void) -> (Void) in
//            } )
        }else {
            //tell caller
            for delegate in mDelegates {
                delegate.connectionStateChanged(false)
            }
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
                SwiftEventBus.post(SWIFTEVENT_BUS_GET_SYSTEM_STATUS_KEY, sender:packet as! RawPacketImpl)

                let data:[UInt8] = NSData2Bytes(packet.getRawData())
                let systemStatus:Int = Int(data[2])
                log.debug("SystemStatus :\(systemStatus)")
                if(systemStatus == SystemStatus.SystemReset.rawValue) {
                    self.setSystemConfig()
                    self.setRTC()
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
            }

            if(packet.getHeader() == SystemEventCommand.HEADER()) {
                let data:[UInt8] = NSData2Bytes(packet.getRawData())
                let eventCommandStatus:Int = Int(data[2])
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
                setGoal(NumberOfStepsGoal(intensity: GoalIntensity.LOW))
            }

            if(packet.getHeader() == SetGoalRequest.HEADER()) {
                //step4: get big syncactivity Activity data
                SwiftEventBus.post(SWIFTEVENT_BUS_BEGIN_BIG_SYNCACTIVITY, sender:nil)
                syncActivityData()
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
                let activityPacket:ActivityPacket = ActivityPacket(data: packet.getRawData())

                NSLog("dailySteps:\(activityPacket.getStepCount()),dailyStepsDate:\(activityPacket.gettimerInterval()),status:\(activityPacket.getFIFOStatus())")

                if (activityPacket.getStepCount() != 0) {
                    let stepsArray = UserSteps.getCriteria("WHERE date = \(activityPacket.gettimerInterval())")
                    if(stepsArray.count>0) {
                        let step:UserSteps = stepsArray[0] as! UserSteps
                        AppTheme.DLog("Data that has been saved····")
                        let stepsModel:UserSteps = UserSteps(keyDict: ["id":step.id, "steps":"\(activityPacket.getStepCount())", "distance": "\(activityPacket.getStepDistance())","date":activityPacket.gettimerInterval()])
                        stepsModel.update()
                    }else {
                        let stepsModel:UserSteps = UserSteps(keyDict: ["id":0, "steps":"\(activityPacket.getStepCount())",  "distance": "\(activityPacket.getStepDistance())", "date":activityPacket.gettimerInterval()])
                        stepsModel.add({ (id, completion) -> Void in

                        })
                    }
                }
                let bigData:[String:Int] = ["timerInterval":activityPacket.gettimerInterval(),"dailySteps":activityPacket.getStepCount()]
                SwiftEventBus.post(SWIFTEVENT_BUS_BIG_SYNCACTIVITY_DATA, sender:bigData)

                //Download more data
                if(activityPacket.getFIFOStatus() == ActivityDataStatus.MoreData.rawValue) {
                    syncActivityData()
                }else{
                    SwiftEventBus.post(SWIFTEVENT_BUS_END_BIG_SYNCACTIVITY, sender:nil)
                }
            }

        }
    }

    func connectionStateChanged(isConnected : Bool) {
        SwiftEventBus.post(SWIFTEVENT_BUS_CONNECTION_STATE_CHANGED_KEY, sender:isConnected)

        if(isConnected) {
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                //setp1: cmd 0x01, set RTC, for every connected Nevo
                self.mPacketsbuffer = []
                //self.setRTC()
                self.readsystemStatus()
            })

        }else {
            SyncQueue.sharedInstance.clear()
            mPacketsbuffer = []
        }
    }

    func firmwareVersionReceived(whichfirmware:DfuFirmwareTypes, version:NSString) {
        let mcuver = AppTheme.GET_SOFTWARE_VERSION()
        let blever = AppTheme.GET_FIRMWARE_VERSION()

        AppTheme.DLog("Build in software version: \(mcuver), firmware version: \(blever)")
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