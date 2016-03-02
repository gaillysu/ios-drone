//
//  AddAlarmSystemCell.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/11.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class AddAlarmSystemCell: UITableViewCell {

    @IBOutlet weak var systemTitle: UILabel!
    @IBOutlet weak var repeatSwicth: UISwitch!
    var mDelegate:ButtonManagerCallBack?

    @IBAction func buttonManager(sender: AnyObject) {
        mDelegate?.controllManager(sender)
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
