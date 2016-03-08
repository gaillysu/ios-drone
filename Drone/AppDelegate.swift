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

let nevoDBDFileURL:String = "nevoDBName";
let nevoDBNames:String = "nevo.sqlite";

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


    let dbQueue:FMDatabaseQueue = FMDatabaseQueue(path: AppDelegate.dbPath())

    class func getAppDelegate()->AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
         UINavigationBar.appearance().tintColor = AppTheme.NEVO_SOLAR_YELLOW()

        // Override point for customization after application launch.
        UINavigationBar.appearance().tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        //Start the logo for the first time
        if(!NSUserDefaults.standardUserDefaults().boolForKey("everLaunched")){
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "everLaunched")
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "firstLaunch")
        }else{
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "firstLaunch")
        }


        mConnectionController = ConnectionControllerImpl()
        mConnectionController?.setDelegate(self)
 
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)

        let navigationController:UINavigationController = UINavigationController(rootViewController: MenuViewController())
        self.window?.rootViewController = navigationController
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
        //nevoDBDFileURL
        docsdir = docsdir.stringByAppendingFormat("%@%@/", "/",nevoDBDFileURL)
        var isDir : ObjCBool = false
        let exit:Bool = filemanage.fileExistsAtPath(docsdir, isDirectory:&isDir )
        if (!exit || !isDir) {
            do{
                try filemanage.createDirectoryAtPath(docsdir, withIntermediateDirectories: true, attributes: nil)
            }catch {

            }

        }
        let dbpath:String = docsdir.stringByAppendingString(nevoDBNames)
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
        sendRequest(SetSystemConfig())
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

    func startConnect(forceScan:Bool,delegate:SyncControllerDelegate){
        AppTheme.DLog("New delegate : \(delegate)")
        mDelegates.append(delegate)
        if forceScan{
            mConnectionController?.forgetSavedAddress()
        }
        mConnectionController?.connect()
    }

    // MARK: -AppDelegate GET Function

    func getMconnectionController()->ConnectionControllerImpl{
        return mConnectionController!
    }

    func  getDailyTrackerInfo(){
        sendRequest(GetActivityRequest())
    }

    func  getDailyTracker(trackerno:UInt8){
        sendRequest(ReadDailyTracker(trackerno:trackerno))
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
            self.getDailyTrackerInfo()
        }

    }

    /**
     When the sync process is finished, le't refresh the date of sync
     */
    func syncFinished() {

        AppTheme.DLog("*** Sync finished ***")

        let userDefaults = NSUserDefaults.standardUserDefaults();

        userDefaults.setObject(NSDate().timeIntervalSince1970,forKey:LAST_SYNC_DATE_KEY)

        userDefaults.synchronize()
    }

    /**
     Remove MyNevoDelegate
     */
    func removeMyNevoDelegate(){
        for(var i:Int = 0; i < mDelegates.count; i++){
            if mDelegates[i] is MyDroneController{
                mDelegates.removeAtIndex(i)
            }
        }
    }

    // MARK: - UIAlertViewDelegate
    /**
    See UIAlertViewDelegate
    */
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){

        disConnectAlert = nil

    }

    // MARK: - ConnectionController protocol
    func  getFirmwareVersion() -> NSString{
        return isConnected() ? self.mConnectionController!.getFirmwareVersion() : NSString()
    }

    func  getSoftwareVersion() -> NSString{
        return isConnected() ? self.mConnectionController!.getSoftwareVersion() : NSString()
    }

    func connect() {
        self.mConnectionController?.connect()
    }

    func isConnected() -> Bool{
        return mConnectionController!.isConnected()

    }

    func sendRequest(r:Request) {
        if(isConnected()){
            SyncQueue.sharedInstance.post( { (Void) -> (Void) in

                self.mConnectionController?.sendRequest(r)

            } )
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
            for delegate in mDelegates {
                delegate.packetReceived(packet)
            }

            if(packet.getHeader() == GetSystemStatus.HEADER()) {
                let data:[UInt8] = NSData2Bytes(packet.getRawData())
                let systemStatus:Int = Int(data[2])<<8
                let systemReset:Int = Int(data[3])
                if(systemStatus == 8) {
                    setSystemConfig()
                }

                if(systemStatus == 3) {
                    setRTC()
                }

                if(systemStatus == 1) {
                    syncActivityData()
                }
            }

            if(packet.getHeader() == SetSystemConfig.HEADER()) {
                //setp2:start set RTC
                setRTC()
            }

            if(packet.getHeader() == SetRTCRequest.HEADER()) {
                //setp3:start set AppConfig
                syncActivityData()
                //setAppConfig()
            }

            if(packet.getHeader() == SetAppConfigRequest.HEADER()) {
                //step3: start set user default goal
                setGoal(NumberOfStepsGoal(intensity: GoalIntensity.LOW))
            }

            if(packet.getHeader() == GetActivityRequest.HEADER()) {
                let syncStatus:[UInt8] = NSData2Bytes(packet.getRawData())
                let status:Int = Int(syncStatus[2])
                var dailySteps:Int = Int(syncStatus[6])
                dailySteps =  dailySteps + Int(syncStatus[7])<<8

                var timerInterval:Int = Int(syncStatus[2])
                timerInterval =  timerInterval + Int(syncStatus[3])<<8
                timerInterval =  timerInterval + Int(syncStatus[4])<<16
                timerInterval =  timerInterval + Int(syncStatus[5])<<24

                if (dailySteps != 0) {
                    let stepsArray = UserSteps.getCriteria("WHERE date = \(timerInterval)")
                    if(stepsArray.count>0) {
                        let step:UserSteps = stepsArray[0] as! UserSteps
                        AppTheme.DLog("Data that has been saved····")
                        let stepsModel:UserSteps = UserSteps(keyDict: ["id":step.id, "steps":"\(dailySteps)", "distance":"0", "hourlysteps": "\(dailySteps)", "hourlydistance":"0", "calories":"0" , "hourlycalories":"0", "inZoneTime":0, "outZoneTime":0, "inactivityTime":0, "goalreach":false, "date":timerInterval])
                        stepsModel.update()
                    }else {
                        let stepsModel:UserSteps = UserSteps(keyDict: ["id":0, "steps":"\(dailySteps)", "distance":"0", "hourlysteps": "\(dailySteps)", "hourlydistance":"0", "calories":"0" , "hourlycalories":"0", "inZoneTime":0, "outZoneTime":0, "inactivityTime":0, "goalreach":false, "date":timerInterval])
                        stepsModel.add({ (id, completion) -> Void in

                        })
                    }
                }

                if(status == 1) {
                    syncActivityData()
                }
            }

        }
    }

    func connectionStateChanged(isConnected : Bool) {
        //send local notification
        if isConnected {
            ConnectionManager.sharedInstance.checkConnectSendNotification(ConnectionManager.Const.connectionStatus.connected)
        }else {
            ConnectionManager.sharedInstance.checkConnectSendNotification(ConnectionManager.Const.connectionStatus.disconnected)
        }

        for delegate in mDelegates {
            delegate.connectionStateChanged(isConnected)
        }

        if(isConnected) {
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                //setp1: cmd 0x01, set RTC, for every connected Nevo
                self.mPacketsbuffer = []
                self.setRTC()
                //self.readsystemStatus()
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

        if ((whichfirmware == DfuFirmwareTypes.SOFTDEVICE  && version.integerValue == mcuver)
            || (whichfirmware == DfuFirmwareTypes.APPLICATION  && version.integerValue == blever)) {
            //for tutorial screen, don't popup update dialog
            if !mAlertUpdateFW {
                mAlertUpdateFW = true
                let alert :UIAlertView = UIAlertView(title: NSLocalizedString("Firmware Upgrade", comment: ""), message: NSLocalizedString("FirmwareAlertMessage", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("ok", comment: ""))
                alert.show()
            }
        }
    }

    /**
     *  Receiving the current device signal strength value
     */
    func receivedRSSIValue(number:NSNumber){
        for delegate in mDelegates {
            delegate.receivedRSSIValue(number)
        }
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