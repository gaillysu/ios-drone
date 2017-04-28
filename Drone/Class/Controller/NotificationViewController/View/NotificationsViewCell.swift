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
    var app:Notification? {
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
