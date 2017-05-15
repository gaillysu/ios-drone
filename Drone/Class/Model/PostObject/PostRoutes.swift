//
//  PostRoutes.swift
//  Drone
//
//  Created by Cloud on 2017/5/10.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit
import MapKit

class PostRoutes: NSObject {

    var placemarks:CLPlacemark?
    var route:MKRoute?
    
    fileprivate override init() {
        super.init()
    }
    
    init(mPlacemarks:CLPlacemark,mRoute:MKRoute) {
        super.init()
        placemarks = mPlacemarks
        route = mRoute
    }
}
