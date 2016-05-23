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
    private var progress:MRProgressOverlayView?
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
            self.progress = MRProgressOverlayView.showOverlayAddedTo(self.navigationController!.view, title: "Please wait...", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
            self.progress!.setTintColor(UIColor.getBaseColor())
            NSTimer.after(120.seconds, {
                MRProgressOverlayView.dismissAllOverlaysForView(self.navigationController!.view, animated: true)
            })
        }
        
        SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_END_BIG_SYNCACTIVITY) { (notification) in
            MRProgressOverlayView.dismissAllOverlaysForView(self.navigationController!.view, animated: true)
        }
        
        SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_BIG_SYNCACTIVITY_DATA) { (notification) in
            let userProfle:NSArray = UserProfile.getAll()
            let profile:UserProfile = userProfle.objectAtIndex(0) as! UserProfile
            
            let data:[String:Int] = notification.object as! [String:Int]
            let steps:Int = data["dailySteps"]!
            let timerInterval:Int = data["timerInterval"]!
            if (steps != 0) {
                let stepsArray = UserSteps.getCriteria("WHERE date = \(timerInterval)")
                if(stepsArray.count>0) {
                    let step:UserSteps = stepsArray[0] as! UserSteps
                    NSLog("Data that has been saved····")
                    let stepsModel:UserSteps = UserSteps(keyDict: ["id":step.id, "steps":"\(steps)", "distance": "\(0)","date":timerInterval])
                    stepsModel.update()
                    
                    //update steps network global queue
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                        HttpPostRequest.postRequest("http://drone.karljohnchow.com/steps/update", data: ["steps": ["id": "\(stepsModel.id)","uid": "\(profile.id)","steps": "\(data["dailySteps"]!)","date": "\(data["timerInterval"]!)"]], completion: { (result) in
                            
                            let json = JSON(result)
                            let message = json["message"].stringValue
                            let status = json["status"].intValue
                            if status == 1{
                                XCGLogger.defaultInstance().debug("\(message), cloud update succeed")
                            }else{
                                XCGLogger.defaultInstance().debug("\(message), cloud update error")
                            }
                        })
                    })
                    
                }else {
                    let stepsModel:UserSteps = UserSteps(keyDict: ["id":0, "steps":"\(steps)",  "distance": "\(0)", "date":timerInterval])
                    stepsModel.add({ (id, completion) -> Void in
                        
                    })
                    
                    //create steps network global queue
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                        HttpPostRequest.postRequest("http://drone.karljohnchow.com/steps/create", data: ["steps": ["uid": "\(profile.id)","steps": "\(data["dailySteps"]!)","date": "\(data["timerInterval"]!)"]], completion: { (result) in
                            let json = JSON(result)
                            let message = json["message"].stringValue
                            let status = json["status"].intValue
                            if status == 1{
                                XCGLogger.defaultInstance().debug(message+"cloud create succeed")
                            }else{
                                XCGLogger.defaultInstance().debug(message+"cloud create error")
                            }
                        })
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