//
//  WorldClockCell.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/25.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class WorldClockCell: UITableViewCell {

    @IBOutlet weak var regionName: UILabel!

    @IBOutlet weak var timerZone: UILabel!

    @IBOutlet weak var timerSwicth: UISwitch!

    class func getWorldClockCell(tableView:UITableView,indexPath:NSIndexPath,clock:NSDictionary)->UITableViewCell {
        let identifier:String = "WorldClockCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier)
        if(cell == nil){
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("WorldClockCell", owner: self, options: nil)
            cell = nibs.objectAtIndex(0) as? UITableViewCell
        }
        let cellDict:NSDictionary = clock
        cellDict.enumerateKeysAndObjectsUsingBlock({ (key, obj, stop) -> Void in
            cell?.textLabel?.text = key as? String
            cell?.detailTextLabel?.text = obj as? String
        })
        return cell!
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
