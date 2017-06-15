//
//  GoogleMapsModel.swift
//  Drone
//
//  Created by Cloud on 2017/6/14.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit

class GoogleMapsGeocodeModel: NSObject {

    var countryLong_name:String = ""
    var countryShort_name:String = ""
    var countryTypes:String = ""
    
    var politicalLong_name:String = ""
    var politicalShort_name:String = ""
    var politicalTypes:String = ""
    
    var localityLong_name:String = ""
    var localityShort_name:String = ""
    var localityTypes:String = ""
    
    var sublocalityLong_name:String = ""
    var sublocalityShort_name:String = ""
    var sublocalityTypes:String = ""

    var routeLong_name:String = ""
    var routeShort_name:String = ""
    var routeTypes:String = ""
    
    var parkLong_name:String = ""
    var parkShort_name:String = ""
    var parkTypes:String = ""
    
    var formatted_address:String = ""
    
    var geometry_location_lat:String = ""
    var geometry_location_lng:String = ""
    var viewport_northeast_lat:String = ""
    var viewport_northeast_lng:String = ""
    var viewport_southwest_lat:String = ""
    var viewport_southwest_lng:String = ""
    var location_type:String = ""
    
    var place_id:String = ""
    var types:[String] = []
}
