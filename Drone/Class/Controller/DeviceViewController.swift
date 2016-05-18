//
//  DeviceViewController.swift
//  Drone
//
//  Created by Karl-John on 1/5/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import UIKit
import SwiftEventBus

class DeviceViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    var leftRightButtonsNeeded = true;
    
    @IBOutlet weak var deviceTableView: UITableView!
    private final let identifier = "device_table_view_cell"
    private final let identifier_header = "device_table_view_cell_header"
    var batteryStatus:[Int] = []
    
    init() {
        super.init(nibName: "DeviceViewController", bundle: NSBundle.mainBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceTableView.registerNib(UINib(nibName: "DeviceTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: identifier)
        deviceTableView.registerNib(UINib(nibName: "DeviceTableViewCellHeader", bundle: NSBundle.mainBundle()), forHeaderFooterViewReuseIdentifier: identifier_header)
    }
    
    override func viewDidLayoutSubviews() {
        deviceTableView.sectionHeaderHeight = 254
        deviceTableView.scrollEnabled = false
        deviceTableView.rowHeight = (deviceTableView.frame.height - 254)/2

        AppDelegate.getAppDelegate().sendRequest(GetBatteryRequest())
        
        SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_BATTERY_STATUS_CHANGED) { (notification) -> Void in
            self.batteryStatus = notification.object as! [Int]
            NSLog("batteryStatus----:\(self.batteryStatus)")
            self.deviceTableView.reloadData()
            /**
             <0x00> - In use
             <0x01> - Charging
             <0x02> - Damaged
             <0x03> - Calculating
             */
        }
        if !AppDelegate.getAppDelegate().isConnected() {
            deviceTableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.row == 0 {
            self.navigationController?.pushViewController(ContactsNotificationViewController(), animated: true)
        }else if indexPath.row == 1 {
            // forget watch
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell: DeviceTableViewCellHeader = deviceTableView.dequeueReusableHeaderFooterViewWithIdentifier(identifier_header) as! DeviceTableViewCellHeader
        headerCell.versionLabel.text = "\(AppDelegate.getAppDelegate().getFirmwareVersion())"
        
        if AppDelegate.getAppDelegate().isConnected() {
            headerCell.connectionStateLabel.text = "Connected"
        }else{
            headerCell.connectionStateLabel.text = "Disconnected"
        }
        if batteryStatus.count>0 {
            switch batteryStatus[0] {
            case 0:
                headerCell.batteryLabel.text = "\(batteryStatus[1])%"
            case 1:
                headerCell.batteryLabel.text = "Charging"
            case 2:
                headerCell.batteryLabel.text = "Damaged"
            case 3:
                headerCell.batteryLabel.text = "Calculating"
                
            default: break
                
            }
        }
        
            headerCell.showLeftRightButtons(leftRightButtonsNeeded);
        return headerCell;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: DeviceTableViewCell = tableView.dequeueReusableCellWithIdentifier(identifier) as! DeviceTableViewCell
        if indexPath.row == 0 {
            cell.titleLabel.text = "Contacts Notifications"
        }else if indexPath.row == 1{
            cell.titleLabel.text = "Forget this watch"
        }
        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
    }
}