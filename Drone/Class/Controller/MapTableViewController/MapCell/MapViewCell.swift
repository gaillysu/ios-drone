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
    @IBOutlet weak var distanceLabel: UILabel!
    
    var placemarks:CLPlacemark? {
        didSet{
            var locationLong:String?
            var locationShort:String?
            
            let placeMark: CLPlacemark = placemarks!
            
            if let street = placeMark.administrativeArea {
                locationShort = "\(street)"
                locationLong = "\(street)"
            }
            
            if let area = placeMark.locality, let _ = locationLong, let _ = locationShort {
                locationShort = locationShort! + ", \(area)"
                locationLong = locationLong! + ", \(area)"
            }
            
            if let district = placeMark.subLocality, let _ = locationLong, let _ = locationShort {
                locationLong = locationLong! + ", \(district)"
            }

            let distancePlacemark:MKPlacemark = MKPlacemark(placemark: placeMark)
            distancePlacemark.calculateRoute { (route, error) in
                if error == nil {
                    self.distanceLabel.text = route!.first!.distance.distanceConvertMetricString()
                }
            }
            
            titleLabel.text = locationLong
            detailLabel.text =  placeMark.name
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
