//
//  ClockSettingsTableViewCell.swift
//  Drone
//
//  Created by Karl-John Chow on 20/4/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import UIKit

class ClockSettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var settingsTextField: UITextField!
    @IBOutlet weak var settingsLabel: UILabel!
    var item:TimeSettingsSectionItem?{
        didSet{
            if let item = item{
                self.settingsLabel.text = item.label
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
