//
//  MyNevoView.swift
//  Nevo
//
//  Created by leiyuncun on 15/5/25.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class MyNevoView: UITableView {
    private var mDelegate:ButtonManagerCallBack?

    class func getMyNevoViewTableViewCell(indexPath:NSIndexPath,tableView:UITableView,title:String,detailText:String)->UITableViewCell {
        let endCellID:String = "getMyNevoViewTableViewCell"
        var endCell = tableView.dequeueReusableCellWithIdentifier(endCellID)
        if (endCell == nil) {
            endCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: endCellID)
        }
        endCell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        //endCell?.selectionStyle = UITableViewCellSelectionStyle.None;
        endCell?.textLabel?.text = title
        endCell?.detailTextLabel?.text = detailText
        return endCell!
    }
    
    func bulidMyNevoView(delegate:ButtonManagerCallBack,navigation:UINavigationItem){
        mDelegate = delegate
        navigation.title = NSLocalizedString("My Drone", comment: "")
        //title.text = NSLocalizedString("My nevo", comment: "")
        //let objArray:NSArray = AppTheme.LoadKeyedArchiverName("LatestUpdate") as! NSArray
    }
}
