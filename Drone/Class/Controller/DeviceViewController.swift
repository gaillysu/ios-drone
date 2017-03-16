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
import MSCellAccessory
import SceneKit

class DeviceViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    var leftRightButtonsNeeded = true;
    
    @IBOutlet weak var deviceTableView: UITableView!
    fileprivate final let identifier = "device_table_view_cell"
    fileprivate final let identifier_header = "device_table_view_cell_header"
    var batteryStatus:[Int] = []
    
    init() {
        super.init(nibName: "DeviceViewController", bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceTableView.register(UINib(nibName: "DeviceTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: identifier)
        deviceTableView.register(UINib(nibName: "DeviceTableViewCellHeader", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: identifier_header)
        self.delay(seconds: 1) { 
            AppDelegate.getAppDelegate().sendRequest(GetBatteryRequest())
        }
        
        _ = SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_BATTERY_STATUS_CHANGED) { (notification) -> Void in
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
    }
    
    override func viewDidLayoutSubviews() {
        deviceTableView.sectionHeaderHeight = 254
        deviceTableView.isScrollEnabled = false
        deviceTableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        SwiftEventBus.unregister(self, name: SWIFTEVENT_BUS_BATTERY_STATUS_CHANGED)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //NSLog("CGRect:\(NSStringFromCGRect(self.view.frame))")
        return (deviceTableView.frame.height - 254)/2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath as NSIndexPath).row == 0 {
            self.navigationController?.pushViewController(NotificationViewController(), animated: true)
        }else if (indexPath as NSIndexPath).row == 1 {
            // forget watch
            let alertView:UIAlertController = UIAlertController(title: NSLocalizedString("forget_watch", comment: ""), message: NSLocalizedString("forget_watch_message", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            
            alertView.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: UIAlertActionStyle.default, handler: { (action) in
                AppDelegate.getAppDelegate().sendRequest(ClearConnectionRequest())
                _ = UserDevice.removeAll()
                 AppDelegate.getAppDelegate().disconnect()
                //Records need to use 0x30
                _ = AppTheme.KeyedArchiverName(RESET_STATE, andObject: [RESET_STATE:true] as AnyObject)
                
                if self.navigationController == nil {
                    self.dismiss(animated: true, completion: nil)
                }else{
                    _ = self.navigationController?.popViewController(animated: true)
                }
            }))
            
            alertView.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: UIAlertActionStyle.cancel, handler: { (action) in
                
            }))
            
            self.present(alertView, animated: true, completion: nil)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell: DeviceTableViewCellHeader = deviceTableView.dequeueReusableHeaderFooterView(withIdentifier: identifier_header) as! DeviceTableViewCellHeader
        
        if "\(AppDelegate.getAppDelegate().getFirmwareVersion())".isEmpty {
            headerCell.versionLabel.text = "Not Connected"
        }else{
            headerCell.versionLabel.text = "\(AppDelegate.getAppDelegate().getFirmwareVersion())"
        }
        
        if AppDelegate.getAppDelegate().isConnected() {
            headerCell.connectionStateLabel.text = "Connected"
        }else{
            headerCell.connectionStateLabel.text = "Not Connected"
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DeviceTableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier) as! DeviceTableViewCell
        cell.accessoryView = MSCellAccessory(type: DISCLOSURE_INDICATOR, color: UIColor.getTintColor())
        if (indexPath as NSIndexPath).row == 0 {
            cell.titleLabel.text = "Notifications"
        }else if (indexPath as NSIndexPath).row == 1{
            cell.titleLabel.text = "Forget this watch"
        }
        cell.separatorInset = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }
}
