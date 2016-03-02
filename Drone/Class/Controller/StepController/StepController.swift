//
//  StepController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/2.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

let NUMBER_OF_STEPS_GOAL_KEY = "NUMBER_OF_STEPS_GOAL_KEY"

class StepController: PublicClassController,UIActionSheetDelegate,SyncControllerDelegate,ClockRefreshDelegate {
    private var rightButton:UIBarButtonItem?
    var waveProgressView:WaveProgressView?
    var goalLabel:UILabel?
    private var goalArray:[Int] = []

    init() {
        super.init(nibName: "StepController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.title = NSLocalizedString("stepGoalTitle", comment: "")
        self.navigationItem.title = "Steps"
        AppDelegate.getAppDelegate().startConnect(false, delegate: self);
        
        rightButton = UIBarButtonItem(title: "Set Goal", style: UIBarButtonItemStyle.Done, target: self, action: Selector("rightBarButtonAction:"))
        rightButton?.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        self.navigationItem.rightBarButtonItem = rightButton

        let leftButton = UIBarButtonItem(title: "AppConfig", style: UIBarButtonItemStyle.Done, target: self, action: Selector("leftBarButtonAction:"))
        leftButton.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
        self.navigationItem.leftBarButtonItem = leftButton

        ClockRefreshManager.sharedInstance.setRefreshDelegate(self)

        //GetStepsGoalRequest
        waveProgressView = WaveProgressView(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width/2.0, 40,UIScreen.mainScreen().bounds.width-40, UIScreen.mainScreen().bounds.width-40))
        waveProgressView?.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2.0, waveProgressView!.center.y)
        //waveProgressView.backgroundImageView?.image = UIImage(named: "clockView600")!
        waveProgressView?.waveViewMargin = UIEdgeInsetsMake(15.0, 15.0, 20.0, 20.0);
        waveProgressView?.numberLabel?.text = "6000";
        waveProgressView?.numberLabel?.font = UIFont.boldSystemFontOfSize(70)
        waveProgressView?.numberLabel?.textColor = AppTheme.NEVO_CUSTOM_COLOR(Red: 45, Green: 61, Blue: 134)
        waveProgressView?.explainLabel?.text = "Steps";
        waveProgressView?.explainLabel?.font = UIFont.systemFontOfSize(20)
        waveProgressView?.explainLabel?.textColor = AppTheme.NEVO_CUSTOM_COLOR(Red: 45, Green: 61, Blue: 134)
        waveProgressView?.percent = 0.0;
        self.view.addSubview(waveProgressView!)
        waveProgressView?.startWave()

        goalLabel = UILabel(frame: CGRectMake(0,waveProgressView!.frame.size.height+waveProgressView!.frame.origin.y+20,150,30))
        goalLabel?.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2.0, goalLabel!.center.y)
        goalLabel?.textAlignment = NSTextAlignment.Center
        goalLabel?.text = "Goal:7000"
        self.view.addSubview(goalLabel!)

    }

    override func viewDidAppear(animated: Bool) {
        let array:NSArray = Presets.getAll()
        goalArray.removeAll()
        for pArray in array {
            let model:Presets = pArray as! Presets
            if(model.status){
                goalArray.append(model.steps)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - ClockRefreshDelegate
    func clockRefreshAction(){
        AppDelegate.getAppDelegate().sendRequest(GetStepsGoalRequest())
    }

    func leftBarButtonAction(leftBar:UIBarButtonItem) {
        AppDelegate.getAppDelegate().sendRequest(SetSystemConfig())
        sleep(1)
        AppDelegate.getAppDelegate().sendRequest(SetRTCRequest())
        sleep(1)
        AppDelegate.getAppDelegate().sendRequest(AppConfigRequest())
        sleep(1)
        self.setGoal(NumberOfStepsGoal(steps: 7000))
    }

    func rightBarButtonAction(rightBar:UIBarButtonItem){

        if((UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0){
            
            let actionSheet:UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            actionSheet.view.tintColor = AppTheme.NEVO_SOLAR_YELLOW()

            let alertAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
            actionSheet.addAction(alertAction)

            for steps:Int in goalArray {
                let alertAction2:UIAlertAction = UIAlertAction(title: "\(steps) steps", style: UIAlertActionStyle.Default) { (action:UIAlertAction) -> Void in
                    if((action.title! as NSString).isEqualToString("\(steps) steps")){
                        NSUserDefaults.standardUserDefaults().setObject(steps, forKey: NUMBER_OF_STEPS_GOAL_KEY)
                        self.setGoal(NumberOfStepsGoal(steps: steps))
                    }
                }
                actionSheet.addAction(alertAction2)
            }
            self.presentViewController(actionSheet, animated: true, completion: nil)
        }else{
            let actionSheet:UIActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil)
            for steps in goalArray {
                actionSheet.addButtonWithTitle("\(steps) steps")
            }
            for button:UIView in actionSheet.subviews{
                button.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
                button.backgroundColor = AppTheme.NEVO_SOLAR_YELLOW()
            }
            actionSheet.layer.backgroundColor = AppTheme.NEVO_SOLAR_YELLOW().CGColor
            actionSheet.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
            actionSheet.actionSheetStyle = UIActionSheetStyle.Default;
            actionSheet.showInView(self.view)
        }
    }


    // MARK: - UIActionSheetDelegate
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int){
        if(buttonIndex != 0){
            NSUserDefaults.standardUserDefaults().setObject(goalArray[buttonIndex-1], forKey: NUMBER_OF_STEPS_GOAL_KEY)
            setGoal(NumberOfStepsGoal(steps: goalArray[buttonIndex-1]))
        }
    }

    func willPresentActionSheet(actionSheet: UIActionSheet){
        for subViwe in actionSheet.subviews{
            subViwe.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
            if(subViwe.isKindOfClass(UIButton.classForCoder())){
                let button:UIButton = subViwe as! UIButton
                button.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
            }
        }
    }

    func setGoal(goal:Goal) {
        AppDelegate.getAppDelegate().setGoal(goal)
    }

    // MARK: - SyncControllerDelegate
    func packetReceived(packet:RawPacket) {
        //Do nothing
        if packet.getHeader() == GetStepsGoalRequest.HEADER(){
            let data:[UInt8] = NSData2Bytes(packet.getRawData())
            var dailySteps:Int = Int(data[7])
            dailySteps =  dailySteps + Int(data[8])<<8
            dailySteps =  dailySteps + Int(data[9])<<16
            dailySteps =  dailySteps + Int(data[10])<<24

            var goal:Int = Int(data[2] )
            goal =  goal + Int(data[3])<<8
            goal =  goal + Int(data[4])<<16
            goal =  goal + Int(data[5])<<24

            goalLabel?.text = "Goal:\(goal)"
            waveProgressView?.percent = CGFloat(dailySteps)/CGFloat(goal);
            waveProgressView?.numberLabel?.text = "\(dailySteps)";
            waveProgressView?.startWave()
            AppTheme.DLog("get Daily Steps is: \(NSData2Bytes(packet.getRawData())))")


        }

    }

    func connectionStateChanged(isConnected : Bool) {
        //Maybe we just got disconnected, let's check

    }

    /**
     *  Receiving the current device signal strength value
     */
    func receivedRSSIValue(number:NSNumber){
        //NSLog("RSSI   :%@",number)
    }
    /**
     *  Data synchronization is complete callback
     */
    func syncFinished(){
        
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
