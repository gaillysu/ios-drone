//
//  alarmClockController.swift
//  Nevo
//
//  Created by leiyuncun on 15/2/12.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class AlarmClockController: UITableViewController, SyncControllerDelegate,AddAlarmDelegate {
    @IBOutlet var alarmView: alarmClockView!

    private var slectedIndex:Int = -1 //To edit a record the number of rows selected content
    var alarmArray:[Alarm] = []
    var mAlarmArray:[UserAlarm] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        alarmView.bulidAlarmView()
        
        AppDelegate.getAppDelegate().startConnect(false, delegate: self)
        self.editButtonItem().tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let rightAddButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("controllManager:"))
        //
        rightAddButton.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        self.navigationItem.rightBarButtonItem = rightAddButton

        self.tableView.allowsSelectionDuringEditing = true;

        let array:NSArray = UserAlarm.getAll()
        for alarmModel in array{
            let useralarm:UserAlarm = alarmModel as! UserAlarm
            mAlarmArray.append(useralarm)

            let date:NSDate = NSDate(timeIntervalSince1970: useralarm.timer)
            let alarm:Alarm = Alarm(index:mAlarmArray.count, hour: date.hour, minute: date.minute, enable: useralarm.status)
            alarmArray.append(alarm)
        }
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        checkConnection()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - ButtonManagerCallBack
    /*
    call back Button Action
    */
    func controllManager(sender:AnyObject){

        if(sender.isKindOfClass(UIBarButtonItem.classForCoder())){
            let addAlarm:AddAlarmController = AddAlarmController()
            addAlarm.mDelegate = self
            addAlarm.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(addAlarm, animated: true)
        }

        if(sender.isKindOfClass(UISwitch.classForCoder())){
            let mSwitch:UISwitch = sender as! UISwitch
            let addalarm:UserAlarm = UserAlarm(keyDict: ["id":mAlarmArray[mSwitch.tag].id,"timer":mAlarmArray[mSwitch.tag].timer,"label":"\(mAlarmArray[mSwitch.tag].label)","status":mSwitch.on,"repeatStatus":mAlarmArray[mSwitch.tag].repeatStatus])
            if(addalarm.update()){
                mAlarmArray.removeAtIndex(mSwitch.tag)
                mAlarmArray.append(addalarm)
                self.tableView.reloadData()

                let date:NSDate = NSDate(timeIntervalSince1970: addalarm.timer)
                let alarm:Alarm = Alarm(index:mAlarmArray.count, hour: date.hour, minute: date.minute, enable: mSwitch.on)
                alarmArray.removeAtIndex(mSwitch.tag)
                alarmArray.append(alarm)
                //AppDelegate.getAppDelegate().setAlarm(alarmArray)
            }

        }

    }

    // MARK: - AddAlarmDelegate
    func onDidAddAlarmAction(timer:NSTimeInterval,repeatStatus:Bool,name:String){

        if(mAlarmArray.count==3){
            let aler:UIAlertView = UIAlertView(title: "Tip", message: "Only add three alarm", delegate: nil, cancelButtonTitle: NSLocalizedString("ok", comment: ""))
            aler.show()
        }else{
            if(slectedIndex >= 0){
                let alarmModel:UserAlarm =  mAlarmArray[slectedIndex]
                let addalarm:UserAlarm = UserAlarm(keyDict: ["id":alarmModel.id,"timer":timer,"label":"\(name)","status":true,"repeatStatus":repeatStatus])
                if(addalarm.update()){
                    mAlarmArray.removeAtIndex(slectedIndex)
                    mAlarmArray.insert(addalarm, atIndex: slectedIndex)
                    self.editing = false
                    self.tableView.setEditing(false, animated: true)
                    self.tableView.reloadData()

                    let date:NSDate = NSDate(timeIntervalSince1970: timer)
                    let alarm:Alarm = alarmArray[slectedIndex]
                    let reAlarm:Alarm = Alarm(index:alarmArray.count, hour: date.hour, minute: date.minute, enable: alarm.getEnable())
                    alarmArray.removeAtIndex(slectedIndex)
                    alarmArray.insert(reAlarm, atIndex: slectedIndex)
                    if(AppDelegate.getAppDelegate().isConnected()){
                        //AppDelegate.getAppDelegate().setAlarm(alarmArray)
                    }
                    slectedIndex = -1
                }
            }else{
                let addalarm:UserAlarm = UserAlarm(keyDict: ["id":0,"timer":timer,"label":"\(name)","status":true,"repeatStatus":repeatStatus])
                addalarm.add({ (id, completion) -> Void in
                    if(completion!){
                        addalarm.id = id!
                        self.mAlarmArray.append(addalarm)
                        self.tableView.reloadData()

                        let date:NSDate = NSDate(timeIntervalSince1970: timer)
                        let alarm:Alarm = Alarm(index:self.alarmArray.count, hour: date.hour, minute: date.minute, enable: true)
                        self.alarmArray.append(alarm)
                        if(AppDelegate.getAppDelegate().isConnected()){
                            //AppDelegate.getAppDelegate().setAlarm(self.alarmArray)
                        }
                    }else{
                        let aler:UIAlertView = UIAlertView(title: "Tip", message: "Database insert fail", delegate: nil, cancelButtonTitle: "ok")
                        aler.show()
                    }
                })
            }
        }
    }

    // MARK: - SyncControllerDelegate
    func receivedRSSIValue(number:NSNumber){

    }

    func packetReceived(packet:RawPacket) {
    
    }

    func connectionStateChanged(isConnected : Bool) {

        //Maybe we just got disconnected, let's check

        //checkConnection()

    }

    func syncFinished(){

    }

    func stringFromDate(date:NSDate) -> String {
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.systemTimeZone()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.dateFormat = "HH:mm a"
        let dateString:String = dateFormatter.stringFromDate(date)
        return dateString
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

    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }


    // MARK: - UITableViewDataSource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{

        return mAlarmArray.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let endCell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("alarmCell", forIndexPath: indexPath)
        let alarmModel:UserAlarm = mAlarmArray[indexPath.row]
        let timerLabel = endCell.contentView.viewWithTag(1500)
        if(timerLabel != nil){
            let date:NSDate = NSDate(timeIntervalSince1970: alarmModel.timer)
            (timerLabel as! UILabel).text = stringFromDate(date)
        }

        let nameLabel = endCell.contentView.viewWithTag(1600)
        if(nameLabel != nil){
            (nameLabel as! UILabel).text = alarmModel.label
        }

        let mSwitch = endCell.contentView.viewWithTag(1700)
        if(mSwitch != nil){
            (mSwitch as! UISwitch).tag = indexPath.row
            (mSwitch as! UISwitch).addTarget(self, action: Selector("controllManager:"), forControlEvents: UIControlEvents.ValueChanged)
            (mSwitch as! UISwitch).on = alarmModel.status
        }

        endCell.selectionStyle = UITableViewCellSelectionStyle.None
        return endCell
    }


    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            if(mAlarmArray[indexPath.row].remove()){
                alarmArray.removeAtIndex(indexPath.row)
                mAlarmArray.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                if(AppDelegate.getAppDelegate().isConnected()){
                    //AppDelegate.getAppDelegate().setAlarm(alarmArray)
                }
            }
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if(self.editing){
            slectedIndex = indexPath.row

            let alarmModel:UserAlarm = mAlarmArray[indexPath.row]
            let addAlarm:AddAlarmController = AddAlarmController()
            addAlarm.timer = alarmModel.timer
            addAlarm.name = alarmModel.label
            addAlarm.repeatStatus = alarmModel.repeatStatus
            addAlarm.mDelegate = self
            addAlarm.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(addAlarm, animated: true)
        }

    }
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }

    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
}
