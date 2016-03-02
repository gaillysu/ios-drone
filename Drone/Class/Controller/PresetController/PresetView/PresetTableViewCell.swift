//
//  PresetTableViewCell.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/3.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class PresetTableViewCell: UITableViewCell,ButtonManagerCallBack {

    @IBOutlet weak var presetSteps: UILabel!
    @IBOutlet weak var presetName: UILabel!
    @IBOutlet weak var presetStates: UISwitch!
    var delegate:ButtonManagerCallBack?


    @IBAction func controllManager(sender: AnyObject) {
       delegate?.controllManager(sender)
        if(presetStates.on){
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
