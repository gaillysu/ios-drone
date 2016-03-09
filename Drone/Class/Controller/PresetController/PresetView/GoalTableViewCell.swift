//
//  PresetTableViewCell.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/3.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class GoalTableViewCell: UITableViewCell{

    @IBOutlet weak var goalSteps: UILabel!
    @IBOutlet weak var goalName: UILabel!
    @IBOutlet weak var goalStates: UISwitch!


    @IBAction func controllManager(sender: AnyObject) {
        if(goalStates.on){
            self.backgroundColor = UIColor.whiteColor()
        }else{
            self.backgroundColor = UIColor.clearColor()
        }
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
