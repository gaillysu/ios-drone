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

class MenuViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate  {
    
    let identifier = "menu_cell_identifier"
    
    @IBOutlet weak var collectionView: UICollectionView!

    var menuItems: [MenuItem] = []
    
    init() {
        super.init(nibName: "MenuViewController", bundle: NSBundle.mainBundle())
        self.menuItems.append(MenuItem(controller: ActivityViewController(), title: "Activity"));
        self.menuItems.append(MenuItem(controller: BuddyViewController(), title: "Buddy"));
        self.menuItems.append(MenuItem(controller: SettingsViewController(), title: "Settings"));
        self.title = "Drone"
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.registerNib(UINib(nibName: "MenuViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: identifier)
        AppDelegate.getAppDelegate().startConnect()

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

    // MARK: - UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuItems.count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:MenuViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! MenuViewCell
        let item:MenuItem = self.menuItems[indexPath.row]
        cell.menuItemLabel.text = item.menuTitle
        cell.selected = true;
        return cell
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: (collectionView.frame.height/3) - 21)
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let item:MenuItem = self.menuItems[indexPath.row]
        self.navigationController?.pushViewController(item.menuViewControllerItem, animated: true)
//        self.presentViewController(UINavigationController(rootViewController: item.menuViewControllerItem), animated: true) { 
//
//        }
        
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
    
    func profileAction(){
        self.navigationController?.pushViewController(ProfileViewController(), animated: true)
    }
}