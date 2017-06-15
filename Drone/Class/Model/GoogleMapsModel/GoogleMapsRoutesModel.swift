//
//  GoogleMapsRoutesModel.swift
//  Drone
//
//  Created by Cloud on 2017/6/15.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import Foundation
import SwiftyJSON

class GoogleMapsRoutesModel: NSObject {
    var bounds_northeast_lat:Double = 0
    var bounds_northeast_lng:Double = 0
    var bounds_southwest_lat:Double = 0
    var bounds_southwest_lng:Double = 0
    var copyrights:String = ""
    var distance_text:String = ""
    var distance_value:Int = 0
    var duration_text:String = ""
    var duration_value:Int = 0
    
    var start_address:String = ""
    var start_location_lat:Double = 0
    var start_location_lng:Double = 0
    
    var end_address:String = ""
    var end_location_lat:Double = 0
    var end_location_lng:Double = 0
    
    var routesSteps:[RoutesStepsModel] = []
    
    var overview_polyline_points:String = ""
    var summary:String =  ""
    var warnings:[JSON] = []
    var waypoint_order:[JSON] = []
}
