//
//  DeviceTableViewCellHeader.swift
//  Drone
//
//  Created by Karl-John on 1/5/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

class DeviceTableViewCellHeader: UITableViewHeaderFooterView {
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var connectionStateLabel: UILabel!
    @IBOutlet weak var batteryLabel: UILabel!
    @IBOutlet weak var arrowRight: UIButton!

    @IBOutlet weak var arrowLeft: UIButton!
    override func awakeFromNib() {
        
    }
 
    func showLeftRightButtons(visible:Bool ){
        arrowRight.hidden = !visible;
        arrowLeft.hidden = !visible;
    }
    
}