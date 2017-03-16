//
//  NotificationsViewCell.swift
//  Drone
//
//  Created by Cloud on 2016/11/21.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit
import SwiftyJSON

class NotificationsViewCell: UITableViewCell {
    @IBOutlet weak var notificationSwicth: UISwitch!
    var switchCallback: ((Bool, String) -> Void)?
    
    var app:DroneNotification? {
        didSet{
            self.setSwicth(on: app!.state)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.transparent()
        let selectedView:UIView = UIView()
        selectedView.backgroundColor = UIColor.getBaseColor()
        selectedBackgroundView = selectedView
        textLabel?.textColor = UIColor.white
        textLabel?.font = UIFont.systemFont(ofSize: 20)
        separatorInset = UIEdgeInsets.zero
        preservesSuperviewLayoutMargins = false
        layoutMargins = UIEdgeInsets.zero
    }
    
    @IBAction func notificationSwicthAction(_ sender: UISwitch) {
        var contact:[String : Any] = SandboxManager().readDataWithName(type: "", fileName: "NotificationTypeFile.plist") as! [String : Any]
        var notificationType:[String:Any] = contact["NotificationType"] as! [String:Any]
        var value:[String:Any] = contactsFilterDict!
        
        var operation:Int = 0
        if sender.isOn {
            operation = 1
        }else{
            operation = 2
        }
        if value.count == 2 {
            value["state"] = sender.isOn
            if keys.length()>0 {
                notificationType[keys] = value
                contact["NotificationType"] = notificationType
                _ = SandboxManager().saveDataWithName(saveData: contact, fileName: "NotificationTypeFile.plist")
            }
            let packageName:String = value["bundleId"] as! String
            let updateRequest = UpdateNotificationRequest(operation: operation, package: packageName)
            AppDelegate.getAppDelegate().sendRequest(updateRequest)
        }else{
            for (key,value1) in value{
                var value2:[String:Any] = value1 as! [String:Any]
                value2["state"] = sender.isOn
                value[key] = value2
                let packageName:String = value2["bundleId"] as! String
                let updateRequest = UpdateNotificationRequest(operation: operation, package: packageName)
                AppDelegate.getAppDelegate().sendRequest(updateRequest)
            }
            
            notificationType[keys] = value
            contact["NotificationType"] = notificationType
            _ = SandboxManager().saveDataWithName(saveData: contact, fileName: "NotificationTypeFile.plist")
        let updateRequest = UpdateNotificationRequest(operation: sender.isOn ? 1 : 2, package: app!.bundleIdentifier)
        AppDelegate.getAppDelegate().sendRequest(updateRequest)
        if let callback = switchCallback{
            callback(sender.isOn, app!.bundleIdentifier)
        }
    }
    
    func delay(seconds:Double, completion: @escaping ()-> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: completion)
    }
    
    func setSwicth(on:Bool) {
        notificationSwicth.setOn(on, animated: true)
    }
}
