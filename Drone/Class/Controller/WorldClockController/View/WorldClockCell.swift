//
//  WorldClockCell.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/25.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class WorldClockCell: UITableViewCell {
 
    @IBOutlet weak var time: UILabel!

    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var timeDescription: UILabel!
    
    class func getWorldClockCell(tableView:UITableView,indexPath:NSIndexPath,clock:WorldClockModel)->UITableViewCell {
        let identifier:String = "WorldClockCell"
        var cell:WorldClockCell = tableView.dequeueReusableCellWithIdentifier(identifier) as! WorldClockCell
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("WorldClockCell", owner: self, options: nil)
        cell = (nibs.objectAtIndex(0) as? WorldClockCell)!
        cell.cityLabel.text = clock.city_name
        let systemName:String? = clock.system_name;
        cell.timeDescription.text = "\(TimeUtil.getGmtOffSetForCity(systemName!))"
        return cell
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
