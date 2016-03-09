//
//  SetingViewController.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/24.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class SettingsViewController: BaseViewController,UIAlertViewDelegate {

    var sources:[String] = []
    var sourcesImage:[String] = []
    var titleArray:[String] = []
    var titleArrayImage:[String] = []
    var selectedB:Bool = false
    //vibrate and show all color light to find my device, only send one request in 6 sec
    //this action take lot power and we maybe told customer less to use it
    var mFindMydeviceDatetime:NSDate = NSDate(timeIntervalSinceNow: -6)
    @IBOutlet var tableListView: UITableView?
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Settings"

        AppDelegate.getAppDelegate().startConnect(false)

        sources = [NSLocalizedString("Link-Loss Notifications", comment: ""),NSLocalizedString("My Drone", comment: "")]
        sourcesImage = ["new_iOS_link_icon","new_iOS_mynevo_iocn"]
        titleArray = [NSLocalizedString("Preset-goals", comment: ""),NSLocalizedString("Find device", comment: ""),NSLocalizedString("World Clock", comment: "")]
        titleArrayImage = ["new_iOS_goals_icon","new_iOS_findmywatch_icon","new_iOS_findmywatch_icon"]
    }

    override func viewDidAppear(animated: Bool) {
        checkConnection()

        let defaults = NSUserDefaults.standardUserDefaults()
        if(defaults.objectForKey("User_Logged_In") != nil){
            if(defaults.objectForKey("User_Logged_In") as! Bool){
                let indexPath = NSIndexPath(forRow: 0, inSection: 2)
                let tableViewCell: UITableViewCell = tableListView!.cellForRowAtIndexPath(indexPath)!
                tableViewCell.backgroundColor=UIColor(red:255/255.0, green: 149/255.0, blue: 38/255.0, alpha: 1.0)
                let loginLabel = tableViewCell.contentView.viewWithTag(1900)
                (loginLabel as! UILabel).text = "Logout"
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 0
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch (indexPath.section){
        case 0:
            if(isEqualString("\(sources[indexPath.row])",string2: NSLocalizedString("My Drone", comment: ""))){
                AppTheme.DLog("My Drone")
                let mynevo:MyDroneController = MyDroneController()
                mynevo.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(mynevo, animated: true)
            }
            break
        case 1:
            if(isEqualString("\(titleArray[indexPath.row])",string2: NSLocalizedString("Find device", comment: ""))){
                AppTheme.DLog("Find device")
                findMydevice()
            }

            if(isEqualString("\(titleArray[indexPath.row])",string2: NSLocalizedString("Preset-goals", comment: ""))){
                AppTheme.DLog("Preset-goals")
                let presetView:GoalTableViewController = GoalTableViewController()
                presetView.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(presetView, animated: true)
            }

            if(isEqualString("\(titleArray[indexPath.row])",string2: NSLocalizedString("World Clock", comment: ""))){
                let worldClock:WorldClockController = WorldClockController()
                worldClock.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(worldClock, animated: true)
            }
        case 2:
            let defaults = NSUserDefaults.standardUserDefaults()
            if(defaults.objectForKey("User_Logged_In") != nil){
                if(defaults.objectForKey("User_Logged_In") as! Bool){
                    defaults.setBool(false, forKey: "User_Logged_In")
                    defaults.setValue("", forKey: "User_Logged_In_UID")
                    defaults.setValue("", forKey: "User_Logged_In_Token")
                    let indexPath = NSIndexPath(forRow: 0, inSection: 2)
                    let tableViewCell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
                    tableViewCell.accessoryType = UITableViewCellAccessoryType.None
                    tableViewCell.backgroundColor=UIColor(red:129.0/255.0, green: 150.0/255.0, blue: 248.0/255.0, alpha: 1.0)
                    let loginLabel = tableViewCell.contentView.viewWithTag(1900)
                    (loginLabel as! UILabel).text = "Login"
                }else{
                    let loginController:LoginController = LoginController()
                    loginController.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(loginController, animated: true)
                }
            }else{
                let loginController:LoginController = LoginController()
                loginController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(loginController, animated: true)
            }
            //WorldClockController
            break
        default: break
        }

    }

    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 3

    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        switch (section){
        case 0:
            return sources.count
        case 1:
            return titleArray.count
        default: return 1;
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (indexPath.section){
        case 0:
            return SetingView.NotificationSystemTableViewCell(indexPath, tableView: tableView, title: sources[indexPath.row] ,imageName:sourcesImage[indexPath.row])

        case 1:
            return SetingView.NotificationSystemTableViewCell(indexPath, tableView: tableView, title: titleArray[indexPath.row] ,imageName:titleArrayImage[indexPath.row])
        case 2:
            let cell = SetingView.NotificationSystemTableViewCell(indexPath, tableView: tableView, title:"" ,imageName:"")
            cell.accessoryType = UITableViewCellAccessoryType.None
            cell.backgroundColor=UIColor(red:129.0/255.0, green: 150.0/255.0, blue: 248.0/255.0, alpha: 1.0)

            var loginLabel = cell.contentView.viewWithTag(1900)
            if(loginLabel == nil){
                loginLabel = UILabel(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,cell.frame.size.height))
                loginLabel?.backgroundColor = UIColor.clearColor()
                loginLabel?.tag = 1900
                (loginLabel as! UILabel).textColor = UIColor.whiteColor()
                (loginLabel as! UILabel).textAlignment = NSTextAlignment.Center
                (loginLabel as! UILabel).text = "Login"
                cell.contentView.addSubview(loginLabel!)
            }
            let defaults = NSUserDefaults.standardUserDefaults()
            if(defaults.objectForKey("User_Logged_In") != nil){
                if(defaults.objectForKey("User_Logged_In") as! Bool){
                    cell.backgroundColor=UIColor(red:255/255.0, green: 149/255.0, blue: 38/255.0, alpha: 1.0)
                    (loginLabel as! UILabel).text = "Logout"
                }
            }
            return cell

        default: return SetingView.NotificationSystemTableViewCell(indexPath, tableView: tableView, title: sources[1] ,imageName:titleArrayImage[indexPath.row]);
        }
    }

    // MARK: - SetingViewController function
    
    func findMydevice(){
        let minDelay:Double = 6
        let offset:Double = (NSDate().timeIntervalSince1970 - mFindMydeviceDatetime.timeIntervalSince1970)
        AppTheme.DLog("findMydevice offset:\(offset)")
        if (offset < minDelay) {
            return
        }
        //AppDelegate.getAppDelegate().SetLedOnOffandVibrator(0x3F0000, motorOnOff: true)
        mFindMydeviceDatetime = NSDate()
    }

    /**
     Checks if any device is currently connected
     */
    func checkConnection() {

        if !AppDelegate.getAppDelegate().isConnected() {
            //We are currently not connected
            reconnect()
        }
    }

    func reconnect() {
        AppDelegate.getAppDelegate().connect()
    }


    // MARK: - UIAlertViewDelegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        if(buttonIndex == 1){
            AppTheme.toOpenUpdateURL()
        }
    }

    func isEqualString(string1:String,string2:String)->Bool{
        let object1:NSString = NSString(format: "\(string1)")
        return object1.isEqualToString(string2)
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    init() {
        super.init(nibName: "SettingsViewController", bundle: NSBundle.mainBundle())
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
