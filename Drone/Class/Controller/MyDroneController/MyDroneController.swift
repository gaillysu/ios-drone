//
//  MyNevoController.swift
//  Nevo
//
//  Created by leiyuncun on 15/5/18.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class MyDroneController: UITableViewController,ButtonManagerCallBack,SyncControllerDelegate,UIAlertViewDelegate {

    //@IBOutlet weak var mynevoView: MyNevoView!
    private var currentBattery:Int = 0
    private var rssialert :UIAlertView?
    private var buildinSoftwareVersion:Int = 0
    private var buildinFirmwareVersion:Int = 0

    var titleArray:[String] = []

    init() {
        super.init(nibName: "MyDroneController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationItem.title = NSLocalizedString("My Drone", comment: "")
        AppDelegate.getAppDelegate().startConnect(false, delegate: self)
        //mynevoView.bulidMyNevoView(self,navigation: self.navigationItem)
        buildinSoftwareVersion = AppTheme.GET_SOFTWARE_VERSION()
        buildinFirmwareVersion = AppTheme.GET_FIRMWARE_VERSION()

        titleArray = ["Firmware","Battery","Watch version"]
    }


    override func viewDidAppear(animated: Bool) {

        checkConnection()
        //mynevoView.setVersionLbael(AppDelegate.getAppDelegate().getSoftwareVersion(), bleNumber: AppDelegate.getAppDelegate().getFirmwareVersion())
        let indexPath:NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }

    override func viewDidDisappear(animated: Bool) {
        AppDelegate.getAppDelegate().removeMyNevoDelegate()
        rssialert?.dismissWithClickedButtonIndex(1, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - controllManager
    func controllManager(sender:AnyObject){

    }

    // MARK: - SyncControllerDelegate
    /**
    See SyncControllerDelegate
    */
    func receivedRSSIValue(number:NSNumber){
        AppTheme.DLog("Red RSSI Value:\(number)")
        if(number.integerValue < -85){
            if(rssialert==nil){
                rssialert = UIAlertView(title: NSLocalizedString("Unstable connection ensure", comment: ""), message:NSLocalizedString("Unstable connection ensure phone is on and in range", comment: "") , delegate: nil, cancelButtonTitle: nil)
                rssialert?.show()
            }
        }else{
            rssialert?.dismissWithClickedButtonIndex(1, animated: true)
            rssialert = nil
        }

        let currentSoftwareVersion:NSString = AppDelegate.getAppDelegate().getSoftwareVersion()
        let currentFirmwareVersion:NSString = AppDelegate.getAppDelegate().getFirmwareVersion()

    }


    func packetReceived(packet:RawPacket){
        if(packet.getHeader() == ReadBatteryLevelNevoRequest.HEADER()) {
            NSLog("%@",packet.getRawData())
            //Int(NSData2Bytes(getPackets()[0])[2] )
            let value:[UInt8] = NSData2Bytes(packet.getRawData())
            let batteryValue:Int = Int(value[2])
            let percent:Int = Int(value[3])
            currentBattery = percent
            let indexPath:NSIndexPath = NSIndexPath(forRow: 1, inSection: 0)
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }

    }

    func connectionStateChanged(isConnected : Bool){
        checkConnection()
        if(!isConnected){
            rssialert?.dismissWithClickedButtonIndex(1, animated: true)
            rssialert = nil
        }
    }

    func syncFinished(){

    }

    /**
     Checks if any device is currently connected
     */
    func checkConnection() {
        if AppDelegate.getAppDelegate().isConnected() {
            AppDelegate.getAppDelegate().ReadBatteryLevel()
        }
    }

    func reconnect() {
        AppDelegate.getAppDelegate().connect()
    }

    // MARK: - checkUpdateVersion
    /**
    Check the update
    */
    func  checkUpdateVersion() {
        MBProgressHUD.showMessage(NSLocalizedString("is_checking_the_update",comment: ""))
        AppTheme.getAppStoreVersion({ (stringVersion, version) -> Void in
            MBProgressHUD.hideHUD()
            let loclString:String = (NSBundle.mainBundle().infoDictionary! as NSDictionary).objectForKey("CFBundleShortVersionString") as! String
            let versionString:NSString = loclString.stringByReplacingOccurrencesOfString(".", withString: "")
            let versionNumber:Double = Double(versionString.floatValue)
            if(version>versionNumber){
                let alertView:UIAlertController = UIAlertController(title: NSLocalizedString("Found the new version",comment: ""), message: String(format: "Found New version:(%@)", stringVersion!), preferredStyle: UIAlertControllerStyle.Alert)
                let alertAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: UIAlertActionStyle.Default) { (action:UIAlertAction) -> Void in
                    AppTheme.toOpenUpdateURL()
                }
                alertView.addAction(alertAction)

                let alertAction2:UIAlertAction = UIAlertAction(title: nil, style: UIAlertActionStyle.Cancel, handler: nil)
                alertView.addAction(alertAction2)
                self.presentViewController(alertView, animated: true, completion: nil)
            }else{
                MBProgressHUD.showSuccess(NSLocalizedString("nevolatestversion",comment: ""))
            }
        })
    }

    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 45.0
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        if(section == 0){
            let headerimage:UIImageView = MyNevoHeaderView.getMyNevoHeaderView()
            return headerimage.frame.size.height
        }
        return 0
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if(indexPath.row == 0){
            //if(AppDelegate.getAppDelegate().getSoftwareVersion().integerValue > buildinSoftwareVersion && AppDelegate.getAppDelegate().getFirmwareVersion().integerValue > buildinFirmwareVersion){return}
            let otaCont:NevoOtaViewController = NevoOtaViewController()
            let navigation:UINavigationController = UINavigationController(rootViewController: otaCont)
            //self.presentViewController(navigation, animated: true, completion: nil)

        }

        if(indexPath.row == 2){
            //checkUpdateVersion()
        }
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView{
        let headerimage:UIImageView = MyNevoHeaderView.getMyNevoHeaderView()
        let view:UIView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, headerimage.frame.size.height))
        view.addSubview(headerimage)
        headerimage.center = CGPointMake(view.frame.size.width/2.0, view.frame.size.height/2.0)
        return view
    }

    // MARK: - UITableViewDataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1

    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return titleArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var detailString:String = ""
        switch (indexPath.row){
        case 0:
            detailString = "MCU:\(AppDelegate.getAppDelegate().getSoftwareVersion()) BLE:\(AppDelegate.getAppDelegate().getFirmwareVersion())"
            //buildinSoftwareVersion:Int = 0 buildinFirmwareVersion:Int = 0
        case 1:
            detailString = "Battery:\(currentBattery)%"
            if(currentBattery<40){
                //detailString = "Battery low"
            }else{
                //detailString = "Battery enough"
            }
        case 2:
            let loclString:String = (NSBundle.mainBundle().infoDictionary! as NSDictionary).objectForKey("CFBundleShortVersionString") as! String
            detailString = loclString
        default: detailString = "Battery low"
        }
        return MyNevoView.getMyNevoViewTableViewCell(indexPath, tableView: tableView, title: titleArray[indexPath.row], detailText: detailString)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
