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
    var switchCallback: ((_ state:Bool, _ identifier:String?, _ hasApp:Bool) -> Void)?
    var app:Notification? {
        didSet{
            if let app = app{
                self.setSwicth(on: app.state)
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textLabel?.textColor = UIColor.white
    }
    
    @IBAction func notificationSwicthAction(_ sender: UISwitch) {
        if let app = self.app{
            
            if let callback = switchCallback{
                callback(sender.isOn, app.bundleIdentifier, true)
            }
        }else{
            if let callback = switchCallback{
                callback(sender.isOn, nil, false)
            }
        }
        
    }
    
    func delay(seconds:Double, completion: @escaping ()-> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: completion)
    }
    
    func setSwicth(on:Bool) {
        notificationSwicth.setOn(on, animated: false)
    }
}
