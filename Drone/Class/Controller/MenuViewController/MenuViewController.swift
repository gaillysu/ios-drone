//
//  MenuViewController.swift
//  Drone
//
//  Created by Karl-John on 7/3/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import SwiftEventBus
import XCGLogger
import MRProgress
import SwiftyJSON
import SwiftyTimer

class MenuViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet var menuTableView: UITableView!
    let identifier = "menu_cell_identifier"

    var menuItems: [MenuItem] = []
    
    init() {
        super.init(nibName: "MenuViewController", bundle: NSBundle.mainBundle())
        self.menuItems.append(MenuItem(controllerName: "StepsViewController", title: "Activities", image: UIImage(named: "icon_activities")!));
        
        self.menuItems.append(MenuItem(controllerName: "WorldClockViewController", title: "World\nClock",image: UIImage(named: "icon_world_clock")!))
 
 
        if(GoalModel.getAll().count == 0){
            let goalModel:GoalModel = GoalModel()
            goalModel.goalSteps = 10000
            goalModel.add({ (id, completion) in})
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.getAppDelegate().startConnect()
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "gradually"), forBarMetrics: UIBarMetrics.Default)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        
        menuTableView.registerNib(UINib(nibName: "MenuViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: identifier)
        AppDelegate.getAppDelegate().startConnect()

        SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_GET_SYSTEM_STATUS_KEY) { (notification) -> Void in
            let data:[UInt8] = NSData2Bytes((notification.object as! RawPacketImpl).getRawData())
            NSLog("SWIFTEVENT_BUS_GET_SYSTEM_STATUS_KEY  :\(data)")
        }

        SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_CONNECTION_STATE_CHANGED_KEY) { (notification) -> Void in
            let connectionState:Bool = notification.object as! Bool
            NSLog("SWIFTEVENT_BUS_CONNECTION_STATE_CHANGED_KEY  :\(connectionState)")
            if(connectionState){

                let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1.5 * Double(NSEC_PER_SEC)))
                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                    //setp1: cmd 0x01, set RTC, for every connected Nevo
                    AppDelegate.getAppDelegate().readsystemStatus()
                })
            }
        }
        
        
        SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_BEGIN_BIG_SYNCACTIVITY) { (notification) in
//            let progress = MRProgressOverlayView.showOverlayAddedTo(self.navigationController!.view, title: "Please wait...", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
//            progress.setTintColor(UIColor.getBaseColor())
//            NSTimer.after(120.seconds, {
//                MRProgressOverlayView.dismissAllOverlaysForView(self.navigationController!.view, animated: true)
//            })
        }
        
        SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_END_BIG_SYNCACTIVITY) { (notification) in
            MRProgressOverlayView.dismissAllOverlaysForView(self.navigationController!.view, animated: true)
            let stepsArray:NSArray = UserSteps.getCriteria(String(format: "WHERE syncnext = %@",false))
            var dayDateArray:[NSDate] = []
            for steps in stepsArray{
                let userSteps:UserSteps = steps as! UserSteps
                let date:NSDate = NSDate(timeIntervalSince1970: userSteps.date).beginningOfDay
                var addKey:Bool = true
                for queryDate:NSDate in dayDateArray{
                    if queryDate.isEqualToDate(date) {
                        addKey = false
                        break
                    }
                }
                
                if addKey {
                    dayDateArray.append(date)
                }
            }
            
            if AppDelegate.getAppDelegate().network!.isReachable {
                self.syncServiceDayData(dayDateArray)
            }

        }
        
        SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_BIG_SYNCACTIVITY_DATA) { (notification) in
            let data:[String:Int] = notification.object as! [String:Int]
            let steps:Int = data["dailySteps"]!
            let timerInterval:Int = data["timerInterval"]!
            if (steps != 0) {
                let stepsArray = UserSteps.getCriteria("WHERE date = \(timerInterval)")
                if(stepsArray.count>0) {
                    let step:UserSteps = stepsArray[0] as! UserSteps
                    NSLog("Data that has been saved····")
                    let stepsModel:UserSteps = UserSteps(keyDict: ["id":step.id, "steps":"\(steps)", "distance": "\(0)","date":timerInterval,"syncnext":false])
                    stepsModel.update()
                    
                }else {
                    let stepsModel:UserSteps = UserSteps(keyDict: ["id":0, "steps":"\(steps)",  "distance": "\(0)", "date":timerInterval,"syncnext":false])
                    stepsModel.add({ (id, completion) -> Void in
                        
                    })
                    
                }
            }

        }
        

        let profileButton:UIButton = UIButton(type: UIButtonType.Custom)
        profileButton.setImage(UIImage(named: "icon_profile"), forState: UIControlState.Normal)
        profileButton.frame = CGRectMake(0, 0, 45, 45);
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileButton)
        profileButton.addTarget(self, action: #selector(MenuViewController.leftAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let addWatchButton:UIButton = UIButton(type: UIButtonType.Custom)
        addWatchButton.setImage(UIImage(named: "icon_add_watch"), forState: UIControlState.Normal)
        addWatchButton.frame = CGRectMake(0, 0, 45, 45)
        addWatchButton.addTarget(self, action: #selector(MenuViewController.rightAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addWatchButton);
        
        var titleView : UIImageView
        titleView = UIImageView(frame:CGRectMake(0, 0, 50, 70))
        titleView.contentMode = .ScaleAspectFit
        titleView.image = UIImage(named: "drone_logo")
        self.navigationItem.titleView = titleView
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        //add test steps data function
        /**
        for index:Int in 0..<31 {
            let date:NSDate = NSDate()
            let timerInterval:Int = Int(date.beginningOfMonth.timeIntervalSince1970)
            let daySeconds:Int = 86400
            for timerIndex:Int in 8..<21 {
                let randomSteps:Int = Int(arc4random()%500)
                let randomHour:Int = Int(arc4random()%10)*5
                let currentDate:Int = timerInterval + (index*daySeconds) + (timerIndex*3600) + (randomHour*60)
                let stepsModel:UserSteps = UserSteps(keyDict: ["id":0, "steps":"\(randomSteps)",  "distance": "\(0)", "date":NSTimeInterval(currentDate),"syncnext":false])
                stepsModel.add({ (id, completion) -> Void in
                    XCGLogger.defaultInstance().debug("stepsModel.add completion:\(Bool(completion!))")
                })
            }
            
        }*/
        
    }
    
    override func viewWillAppear(animated: Bool) {
        if (UserProfile.getAll().count == 0){
            let navigationController = UINavigationController(rootViewController:WelcomeViewController());
            navigationController.navigationBarHidden = true
            self.presentViewController(navigationController, animated: true, completion: nil);
        }
    }

    func leftAction(item:UIBarButtonItem) {
        if (UserProfile.getAll().count == 0){
            let navigationController = UINavigationController(rootViewController:WelcomeViewController());
            navigationController.navigationBarHidden = true
            self.presentViewController(navigationController, animated: true, completion: nil);
            
        }else{
            let profileNavigationController = UINavigationController(rootViewController: ProfileViewController())
            profileNavigationController.navigationBar.setBackgroundImage(UIImage(named: "gradually"), forBarMetrics: UIBarMetrics.Default)
            self.presentViewController(profileNavigationController, animated: true) {}
        }
    }

    func rightAction(item:UIBarButtonItem) {
        self.navigationController?.title = "WATCH SETTINGS"
        self.navigationController?.pushViewController(MyDeviceViewController(), animated: true);
    }
    
    
    //Will be no sync of data sync to the server
    func syncServiceDayData(dayDateArray:[NSDate]) {
        
        var dayData:[String:String] = [:]
        var dayTime:[Double] = []
        var cidArray:[Int] = []
        for day:NSDate in dayDateArray {
            var yVals:[[Double]] = []
            var activeTime:Double = 0
            let dayDate:NSDate = day
            var cid:Int = 0
            for hour:Int in 0 ..< 24 {
                let dayTime:NSTimeInterval = NSDate.date(year: dayDate.year, month: dayDate.month, day: dayDate.day, hour: hour, minute: 0, second: 0).timeIntervalSince1970
                let hours:NSArray = UserSteps.getCriteria("WHERE date BETWEEN \(dayTime) AND \(dayTime+3600)") //one hour = 3600s
                var hourData:[Double] = [0,0,0,0,0,0,0,0,0,0,0,0]
                var timer:Double = 0
                for userSteps in hours {
                    let hSteps:UserSteps = userSteps as! UserSteps
                    let minutesDate:NSDate = NSDate(timeIntervalSince1970: hSteps.date)
                    var k:Int = Int(minutesDate.minute/5)
                    if minutesDate.minute == 0 {
                        k = 0
                    }else{
                        minutesDate.minute%5 == 0 ? (k = Int(minutesDate.minute/5)-1):(k = Int(Double(13)/Double(5)))
                    }
                    
                    if hour == minutesDate.hour {
                        hourData[k] = Double(hSteps.steps)
                    }
                    
                    if hSteps.steps>0 {
                        timer+=5
                    }
                    
                    if cid != hSteps.cid {
                        cid = hSteps.cid
                    }
                    hSteps.syncnext = true
                    hSteps.update()
                }
                activeTime = activeTime+timer
                yVals.append(hourData);
            }
            
            let dailySteps = AppTheme.toJSONString(yVals)
            let date:NSDate = dayDate
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = "\(formatter.stringFromDate(date))"
            dayData[dateString] = "\(dailySteps)"
            dayTime.append(activeTime)
            cidArray.append(cid)
        }
        
        var cidIndex:Int = 0
        for (keys,value) in dayData {
            let cid:Int = cidArray[cidIndex]
            if cid>0 {
                self.updateToServerData(cid, key: keys, value: value)
            }else{
                self.createToServerData(keys, value: value)
            }
            cidIndex += 1
        }
    
    }
 
    func updateToServerData(cid:Int,key:String,value:String) {
        let userProfle:NSArray = UserProfile.getAll()
        let profile:UserProfile = userProfle.objectAtIndex(0) as! UserProfile
        
        //create steps network global queue
        let queue:dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        let group = dispatch_group_create()
        
        dispatch_group_async(group, queue, {
            HttpPostRequest.postRequest("http://drone.karljohnchow.com/steps/update", data: ["steps": ["id":"\(cid)","uid": "\(profile.id)","steps": "\(value)","date": "\(key)","active_time":0]], completion: { (result) in
                let json = JSON(result)
                let message = json["message"].stringValue
                let status = json["status"].intValue
                
                if status == 1{
                    let date = json["steps"].dictionaryValue["date"]?.dictionaryValue["date"]?.stringValue
                    XCGLogger.defaultInstance().debug(date!+message+"cloud update succeed")
                }else{
                    XCGLogger.defaultInstance().debug("\(key)"+message+"cloud update error")
                }
            })
        })
        
        
        dispatch_group_notify(group, queue, {
            XCGLogger.defaultInstance().debug("create steps completed")
        })
    }
    
    func createToServerData(key:String,value:String) {
        let userProfle:NSArray = UserProfile.getAll()
        let profile:UserProfile = userProfle.objectAtIndex(0) as! UserProfile
        
        //create steps network global queue
        let queue:dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        let group = dispatch_group_create()
        
        dispatch_group_async(group, queue, {
            HttpPostRequest.postRequest("http://drone.karljohnchow.com/steps/create", data: ["steps": ["uid": "\(profile.id)","steps": "\(value)","date": "\(key)","active_time":0]], completion: { (result) in
                let json = JSON(result)
                let message = json["message"].stringValue
                let status = json["status"].intValue
                
                if status == 1{
                    let date = json["steps"].dictionaryValue["date"]?.dictionaryValue["date"]?.stringValue
                    XCGLogger.defaultInstance().debug(date!+message+"cloud create succeed")
                }else{
                    XCGLogger.defaultInstance().debug("\(key)"+message+"cloud create error")
                }
            })
        })
        
        
        dispatch_group_notify(group, queue, {
            XCGLogger.defaultInstance().debug("create steps completed")
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: MenuViewCell = menuTableView.dequeueReusableCellWithIdentifier(identifier) as! MenuViewCell
        let item:MenuItem = self.menuItems[indexPath.row]
        cell.menuItemLabel.text = item.menuTitle.uppercaseString
        cell.menuItemLabel.highlightedTextColor = UIColor.whiteColor()
        cell.imageView?.image = item.image;
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.getTintColor()
        cell.selectedBackgroundView = bgColorView
        if(item.commingSoon){
            cell.userInteractionEnabled = false;
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item:MenuItem = self.menuItems[indexPath.row]

        let infoDictionary:[String : AnyObject] = NSBundle.mainBundle().infoDictionary!
        let appName:String = infoDictionary["CFBundleName"] as! String

        //Use the init of class name
        let classType: AnyObject.Type = NSClassFromString("\(appName)."+item.menuViewControllerItem)!
        let controllerType : UIViewController.Type = classType as! UIViewController.Type
        let viewController: UIViewController = controllerType.init()

        menuTableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat((menuTableView.frame.height/3));
    }
    
    func profileAction(){
        self.navigationController?.pushViewController(ProfileSetupViewController(), animated: true)
    }
}