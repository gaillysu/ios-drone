//
//  MyNevoView.swift
//  Nevo
//
//  Created by leiyuncun on 15/5/25.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class MyNevoView: UITableView {

    class func getMyNevoViewTableViewCell(_ indexPath:IndexPath,tableView:UITableView,title:String,detailText:String)->UITableViewCell {
        let endCellID:String = "getMyNevoViewTableViewCell"
        var endCell = tableView.dequeueReusableCell(withIdentifier: endCellID)
        if (endCell == nil) {
            endCell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: endCellID)
        }
        endCell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        //endCell?.selectionStyle = UITableViewCellSelectionStyle.None;
        endCell?.textLabel?.text = title
        endCell?.detailTextLabel?.text = detailText
        return endCell!
    }
    
    func bulidMyNevoView(_ navigation:UINavigationItem){

        navigation.title = NSLocalizedString("My Drone", comment: "")
        //title.text = NSLocalizedString("My nevo", comment: "")
        //let objArray:NSArray = AppTheme.LoadKeyedArchiverName("LatestUpdate") as! NSArray
    }
}
