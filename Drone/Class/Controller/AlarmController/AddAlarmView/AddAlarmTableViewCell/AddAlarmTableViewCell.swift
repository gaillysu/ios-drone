//
//  AddAlarmTableViewCell.swift
//  Nevo
//
//  Created by leiyuncun on 15/11/27.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class AddAlarmTableViewCell: UITableViewCell {

    @IBOutlet weak var datePicker: UIDatePicker!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        datePicker.datePickerMode = UIDatePickerMode.Time;
        datePicker.addTarget(self, action: "selectedTimerAction:", forControlEvents: UIControlEvents.ValueChanged)
    }

    func selectedTimerAction(timer:UIDatePicker){

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
