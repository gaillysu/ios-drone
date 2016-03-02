//
//  UserNotification.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/16.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class UserNotification: NSObject,BaseEntryDatabaseHelper {
    var id:Int = 0
    var clock:Int = 0
    var NotificationType:String = ""
    var status:Bool = false

    private var notificationModel:NotificationModel = NotificationModel()

    /**
     When it is the first time you install and use must be implemented
     *在用户第一次安装使用的时候必须实现
     */
    class func defaultNotificationColor(){
        let array = NotificationModel.getAll()
        if(array.count == 0){
            let notificationTypeArray:[String] = ["Calendar", "Facebook", "WeChat", "EMAIL", "CALL", "SMS", "Whatsapp"]
            for (var index:Int = 0; index < notificationTypeArray.count ; index++) {
                let notification:UserNotification = UserNotification(keyDict: ["id":index,"clock":(index+1)*2,"NotificationType":notificationTypeArray[index],"status":false])
                notification.add({ (id, completion) -> Void in

                })
            }
        }
    }

    init(keyDict:NSDictionary) {
        super.init()
        self.setValue(keyDict.objectForKey("id"), forKey: "id")
        self.setValue(keyDict.objectForKey("clock"), forKey: "clock")
        self.setValue(keyDict.objectForKey("NotificationType"), forKey: "NotificationType")
        self.setValue(keyDict.objectForKey("status"), forKey: "status")
    }

    func add(result:((id:Int?,completion:Bool?) -> Void)){
        notificationModel.clock = clock
        notificationModel.NotificationType = NotificationType
        notificationModel.status = status
        notificationModel.add { (id, completion) -> Void in
            result(id: id, completion: completion)
        }
    }

    func update()->Bool{
        notificationModel.id = id
        notificationModel.clock = clock
        notificationModel.NotificationType = NotificationType
        notificationModel.status = status
        return notificationModel.update()
    }

    func remove()->Bool{
        notificationModel.id = id
        return notificationModel.remove()
    }

    class func removeAll()->Bool{
        return NotificationModel.removeAll()
    }

    class func getCriteria(criteria:String)->NSArray{
        let modelArray:NSArray = NotificationModel.getCriteria(criteria)
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let notificationModel:NotificationModel = model as! NotificationModel
            let notification:UserNotification = UserNotification(keyDict: ["id":notificationModel.id,"clock":notificationModel.clock,"NotificationType":notificationModel.NotificationType,"status":notificationModel.status])
            allArray.addObject(notification)
        }
        return allArray
    }

    class func getAll()->NSArray{
        let modelArray:NSArray = NotificationModel.getAll()
        let allArray:NSMutableArray = NSMutableArray()
        for model in modelArray {
            let notificationModel:NotificationModel = model as! NotificationModel
            let notification:UserNotification = UserNotification(keyDict: ["id":notificationModel.id,"clock":notificationModel.clock,"NotificationType":notificationModel.NotificationType,"status":notificationModel.status])
            allArray.addObject(notification)
        }
        return allArray
    }

}
