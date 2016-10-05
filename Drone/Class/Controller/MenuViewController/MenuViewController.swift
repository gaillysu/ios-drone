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
        super.init(nibName: "MenuViewController", bundle: Bundle.main)
        self.menuItems.append(MenuItem(controllerName: "StepsViewController", title: "Activities", image: UIImage(named: "icon_activities")!));
        
        self.menuItems.append(MenuItem(controllerName: "WorldClockViewController", title: "World\nClock",image: UIImage(named: "icon_world_clock")!))
        self.menuItems.append(MenuItem(controllerName: "PhysioViewController", title: "Exercise",image: UIImage(named: "researcher")!))
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
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "gradually"), for: UIBarMetrics.default)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        
        menuTableView.register(UINib(nibName: "MenuViewCell", bundle: Bundle.main), forCellReuseIdentifier: identifier)
        AppDelegate.getAppDelegate().startConnect()

        _ = SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_GET_SYSTEM_STATUS_KEY) { (notification) -> Void in
            let data:[UInt8] = NSData2Bytes((notification.object as! RawPacketImpl).getRawData())
            NSLog("SWIFTEVENT_BUS_GET_SYSTEM_STATUS_KEY  :\(data)")
        }

        _ = SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_CONNECTION_STATE_CHANGED_KEY) { (notification) -> Void in
            let connectionState:Bool = notification.object as! Bool
            if(connectionState){

                let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(1.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                    //setp1: cmd 0x01, set RTC, for every connected Nevo
                    AppDelegate.getAppDelegate().readsystemStatus()
                })
            }
        }
        
        _ = SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_BEGIN_BIG_SYNCACTIVITY) { (notification) in
        }
        
        _ = SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_END_BIG_SYNCACTIVITY) { (notification) in
            MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
            let stepsArray:NSArray = UserSteps.getCriteria(String(format: "WHERE syncnext = \(false)"))
            var dayDateArray:[Date] = []
            for steps in stepsArray{
                let userSteps:UserSteps = steps as! UserSteps
                let date:Date = Date(timeIntervalSince1970: userSteps.date).beginningOfDay
                var addKey:Bool = true
                for queryDate:Date in dayDateArray{
                    if queryDate == date {
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
        
        _ = SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_BIG_SYNCACTIVITY_DATA) { (notification) in
            let data:[String:Int] = notification.object as! [String:Int]
            let steps:Int = data["dailySteps"]!
            let timerInterval:Int = data["timerInterval"]!
            if (steps != 0) {
                let stepsArray = UserSteps.getCriteria("WHERE date = \(timerInterval)")
                if(stepsArray.count>0) {
                    let step:UserSteps = stepsArray[0] as! UserSteps
                    NSLog("Data that has been saved····")
                    let stepsModel:UserSteps = UserSteps(keyDict: ["id":step.id, "steps":"\(steps)", "distance": "\(0)","date":timerInterval,"syncnext":false])
                    _ = stepsModel.update()
                    
                }else {
                    let stepsModel:UserSteps = UserSteps(keyDict: ["id":0, "steps":"\(steps)",  "distance": "\(0)", "date":timerInterval,"syncnext":false])
                    stepsModel.add({ (id, completion) -> Void in
                        
                    })
                    
                }
            }

        }
        

        let profileButton:UIButton = UIButton(type: UIButtonType.custom)
        profileButton.setImage(UIImage(named: "icon_profile"), for: UIControlState())
        profileButton.frame = CGRect(x: 0, y: 0, width: 45, height: 45);
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileButton)
        profileButton.addTarget(self, action: #selector(MenuViewController.leftAction(_:)), for: UIControlEvents.touchUpInside)
        
        let addWatchButton:UIButton = UIButton(type: UIButtonType.custom)
        addWatchButton.setImage(UIImage(named: "icon_add_watch"), for: UIControlState())
        addWatchButton.frame = CGRect(x: 0, y: 0, width: 45, height: 45)
        addWatchButton.addTarget(self, action: #selector(MenuViewController.rightAction(_:)), for: UIControlEvents.touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addWatchButton);
        
        var titleView : UIImageView
        titleView = UIImageView(frame:CGRect(x: 0, y: 0, width: 50, height: 70))
        titleView.contentMode = .scaleAspectFit
        titleView.image = UIImage(named: "drone_logo")
        self.navigationItem.titleView = titleView
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (UserProfile.getAll().count == 0){
            let alertController = UIAlertController(title: "No user logged in", message: "Do you want to login?", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { action in
                let navigationController = UINavigationController(rootViewController:WelcomeViewController());
                navigationController.isNavigationBarHidden = true
                self.present(navigationController, animated: true, completion: nil);
                alertController.dismiss(animated: true, completion: nil)
            }))
            alertController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: { action in
                alertController.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }

    func leftAction(_ item:UIBarButtonItem) {
        if (UserProfile.getAll().count == 0){
            let navigationController = UINavigationController(rootViewController:WelcomeViewController());
            navigationController.isNavigationBarHidden = true
            self.present(navigationController, animated: true, completion: nil);
            
        }else{
            let profileNavigationController = UINavigationController(rootViewController: ProfileViewController())
            profileNavigationController.navigationBar.setBackgroundImage(UIImage(named: "gradually"), for: UIBarMetrics.default)
            self.present(profileNavigationController, animated: true) {}
        }
    }

    func rightAction(_ item:UIBarButtonItem) {
        self.navigationController?.title = "WATCH SETTINGS"
        self.navigationController?.pushViewController(MyDeviceViewController(), animated: true);
    }
    
    
    //Will be no sync of data sync to the server
    func syncServiceDayData(_ dayDateArray:[Date]) {
        
        var dayData:[String:String] = [:]
        var dayTime:[Double] = []
        var cidArray:[Int] = []
        for day:Date in dayDateArray {
            var yVals:[[Double]] = []
            var activeTime:Double = 0
            let dayDate:Date = day
            var cid:Int = 0
            for hour:Int in 0 ..< 24 {
                let dayTime:TimeInterval = Date.date(year: dayDate.year, month: dayDate.month, day: dayDate.day, hour: hour, minute: 0, second: 0).timeIntervalSince1970
                let hours:NSArray = UserSteps.getCriteria("WHERE date BETWEEN \(dayTime) AND \(dayTime+3600)") //one hour = 3600s
                var hourData:[Double] = [0,0,0,0,0,0,0,0,0,0,0,0]
                var timer:Double = 0
                for userSteps in hours {
                    let hSteps:UserSteps = userSteps as! UserSteps
                    let minutesDate:Date = Date(timeIntervalSince1970: hSteps.date)
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
                    _ = hSteps.update()
                }
                activeTime = activeTime+timer
                yVals.append(hourData);
            }
            
            let dailySteps = AppTheme.toJSONString(yVals as AnyObject!)
            let date:Date = dayDate
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = "\(formatter.string(from: date))"
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
 
    func updateToServerData(_ cid:Int,key:String,value:String) {
        let userProfle:NSArray = UserProfile.getAll()
        let profile:UserProfile = userProfle.object(at: 0) as! UserProfile
        
        //create steps network global queue
        let queue:DispatchQueue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)
        let group = DispatchGroup()
        
        queue.async(group: group, execute: {
            HttpPostRequest.postRequest("http://drone.karljohnchow.com/steps/update", data: ["steps": ["id":"\(cid)","uid": "\(profile.id)","steps": "\(value)","date": "\(key)","active_time":0]], completion: { (result) in
                let json = JSON(result)
                let message = json["message"].stringValue
                let status = json["status"].intValue
                
                if status == 1{
                    let date = json["steps"].dictionaryValue["date"]?.dictionaryValue["date"]?.stringValue
                    XCGLogger.debug(date!+message+"cloud update succeed")
                }else{
                    XCGLogger.debug("\(key)"+message+"cloud update error")
                }
            })
        })
        
        
        group.notify(queue: queue, execute: {
            XCGLogger.default.debug("create steps completed")
        })
    }
    
    func createToServerData(_ key:String,value:String) {
        let userProfle:NSArray = UserProfile.getAll()
        let profile:UserProfile = userProfle.object(at: 0) as! UserProfile
        
        //create steps network global queue
        let queue:DispatchQueue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)
        let group = DispatchGroup()
        
        queue.async(group: group, execute: {
            HttpPostRequest.postRequest("http://drone.karljohnchow.com/steps/create", data: ["steps": ["uid": "\(profile.id)","steps": "\(value)","date": "\(key)","active_time":0]], completion: { (result) in
                let json = JSON(result)
                let message = json["message"].stringValue
                let status = json["status"].intValue
                
                if status == 1{
                    let date = json["steps"].dictionaryValue["date"]?.dictionaryValue["date"]?.stringValue
                    XCGLogger.debug(date!+message+"cloud create succeed")
                }else{
                    XCGLogger.debug("\(key)"+message+"cloud create error")
                }
            })
        })
        
        
        group.notify(queue: queue, execute: {
            XCGLogger.default.debug("create steps completed")
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MenuViewCell = menuTableView.dequeueReusableCell(withIdentifier: identifier) as! MenuViewCell
        let item:MenuItem = self.menuItems[(indexPath as NSIndexPath).row]
        cell.menuItemLabel.text = item.menuTitle.uppercased()
        cell.menuItemLabel.highlightedTextColor = UIColor.white
        cell.imageView?.image = item.image;
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.getTintColor()
        cell.selectedBackgroundView = bgColorView
        if(item.commingSoon){
            cell.isUserInteractionEnabled = false;
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item:MenuItem = self.menuItems[(indexPath as NSIndexPath).row]

        let infoDictionary:[String : AnyObject] = Bundle.main.infoDictionary! as [String : AnyObject]
        let appName:String = infoDictionary["CFBundleName"] as! String

        //Use the init of class name
        let classType: AnyObject.Type = NSClassFromString("\(appName)."+item.menuViewControllerItem)!
        let controllerType : UIViewController.Type = classType as! UIViewController.Type
        let viewController: UIViewController = controllerType.init()

        menuTableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat((menuTableView.frame.height/3));
    }
    
    func profileAction(){
        self.navigationController?.pushViewController(ProfileSetupViewController(), animated: true)
    }
}
