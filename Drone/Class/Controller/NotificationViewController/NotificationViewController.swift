//
//  ContactsNotificationViewController.swift
//  Drone
//
//  Created by Karl Chow on 5/11/16.
//  Copyright © 2016 Cloud. All rights reserved.
//

import RealmSwift
import UIKit
import Contacts
import AddressBook
import AddressBookUI
import MRProgress
import SwiftyTimer
import BRYXBanner


class NotificationViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!
    let reuseIdentifier = "NotificationsViewCell"
    let tableViewIdentifier = "UITableViewCell"
    var realm:Realm?
    
    fileprivate var realmApps:[Notification] = []
    fileprivate var allApps:[String] = ["All Apps"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        realm = try! Realm()
        self.navigationItem.title = "Notifications"
        self.tableView.separatorColor = .white
        self.tableView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: tableViewIdentifier)
        
        let plist:[String : Any] = SandboxManager().readDataWithName(type: "", fileName: "NotificationTypeFile.plist") as! [String : Any]
        let apps = plist["NotificationType"] as! [String:Any]
        if realm!.objects(Notification.self).isEmpty{
            for app in apps{
                let plistApp = apps[app.key] as! [String : Any]?
                let notification = Notification()
                notification.appName = app.key
                if let bundleid = plistApp!["bundleId"] {
                    notification.bundleIdentifier = bundleid as! String
                }
                try! realm!.write ({
                    realm!.add(notification)
                })
            }
        }
        realm!.objects(Notification.self).forEach { notification in
            realmApps.insert(notification, at: 0)
        }
        addCloseButton(#selector(dismissViewController))
    }
    
    func dismissViewController(){
        if self.navigationController?.popViewController(animated: true) == nil {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    func callback(isOn:Bool, bundleIdentifier:String?, hasApp:Bool){
        if hasApp{
            
            if let notification = realmApps.filter({  $0.bundleIdentifier == bundleIdentifier }).first{
                try! realm?.write ({
                    notification.state = isOn
                    realm?.add(notification, update: true)
                })
                AppDelegate.getAppDelegate().sendRequest(UpdateNotificationRequest(operation: isOn ? 1 : 2, package: notification.bundleIdentifier))
            }
        }else{
            DTUserDefaults.enabledAllNotifications = isOn
            AppDelegate.getAppDelegate().updateNotification()
            tableView.reloadSections([2], animationStyle: .automatic)
        }
        
    }
}

extension NotificationViewController{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 && AppTheme.hasGearbox(){
            return "Customize your watch's vibration pattern for notifications"
        }else if section == 1 {
            return "Turn notifications on for all apps."
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && AppTheme.hasGearbox(){
            return 1
        }else if section == 1 {
            return allApps.count
        }else if !DTUserDefaults.enabledAllNotifications && section == 2{
            return realmApps.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:NotificationsViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.textLabel?.textColor = UIColor.white
        if indexPath.section == 0 && indexPath.row == 0 {
            cell.textLabel?.text = "Vibration Patterns"
            cell.app = nil
            cell.accessoryType = .disclosureIndicator
            cell.switchCallback = nil
            cell.notificationSwicth.isHidden = true
            cell.backgroundColor = UIColor("#C0913D")
            cell.textLabel?.textColor = UIColor.white.withAlphaComponent(0.5)
        }else if indexPath.section == 1 {
            cell.textLabel?.text = allApps[indexPath.row]
            cell.notificationSwicth.setOn(DTUserDefaults.enabledAllNotifications, animated: false)
            cell.switchCallback = callback
            cell.app = nil
            cell.accessoryType = .none
        } else if indexPath.section == 2 {
            let app = realmApps[indexPath.row]
            cell.textLabel?.text = app.appName
            cell.app = app
            cell.switchCallback = callback
            cell.accessoryType = .none
            cell.notificationSwicth.isHidden = false
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if !AppTheme.hasGearbox() && section == 0 {
            return 0.1
        }
        return 18
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
    }
}

