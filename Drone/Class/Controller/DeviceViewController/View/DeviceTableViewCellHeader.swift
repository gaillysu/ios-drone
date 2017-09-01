//
//  DeviceTableViewCellHeader.swift
//  Drone
//
//  Created by Karl-John on 1/5/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import UIKit
class DeviceTableViewCellHeader: UITableViewHeaderFooterView {
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var connectionStateLabel: UILabel!
    @IBOutlet weak var batteryLabel: UILabel!
    @IBOutlet weak var arrowRight: UIButton!
    @IBOutlet weak var watchImage: UIImageView!
    @IBOutlet weak var arrowLeft: UIButton!
    
    var watchInfo:WatchInfoModel? {
        didSet{
            versionLabel.text = watchInfo?.getWatchInfo().version;
            connectionStateLabel.text = watchInfo?.getWatchInfo().stateText
            batteryLabel.text = watchInfo?.getWatchInfo().battery
        }
    }
    
    override func awakeFromNib() {
        if let imageName = DTUserDefaults.selectedWatchPicture{
            guard let image = UIImage(named: imageName) else { return }
            watchImage.image = image
        }
    }
 
    func showLeftRightButtons(_ visible:Bool ){
        arrowRight.isHidden = !visible;
        arrowLeft.isHidden = !visible;
    }
    
}
