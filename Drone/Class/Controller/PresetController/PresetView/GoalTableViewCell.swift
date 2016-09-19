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


    @IBAction func controllManager(_ sender: AnyObject) {
        if(goalStates.isOn){
            self.backgroundColor = UIColor.white
        }else{
            self.backgroundColor = UIColor.clear
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
