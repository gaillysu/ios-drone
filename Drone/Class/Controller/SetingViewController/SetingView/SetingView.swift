//
//  SetingView.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/24.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class SetingView: UIView {

    //var animationView:AnimationView!
    var mSendLocalNotificationSwitchButton:UISwitch!



    @IBAction func buttonAction(_ sender: AnyObject) {
    }
    
    /**
     Constructing the title only TableViewCell

     :param: indexPath The path of the TableView
     :param: tableView TableView Object
     :param: title     The title string

     :returns: UITableViewCell
     */
    class func NotificationSystemTableViewCell(_ indexPath:IndexPath,tableView:UITableView,title:String,imageName:String)->UITableViewCell {
        let endCellID:String = "NotificationSystemTableViewCell"
        var endCell = tableView.dequeueReusableCell(withIdentifier: endCellID)
        if (endCell == nil) {
            endCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: endCellID)
        }
        endCell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        //endCell?.selectionStyle = UITableViewCellSelectionStyle.None;
        endCell?.textLabel?.text = title
        endCell?.imageView?.image = UIImage(named: imageName)
        return endCell!
    }

    

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
