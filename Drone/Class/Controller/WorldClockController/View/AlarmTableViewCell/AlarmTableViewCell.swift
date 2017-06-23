
//
//  AlarmTableViewCell.swift
//  Drone
//
//  Created by Karl-John Chow on 19/6/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import UIKit
import RxSwift

class AlarmTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var enabledSwitch: UISwitch!
    @IBOutlet weak var nameLabel: UILabel!
    
    var disposeBag = DisposeBag()
    
    var alarm:MEDAlarm? {
        didSet {
            timeLabel.text = (alarm?.hour.to2String())! + ":" + (alarm?.minute.to2String())!
            nameLabel.text = (alarm?.label)! + ", " + (alarm?.repeatLabel())!
            enabledSwitch.setOn((alarm?.enabled)!, animated: true)
            self.swap(bool: (alarm?.enabled)!)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        enabledSwitch.onTintColor = .getTintColor()
        enabledSwitch.rx.isOn
            .subscribe {
            if let enabled = $0.element{
                self.alarm?.update(operation: { $0.enabled = enabled })
                self.swap(bool: enabled)
            }
            }.addDisposableTo(disposeBag)
    }
    
    private func swap(bool:Bool){
        if bool {
            self.timeLabel.textColor = .white
            self.nameLabel.textColor = .white
        }else{
            self.timeLabel.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
            self.nameLabel.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        }
    }
}
