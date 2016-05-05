//
//  MenuViewController.swift
//  Drone
//
//  Created by Karl-John on 7/3/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import SwiftEventBus
import NVActivityIndicatorView

class MenuViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet var menuTableView: UITableView!
    let identifier = "menu_cell_identifier"

    var menuItems: [MenuItem] = []
    
    init() {
        super.init(nibName: "MenuViewController", bundle: NSBundle.mainBundle())
        self.menuItems.append(MenuItem(controller: StepsViewController(), title: "Activities", image: UIImage(named: "icon_activities")!));
        let sleepItem = MenuItem(controller: SleepViewController(), title: "Sleep",image: UIImage(named: "icon_sleep")!)
        sleepItem.commingSoon = true;
        self.menuItems.append(sleepItem);
        self.menuItems.append(MenuItem(controller: WorldClockViewController(), title: "World\nClock",image: UIImage(named: "icon_world_clock")!))
        let galleryItem = MenuItem(controller: GalleryViewController(), title: "Gallery",image: UIImage(named: "icon_gallery")!)
        galleryItem.commingSoon = true
        self.menuItems.append(galleryItem)
        self.menuItems.append(MenuItem(controller: SettingsViewController(), title: "Settings",image: UIImage(named: "icon_settings")!));
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
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "gradually"), forBarMetrics: UIBarMetrics.Default)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        menuTableView.registerNib(UINib(nibName: "MenuViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: identifier)
//        AppDelegate.getAppDelegate().startConnect()
        
        SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_RAWPACKET_DATA_KEY) { (notification) -> Void in
            let data:[UInt8] = NSData2Bytes((notification.object as! RawPacketImpl).getRawData())
            NSLog("SWIFTEVENT_BUS_RAWPACKET_DATA_KEY  :\(data)")
        }

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

    // MARK: - left or right Action
    func leftAction(item:UIBarButtonItem) {
        let profileNavigationController = UINavigationController(rootViewController: ProfileViewController())
        profileNavigationController.navigationBar.setBackgroundImage(UIImage(named: "gradually"), forBarMetrics: UIBarMetrics.Default)
        self.presentViewController(profileNavigationController, animated: true) {}
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
        self.navigationController?.pushViewController(item.menuViewControllerItem, animated: true)
        menuTableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat((menuTableView.frame.height/3));
    }
    
    func profileAction(){
        self.navigationController?.pushViewController(ProfileSetupViewController(), animated: true)
    }
}