//
//  ClockSettingsTableViewCell.swift
//  Drone
//
//  Created by Karl-John Chow on 20/4/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import UIKit

class ClockSettingsTableViewCellSwitch: UITableViewCell {

    @IBOutlet weak var settingLabel: UILabel!
    @IBOutlet weak var settingSwitch: UISwitch!
    var item:TimeSettingsSectionItem?{
        didSet{
            if let item = item{
                self.settingLabel.text = item.label
                if let  status = item.enabled{
                    settingSwitch.setOn(status, animated: true)
                }else{
                    settingSwitch.isHidden = true
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    } 
}
