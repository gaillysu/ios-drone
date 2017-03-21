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

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
