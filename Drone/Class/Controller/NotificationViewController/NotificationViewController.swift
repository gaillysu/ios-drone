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
import MSCellAccessory


class NotificationViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!
    let reuseIdentifier = "Notifications_Identifier"
    var realm:Realm?
    fileprivate var realmApps:[DroneNotification] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        realm = try! Realm()
        self.navigationItem.title = "Notifications"
        self.tableView.separatorColor = UIColor.clear
        self.tableView.rowHeight = 60.0
        self.tableView.register(UINib(nibName: "NotificationsViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        let plist:[String : Any] = SandboxManager().readDataWithName(type: "", fileName: "NotificationTypeFile.plist") as! [String : Any]
        let apps = plist["NotificationType"] as! [String:Any]
        
        if  realm!.objects(DroneNotification.self).isEmpty{
            for app in apps{
                let plistApp = apps[app.key] as! [String : Any]?
                let notification = DroneNotification()
                notification.appName = app.key
                if let bundleid = plistApp!["bundleId"] {
                    notification.bundleIdentifier = bundleid as! String
                }
                
                try! realm!.write ({
                    realm!.add(notification)
                })
                
            }
        }
        realm!.objects(DroneNotification.self).forEach { notification in
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
    
    func callback(isOn:Bool, bundleIdentifier:String){
        print("Turned \(bundleIdentifier) \(isOn)")
        for realmApp in realmApps{
            if realmApp.bundleIdentifier == bundleIdentifier {
                try! realm?.write ({
                    realmApp.state = isOn
                    realm?.add(realmApp, update: true)
                })
                return
            }
            
        }
    }
}

extension NotificationViewController{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return realmApps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:NotificationsViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationsViewCell
        let app = realmApps[indexPath.row]
        cell.textLabel?.text = app.appName
        cell.app = app
        cell.switchCallback = callback
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
    }
}

class DroneNotification: Object{
    
    dynamic var bundleIdentifier = ""
    dynamic var appName = ""
    dynamic var state = false
    
    override static func primaryKey() -> String? {
        return "bundleIdentifier"
    }
}
