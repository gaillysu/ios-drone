//
//  PostRoutes.swift
//  Drone
//
//  Created by Cloud on 2017/5/10.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit
import GoogleMaps

class PostRoutes: NSObject {

    var endLocation:CLLocationCoordinate2D?
    var roadsLine:GMSPolyline?
    
    fileprivate override init() {
        super.init()
    }
    
    init(line:GMSPolyline) {
        super.init()
        self.roadsLine = line
    }
}
