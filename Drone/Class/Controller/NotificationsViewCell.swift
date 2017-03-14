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
    var keys:String = ""
    var contactsFilterDict:[String:Any]? {
        didSet{
            let json = JSON(contactsFilterDict!)
            if contactsFilterDict?.count == 2 {
                self.setSwicth(on: json["state"].boolValue)
            }else{
                var res:Bool = true
                for (key,value) in json {
                    if !value["state"].boolValue {
                        res = false
                        break
                    }
                    res = true
                }
                self.setSwicth(on: res)
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
        }
    }
    
    func delay(seconds:Double, completion: @escaping ()-> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: completion)
    }
    
    func setSwicth(on:Bool) {
        notificationSwicth.setOn(on, animated: true)
    }
}
