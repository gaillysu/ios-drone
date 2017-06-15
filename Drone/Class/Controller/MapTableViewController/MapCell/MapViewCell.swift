//
//  MapViewCell.swift
//  Drone
//
//  Created by Cloud on 2017/5/5.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit
import SwiftEventBus
import CoreLocation
import MapKit

class MapViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    var googleModel:GoogleMapsGeocodeModel? {
        didSet{
            titleLabel.text = googleModel?.localityLong_name
            detailLabel.text =  googleModel?.formatted_address
        }
    }
        
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
