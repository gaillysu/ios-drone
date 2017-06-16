//
//  RoutesStepsModel.swift
//  Drone
//
//  Created by Cloud on 2017/6/15.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit

class RoutesStepsModel: NSObject {
    var distance_text:String = ""
    var distance_value:Int = 0
    var duration_text:String = ""
    var duration_value:Int = 0
    
    var end_location_lat:Double = 0
    var end_location_lng:Double = 0
    
    var start_location_lat:Double = 0
    var start_location_lng:Double = 0
    
    var html_instructions:String = ""
    var polyline_points:String = ""
    var travel_mode:String = ""
}
