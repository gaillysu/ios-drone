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
        self.menuItems.append(MenuItem(controller: ProfileViewController(), title: "Profile"));
        self.menuItems.append(MenuItem(controller: SettingsViewController(), title: "Settings"));
        self.title = "Drone"
        
        let uiBusy = NVActivityIndicatorView(frame:CGRectMake(0, 0, 10, 10),color:AppTheme.BASE_COLOR(), type:.BallClipRotatePulse)
        uiBusy.size = CGSizeMake(25, 25)
        uiBusy.startAnimation()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: uiBusy)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.registerNib(UINib(nibName: "MenuViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: identifier)
        AppDelegate.getAppDelegate().startConnect(false)

        SwiftEventBus.onMainThread(self, name: RAWPACKET_DATA_KEY) { (notification) -> Void in
            NSLog("RAWPACKET_DATA_KEY  :\(NSData2Bytes((notification.object as! RawPacketImpl).getRawData()))")
        }
    }
    
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
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let item:MenuItem = self.menuItems[indexPath.row]
        self.navigationController?.pushViewController(item.menuViewControllerItem, animated: true)
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
}