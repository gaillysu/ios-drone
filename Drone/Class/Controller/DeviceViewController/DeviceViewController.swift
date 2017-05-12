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
    fileprivate final let headerHeight:CGFloat = 254.0
    
    fileprivate var batteryStatus:[PostBatteryStatus] = []
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
        
        _ = SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_BATTERY_STATUS_CHANGED) { [weak self](notification) -> Void in
            
            self?.batteryStatus.removeAll()
            
            let battery:PostBatteryStatus = notification.object as! PostBatteryStatus
            self?.batteryStatus.append(battery)
            self?.deviceTableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        deviceTableView.isScrollEnabled = false
        deviceTableView.reloadData()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        SwiftEventBus.unregister(self, name: SWIFTEVENT_BUS_BATTERY_STATUS_CHANGED)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2;
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (deviceTableView.frame.height - headerHeight)/2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            self.navigationController?.pushViewController(NotificationViewController(), animated: true)
        }else if indexPath.row == 1 {
            // forget watch
            selectedForgetWatch()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell: DeviceTableViewCellHeader = deviceTableView.dequeueReusableHeaderFooterView(withIdentifier: identifier_header) as! DeviceTableViewCellHeader
        if batteryStatus.count>0 {
            let battery:PostBatteryStatus = batteryStatus.first!
            headerCell.watchInfo = WatchInfoModel(batteryLevel: battery);
        }else{
            headerCell.watchInfo = WatchInfoModel(batteryLevel: nil)
        }
        
        headerCell.showLeftRightButtons(leftRightButtonsNeeded)
        
        return headerCell;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DeviceTableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier) as! DeviceTableViewCell
        cell.accessoryView = MSCellAccessory(type: DISCLOSURE_INDICATOR, color: UIColor.getTintColor())
        if indexPath.row == 0 {
            cell.titleLabel.text = "Notifications"
        }else if indexPath.row == 1{
            cell.titleLabel.text = "Forget this watch"
        }
        cell.separatorInset = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }
}

extension DeviceViewController{

    fileprivate func selectedForgetWatch() {
        let alertView:UIAlertController = UIAlertController(title: NSLocalizedString("forget_watch", comment: ""), message: NSLocalizedString("forget_watch_message", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        
        alertView.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: UIAlertActionStyle.default, handler: { (action) in
            AppDelegate.getAppDelegate().sendRequest(ClearConnectionRequest())
//            AppDelegate.getAppDelegate().disconnect()
            _ = UserDevice.removeAll()
            //Records need to use 0x30
            let resetModel:ResetCacheModel = ResetCacheModel(reState: true, date: Date().timeIntervalSince1970)
            _ = AppTheme.KeyedArchiverName(AppDelegate.RESET_STATE, andObject: resetModel)
            
            if self.navigationController?.popViewController(animated: true)==nil {
                self.dismiss(animated: true, completion: nil)
            }
        }))
        
        alertView.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: UIAlertActionStyle.cancel, handler: { (action) in
            
        }))
        
        self.present(alertView, animated: true, completion: nil)
    }
}
