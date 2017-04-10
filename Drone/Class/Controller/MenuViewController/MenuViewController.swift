//
//  MenuViewController.swift
//  Drone
//
//  Created by Karl-John on 7/3/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import SwiftEventBus

import MRProgress
import SwiftyJSON
import SwiftyTimer
import UIKit
import RealmSwift

class MenuViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet var menuTableView: UITableView!
    let identifier = "menu_cell_identifier"

    var menuItems: [MenuItem] = []
    
    init() {
        super.init(nibName: "MenuViewController", bundle: Bundle.main)
        self.menuItems.append(MenuItem(controllerName: "StepsViewController", title: "Activities", image: UIImage(named: "icon_activities")!));
        
        self.menuItems.append(MenuItem(controllerName: "WorldClockViewController", title: "World\nClock",image: UIImage(named: "icon_world_clock")!))
        if(UserGoal.getAll().count == 0){
            let goalModel:UserGoal = UserGoal()
            goalModel.goalSteps = 10000
            goalModel.label = " "
            goalModel.status = true
            _ = goalModel.add()
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "gradually"), for: UIBarMetrics.default)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
       
        menuTableView.register(UINib(nibName: "MenuViewCell", bundle: Bundle.main), forCellReuseIdentifier: identifier)
        AppDelegate.getAppDelegate().startConnect()

        if AppDelegate.getAppDelegate().network!.isReachable {
            StepsManager.sharedInstance.syncLastSevenDaysData()
        }
        
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
            
            let stepsArray = UserSteps.getFilter("syncnext == \(false)")
            var dayDateArray:[Date] = []
            for steps in stepsArray{
                let userSteps:UserSteps = steps as! UserSteps
                let date:Date = Date(timeIntervalSince1970: userSteps.date).beginningOfDay
                dayDateArray.append(date)
            }
            
            if AppDelegate.getAppDelegate().network!.isReachable {
                StepsManager.sharedInstance.syncServiceDayData(dayDateArray)
            }
        }
        
        _ = SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_BIG_SYNCACTIVITY_DATA) { (notification) in
            let data = notification.object as! (timerInterval:Int,dailySteps:Int)
            let steps:Int = data.dailySteps
            let timerInterval:Int = data.timerInterval
            if (steps != 0) {
                let stepsArray = UserSteps.getFilter("date == \(timerInterval)")
                if(stepsArray.count>0) {
                    let step:UserSteps = stepsArray[0] as! UserSteps
                    NSLog("Data that has been saved····")
                    let realm = try! Realm()
                    try! realm.write({
                        step.steps = steps
                        step.date = TimeInterval(timerInterval)
                        step.syncnext = true
                    })
                    
                }else {
                    let stepsModel:UserSteps = UserSteps()
                    stepsModel.id = Int(Date().timeIntervalSince1970)
                    stepsModel.distance = 0
                    stepsModel.steps = steps
                    stepsModel.date = TimeInterval(timerInterval)
                    stepsModel.syncnext = false
                    _ = stepsModel.add()
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
        titleView = UIImageView(frame:CGRect(x: 0, y: 0, width: 40, height: 30))
        titleView.backgroundColor = UIColor.clear
        titleView.contentMode = .scaleAspectFit
        titleView.image = UIImage(named: "drone_logo")
        self.navigationItem.titleView = titleView
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        if(UserDevice.getAll().count == 0){
            let navigationController:UINavigationController = UINavigationController(rootViewController: WhichDeviceViewController(toMenu: false))
            navigationController.navigationBar.isHidden = true
            self.navigationController?.present(navigationController, animated: true, completion: nil)
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
        if (indexPath.row == 0){
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
                    self.tableItemClicked(index: indexPath.row)

                }))
                self.present(alertController, animated: true, completion: nil)
            }
        }
        tableItemClicked(index: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableItemClicked(index:Int){
        let item:MenuItem = self.menuItems[index]
        
        let infoDictionary:[String : AnyObject] = Bundle.main.infoDictionary! as [String : AnyObject]
        let appName:String = infoDictionary["CFBundleName"] as! String
        
        //Use the init of class name
        let classType: AnyObject.Type = NSClassFromString("\(appName)."+item.menuViewControllerItem)!
        let controllerType : UIViewController.Type = classType as! UIViewController.Type
        let viewController: UIViewController = controllerType.init()
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat((menuTableView.frame.height/3));
    }
    
    func profileAction(){
        self.navigationController?.pushViewController(ProfileSetupViewController(), animated: true)
    }
}
