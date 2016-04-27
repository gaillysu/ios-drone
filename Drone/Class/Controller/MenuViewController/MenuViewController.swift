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
        self.menuItems.append(MenuItem(controller: StepsViewController(), title: "Activity"));
        self.menuItems.append(MenuItem(controller: SleepViewController(), title: "Sleep"));
        self.menuItems.append(MenuItem(controller: WorldClockController(), title: "WorldClock"));
        self.menuItems.append(MenuItem(controller: SettingsViewController(), title: "Settings"));
        self.title = "Drone"
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: #selector(MenuViewController.leftAction(_:)))

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: #selector(MenuViewController.rightAction(_:)))
    }

    // MARK: - left or right Action
    func leftAction(item:UIBarButtonItem) {

    }

    func rightAction(item:UIBarButtonItem) {
        
    }
 
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: MenuViewCell = menuTableView.dequeueReusableCellWithIdentifier(identifier) as! MenuViewCell
        let item:MenuItem = self.menuItems[indexPath.row]
        cell.menuItemLabel.text = item.menuTitle
        cell.selected = true;
        return cell
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let item:MenuItem = self.menuItems[indexPath.row]
        self.navigationController?.pushViewController(item.menuViewControllerItem, animated: true)
        menuTableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: (collectionView.frame.height/3) - 21)
    }
   
    
    func profileAction(){
        self.navigationController?.pushViewController(ProfileSetupViewController(), animated: true)
    }
}