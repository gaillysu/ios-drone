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
import SceneKit
import BRYXBanner

class DeviceViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    var leftRightButtonsNeeded = true;
    
    @IBOutlet weak var deviceTableView: UITableView!
    fileprivate final let deviceTableViewCellIdentifier = "DeviceTableViewCell"
    fileprivate final let deviceTableViewCellHeaderIdentifier = "DeviceTableViewCellHeader"
    
    fileprivate var batteryStatus:[PostBatteryStatus] = []
    init() {
        super.init(nibName: "DeviceViewController", bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceTableView.register(UINib(nibName: deviceTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: deviceTableViewCellIdentifier)
        deviceTableView.register(UINib(nibName: deviceTableViewCellHeaderIdentifier, bundle: nil), forHeaderFooterViewReuseIdentifier: deviceTableViewCellHeaderIdentifier)
        
        _ = SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_BATTERY_STATUS_CHANGED) { [weak self](notification) -> Void in
            
            self?.batteryStatus.removeAll()
            
            let battery:PostBatteryStatus = notification.object as! PostBatteryStatus
            self?.batteryStatus.append(battery)
            self?.deviceTableView.reloadData()
        }
        AppDelegate.getAppDelegate().sendRequest(GetBatteryRequest())
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
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (deviceTableView.frame.height - 254.0)/2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0{
            upgradeWatch()
        }else if indexPath.row == 1{
            forgetWatch()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell: DeviceTableViewCellHeader = deviceTableView.dequeueReusableHeaderFooterView(withIdentifier: deviceTableViewCellHeaderIdentifier) as! DeviceTableViewCellHeader
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
        let cell: DeviceTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        if indexPath.row == 0 {
            cell.titleLabel.text = "OTA Upgrade"
        }else if indexPath.row == 1{
            cell.titleLabel.text = "Forget this watch"
        }
        return cell
    }
    
    fileprivate func forgetWatch() {
        let alertView = UIAlertController(title: NSLocalizedString("forget_watch", comment: ""), message: NSLocalizedString("forget_watch_message", comment: ""), preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { (action) in
            AppDelegate.getAppDelegate().sendRequest(ClearConnectionRequest())
            AppDelegate.getAppDelegate().disconnect()
            _ = UserDevice.removeAll()
            _ = AppTheme.KeyedArchiverName(AppDelegate.RESET_STATE, andObject: ResetCacheModel(reState: true, date: Date().timeIntervalSince1970))
            if self.navigationController?.popViewController(animated: true)==nil {
                self.dismiss(animated: true, completion: nil)
            }
        }))
        alertView.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
    
    fileprivate func upgradeWatch(){
        guard let url = AppTheme.GET_FIRMWARE_FILES("DFUFirmware").first else{
            fatalError("Could not open Firmware file for some reason")
        }
        let firmwareVersion = AppTheme.firmwareVersionFrom(path: url)
        let currentVersion = DTUserDefaults.lastKnownWatchVersion
        
        if !AppDelegate.getAppDelegate().isConnected(){
            let banner = Banner(title: "Watch is not connected", subtitle: nil, image: nil, backgroundColor:UIColor.getBaseColor())
            banner.dismissesOnTap = true
            banner.show(duration: 1.2)
            return
        }
        if firmwareVersion >= currentVersion{
            let alertView = UIAlertController(title: "Newest Version", message: "You already got the newest version, do you wish to proceed?", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                self.navigationController?.pushViewController(OTAViewController(), animated: true)
            }))
            alertView.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(alertView, animated: true, completion: nil)
        }else{
            self.navigationController?.pushViewController(OTAViewController(), animated: true)
        }
    }
}

